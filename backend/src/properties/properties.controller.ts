import { Body, Controller, Delete, Get, Header, Param, Patch, Post, Query, Res, UseGuards } from '@nestjs/common';
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

@ApiTags('properties')
@Controller('properties')
export class PropertiesController {
  constructor(
    private readonly properties: PropertiesService,
    private readonly prisma: PrismaService,
  ) {}

  @Get()
  @ApiOperation({
    summary: 'Mirrors PropertyRepository.all()/.discoverable() — pass discoverableOnly=true for the latter.',
  })
  @ApiOkResponse({ type: [PropertyDto] })
  findAll(@Query('discoverableOnly') discoverableOnly?: string): Promise<PropertyDto[]> {
    return this.properties.findAll(discoverableOnly === 'true');
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
  async close(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedRequestUser,
  ): Promise<PropertyDto> {
    const brokerId = await requireBrokerIdForOwner(this.prisma, user.userId);
    return this.properties.close(id, brokerId);
  }
}
