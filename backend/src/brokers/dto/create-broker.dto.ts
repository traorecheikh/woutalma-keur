import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { BrokerKind } from '@prisma/client';
import {
  ArrayMaxSize,
  IsArray,
  IsEnum,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

/// B01 — a signed-in user creating their broker profile for the first time.
///
/// `verification` is not settable here and starts at NONE: a new profile is
/// unverified by construction, and the badge is the product's only trust
/// signal (PRODUCT.md §4).
export class CreateBrokerDto {
  @ApiProperty({ enum: BrokerKind })
  @IsEnum(BrokerKind)
  kind!: BrokerKind;

  @ApiProperty()
  @IsString()
  @MaxLength(120)
  name!: string;

  @ApiProperty()
  @IsString()
  @MaxLength(32)
  phone!: string;

  @ApiPropertyOptional({ type: String, nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(32)
  whatsapp?: string | null;

  @ApiProperty()
  @IsLatitude()
  latitude!: number;

  @ApiProperty()
  @IsLongitude()
  longitude!: number;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @ArrayMaxSize(20)
  coverage?: string[];

  @ApiPropertyOptional({ type: String, nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  logoAsset?: string | null;
}
