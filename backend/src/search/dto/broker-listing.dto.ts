import { ApiProperty } from '@nestjs/swagger';
import { BrokerDto } from '../../brokers/dto/broker.dto';

/// Mirrors lib/app/domain/entities.dart's BrokerListing — a computed view,
/// never a stored table (see backend/prisma/schema.prisma's comment on
/// Broker/Property). Produced only by /search/brokers.
export class BrokerListingDto {
  @ApiProperty({ type: BrokerDto })
  broker!: BrokerDto;

  @ApiProperty()
  distanceMeters!: number;

  @ApiProperty()
  averageRating!: number;

  @ApiProperty()
  reviewCount!: number;

  @ApiProperty()
  availableProperties!: number;

  @ApiProperty()
  score!: number;
}
