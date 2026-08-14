import { ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

/// Resolves the signed-in user to the broker profile they own.
///
/// A plain function rather than an injectable so both BrokersController and
/// PropertiesController can use it without BrokersModule and PropertiesModule
/// importing each other (they already form a one-way edge, and this would
/// close it into a cycle).
///
/// Throws 403 rather than 404: the caller is authenticated, they simply are
/// not a broker, and "you cannot do this" is the honest answer.
export async function requireBrokerIdForOwner(prisma: PrismaService, userId: string): Promise<string> {
  const broker = await prisma.broker.findUnique({ where: { ownerId: userId }, select: { id: true } });
  if (!broker) {
    throw new ForbiddenException('This account has no broker profile');
  }
  return broker.id;
}
