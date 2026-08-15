import { ApiProperty } from '@nestjs/swagger';
import { ContactChannel, ContactOutcome } from '@prisma/client';

/// What a broker is allowed to know about a contact they received.
///
/// Deliberately NOT ContactLogDto minus a field: this is a different view of
/// the same row, for a different reader, and it must stay impossible to widen
/// it by accident. PRODUCT.md §4 rule 7 — the client is never identified to
/// the broker. The broker already learns who called them through the call
/// itself; the app must not hand them a durable, exportable list of client
/// account ids on top of that.
///
/// `clientId` therefore has no place here, and neither does anything that
/// would let one client's contacts be stitched together across brokers.
export class BrokerContactLogDto {
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

  /// Whether this exchange produced a review, without saying which one:
  /// pairing a review with the exact call it came from narrows "who wrote
  /// this" down to a single caller the broker spoke to.
  @ApiProperty()
  hasReview!: boolean;

  @ApiProperty()
  createdAt!: Date;
}
