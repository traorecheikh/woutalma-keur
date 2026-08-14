import { Body, Controller, Headers, Post } from '@nestjs/common';
import { ApiHeader, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { AuthSessionDto } from './dto/auth-session.dto';
import { GoogleSignInDto } from './dto/google-sign-in.dto';
import { DevSignInDto } from './dto/dev-sign-in.dto';
import { RefreshSessionDto } from './dto/refresh-session.dto';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('google')
  @ApiOperation({
    summary: 'Sign in (or sign up) with a Google ID token obtained on-device.',
  })
  @ApiOkResponse({ type: AuthSessionDto })
  signInWithGoogle(@Body() dto: GoogleSignInDto): Promise<AuthSessionDto> {
    return this.auth.signInWithGoogle(dto.idToken);
  }

  @Post('dev')
  @ApiOperation({
    summary:
      'Sign in as a seeded demo persona. Returns 404 unless the deployment sets DEV_AUTH_ENABLED=true, and 401 without the matching x-dev-auth-secret header.',
  })
  @ApiHeader({ name: 'x-dev-auth-secret', required: true })
  @ApiOkResponse({ type: AuthSessionDto })
  signInAsDev(
    @Body() dto: DevSignInDto,
    @Headers('x-dev-auth-secret') secret?: string,
  ): Promise<AuthSessionDto> {
    return this.auth.signInAsDev(dto.persona, secret);
  }

  @Post('refresh')
  @ApiOperation({
    summary: 'Exchange a refresh token for a fresh access/refresh pair.',
  })
  @ApiOkResponse({ type: AuthSessionDto })
  refresh(@Body() dto: RefreshSessionDto): Promise<AuthSessionDto> {
    return this.auth.refresh(dto.refreshToken);
  }
}
