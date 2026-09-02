import { Controller, Get, Query, ValidationPipe } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { SearchService } from './search.service';
import { SearchQueryDto } from './dto/search-query.dto';
import {
  BrokerSearchResultsDto,
  PropertySearchResultsDto,
  SearchSuggestionsDto,
} from './dto/search-results.dto';

@ApiTags('search')
@Controller('search')
export class SearchController {
  constructor(private readonly search: SearchService) {}

  @Get('brokers')
  @ApiOperation({ summary: 'Mirrors DiscoveryService.findBrokers, ranked server-side via PostGIS.' })
  @ApiOkResponse({ type: BrokerSearchResultsDto })
  findBrokers(
    @Query(new ValidationPipe({ transform: true })) query: SearchQueryDto,
  ): Promise<BrokerSearchResultsDto> {
    return this.search.findBrokers(query);
  }

  @Get('properties')
  @ApiOperation({ summary: 'Mirrors DiscoveryService.findProperties, sorted by distance.' })
  @ApiOkResponse({ type: PropertySearchResultsDto })
  findProperties(
    @Query(new ValidationPipe({ transform: true })) query: SearchQueryDto,
  ): Promise<PropertySearchResultsDto> {
    return this.search.findProperties(query);
  }

  @Get('suggestions')
  @ApiOperation({ summary: 'Returns ranked server-side search suggestions.' })
  @ApiOkResponse({ type: SearchSuggestionsDto })
  suggestions(
    @Query(new ValidationPipe({ transform: true })) query: SearchQueryDto,
  ): Promise<SearchSuggestionsDto> {
    return this.search.suggestions(query);
  }
}
