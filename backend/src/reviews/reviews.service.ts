import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { ContactOutcome, ModerationStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { ReplyReviewDto } from './dto/reply-review.dto';
import { ReportReviewDto } from './dto/report-review.dto';
import { ReviewDto } from './dto/review.dto';
import { mapReview } from './review-row.mapper';
import { ReviewRefusedException } from './review-refusal';

/// Who is asking to read a broker's reviews. `undefined` for an anonymous
/// caller — the route is public (OptionalJwtAuthGuard), so most requests
/// arrive without one.
export interface ReviewAudience {
  /// The caller asked for the unmoderated ones too. Granted only to the
  /// broker the reviews are about.
  includeNonPublic?: boolean;
  viewerId?: string;
}

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

  /// Every published review, all brokers together — what the client app folds
  /// into a broker's average rating.
  ///
  /// Unconditionally public-only. This route has no owner to identify (it
  /// spans every broker), so there is nobody an unmoderated row could
  /// legitimately be shown to, and an `onlyPublic=false` on an unauthenticated
  /// endpoint was simply a way to read the whole moderation queue.
  async all(): Promise<ReviewDto[]> {
    const rows = await this.prisma.review.findMany({
      where: { moderation: ModerationStatus.PUBLISHED },
      orderBy: { createdAt: 'desc' },
    });
    return rows.map(mapReview);
  }

  /// Reviews of one broker.
  ///
  /// Public by default and public for everyone but one person: the broker
  /// themselves, who needs to see a review still awaiting moderation in order
  /// to answer it (B05). A caller who asks for the wider view without owning
  /// the profile is not refused, they are simply served the public list — the
  /// same answer a stranger would get with no parameter at all, so the
  /// parameter leaks nothing by its presence or absence.
  async byBroker(brokerId: string, audience: ReviewAudience = {}): Promise<ReviewDto[]> {
    const includeNonPublic =
      audience.includeNonPublic === true &&
      audience.viewerId !== undefined &&
      (await this.ownsBroker(brokerId, audience.viewerId));

    const rows = await this.prisma.review.findMany({
      where: { brokerId, ...(includeNonPublic ? {} : { moderation: ModerationStatus.PUBLISHED }) },
      orderBy: { createdAt: 'desc' },
    });
    return rows.map(mapReview);
  }

  /// B05 — the broker answers a review about them. PRODUCT.md §4: the reply is
  /// the only lever a broker has over an unfavourable review; the rating, the
  /// comment and the moderation status are not theirs to touch.
  async reply(reviewId: string, ownerId: string, dto: ReplyReviewDto): Promise<ReviewDto> {
    await this.requireReviewedBrokerOwner(reviewId, ownerId);
    const row = await this.prisma.review.update({
      where: { id: reviewId },
      data: { brokerReply: dto.reply },
    });
    return mapReview(row);
  }

  /// B05 — the broker flags a review for a human to look at again.
  ///
  /// PENDING is the only status this may ever write: it takes the review out
  /// of the public fiche while an operator reads it, but it does not decide
  /// anything. Letting a broker write REJECTED here would turn "signaler" into
  /// "supprimer la critique", which is the failure mode the whole moderation
  /// state machine exists to prevent.
  async report(reviewId: string, ownerId: string, dto: ReportReviewDto): Promise<ReviewDto> {
    await this.requireReviewedBrokerOwner(reviewId, ownerId);
    const row = await this.prisma.review.update({
      where: { id: reviewId },
      data: { moderation: ModerationStatus.PENDING, reportedReason: dto.reason ?? null },
    });
    return mapReview(row);
  }

  /// Resolves `review → broker → owner` and refuses anyone else. 403 rather
  /// than 404 on the ownership branch: the review exists, the caller simply is
  /// not the broker it is about.
  private async requireReviewedBrokerOwner(reviewId: string, ownerId: string): Promise<void> {
    const review = await this.prisma.review.findUnique({
      where: { id: reviewId },
      select: { broker: { select: { ownerId: true } } },
    });
    if (!review) {
      throw new NotFoundException(`Review ${reviewId} not found`);
    }
    if (review.broker.ownerId !== ownerId) {
      throw new ForbiddenException('This review is about another broker');
    }
  }

  private async ownsBroker(brokerId: string, userId: string): Promise<boolean> {
    const broker = await this.prisma.broker.findUnique({
      where: { id: brokerId },
      select: { ownerId: true },
    });
    return broker?.ownerId === userId;
  }
}
