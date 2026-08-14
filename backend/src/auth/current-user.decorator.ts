import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AuthenticatedRequestUser } from './jwt-payload.interface';

export const CurrentUser = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): AuthenticatedRequestUser => {
    const request = ctx.switchToHttp().getRequest();
    return request.user as AuthenticatedRequestUser;
  },
);
