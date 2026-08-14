import { ApiProperty } from '@nestjs/swagger';
import { ModerationStatus } from '@prisma/client';

/// Mirrors lib/app/domain/entities.dart's Review.
export class ReviewDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  brokerId!: string;

  @ApiProperty()
  contactId!: string;

  @ApiProperty()
  rating!: number;

  @ApiProperty({ type: Number, required: false, nullable: true })
  responsiveness!: number | null;

  @ApiProperty({ type: Number, required: false, nullable: true })
  accuracy!: number | null;

  @ApiProperty({ type: Number, required: false, nullable: true })
  courtesy!: number | null;

  @ApiProperty({ type: String, required: false, nullable: true })
  comment!: string | null;

  @ApiProperty({ enum: ModerationStatus })
  moderation!: ModerationStatus;

  @ApiProperty({ type: String, required: false, nullable: true })
  brokerReply!: string | null;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  isPublic!: boolean;
}
