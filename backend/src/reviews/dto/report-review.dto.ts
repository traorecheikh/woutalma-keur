import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

/// A broker flagging a review about them for a human to look at. The reason is
/// free text and optional: it is context for the operator who will re-moderate,
/// not an input to any automatic rule.
export class ReportReviewDto {
  @ApiPropertyOptional({ maxLength: 500 })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string;
}
