import { ApiProperty } from '@nestjs/swagger';
import { IsString, MaxLength, MinLength } from 'class-validator';

/// The broker's right of reply. Only the reply text is reachable from here:
/// the rating, the client's comment and the moderation status all stay out of
/// the broker's hands — an unfavourable review is answered, never edited or
/// removed.
export class ReplyReviewDto {
  @ApiProperty({ maxLength: 2000 })
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  reply!: string;
}
