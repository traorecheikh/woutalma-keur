import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { PropertyKind, PropertyStatus, TransactionKind } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

/// Photo bytes are stored in Postgres (see PropertyPhoto in schema.prisma).
/// The limits here are the only thing standing between a free-tier instance
/// and a trivial memory/storage exhaustion, so they are enforced server-side
/// and not merely respected by the client.
export const MAX_PHOTOS_PER_PROPERTY = 3;
export const MAX_PHOTO_BYTES = 160 * 1024;
export const ALLOWED_PHOTO_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'] as const;

/// One optional voice note per listing, same storage bargain as the photos.
/// 512 KB is roughly a minute of the AAC/Opus a phone recorder produces at the
/// bitrate speech needs — long enough to describe a listing, short enough that
/// a free-tier database survives it.
export const MAX_VOICE_NOTE_BYTES = 512 * 1024;
export const ALLOWED_VOICE_NOTE_MIME_TYPES = [
  'audio/mp4',
  'audio/aac',
  'audio/mpeg',
  'audio/ogg',
  'audio/webm',
] as const;

/// Where the line is drawn on free text, and why.
///
/// The only defects a phone keyboard produces *by accident* are whitespace
/// ones: a trailing space left by autocorrect, a double space between words, a
/// newline from the return key landing in a single-line field. Those are
/// normalised away, because two listings differing only by a stray space are
/// the same listing and should sort, dedupe and display as one.
///
/// Nothing else is touched. Accents are NOT stripped, non-ASCII is NOT
/// rejected, no charset is imposed: the product is Senegalese and its titles
/// legitimately carry French accents (Sacré-Cœur, Médina), Wolof spellings and
/// Arabic script. A server that "cleans" those is corrupting data, not
/// validating it. Rejecting is likewise reserved for input that carries no
/// information at all — a title that is empty once trimmed.
///
/// `MAX_TITLE_LENGTH` and the neighbourhood cap stay where they were: a long
/// title is ugly, not dangerous, and the display layer truncates.
export const MAX_TITLE_LENGTH = 120;
export const MAX_NEIGHBOURHOOD_LENGTH = 120;
export const MAX_DESCRIPTION_LENGTH = 2000;

/// CFA francs. The old ceiling was 100 000 000 000 (≈ 152 M€), which is not a
/// price, it is a typo waiting to be stored. 10 000 000 000 FCFA is ≈ 15 M€ —
/// an order of magnitude above the most expensive villa ever listed on the
/// Almadies/Ngor corniche, so it still rejects nothing real while keeping a
/// slipped keystroke from producing a listing no filter can bracket.
/// The floor is 1, not 0: the editor already refuses a free listing
/// (`price <= 0` in property_editor_view_model.dart) and "prix sur demande" is
/// not a product feature. No floor above 1 is invented — the server cannot
/// tell 50 000 from a mistyped 500 000.
export const MAX_PRICE_CFA = 10_000_000_000;

/// Square metres. 1 000 000 m² is 100 ha — far beyond any residential lot or
/// terrain a broker publishes here, so it costs nothing and stops a surface
/// that no longer means anything. The floor is 1: a surface picker's smallest
/// bracket is still a positive number, and "not stated" travels as null (the
/// Dart client maps a blank field to null, never to 0).
export const MAX_SURFACE_SQM = 1_000_000;

/// Rooms. The floor stays 0 on purpose: a LAND listing has no rooms, and 0 is
/// the honest answer to "combien de pièces" for a terrain — omitting the field
/// is equally accepted. 50 is well past the largest villa or subdivided
/// building anyone would advertise as a single listing.
export const MAX_ROOMS = 50;

/// Trims, and collapses every run of whitespace — including newlines and
/// non-breaking spaces — into a single ordinary space. For single-line fields
/// only; see `trimEnds` for prose.
///
/// Non-strings pass through untouched so `@IsString()` still reports the real
/// error instead of this transform masking it, and `undefined` stays
/// `undefined` so `PartialType` patches keep meaning "field absent".
function normaliseLine(value: unknown): unknown {
  if (typeof value !== 'string') {
    return value;
  }
  return value.replace(/\s+/gu, ' ').trim();
}

/// Trims the ends only. The description is composed from the other fields and
/// the broker may rewrite it, so it can legitimately hold line breaks and
/// deliberate blank lines — collapsing them would flatten a list of features
/// into one unreadable paragraph.
function trimEnds(value: unknown): unknown {
  return typeof value === 'string' ? value.trim() : value;
}

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

export class UploadVoiceNoteDto {
  @ApiProperty({ enum: ALLOWED_VOICE_NOTE_MIME_TYPES })
  @IsEnum(
    ALLOWED_VOICE_NOTE_MIME_TYPES.reduce<Record<string, string>>(
      (acc, mime) => ({ ...acc, [mime]: mime }),
      {},
    ),
  )
  mimeType!: string;

