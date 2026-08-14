import { ApiProperty } from '@nestjs/swagger';
import { BrokerListingDto } from './broker-listing.dto';
import { PropertyDto } from '../../properties/dto/property.dto';

export class BrokerSearchResultsDto {
  @ApiProperty({ type: [BrokerListingDto] })
  items!: BrokerListingDto[];

  @ApiProperty()
  totalCount!: number;

  @ApiProperty()
  limit!: number;

  @ApiProperty()
  offset!: number;
}

export class PropertySearchResultsDto {
  @ApiProperty({ type: [PropertyDto] })
  items!: PropertyDto[];

  @ApiProperty()
  totalCount!: number;

  @ApiProperty()
  limit!: number;

  @ApiProperty()
  offset!: number;
}

export class SearchSuggestionsDto {
  @ApiProperty({ type: [String] })
  items!: string[];
}
