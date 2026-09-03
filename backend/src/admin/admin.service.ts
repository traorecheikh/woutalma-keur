import {
  BadRequestException,
  Injectable,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { ModerationStatus, Role, VerificationStatus } from '@prisma/client';
import { createHash, timingSafeEqual } from 'node:crypto';
import { PrismaService } from '../prisma/prisma.service';
import { AdminSessionDto, DecideVerificationDto, ModerateReviewDto } from './admin.dto';

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly jwt: JwtService,
  ) {}

  async login(email: string, password: string): Promise<AdminSessionDto> {
    const expectedEmail = this.config.get<string>('ADMIN_EMAIL');
    const expectedPassword = this.config.get<string>('ADMIN_PASSWORD');
    if (!expectedEmail || !expectedPassword) {
      throw new ServiceUnavailableException('Admin access is not configured');
    }
    const normalizedEmail = email.trim().toLowerCase();
    if (
      !sameSecret(normalizedEmail, expectedEmail.trim().toLowerCase()) ||
      !sameSecret(password, expectedPassword)
    ) {
      throw new UnauthorizedException('Invalid admin credentials');
    }
    return {
      accessToken: await this.jwt.signAsync(
        { sub: `admin:${normalizedEmail}`, role: Role.ADMIN, typ: 'access' },
        { expiresIn: this.config.get<string>('ADMIN_TOKEN_TTL') ?? '8h' },
      ),
    };
  }

  async queue() {
    const [verifications, reviews] = await Promise.all([
      this.prisma.broker.findMany({
        where: { verification: VerificationStatus.PENDING },
        orderBy: { updatedAt: 'asc' },
        select: {
          id: true,
          kind: true,
          name: true,
          phone: true,
          whatsapp: true,
          coverage: true,
          updatedAt: true,
        },
      }),
      this.prisma.review.findMany({
        where: { moderation: ModerationStatus.PENDING },
        orderBy: { updatedAt: 'asc' },
        select: {
          id: true,
          rating: true,
          comment: true,
          reportedReason: true,
          brokerReply: true,
          createdAt: true,
          broker: { select: { id: true, name: true } },
        },
      }),
    ]);
    return { verifications, reviews };
  }

  async decideVerification(id: string, dto: DecideVerificationDto) {
    if (dto.status !== VerificationStatus.VERIFIED && dto.status !== VerificationStatus.REJECTED) {
      throw new BadRequestException('Verification can only be approved or rejected');
    }
    const reason = dto.reason?.trim();
    if (dto.status === VerificationStatus.REJECTED && !reason) {
      throw new BadRequestException('A rejection reason is required');
    }
    return this.prisma.broker.update({
      where: { id },
      data: {
        verification: dto.status,
        rejectionReason: dto.status === VerificationStatus.REJECTED ? reason : null,
      },
      select: { id: true, verification: true, rejectionReason: true },
    });
  }

  async moderateReview(id: string, dto: ModerateReviewDto) {
    if (dto.status !== ModerationStatus.PUBLISHED && dto.status !== ModerationStatus.REJECTED) {
      throw new BadRequestException('A review can only be published or rejected');
    }
    return this.prisma.review.update({
      where: { id },
      data: { moderation: dto.status, reportedReason: null },
      select: { id: true, moderation: true },
    });
  }
}

function sameSecret(value: string, expected: string): boolean {
  const digest = (input: string) => createHash('sha256').update(input).digest();
  return timingSafeEqual(digest(value), digest(expected));
}
