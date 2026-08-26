import { Body, Controller, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { BrokersService } from './brokers.service';
import { BrokerDto } from './dto/broker.dto';
import { CreateBrokerDto } from './dto/create-broker.dto';
import { UpdateBrokerDto } from './dto/update-broker.dto';
import { PropertiesService } from '../properties/properties.service';
import { PropertyDto } from '../properties/dto/property.dto';
import { ContactsService } from '../contacts/contacts.service';
import { BrokerContactLogDto } from '../contacts/dto/broker-contact-log.dto';
import { CurrentUser } from '../auth/current-user.decorator';
import { AuthenticatedRequestUser } from '../auth/jwt-payload.interface';
import { OptionalJwtAuthGuard } from '../auth/optional-jwt.guard';

@ApiTags('brokers')
@Controller('brokers')
export class BrokersController {
  constructor(
    private readonly brokers: BrokersService,
    private readonly properties: PropertiesService,
    private readonly contacts: ContactsService,
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
  create(@Body() dto: CreateBrokerDto, @CurrentUser() user: AuthenticatedRequestUser): Promise<BrokerDto> {
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

  @Post(':id/verification-request')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary:
      'B02 — puts the caller’s own profile in the verification queue (NONE/REJECTED → PENDING). A request, never a grant: PENDING is the only status it can write, and calling it again while PENDING or VERIFIED just returns the current state.',
  })
  @ApiOkResponse({ type: BrokerDto })
  requestVerification(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedRequestUser,
  ): Promise<BrokerDto> {
    return this.brokers.requestVerification(id, user.userId);
  }

  @Get(':id/contacts')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary:
      'Contacts this broker RECEIVED — the broker-side counterpart of GET /contacts, which only ever lists what the caller sent as a client. Owner-only, and without any client-identifying field (PRODUCT.md §4 rule 7).',
  })
  @ApiOkResponse({ type: [BrokerContactLogDto] })
  async findContacts(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedRequestUser,
  ): Promise<BrokerContactLogDto[]> {
    await this.brokers.requireOwned(id, user.userId);
    return this.contacts.byBrokerForOwner(id);
  }

  @Get(':id/properties')
  @UseGuards(OptionalJwtAuthGuard)
  @ApiOperation({
    summary:
      'Mirrors PropertyRepository.byBroker(brokerId, {onlyDiscoverable}). onlyDiscoverable=false is owner-only — B02 needs its own withdrawn listings, a visitor has no business reading them.',
  })
  @ApiQuery({ name: 'onlyDiscoverable', required: false, type: Boolean })
  @ApiOkResponse({ type: [PropertyDto] })
  async findProperties(
    @Param('id') id: string,
    @Query('onlyDiscoverable') onlyDiscoverable?: string,
    @CurrentUser() user?: AuthenticatedRequestUser,
  ): Promise<PropertyDto[]> {
    const withdrawnToo = onlyDiscoverable === 'false' && (await this.brokers.isOwnedBy(id, user?.userId));
    return this.properties.findByBroker(id, !withdrawnToo);
  }
}
