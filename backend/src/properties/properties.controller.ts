import {
  Body,
  Controller,
  Delete,
  Get,
  Header,
  Param,
  Patch,
  Post,
  Query,
  Res,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import type { Response } from 'express';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { PropertiesService } from './properties.service';
import { PropertyDto } from './dto/property.dto';
import { CreatePropertyDto, UpdatePropertyDto } from './dto/write-property.dto';
import { CurrentUser } from '../auth/current-user.decorator';
import { AuthenticatedRequestUser } from '../auth/jwt-payload.interface';
import { PrismaService } from '../prisma/prisma.service';
import { requireBrokerIdForOwner } from '../common/broker-owner';
import { OptionalJwtAuthGuard } from '../auth/optional-jwt.guard';

@ApiTags('properties')
@Controller('properties')
export class PropertiesController {
  constructor(
    private readonly properties: PropertiesService,
    private readonly prisma: PrismaService,
  ) {}

  @Get()
  @UseGuards(OptionalJwtAuthGuard)
  @ApiOperation({
    summary:
      'Mirrors PropertyRepository.all()/.discoverable(). discoverableOnly=false additionally returns the CALLER’S OWN withdrawn listings; another broker’s never leave their account.',
  })
  @ApiOkResponse({ type: [PropertyDto] })
  async findAll(
    @Query('discoverableOnly') discoverableOnly?: string,
    @CurrentUser() user?: AuthenticatedRequestUser,
  ): Promise<PropertyDto[]> {
    const onlyDiscoverable = discoverableOnly === 'true';
    const viewerBrokerId = onlyDiscoverable ? undefined : await this.viewerBrokerId(user);
    return this.properties.findAll(onlyDiscoverable, viewerBrokerId);
  }

  /// The broker profile of a signed-in caller, or undefined for anyone else.
  /// Never throws: these routes stay public, they simply show less.
  private async viewerBrokerId(user?: AuthenticatedRequestUser): Promise<string | undefined> {
    if (!user) {
      return undefined;
    }
    const broker = await this.prisma.broker.findUnique({
      where: { ownerId: user.userId },
      select: { id: true },
    });
    return broker?.id;
  }

  /// Declared before ':id' so the literal segment wins the route match.
  @Get('photos/:photoId')
  @ApiOperation({ summary: 'Bytes behind an `api:<id>` photoAssets entry. Public, like the listing itself.' })
  @Header('Cache-Control', 'public, max-age=31536000, immutable')
  async findPhoto(@Param('photoId') photoId: string, @Res() res: Response): Promise<void> {
    const photo = await this.properties.findPhoto(photoId);
    res.type(photo.mimeType).send(photo.bytes);
  }

  @Get('voice-notes/:noteId')
  @ApiOperation({ summary: 'Bytes behind an `api:<id>` voiceAsset key. Public, like the listing itself.' })
  @Header('Cache-Control', 'public, max-age=31536000, immutable')
  async findVoiceNote(@Param('noteId') noteId: string, @Res() res: Response): Promise<void> {
    const note = await this.properties.findVoiceNote(noteId);
    res.type(note.mimeType).send(note.bytes);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Mirrors PropertyRepository.byId.' })
  @ApiOkResponse({ type: PropertyDto })
  findById(@Param('id') id: string): Promise<PropertyDto> {
    return this.properties.findById(id);
  }

  @Post()
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Publish a listing under the caller’s own broker profile (B03 save).' })
  @ApiOkResponse({ type: PropertyDto })
  async create(
    @Body() dto: CreatePropertyDto,
    @CurrentUser() user: AuthenticatedRequestUser,
  ): Promise<PropertyDto> {
    const brokerId = await requireBrokerIdForOwner(this.prisma, user.userId);
    return this.properties.create(brokerId, dto);
  }

  @Patch(':id')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Edit one of the caller’s own listings. 403 for someone else’s.' })
  @ApiOkResponse({ type: PropertyDto })
  async update(
    @Param('id') id: string,
    @Body() dto: UpdatePropertyDto,
    @CurrentUser() user: AuthenticatedRequestUser,
  ): Promise<PropertyDto> {
    const brokerId = await requireBrokerIdForOwner(this.prisma, user.userId);
    return this.properties.update(id, brokerId, dto);
  }

  @Delete(':id')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Withdraw a listing. Soft delete to CLOSED so client contact history keeps resolving it.',
  })
  @ApiOkResponse({ type: PropertyDto })
  async close(@Param('id') id: string, @CurrentUser() user: AuthenticatedRequestUser): Promise<PropertyDto> {
    const brokerId = await requireBrokerIdForOwner(this.prisma, user.userId);
    return this.properties.close(id, brokerId);
  }
}
