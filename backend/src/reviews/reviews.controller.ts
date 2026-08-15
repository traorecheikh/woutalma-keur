import { Body, Controller, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { ReplyReviewDto } from './dto/reply-review.dto';
import { ReportReviewDto } from './dto/report-review.dto';
import { ReviewDto } from './dto/review.dto';
import { CurrentUser } from '../auth/current-user.decorator';
import { OptionalJwtAuthGuard } from '../auth/optional-jwt.guard';
import { AuthenticatedRequestUser } from '../auth/jwt-payload.interface';

@ApiTags('reviews')
@ApiBearerAuth()
@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviews: ReviewsService) {}

  @Get()
  @ApiOperation({
    summary: 'Published reviews only, every broker together — feeds the client-side averages.',
  })
  @ApiOkResponse({ type: [ReviewDto] })
  all(): Promise<ReviewDto[]> {
    return this.reviews.all();
  }

  @Get('broker/:brokerId')
  @UseGuards(OptionalJwtAuthGuard)
  @ApiOperation({
    summary:
      'Published reviews of one broker. `onlyPublic=false` additionally returns the pending/rejected ones, and only to the broker who owns the profile — for anyone else it is ignored.',
  })
  @ApiQuery({ name: 'onlyPublic', required: false, type: Boolean })
  @ApiOkResponse({ type: [ReviewDto] })
  byBroker(
    @Param('brokerId') brokerId: string,
    @Query('onlyPublic') onlyPublic?: string,
    @CurrentUser() user?: AuthenticatedRequestUser,
  ): Promise<ReviewDto[]> {
    return this.reviews.byBroker(brokerId, {
      includeNonPublic: onlyPublic === 'false',
      viewerId: user?.userId,
    });
  }

  @Post()
  @UseGuards(AuthGuard('jwt'))
  @ApiOperation({
    summary:
      'Port of ReviewEligibilityService — 403s with a `reason` (noContact/notReached/alreadyReviewed/notOwner) when not eligible.',
  })
  @ApiCreatedResponse({ type: ReviewDto })
  create(@Body() dto: CreateReviewDto, @CurrentUser() user: AuthenticatedRequestUser): Promise<ReviewDto> {
    return this.reviews.create(dto, user.userId);
  }

  @Patch(':id/reply')
  @UseGuards(AuthGuard('jwt'))
  @ApiOperation({
    summary: 'B05 — the broker answers a review about them. 403 for a review about someone else.',
  })
  @ApiOkResponse({ type: ReviewDto })
  reply(
    @Param('id') id: string,
    @Body() dto: ReplyReviewDto,
    @CurrentUser() user: AuthenticatedRequestUser,
  ): Promise<ReviewDto> {
    return this.reviews.reply(id, user.userId, dto);
  }

  @Post(':id/report')
  @UseGuards(AuthGuard('jwt'))
  @ApiOperation({
    summary:
      'B05 — the broker asks for a review to be re-moderated. Sets PENDING and nothing else: a broker cannot reject a review about them.',
  })
  @ApiOkResponse({ type: ReviewDto })
  report(
    @Param('id') id: string,
    @Body() dto: ReportReviewDto,
    @CurrentUser() user: AuthenticatedRequestUser,
  ): Promise<ReviewDto> {
    return this.reviews.report(id, user.userId, dto);
  }
}
