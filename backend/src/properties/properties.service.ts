import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, PropertyStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { geographyPoint, selectLatLng } from '../common/postgis';
import { mapPropertyRow, PropertyRow } from './property-row.mapper';
import { PropertyDto } from './dto/property.dto';
import {
  ALLOWED_PHOTO_MIME_TYPES,
  CreatePropertyDto,
  MAX_PHOTOS_PER_PROPERTY,
  MAX_PHOTO_BYTES,
  UpdatePropertyDto,
  UploadPhotoDto,
} from './dto/write-property.dto';

/// Prefix marking a photoAssets entry that resolves to bytes in
/// `property_photos` rather than a bundled seed asset.
const API_PHOTO_PREFIX = 'api:';

const SELECT_COLUMNS = Prisma.sql`
  "id", "brokerId", "kind", "transaction", "title", "description", "price",
  "surface", "rooms", "neighbourhood", "photoAssets", "status", "createdAt",
  ${selectLatLng(Prisma.raw('"position"'))}
`;

@Injectable()
export class PropertiesService {
  constructor(private readonly prisma: PrismaService) {}

  /// Mirrors PropertyRepository.all()/.discoverable().
  async findAll(discoverableOnly: boolean): Promise<PropertyDto[]> {
    const rows = await this.prisma.$queryRaw<PropertyRow[]>(Prisma.sql`
      SELECT ${SELECT_COLUMNS} FROM "properties"
      ${discoverableOnly ? Prisma.sql`WHERE "status" != ${PropertyStatus.CLOSED}::"PropertyStatus"` : Prisma.empty}
      ORDER BY "createdAt" DESC
    `);
    return rows.map(mapPropertyRow);
  }

  /// Mirrors PropertyRepository.byId.
  async findById(id: string): Promise<PropertyDto> {
    const rows = await this.prisma.$queryRaw<PropertyRow[]>(Prisma.sql`
      SELECT ${SELECT_COLUMNS} FROM "properties" WHERE "id" = ${id} LIMIT 1
    `);
    const row = rows[0];
    if (!row) {
      throw new NotFoundException(`Property ${id} not found`);
    }
    return mapPropertyRow(row);
  }

  /// Mirrors PropertyRepository.byBroker(brokerId, {onlyDiscoverable}).
  async findByBroker(brokerId: string, onlyDiscoverable: boolean): Promise<PropertyDto[]> {
    const rows = await this.prisma.$queryRaw<PropertyRow[]>(Prisma.sql`
      SELECT ${SELECT_COLUMNS} FROM "properties"
      WHERE "brokerId" = ${brokerId}
      ${onlyDiscoverable ? Prisma.sql`AND "status" != ${PropertyStatus.CLOSED}::"PropertyStatus"` : Prisma.empty}
      ORDER BY "createdAt" DESC
    `);
    return rows.map(mapPropertyRow);
  }

  /// Raw bytes for an `api:<id>` photo key. Public: property photos are part
  /// of a public listing, and the id is an unguessable cuid.
  async findPhoto(photoId: string): Promise<{ mimeType: string; bytes: Buffer }> {
    const photo = await this.prisma.propertyPhoto.findUnique({
      where: { id: photoId },
      select: { mimeType: true, bytes: true },
    });
    if (!photo) {
      throw new NotFoundException(`Photo ${photoId} not found`);
    }
    return { mimeType: photo.mimeType, bytes: Buffer.from(photo.bytes) };
  }

