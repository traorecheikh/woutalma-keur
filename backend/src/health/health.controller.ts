import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiServiceUnavailableResponse, ApiTags } from '@nestjs/swagger';
import { PrismaService } from '../prisma/prisma.service';
import { LivenessDto, ReadinessDto } from './dto/health.dto';

/// Two endpoints, deliberately.
///
/// `/healthz` is Render's `healthCheckPath`. It must not touch the database:
/// Render treats a failing health check during a rollout as a failed deploy,
/// so a transient database blip would roll back a perfectly good build.
///
/// `/readyz` is what the Flutter app pings at boot. Render's free Postgres
/// does not sleep — only the web service does — so the point of the round trip
/// is not to wake the database but to force the Prisma pool through its
/// TCP+TLS handshake, so the user's first /search/brokers isn't paying
/// connection setup on top of a ~50 s cold start.
///
/// Neither handler takes a DTO-bound parameter, so the global ValidationPipe
/// is a no-op here, and there is no global auth guard in this app (AuthGuard
/// is applied per controller), so both are public without any opt-out.
@ApiTags('health')
@Controller()
export class HealthController {
  private readonly startedAt = Date.now();

  constructor(private readonly prisma: PrismaService) {}

  @Get('healthz')
  @ApiOperation({ summary: 'Liveness. Always 200 while the process is up. Never touches the database.' })
  @ApiOkResponse({ type: LivenessDto })
  liveness(): LivenessDto {
    return { status: 'ok', uptimeSeconds: this.uptimeSeconds() };
  }

  @Get('readyz')
  @ApiOperation({
    summary: 'Readiness. Round-trips the database so a boot-time ping actually warms the connection pool.',
  })
  @ApiOkResponse({ type: ReadinessDto })
  @ApiServiceUnavailableResponse({ type: ReadinessDto })
  async readiness(): Promise<ReadinessDto> {
    const startedAt = Date.now();
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      return {
        status: 'ok',
        database: 'up',
        latencyMs: Date.now() - startedAt,
        uptimeSeconds: this.uptimeSeconds(),
      };
    } catch {
      throw new ServiceUnavailableException({
        status: 'degraded',
        database: 'down',
        latencyMs: Date.now() - startedAt,
        uptimeSeconds: this.uptimeSeconds(),
      } satisfies ReadinessDto);
    }
  }

  private uptimeSeconds(): number {
    return Math.round((Date.now() - this.startedAt) / 1000);
  }
}
