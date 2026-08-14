import { ApiProperty } from '@nestjs/swagger';
import { ContactChannel, ContactOutcome } from '@prisma/client';

/// Mirrors lib/app/domain/entities.dart's ContactLog. No client-identifying
/// field beyond the caller's own id — PRODUCT.md §4 rule 7 (a client's
/// phone number is never exposed in a fiche).
export class ContactLogDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  brokerId!: string;

  @ApiProperty({ type: String, required: false, nullable: true })
  propertyId!: string | null;

  @ApiProperty({ enum: ContactChannel })
  channel!: ContactChannel;

  @ApiProperty({ enum: ContactOutcome })
  outcome!: ContactOutcome;

  @ApiProperty({ type: String, required: false, nullable: true })
  reviewId!: string | null;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  allowsReview!: boolean;
}
