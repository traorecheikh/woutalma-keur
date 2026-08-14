import { ApiProperty } from '@nestjs/swagger';
import { ContactOutcome } from '@prisma/client';
import { IsEnum } from 'class-validator';

/// Mirrors the outcome half of ContactRepository.update(...) — the other
/// fields on ContactLog (channel, broker, property) are set once at
/// creation and never revised.
export class UpdateContactOutcomeDto {
  @ApiProperty({ enum: ContactOutcome })
  @IsEnum(ContactOutcome)
  outcome!: ContactOutcome;
}