  /// Mirrors PropertyRepository.save() for a new listing. `position` is an
  /// Unsupported() column, so the insert is raw — and must supply updatedAt
  /// itself, since Prisma's @updatedAt is client-side only and the column has
  /// no SQL default.
  async create(brokerId: string, dto: CreatePropertyDto): Promise<PropertyDto> {
    const id = cuidLike();
    const retained = dto.photoAssets ?? [];
    const uploads = dto.newPhotos ?? [];
    assertPhotoBudget(retained, uploads);

    await this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw(Prisma.sql`
        INSERT INTO "properties" (
          "id", "brokerId", "kind", "transaction", "title", "description", "price",
          "surface", "rooms", "position", "neighbourhood", "photoAssets", "status",
          "createdAt", "updatedAt"
        ) VALUES (
          ${id}, ${brokerId}, ${dto.kind}::"PropertyKind", ${dto.transaction}::"TransactionKind",
          ${dto.title}, ${dto.description ?? ''}, ${dto.price},
          ${dto.surface ?? null}, ${dto.rooms ?? null},
          ${geographyPoint(dto.latitude, dto.longitude)},
          ${dto.neighbourhood}, ${textArray(retained)},
          ${dto.status ?? PropertyStatus.AVAILABLE}::"PropertyStatus",
          now(), now()
        )
      `);
      const appended = await this.storePhotos(tx, id, uploads, retained.length);
      if (appended.length > 0) {
        await tx.$executeRaw(Prisma.sql`
          UPDATE "properties" SET "photoAssets" = ${textArray([...retained, ...appended])}
          WHERE "id" = ${id}
        `);
      }
    });

    return this.findById(id);
  }

  /// Partial update. Only the keys present in the body are touched, so the
  /// editor can save one field without resending photo bytes.
  async update(id: string, brokerId: string, dto: UpdatePropertyDto): Promise<PropertyDto> {
    await this.assertOwned(id, brokerId);

    const uploads = dto.newPhotos ?? [];
    const retained = dto.photoAssets;
    if (retained !== undefined || uploads.length > 0) {
      assertPhotoBudget(retained ?? [], uploads);
    }

    await this.prisma.$transaction(async (tx) => {
      const assignments: Prisma.Sql[] = [];
      if (dto.kind !== undefined) assignments.push(Prisma.sql`"kind" = ${dto.kind}::"PropertyKind"`);
      if (dto.transaction !== undefined) {
        assignments.push(Prisma.sql`"transaction" = ${dto.transaction}::"TransactionKind"`);
      }
      if (dto.title !== undefined) assignments.push(Prisma.sql`"title" = ${dto.title}`);
      if (dto.description !== undefined) assignments.push(Prisma.sql`"description" = ${dto.description}`);
      if (dto.price !== undefined) assignments.push(Prisma.sql`"price" = ${dto.price}`);
      if (dto.surface !== undefined) assignments.push(Prisma.sql`"surface" = ${dto.surface}`);
      if (dto.rooms !== undefined) assignments.push(Prisma.sql`"rooms" = ${dto.rooms}`);
      if (dto.neighbourhood !== undefined) {
        assignments.push(Prisma.sql`"neighbourhood" = ${dto.neighbourhood}`);
      }
      if (dto.status !== undefined) {
        assignments.push(Prisma.sql`"status" = ${dto.status}::"PropertyStatus"`);
      }
      if (dto.latitude !== undefined && dto.longitude !== undefined) {
        assignments.push(Prisma.sql`"position" = ${geographyPoint(dto.latitude, dto.longitude)}`);
      } else if (dto.latitude !== undefined || dto.longitude !== undefined) {
        throw new BadRequestException('latitude and longitude must be sent together');
      }

      let finalAssets: string[] | undefined;
      if (retained !== undefined || uploads.length > 0) {
        const base = retained ?? (await this.currentAssets(tx, id));
        const appended = await this.storePhotos(tx, id, uploads, base.length);
        finalAssets = [...base, ...appended];
        // Any api: photo the client dropped from the list loses its bytes too;
        // otherwise every edit would leak a row nothing references.
        await this.pruneOrphanPhotos(tx, id, finalAssets);
        assignments.push(Prisma.sql`"photoAssets" = ${textArray(finalAssets)}`);
      }

      if (assignments.length === 0) {
        return;
      }
      assignments.push(Prisma.sql`"updatedAt" = now()`);
      await tx.$executeRaw(Prisma.sql`
        UPDATE "properties" SET ${Prisma.join(assignments, ', ')} WHERE "id" = ${id}
      `);
    });

    return this.findById(id);
  }

  /// Soft delete. A hard DELETE would break every ContactLog that references
  /// the listing, and a client's history must survive the broker withdrawing
  /// it. CLOSED already means "no longer available" everywhere else.
  async close(id: string, brokerId: string): Promise<PropertyDto> {
    await this.assertOwned(id, brokerId);
    await this.prisma.$executeRaw(Prisma.sql`
      UPDATE "properties"
      SET "status" = ${PropertyStatus.CLOSED}::"PropertyStatus", "updatedAt" = now()
      WHERE "id" = ${id}
    `);
    return this.findById(id);
  }

  private async assertOwned(propertyId: string, brokerId: string): Promise<void> {
    const property = await this.prisma.property.findUnique({
      where: { id: propertyId },
      select: { brokerId: true },
    });
    if (!property) {
      throw new NotFoundException(`Property ${propertyId} not found`);
    }
    if (property.brokerId !== brokerId) {
      throw new ForbiddenException('This property belongs to another broker');
    }
  }

  private async currentAssets(tx: Prisma.TransactionClient, id: string): Promise<string[]> {
    const property = await tx.property.findUnique({ where: { id }, select: { photoAssets: true } });
    return property?.photoAssets ?? [];
  }

  private async storePhotos(
    tx: Prisma.TransactionClient,
    propertyId: string,
    uploads: UploadPhotoDto[],
    startOrder: number,
  ): Promise<string[]> {
    const keys: string[] = [];
    for (const [index, upload] of uploads.entries()) {
      const bytes = decodePhoto(upload);
      const created = await tx.propertyPhoto.create({
        data: { propertyId, mimeType: upload.mimeType, bytes, sortOrder: startOrder + index },
        select: { id: true },
      });
      keys.push(`${API_PHOTO_PREFIX}${created.id}`);
    }
    return keys;
  }

  private async pruneOrphanPhotos(
    tx: Prisma.TransactionClient,
    propertyId: string,
    keptAssets: string[],
  ): Promise<void> {
    const keptIds = keptAssets
      .filter((asset) => asset.startsWith(API_PHOTO_PREFIX))
      .map((asset) => asset.slice(API_PHOTO_PREFIX.length));
    await tx.propertyPhoto.deleteMany({
      where: { propertyId, ...(keptIds.length > 0 ? { id: { notIn: keptIds } } : {}) },
    });
  }
}

