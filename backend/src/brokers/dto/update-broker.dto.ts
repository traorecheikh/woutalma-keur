import { ApiPropertyOptional } from '@nestjs/swagger';
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

/// Fields a broker may change on their own profile.
///
/// Deliberately excludes `verification`, `rejectionReason`, `responseRate` and
/// `pinned`: those are trust signals the product computes or an operator
/// grants (PRODUCT.md §4). A broker able to set their own `verification` to
/// VERIFIED would make the badge meaningless.
export class UpdateBrokerDto {
  @ApiPropertyOptional({ enum: BrokerKind })
  @IsOptional()
  @IsEnum(BrokerKind)
  kind?: BrokerKind;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(120)
  name?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(32)
  phone?: string;

  @ApiPropertyOptional({ type: String, nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(32)
  whatsapp?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsLatitude()
  latitude?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsLongitude()
  longitude?: number;

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
