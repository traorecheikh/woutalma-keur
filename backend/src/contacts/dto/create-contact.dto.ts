import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ContactChannel } from '@prisma/client';
import { IsEnum, IsOptional, IsString } from 'class-validator';

/// Mirrors ContactRepository.log(...) in lib/app/domain/repositories.dart.
/// Called by the client BEFORE it opens tel:/sms:/wa.me — see
/// contacts.controller.ts's doc comment for why the ordering matters.
export class CreateContactDto {
  @ApiProperty()
  @IsString()
  brokerId!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  propertyId?: string;

  @ApiProperty({ enum: ContactChannel })
  @IsEnum(ContactChannel)
  channel!: ContactChannel;

  @ApiPropertyOptional({ description: 'Stable client-generated key for retry-safe contact logging.' })
  @IsOptional()
  @IsString()
  clientRequestId?: string;
}
