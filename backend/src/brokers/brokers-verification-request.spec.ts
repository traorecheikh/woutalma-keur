import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { Prisma, VerificationStatus } from '@prisma/client';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';
import { BrokersService } from './brokers.service';
import { geographyPoint } from '../common/postgis';

/// "Demander la vérification" is a request, not a grant (PRODUCT.md §4: the
/// badge is an operator's statement about a broker). The whole value of this
/// endpoint is what it *cannot* do, so that is what is pinned here: PENDING
/// is the only status it ever writes, and no sequence of calls reaches
/// VERIFIED.
describe('BrokersService — verification request', () => {
  let prisma: PrismaService;
  let brokers: BrokersService;

  let ownerId: string;
  let strangerId: string;
  let brokerId: string;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [PrismaModule],
      providers: [BrokersService],
    }).compile();
    prisma = moduleRef.get(PrismaService);
    brokers = moduleRef.get(BrokersService);
  });

  beforeEach(async () => {
    await prisma.review.deleteMany();
    await prisma.contactLog.deleteMany();
    await prisma.property.deleteMany();
    await prisma.broker.deleteMany();
    await prisma.user.deleteMany();

    const owner = await prisma.user.create({ data: { email: 'broker@example.sn' } });
    const stranger = await prisma.user.create({ data: { email: 'stranger@example.sn' } });
    ownerId = owner.id;
    strangerId = stranger.id;

    const [broker] = await prisma.$queryRaw<{ id: string }[]>(Prisma.sql`
      INSERT INTO "brokers" ("id", "ownerId", "kind", "name", "phone", "position", "coverage", "updatedAt")
      VALUES (gen_random_uuid()::text, ${ownerId}, 'INDIVIDUAL', 'Moussa', '+221770000000',
              ${geographyPoint(14.69, -17.44)}, ARRAY[]::text[], now())
      RETURNING "id"
    `);
    brokerId = broker.id;
  });

  async function setVerification(status: VerificationStatus, rejectionReason: string | null = null) {
    await prisma.$executeRaw(Prisma.sql`
      UPDATE "brokers"
      SET "verification" = ${status}::"VerificationStatus", "rejectionReason" = ${rejectionReason}
      WHERE "id" = ${brokerId}
    `);
  }

  async function storedVerification(): Promise<VerificationStatus> {
    const row = await prisma.broker.findUniqueOrThrow({
      where: { id: brokerId },
      select: { verification: true },
    });
    return row.verification;
  }

  it('moves an unverified profile into the queue', async () => {
    const before = await brokers.findById(brokerId);
    expect(before.verification).toBe('NONE');

    const after = await brokers.requestVerification(brokerId, ownerId);

    expect(after.verification).toBe('PENDING');
    expect(await storedVerification()).toBe('PENDING');
  });

  it('is idempotent — a second request while PENDING changes nothing and does not error', async () => {
    const first = await brokers.requestVerification(brokerId, ownerId);
    const second = await brokers.requestVerification(brokerId, ownerId);
    const third = await brokers.requestVerification(brokerId, ownerId);

    expect(first.verification).toBe('PENDING');
    expect(second.verification).toBe('PENDING');
    expect(third.verification).toBe('PENDING');
  });

  it('never downgrades an already verified profile, and never grants the badge itself', async () => {
    await setVerification(VerificationStatus.VERIFIED);

    const result = await brokers.requestVerification(brokerId, ownerId);

    expect(result.verification).toBe('VERIFIED');
    expect(await storedVerification()).toBe('VERIFIED');
  });

  it('cannot reach VERIFIED from any starting state', async () => {
    for (const start of [VerificationStatus.NONE, VerificationStatus.REJECTED, VerificationStatus.PENDING]) {
      await setVerification(start);

      await brokers.requestVerification(brokerId, ownerId);
      await brokers.requestVerification(brokerId, ownerId);

      expect(await storedVerification()).toBe('PENDING');
    }
  });

  it('lets a rejected broker apply again, dropping the stale rejection reason', async () => {
    await setVerification(VerificationStatus.REJECTED, 'Document illisible');

    const result = await brokers.requestVerification(brokerId, ownerId);

    expect(result.verification).toBe('PENDING');
    const row = await prisma.broker.findUniqueOrThrow({
      where: { id: brokerId },
      select: { rejectionReason: true },
    });
    expect(row.rejectionReason).toBeNull();
  });

  it('refuses a request for somebody else’s profile', async () => {
    await expect(brokers.requestVerification(brokerId, strangerId)).rejects.toBeInstanceOf(
      ForbiddenException,
    );
    expect(await storedVerification()).toBe('NONE');
  });

  it('404s on a profile that does not exist', async () => {
    await expect(brokers.requestVerification('does-not-exist', ownerId)).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });
});
