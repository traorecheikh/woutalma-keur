import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class RefreshSessionDto {
  @ApiProperty({ description: 'The refreshToken from a previous AuthSessionDto.' })
  @IsString()
  @MinLength(1)
  refreshToken!: string;
}