/// `text[]` bound explicitly. Passing a JS array straight into Prisma.sql
/// does not produce a Postgres array literal, and the empty case needs its
/// own cast or Postgres cannot infer the element type.
function textArray(values: string[]): Prisma.Sql {
  if (values.length === 0) {
    return Prisma.sql`ARRAY[]::text[]`;
  }
  return Prisma.sql`ARRAY[${Prisma.join(values.map((value) => Prisma.sql`${value}`))}]::text[]`;
}

function assertPhotoBudget(retained: string[], uploads: UploadPhotoDto[]): void {
  if (retained.length + uploads.length > MAX_PHOTOS_PER_PROPERTY) {
    throw new BadRequestException(`A property carries at most ${MAX_PHOTOS_PER_PROPERTY} photos`);
  }
}

function decodePhoto(upload: UploadPhotoDto): Buffer {
  if (!(ALLOWED_PHOTO_MIME_TYPES as readonly string[]).includes(upload.mimeType)) {
    throw new BadRequestException(`Unsupported photo type ${upload.mimeType}`);
  }
  const bytes = Buffer.from(upload.dataBase64, 'base64');
  if (bytes.length === 0) {
    throw new BadRequestException('Photo payload is empty or not valid base64');
  }
  if (bytes.length > MAX_PHOTO_BYTES) {
    throw new BadRequestException(`Photo exceeds ${MAX_PHOTO_BYTES} bytes after decoding — compress it first`);
  }
  return bytes;
}

/// Ids are minted here rather than by `@default(cuid())` because the insert is
/// raw SQL, which never runs Prisma's default. Same collision-resistance
/// shape as cuid: monotonic time prefix plus randomness.
function cuidLike(): string {
  const time = Date.now().toString(36);
  const random = Math.random().toString(36).slice(2, 12);
  return `c${time}${random}`;
}
