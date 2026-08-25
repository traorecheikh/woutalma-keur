import { ApiProperty } from '@nestjs/swagger';
import { PropertyKind, PropertyStatus, TransactionKind } from '@prisma/client';
import { GeoPointDto } from '../../common/geo-point.dto';

/// Mirrors lib/app/domain/entities.dart's Property.
export class PropertyDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  brokerId!: string;

  @ApiProperty({ enum: PropertyKind })
  kind!: PropertyKind;

  @ApiProperty({ enum: TransactionKind })
  transaction!: TransactionKind;

  @ApiProperty()
  title!: string;

  @ApiProperty()
  description!: string;

  @ApiProperty({ description: 'CFA francs, integer.' })
  price!: number;

  @ApiProperty({ type: Number, required: false, nullable: true })
  surface!: number | null;

  @ApiProperty({ type: Number, required: false, nullable: true })
  rooms!: number | null;

  @ApiProperty({ type: GeoPointDto })
  position!: GeoPointDto;

  @ApiProperty()
  neighbourhood!: string;

  @ApiProperty({ type: [String] })
  photoAssets!: string[];

  @ApiProperty({ type: String, required: false, nullable: true })
  voiceAsset!: string | null;

  @ApiProperty({ enum: PropertyStatus })
  status!: PropertyStatus;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  isDiscoverable!: boolean;
}
