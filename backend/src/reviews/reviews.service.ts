import { Injectable } from '@nestjs/common';
import { ContactOutcome, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { ReviewDto } from './dto/review.dto';
import { mapReview } from './review-row.mapper';
import { ReviewRefusedException } from './review-refusal';

/// Server-side port of ReviewEligibilityService
/// (lib/app/domain/review_eligibility.dart) — "La règle anti-faux-avis du
/// cahier des charges." On-device it only gates a button; here it's the
/// actual authorization, because a modified client can't be trusted to
/// self-report eligibility. See PRODUCT.md §10: "Fraude malgré le lien
/// entre contact et avis" is a named open risk this closes.
@Injectable()
export class ReviewsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateReviewDto, authorId: string): Promise<ReviewDto> {
    try {
      return await this.prisma.$transaction(async (tx) => {
        const contact = await tx.contactLog.findUnique({
          where: { id: dto.contactId },
          include: { review: { select: { id: true } } },
        });

        if (!contact) {
          throw new ReviewRefusedException('noContact');
        }
        if (contact.clientId !== authorId) {
          throw new ReviewRefusedException('notOwner');
        }
        if (contact.review) {
          throw new ReviewRefusedException('alreadyReviewed');
        }
        if (contact.outcome !== ContactOutcome.REACHED) {
          throw new ReviewRefusedException('notReached');
        }

        const review = await tx.review.create({
          data: {
            brokerId: contact.brokerId,
            contactId: contact.id,
            authorId,
            rating: dto.rating,
            responsiveness: dto.responsiveness,
            accuracy: dto.accuracy,
            courtesy: dto.courtesy,
            comment: dto.comment,
          },
        });
        return mapReview(review);
      });
    } catch (error) {
      // Belt-and-suspenders: two concurrent requests can both pass the
      // `contact.review` check above before either commits (default READ
      // COMMITTED isolation doesn't lock on a plain read). The
      // `Review.contactId` unique constraint in schema.prisma is the actual
      // race-safety backstop — this just turns its violation into the same
      // typed refusal instead of a raw 500.
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        throw new ReviewRefusedException('alreadyReviewed');
      }
      throw error;
    }
  }

  async all(onlyPublic = true): Promise<ReviewDto[]> {
    const rows = await this.prisma.review.findMany({
      where: onlyPublic ? { moderation: 'PUBLISHED' } : undefined,
      orderBy: { createdAt: 'desc' },
    });
    return rows.map(mapReview);
  }

  async byBroker(brokerId: string, onlyPublic = true): Promise<ReviewDto[]> {
    const rows = await this.prisma.review.findMany({
      where: { brokerId, ...(onlyPublic ? { moderation: 'PUBLISHED' } : {}) },
      orderBy: { createdAt: 'desc' },
    });
    return rows.map(mapReview);
  }
}
