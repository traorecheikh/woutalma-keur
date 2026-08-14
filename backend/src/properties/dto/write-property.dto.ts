import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { PropertyKind, PropertyStatus, TransactionKind } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsEnum,
  IsInt,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';

/// Photo bytes are stored in Postgres (see PropertyPhoto in schema.prisma).
/// The limits here are the only thing standing between a free-tier instance
/// and a trivial memory/storage exhaustion, so they are enforced server-side
/// and not merely respected by the client.
export const MAX_PHOTOS_PER_PROPERTY = 3;
export const MAX_PHOTO_BYTES = 160 * 1024;
export const ALLOWED_PHOTO_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'] as const;

export class UploadPhotoDto {
  @ApiProperty({ enum: ALLOWED_PHOTO_MIME_TYPES })
  @IsEnum(
    ALLOWED_PHOTO_MIME_TYPES.reduce<Record<string, string>>((acc, mime) => ({ ...acc, [mime]: mime }), {}),
  )
  mimeType!: string;

  @ApiProperty({
    description: `Base64-encoded image bytes. Decoded size must not exceed ${MAX_PHOTO_BYTES} bytes — compress before sending.`,
  })
  @IsString()
  dataBase64!: string;
}

export class CreatePropertyDto {
  @ApiProperty({ enum: PropertyKind })
  @IsEnum(PropertyKind)
  kind!: PropertyKind;

  @ApiProperty({ enum: TransactionKind })
  @IsEnum(TransactionKind)
  transaction!: TransactionKind;

  @ApiProperty()
  @IsString()
  @MaxLength(120)
  title!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string;

  @ApiProperty({ description: 'CFA francs, integer.' })
  @IsInt()
  @Min(0)
  @Max(100_000_000_000)
  price!: number;

  @ApiPropertyOptional({ type: Number, nullable: true })
  @IsOptional()
  @IsInt()
  @Min(0)
  surface?: number | null;

  @ApiPropertyOptional({ type: Number, nullable: true })
  @IsOptional()
  @IsInt()
  @Min(0)
  rooms?: number | null;

  @ApiProperty()
  @IsLatitude()
  latitude!: number;

  @ApiProperty()
  @IsLongitude()
  longitude!: number;

  @ApiProperty()
  @IsString()
  @MaxLength(120)
  neighbourhood!: string;

  @ApiPropertyOptional({ enum: PropertyStatus })
  @IsOptional()
  @IsEnum(PropertyStatus)
  status?: PropertyStatus;

  /// Display keys to keep, in order — `demo:...` seed assets or `api:<id>`
  /// entries already owned by this property. Any `api:` key omitted here has
  /// its bytes deleted.
  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @ArrayMaxSize(MAX_PHOTOS_PER_PROPERTY)
  photoAssets?: string[];

  /// New uploads, appended after `photoAssets`.
  @ApiPropertyOptional({ type: [UploadPhotoDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => UploadPhotoDto)
  @ArrayMaxSize(MAX_PHOTOS_PER_PROPERTY)
  newPhotos?: UploadPhotoDto[];
}

export class UpdatePropertyDto extends PartialType(CreatePropertyDto) {}
