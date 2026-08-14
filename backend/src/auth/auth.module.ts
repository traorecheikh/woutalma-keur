import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';
import { GoogleAuthProvider } from './providers/google-auth.provider';
import { DevAuthProvider } from './providers/dev-auth.provider';

@Module({
  imports: [
    PassportModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.getOrThrow<string>('JWT_SECRET'),
        signOptions: { expiresIn: config.getOrThrow<string>('JWT_ACCESS_TOKEN_TTL') },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, GoogleAuthProvider, DevAuthProvider, JwtStrategy],
  exports: [JwtModule],
})
export class AuthModule {}
