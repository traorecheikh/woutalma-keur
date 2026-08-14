import { ApiProperty } from '@nestjs/swagger';

export class LivenessDto {
  @ApiProperty({ example: 'ok' })
  status!: 'ok';

  @ApiProperty({ example: 412 })
  uptimeSeconds!: number;
}

export class ReadinessDto {
  @ApiProperty({ enum: ['ok', 'degraded'], example: 'ok' })
  status!: 'ok' | 'degraded';

  @ApiProperty({ enum: ['up', 'down'], example: 'up' })
  database!: 'up' | 'down';

  @ApiProperty({ example: 12, description: 'Round-trip time of the readiness query.' })
  latencyMs!: number;

  @ApiProperty({ example: 412 })
  uptimeSeconds!: number;
}
