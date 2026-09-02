import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsPositive,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { PropertyKind, TransactionKind } from '@prisma/client';

/// Mirrors lib/app/domain/discovery.dart's DiscoveryFilters, plus the
/// client's own position (`from` there, `lat`/`lng` here since query params
/// can't carry a GeoPoint object directly).
export class SearchQueryDto {
  @ApiProperty({ description: 'Client latitude — required to rank/sort by distance.' })
  @Transform(({ value }) => Number(value))
  @IsLatitude()
  lat!: number;

  @ApiProperty({ description: 'Client longitude — required to rank/sort by distance.' })
  @Transform(({ value }) => Number(value))
  @IsLongitude()
  lng!: number;

  @ApiPropertyOptional({ enum: TransactionKind })
  @IsOptional()
  @IsIn(Object.values(TransactionKind))
  transaction?: TransactionKind;

  @ApiPropertyOptional({ enum: PropertyKind })
  @IsOptional()
  @IsIn(Object.values(PropertyKind))
  kind?: PropertyKind;

  @ApiPropertyOptional()
  @IsOptional()
  @Transform(({ value }) => (value === undefined ? undefined : Number(value)))
  @IsInt()
  @IsPositive()
  maxPrice?: number;

  @ApiPropertyOptional({ description: 'Meters.' })
  @IsOptional()
  @Transform(({ value }) => (value === undefined ? undefined : Number(value)))
  @IsPositive()
  radiusMeters?: number;

  @ApiPropertyOptional({
    description: 'Free text against broker name/coverage or property title/neighbourhood.',
  })
  @IsOptional()
  @IsString()
  query?: string;

  @ApiPropertyOptional({ minimum: 1, maximum: 50, default: 20 })
  @IsOptional()
  @Transform(({ value }) => (value === undefined ? undefined : Number(value)))
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number;

  @ApiPropertyOptional({ minimum: 0, default: 0 })
  @IsOptional()
  @Transform(({ value }) => (value === undefined ? undefined : Number(value)))
  @IsInt()
  @Min(0)
  offset?: number;
}
