import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { Role } from '@prisma/client';
import { Throttle, ThrottlerGuard } from '@nestjs/throttler';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { AdminLoginDto, AdminSessionDto, DecideVerificationDto, ModerateReviewDto } from './admin.dto';
import { AdminService } from './admin.service';

@ApiTags('admin')
@Controller('admin-api')
@UseGuards(ThrottlerGuard)
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @Post('login')
  @Throttle({ default: { limit: 5, ttl: 60_000, blockDuration: 300_000 } })
  @ApiOkResponse({ type: AdminSessionDto })
  @ApiOperation({ summary: 'Open an environment-configured moderator session.' })
  login(@Body() dto: AdminLoginDto): Promise<AdminSessionDto> {
    return this.admin.login(dto.email, dto.password);
  }

  @Get('queue')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  queue() {
    return this.admin.queue();
  }

  @Patch('verifications/:id')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  decideVerification(@Param('id') id: string, @Body() dto: DecideVerificationDto) {
    return this.admin.decideVerification(id, dto);
  }

  @Patch('reviews/:id')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  moderateReview(@Param('id') id: string, @Body() dto: ModerateReviewDto) {
    return this.admin.moderateReview(id, dto);
  }
}
