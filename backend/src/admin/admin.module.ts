import { Module } from '@nestjs/common';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { ThrottlerStorageRedisService } from '@nest-lab/throttler-storage-redis';
import { AuthModule } from '../auth/auth.module';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';

@Module({
  imports: [
    AuthModule,
    ThrottlerModule.forRoot({
      throttlers: [{ ttl: 60_000, limit: 120 }],
      storage: process.env.REDIS_URL
        ? new ThrottlerStorageRedisService(process.env.REDIS_URL)
        : undefined,
    }),
  ],
  controllers: [AdminController],
  providers: [AdminService, ThrottlerGuard],
})
export class AdminModule {}
