import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';
import { ROLES_KEY } from './roles.decorator';
import { AuthenticatedRequestUser } from './jwt-payload.interface';

/// Runs after AuthGuard('jwt'). Routes with no @Roles() decorator are open
/// to any authenticated user; PRODUCT.md §4 rule 8 lets one account hold
/// both roles, so this checks the *active* role on the token, not identity.
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<Role[] | undefined>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!required || required.length === 0) {
      return true;
    }
    const user = context.switchToHttp().getRequest().user as AuthenticatedRequestUser | undefined;
    return !!user && required.includes(user.role);
  }
}
