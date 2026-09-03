import { ApiProperty } from '@nestjs/swagger';
import { ModerationStatus, VerificationStatus } from '@prisma/client';
import { IsEmail, IsEnum, IsString, MaxLength, MinLength } from 'class-validator';

export class AdminLoginDto {
  @ApiProperty()
  @IsEmail()
  email!: string;

  @ApiProperty()
  @IsString()
  @MinLength(12)
  @MaxLength(256)
  password!: string;
}

export class AdminSessionDto {
  @ApiProperty()
  accessToken!: string;
}

export class DecideVerificationDto {
  @ApiProperty({ enum: [VerificationStatus.VERIFIED, VerificationStatus.REJECTED] })
  @IsEnum(VerificationStatus)
  status!: VerificationStatus;

  @ApiProperty({ required: false })
  @IsString()
  @MaxLength(300)
  reason?: string;
}

export class ModerateReviewDto {
  @ApiProperty({ enum: [ModerationStatus.PUBLISHED, ModerationStatus.REJECTED] })
  @IsEnum(ModerationStatus)
  status!: ModerationStatus;
}
