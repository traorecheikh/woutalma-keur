import { ApiProperty } from '@nestjs/swagger';
import { Role } from '@prisma/client';

export class AuthSessionDto {
  @ApiProperty()
  accessToken!: string;

  @ApiProperty()
  refreshToken!: string;

  @ApiProperty()
  userId!: string;

  @ApiProperty({ enum: Role })
  activeRole!: Role;

  /// Non-null once the user has created a broker profile — lets the client
  /// resolve `AppDependencies.currentBrokerId` without a second round trip.
  @ApiProperty({ type: String, required: false, nullable: true })
  brokerId!: string | null;
}
