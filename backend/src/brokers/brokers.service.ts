import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, Role, VerificationStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { geographyPoint, selectLatLng } from '../common/postgis';
import { mapBrokerRow, BrokerRow } from './broker-row.mapper';
import { BrokerDto } from './dto/broker.dto';
import { CreateBrokerDto } from './dto/create-broker.dto';
import { UpdateBrokerDto } from './dto/update-broker.dto';

const SELECT_COLUMNS = Prisma.sql`
  "id", "kind", "name", "phone", "whatsapp", "coverage", "logoAsset",
  "verification", "responseRate", "pinned",
  ${selectLatLng(Prisma.raw('"position"'))}
`;

@Injectable()
export class BrokersService {
  constructor(private readonly prisma: PrismaService) {}

  /// Mirrors BrokerRepository.all().
  async findAll(): Promise<BrokerDto[]> {
    const rows = await this.prisma.$queryRaw<BrokerRow[]>(Prisma.sql`
      SELECT ${SELECT_COLUMNS} FROM "brokers" ORDER BY "name" ASC
    `);
    return rows.map(mapBrokerRow);
  }

  /// Mirrors BrokerRepository.byId in lib/app/domain/repositories.dart.
  async findById(id: string): Promise<BrokerDto> {
    const rows = await this.prisma.$queryRaw<BrokerRow[]>(Prisma.sql`
      SELECT ${SELECT_COLUMNS} FROM "brokers" WHERE "id" = ${id} LIMIT 1
    `);
    const row = rows[0];
    if (!row) {
      throw new NotFoundException(`Broker ${id} not found`);
    }
    return mapBrokerRow(row);
  }

  /// B01 — creates the caller's own broker profile and flips their active role.
  /// `Broker.ownerId` is unique, so a second call is a conflict, not a second
  /// profile.
  async createForOwner(ownerId: string, dto: CreateBrokerDto): Promise<BrokerDto> {
    const existing = await this.prisma.broker.findUnique({ where: { ownerId }, select: { id: true } });
    if (existing) {
      throw new ConflictException('This account already has a broker profile');
    }

    const id = cuidLike();
    await this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw(Prisma.sql`
        INSERT INTO "brokers" (
          "id", "ownerId", "kind", "name", "phone", "whatsapp", "position", "coverage",
          "logoAsset", "verification", "responseRate", "pinned", "createdAt", "updatedAt"
        ) VALUES (
          ${id}, ${ownerId}, ${dto.kind}::"BrokerKind", ${dto.name}, ${dto.phone}, ${dto.whatsapp ?? null},
          ${geographyPoint(dto.latitude, dto.longitude)}, ${textArray(dto.coverage ?? [])},
          ${dto.logoAsset ?? null}, 'NONE'::"VerificationStatus", 0, false, now(), now()
        )
      `);
      await tx.user.update({ where: { id: ownerId }, data: { activeRole: Role.BROKER } });
    });

    return this.findById(id);
  }

  /// Partial update of the caller's own profile. Trust signals
  /// (verification, responseRate, pinned) are not in UpdateBrokerDto and so
  /// cannot be reached from here.
  async updateOwned(id: string, ownerId: string, dto: UpdateBrokerDto): Promise<BrokerDto> {
    await this.requireOwned(id, ownerId);

    const assignments: Prisma.Sql[] = [];
    if (dto.kind !== undefined) assignments.push(Prisma.sql`"kind" = ${dto.kind}::"BrokerKind"`);
    if (dto.name !== undefined) assignments.push(Prisma.sql`"name" = ${dto.name}`);
    if (dto.phone !== undefined) assignments.push(Prisma.sql`"phone" = ${dto.phone}`);
    if (dto.whatsapp !== undefined) assignments.push(Prisma.sql`"whatsapp" = ${dto.whatsapp}`);
    if (dto.coverage !== undefined) assignments.push(Prisma.sql`"coverage" = ${textArray(dto.coverage)}`);
    if (dto.logoAsset !== undefined) assignments.push(Prisma.sql`"logoAsset" = ${dto.logoAsset}`);
    if (dto.latitude !== undefined && dto.longitude !== undefined) {
      assignments.push(Prisma.sql`"position" = ${geographyPoint(dto.latitude, dto.longitude)}`);
    } else if (dto.latitude !== undefined || dto.longitude !== undefined) {
      throw new BadRequestException('latitude and longitude must be sent together');
    }

    if (assignments.length > 0) {
      assignments.push(Prisma.sql`"updatedAt" = now()`);
      await this.prisma.$executeRaw(Prisma.sql`
        UPDATE "brokers" SET ${Prisma.join(assignments, ', ')} WHERE "id" = ${id}
      `);
    }

    return this.findById(id);
  }

  /// B02 — "Demander la vérification".
  ///
  /// A request, not a grant. PENDING is the only value this may ever write:
  /// the badge is an operator's statement about a broker, so the broker can
  /// only ever put themselves in the queue. UpdateBrokerDto refuses
  /// `verification` outright for the same reason; this endpoint exists so the
  /// button has somewhere legitimate to go instead of PATCHing nothing and
  /// still showing a success toast.
  ///
  /// Idempotent by state, not by count: a broker already PENDING (or already
  /// VERIFIED) gets their current state back with no write and no error, so a
  /// double tap, a retry on a flaky network or a re-installed app cannot
  /// disturb a decision already taken.
  async requestVerification(id: string, ownerId: string): Promise<BrokerDto> {
    const current = await this.requireOwned(id, ownerId);

    if (
      current.verification === VerificationStatus.PENDING ||
      current.verification === VerificationStatus.VERIFIED
    ) {
      return this.findById(id);
    }

    // NONE or REJECTED. The previous rejection reason goes with the previous
    // decision: leaving it would make the app show "refusé parce que …" next
    // to a request that is once again waiting.
    await this.prisma.$executeRaw(Prisma.sql`
      UPDATE "brokers"
      SET "verification" = 'PENDING'::"VerificationStatus", "rejectionReason" = NULL, "updatedAt" = now()
      WHERE "id" = ${id}
    `);
    return this.findById(id);
  }

  /// Shared 404-then-403 ownership gate for the write paths above, and for
  /// the owner-only reads BrokersController serves (received contacts).
  ///
  /// Distinct from requireBrokerIdForOwner() in common/broker-owner.ts: that
  /// one asks "which profile does this user own", this one asks "does this
  /// user own *that* profile" — the difference matters for a route whose id
  /// comes from the URL.
  async requireOwned(id: string, ownerId: string): Promise<{ verification: VerificationStatus }> {
    const broker = await this.prisma.broker.findUnique({
      where: { id },
      select: { ownerId: true, verification: true },
    });
    if (!broker) {
      throw new NotFoundException(`Broker ${id} not found`);
    }
    if (broker.ownerId !== ownerId) {
      throw new ForbiddenException('This profile belongs to another account');
    }
    return { verification: broker.verification };
  }
}

/// See the identical helper in properties.service.ts — `text[]` needs an
/// explicit array literal, and the empty case needs its own cast.
function textArray(values: string[]): Prisma.Sql {
  if (values.length === 0) {
    return Prisma.sql`ARRAY[]::text[]`;
  }
  return Prisma.sql`ARRAY[${Prisma.join(values.map((value) => Prisma.sql`${value}`))}]::text[]`;
}

/// Raw SQL never runs Prisma's `@default(cuid())`, so ids are minted here.
function cuidLike(): string {
  const time = Date.now().toString(36);
  const random = Math.random().toString(36).slice(2, 12);
  return `c${time}${random}`;
}
