import { ModerationStatus, Review } from '@prisma/client';
import { ReviewDto } from './dto/review.dto';

export function mapReview(review: Review): ReviewDto {
  return {
    id: review.id,
    brokerId: review.brokerId,
    contactId: review.contactId,
    rating: review.rating,
    responsiveness: review.responsiveness,
    accuracy: review.accuracy,
    courtesy: review.courtesy,
    comment: review.comment,
    moderation: review.moderation,
    brokerReply: review.brokerReply,
    createdAt: review.createdAt,
    isPublic: review.moderation === ModerationStatus.PUBLISHED,
  };
}
