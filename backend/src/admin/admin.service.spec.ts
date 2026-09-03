import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { VerificationStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AdminService } from './admin.service';

describe('AdminService', () => {
  const update = jest.fn();
  const prisma = {
    broker: { update, findMany: jest.fn().mockResolvedValue([]) },
    review: { update: jest.fn(), findMany: jest.fn().mockResolvedValue([]) },
  } as unknown as PrismaService;
  const config = {
    get: jest.fn(
      (key: string) =>
        ({
          ADMIN_EMAIL: 'admin@woutalma.sn',
          ADMIN_PASSWORD: 'a-long-test-password',
          ADMIN_TOKEN_TTL: '8h',
        })[key],
    ),
  } as unknown as ConfigService;
  const jwt = { signAsync: jest.fn().mockResolvedValue('admin-token') } as unknown as JwtService;
  const service = new AdminService(prisma, config, jwt);

  beforeEach(() => jest.clearAllMocks());

  it('authenticates the configured moderator and requires a rejection reason', async () => {
    await expect(service.login('ADMIN@WOUTALMA.SN', 'a-long-test-password')).resolves.toEqual({
      accessToken: 'admin-token',
    });
    await expect(service.login('admin@woutalma.sn', 'wrong-password')).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    await expect(
      service.decideVerification('broker-1', { status: VerificationStatus.REJECTED }),
    ).rejects.toBeInstanceOf(BadRequestException);
    expect(update).not.toHaveBeenCalled();
  });
});
