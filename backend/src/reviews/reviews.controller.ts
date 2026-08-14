import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiBearerAuth, ApiCreatedResponse, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { ReviewDto } from './dto/review.dto';
import { CurrentUser } from '../auth/current-user.decorator';
import { AuthenticatedRequestUser } from '../auth/jwt-payload.interface';

@ApiTags('reviews')
@ApiBearerAuth()
@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviews: ReviewsService) {}

  @Get()
  @ApiOkResponse({ type: [ReviewDto] })
  all(@Query('onlyPublic') onlyPublic?: string): Promise<ReviewDto[]> {
    return this.reviews.all(onlyPublic !== 'false');
  }

  @Get('broker/:brokerId')
  @ApiOkResponse({ type: [ReviewDto] })
  byBroker(@Param('brokerId') brokerId: string, @Query('onlyPublic') onlyPublic?: string): Promise<ReviewDto[]> {
    return this.reviews.byBroker(brokerId, onlyPublic !== 'false');
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
}
