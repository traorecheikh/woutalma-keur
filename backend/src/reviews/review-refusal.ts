import { ForbiddenException } from '@nestjs/common';

/// Mirrors ReviewRefusal in lib/app/domain/review_eligibility.dart, plus one
/// case that file has no reason to model (a single local user can't submit
/// someone else's contactId): notOwner.
export type ReviewRefusalReason = 'noContact' | 'notReached' | 'alreadyReviewed' | 'notOwner';

export class ReviewRefusedException extends ForbiddenException {
  constructor(reason: ReviewRefusalReason) {
    super({ statusCode: 403, message: `Review not allowed: ${reason}`, reason });
  }
}
