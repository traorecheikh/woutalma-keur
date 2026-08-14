import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class GoogleSignInDto {
  @ApiProperty({ description: 'ID token returned by Google Sign-In on the device.' })
  @IsString()
  @MinLength(10)
  idToken!: string;
}
