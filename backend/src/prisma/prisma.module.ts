import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

/// Global so every feature module can inject PrismaService without each one
/// re-importing this module — same "one composition root" spirit as
/// AppDependencies on the Flutter side.
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
