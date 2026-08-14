import { Body, Controller, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { BrokersService } from './brokers.service';
import { BrokerDto } from './dto/broker.dto';
import { CreateBrokerDto } from './dto/create-broker.dto';
import { UpdateBrokerDto } from './dto/update-broker.dto';
import { PropertiesService } from '../properties/properties.service';
import { PropertyDto } from '../properties/dto/property.dto';
import { CurrentUser } from '../auth/current-user.decorator';
import { AuthenticatedRequestUser } from '../auth/jwt-payload.interface';

@ApiTags('brokers')
@Controller('brokers')
export class BrokersController {
  constructor(
    private readonly brokers: BrokersService,
    private readonly properties: PropertiesService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Mirrors BrokerRepository.all().' })
  @ApiOkResponse({ type: [BrokerDto] })
  findAll(): Promise<BrokerDto[]> {
    return this.brokers.findAll();
  }

  @Post()
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'B01 — create the caller’s broker profile. Starts unverified.' })
  @ApiOkResponse({ type: BrokerDto })
  create(
    @Body() dto: CreateBrokerDto,
    @CurrentUser() user: AuthenticatedRequestUser,
  ): Promise<BrokerDto> {
    return this.brokers.createForOwner(user.userId, dto);
  }

  @Patch(':id')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Edit the caller’s own broker profile. 403 for someone else’s.' })
  @ApiOkResponse({ type: BrokerDto })
  update(
    @Param('id') id: string,
    @Body() dto: UpdateBrokerDto,
    @CurrentUser() user: AuthenticatedRequestUser,
  ): Promise<BrokerDto> {
    return this.brokers.updateOwned(id, user.userId, dto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Mirrors BrokerRepository.byId.' })
  @ApiOkResponse({ type: BrokerDto })
  findById(@Param('id') id: string): Promise<BrokerDto> {
    return this.brokers.findById(id);
  }

  @Get(':id/properties')
  @ApiOperation({ summary: 'Mirrors PropertyRepository.byBroker(brokerId, {onlyDiscoverable}).' })
  @ApiQuery({ name: 'onlyDiscoverable', required: false, type: Boolean })
  @ApiOkResponse({ type: [PropertyDto] })
  findProperties(
    @Param('id') id: string,
    @Query('onlyDiscoverable') onlyDiscoverable?: string,
  ): Promise<PropertyDto[]> {
    return this.properties.findByBroker(id, onlyDiscoverable !== 'false');
  }
}
