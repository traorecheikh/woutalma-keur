import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiBearerAuth, ApiCreatedResponse, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ContactsService } from './contacts.service';
import { CreateContactDto } from './dto/create-contact.dto';
import { UpdateContactOutcomeDto } from './dto/update-contact-outcome.dto';
import { ContactLogDto } from './dto/contact-log.dto';
import { CurrentUser } from '../auth/current-user.decorator';
import { AuthenticatedRequestUser } from '../auth/jwt-payload.interface';

@ApiTags('contacts')
@ApiBearerAuth()
@Controller('contacts')
@UseGuards(AuthGuard('jwt'))
export class ContactsController {
  constructor(private readonly contacts: ContactsService) {}

  @Post()
  @ApiOperation({
    summary:
      'Logs a contact BEFORE the client opens the external channel (tel:/sms:/wa.me) — PRODUCT.md §3: "Journal local avant l\'ouverture du canal externe."',
  })
  @ApiCreatedResponse({ type: ContactLogDto })
  log(@Body() dto: CreateContactDto, @CurrentUser() user: AuthenticatedRequestUser): Promise<ContactLogDto> {
    return this.contacts.log(dto, user.userId);
  }

  @Get()
  @ApiOkResponse({ type: [ContactLogDto] })
  all(@CurrentUser() user: AuthenticatedRequestUser): Promise<ContactLogDto[]> {
    return this.contacts.all(user.userId);
  }

  @Get(':id')
  @ApiOkResponse({ type: ContactLogDto })
  byId(@Param('id') id: string, @CurrentUser() user: AuthenticatedRequestUser): Promise<ContactLogDto> {
    return this.contacts.byId(id, user.userId);
  }

  @Patch(':id/outcome')
  @ApiOperation({
    summary: "Records the exchange result — 'reached' is the only outcome that opens a review.",
  })
  @ApiOkResponse({ type: ContactLogDto })
  updateOutcome(
    @Param('id') id: string,
    @Body() dto: UpdateContactOutcomeDto,
    @CurrentUser() user: AuthenticatedRequestUser,
  ): Promise<ContactLogDto> {
    return this.contacts.updateOutcome(id, user.userId, dto);
  }
}
