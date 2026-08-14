import { ApiProperty } from '@nestjs/swagger';
import { BrokerKind, VerificationStatus } from '@prisma/client';
import { GeoPointDto } from '../../common/geo-point.dto';

/// Mirrors lib/app/domain/entities.dart's Broker. Deliberately has no field
/// that could identify a client (PRODUCT.md §4 rule 7 — the client's number
/// is never exposed on a broker-facing or public fiche).
export class BrokerDto {
  @ApiProperty()
  id!: string;

  @ApiProperty({ enum: BrokerKind })
  kind!: BrokerKind;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  phone!: string;

  @ApiProperty({ type: String, required: false, nullable: true })
  whatsapp!: string | null;

  @ApiProperty({ type: GeoPointDto })
  position!: GeoPointDto;

  @ApiProperty({ type: [String] })
  coverage!: string[];

  @ApiProperty({ type: String, required: false, nullable: true })
  logoAsset!: string | null;

  @ApiProperty({ enum: VerificationStatus })
  verification!: VerificationStatus;

  @ApiProperty({ description: 'Between 0 and 1.' })
  responseRate!: number;

  @ApiProperty()
  pinned!: boolean;

  @ApiProperty()
  isVerified!: boolean;
}
