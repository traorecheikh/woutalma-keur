import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsString, Matches, MinLength } from 'class-validator';

/// Numéro au format international, chiffres et un « + » optionnel.
const PHONE = /^\+?[0-9]{8,15}$/;

export class DevRequestCodeDto {
  @ApiProperty({ example: '+221771234567' })
  @IsString()
  @Matches(PHONE, { message: 'phone must be 8 to 15 digits, optionally prefixed with +' })
  phone!: string;
}

export class DevRequestCodeResponseDto {
  @ApiProperty({
    description:
      'The code, returned in the response because no SMS is sent. Only ever exposed on a deployment that has explicitly enabled dev auth.',
    example: '481920',
  })
  code!: string;

  @ApiProperty({ example: '+221771234567' })
  phone!: string;
}

export class DevVerifyCodeDto {
  @ApiProperty({ example: '+221771234567' })
  @IsString()
  @Matches(PHONE)
  phone!: string;

  @ApiProperty({ example: '481920' })
  @IsString()
  @MinLength(4)
  code!: string;

  @ApiPropertyOptional({
    description:
      'Give this account a broker profile if it has none, so the broker side is reachable without an operator. Dev auth only.',
    default: false,
  })
  @IsOptional()
  @IsBoolean()
  asBroker?: boolean;
}
