import { ContactLog, ContactOutcome } from '@prisma/client';
import { ContactLogDto } from './dto/contact-log.dto';

type ContactLogWithReview = ContactLog & { review: { id: string } | null };

export function mapContactLog(row: ContactLogWithReview): ContactLogDto {
  return {
    id: row.id,
    brokerId: row.brokerId,
    propertyId: row.propertyId,
    channel: row.channel,
    outcome: row.outcome,
    reviewId: row.review?.id ?? null,
    createdAt: row.createdAt,
    // Matches ContactLog.allowsReview in lib/app/domain/entities.dart.
    allowsReview: row.outcome === ContactOutcome.REACHED && !row.review,
  };
}
