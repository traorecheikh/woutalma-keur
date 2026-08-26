import { ApiPropertyOptional } from '@nestjs/swagger';
import { BrokerKind } from '@prisma/client';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
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

  /// built_value omits nulls on the wire, so a broker who empties the WhatsApp
  /// field sent nothing and kept their old number — with a button that opened
  /// a conversation they no longer read. This flag is how the field is
  /// actually cleared.
  @ApiPropertyOptional({ description: 'Removes the WhatsApp number. Wins over `whatsapp`.' })
  @IsOptional()
  @IsBoolean()
  clearWhatsapp?: boolean;
}