  @ApiProperty({
    description: `Base64-encoded audio bytes. Decoded size must not exceed ${MAX_VOICE_NOTE_BYTES} bytes — record short, at a speech bitrate.`,
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

  @ApiProperty({
    description:
      'Trimmed, and runs of whitespace collapsed to one space, before storage. Accents and non-Latin scripts are preserved. Must not be empty once trimmed.',
    minLength: 1,
    maxLength: MAX_TITLE_LENGTH,
  })
  @Transform(({ value }) => normaliseLine(value))
  @IsString()
  @MinLength(1)
  @MaxLength(MAX_TITLE_LENGTH)
  title!: string;

  @ApiPropertyOptional({
    description:
      'Composed by the editor from the entered data, overridable by the broker. Trimmed at the ends; internal line breaks are kept.',
    maxLength: MAX_DESCRIPTION_LENGTH,
  })
  @Transform(({ value }) => trimEnds(value))
  @IsOptional()
  @IsString()
  @MaxLength(MAX_DESCRIPTION_LENGTH)
  description?: string;

  @ApiProperty({
    description: `CFA francs, integer. At least 1 — a free listing is not a product feature — and at most ${MAX_PRICE_CFA}.`,
    minimum: 1,
    maximum: MAX_PRICE_CFA,
  })
  @IsInt()
  @Min(1)
  @Max(MAX_PRICE_CFA)
  price!: number;

  @ApiPropertyOptional({
    type: Number,
    nullable: true,
    description: `Square metres. Omit or send null when unknown, never 0. At most ${MAX_SURFACE_SQM}.`,
    minimum: 1,
    maximum: MAX_SURFACE_SQM,
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(MAX_SURFACE_SQM)
  surface?: number | null;

  @ApiPropertyOptional({
    type: Number,
    nullable: true,
    description: `Room count. 0 is accepted and meaningful for a LAND listing; null/omitted means unstated. At most ${MAX_ROOMS}.`,
    minimum: 0,
    maximum: MAX_ROOMS,
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(MAX_ROOMS)
  rooms?: number | null;

  @ApiProperty()
  @IsLatitude()
  latitude!: number;

  @ApiProperty()
  @IsLongitude()
  longitude!: number;

  /// The editor now offers a picker of the Dakar quartiers listed in
  /// lib/app/domain/location_service.dart, but the column stays free text and
  /// the server does NOT reject a value outside that list. The list is
  /// eighteen names long and Dakar is not: a broker who covers Diamniadio,
  /// Bargny or Thiès is right and the list is late. Constraining the API to it
  /// would turn a missing entry in a client-side constant into a published
  /// listing the broker cannot save, and would pin the backend to a Dart file
  /// it has no way to stay in sync with.
  @ApiProperty({
    description:
      'Quartier name. The client offers a picker of known Dakar quartiers, but any non-empty name is accepted — the list is not exhaustive. Trimmed and whitespace-collapsed before storage.',
    minLength: 1,
    maxLength: MAX_NEIGHBOURHOOD_LENGTH,
  })
  @Transform(({ value }) => normaliseLine(value))
  @IsString()
  @MinLength(1)
  @MaxLength(MAX_NEIGHBOURHOOD_LENGTH)
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

  @ApiPropertyOptional({
    description:
      'Existing `api:<id>` key to keep. Send an empty string to remove the voice note. Omit to leave it unchanged.',
    maxLength: 200,
  })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  voiceAsset?: string;

  /// A new recording, replacing whatever the listing carried.
  @ApiPropertyOptional({ type: UploadVoiceNoteDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => UploadVoiceNoteDto)
  newVoiceNote?: UploadVoiceNoteDto;

  /// Minted by the editor before the first attempt and reused on every retry.
  /// A broker on a weak network taps "Publier" again — or the app is killed
  /// and reopened — and the second POST returns the listing already stored
  /// rather than publishing it twice.
  @ApiPropertyOptional({
    description: 'Idempotency key, unique per broker. Replaying it returns the listing already created.',
    maxLength: 64,
  })
  @IsOptional()
  @IsString()
  @MaxLength(64)
  clientRequestId?: string;
}

/// A patch that only carries the keys it changes cannot say "erase this one":
/// built_value omits nulls on the wire, so `surface: null` never leaves the
/// phone and the server could not tell it from "unchanged". These flags do,
/// and they are the only way B03 can take a listing from "3 pièces" back to
/// "non précisé" — a terrain, for instance, has none.
export class UpdatePropertyDto extends PartialType(CreatePropertyDto) {
  @ApiPropertyOptional({ description: 'Sets surface back to unstated. Wins over `surface`.' })
  @IsOptional()
  @IsBoolean()
  clearSurface?: boolean;

  @ApiPropertyOptional({ description: 'Sets rooms back to unstated. Wins over `rooms`.' })
  @IsOptional()
  @IsBoolean()
  clearRooms?: boolean;
}
