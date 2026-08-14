import { ApiProperty } from '@nestjs/swagger';
import { IsIn } from 'class-validator';
import { DEV_PERSONAS, DevPersona } from '../providers/dev-auth.provider';

export class DevSignInDto {
  @ApiProperty({
    enum: DEV_PERSONAS,
    description:
      'Which seeded demo account to sign in as. Only available when the deployment sets DEV_AUTH_ENABLED=true.',
  })
  @IsIn(DEV_PERSONAS as unknown as string[])
  persona!: DevPersona;
}
