import { ForbiddenException } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { Prisma } from '@prisma/client';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';
import { ReviewsService } from './reviews.service';
import { geographyPoint } from '../common/postgis';

/// The broker side of a review: answering it, flagging it, and reading the
/// ones that are not published yet. Each of those is a place where "the
/// broker" and "somebody else" must get different answers, so every case here
/// is run twice — once as the owner, once as a stranger.
describe('ReviewsService — broker-side actions and visibility', () => {
  let prisma: PrismaService;
  let reviews: ReviewsService;

  let clientId: string;
  let brokerOwnerId: string;
  let strangerOwnerId: string;
  let brokerId: string;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [PrismaModule],
      providers: [ReviewsService],
    }).compile();
    prisma = moduleRef.get(PrismaService);
    reviews = moduleRef.get(ReviewsService);
  });

  beforeEach(async () => {
    await prisma.review.deleteMany();
    await prisma.contactLog.deleteMany();
    await prisma.property.deleteMany();
    await prisma.broker.deleteMany();
    await prisma.user.deleteMany();

    const client = await prisma.user.create({ data: { email: 'client@example.sn' } });
    const owner = await prisma.user.create({ data: { email: 'broker@example.sn' } });
    const stranger = await prisma.user.create({ data: { email: 'other-broker@example.sn' } });
    clientId = client.id;
    brokerOwnerId = owner.id;
    strangerOwnerId = stranger.id;

    const [broker] = await prisma.$queryRaw<{ id: string }[]>(Prisma.sql`
      INSERT INTO "brokers" ("id", "ownerId", "kind", "name", "phone", "position", "coverage", "updatedAt")
      VALUES (gen_random_uuid()::text, ${brokerOwnerId}, 'INDIVIDUAL', 'Moussa', '+221770000000',
              ${geographyPoint(14.69, -17.44)}, ARRAY[]::text[], now())
      RETURNING "id"
    `);
    brokerId = broker.id;

    // The stranger owns a broker profile of their own, so a refusal below
    // proves the check is "owns THIS broker", not merely "is a broker".
    await prisma.$executeRaw(Prisma.sql`
      INSERT INTO "brokers" ("id", "ownerId", "kind", "name", "phone", "position", "coverage", "updatedAt")
      VALUES (gen_random_uuid()::text, ${strangerOwnerId}, 'INDIVIDUAL', 'Awa', '+221770000002',
              ${geographyPoint(14.7, -17.45)}, ARRAY[]::text[], now())
    `);
  });

  async function createReview(moderation: 'PENDING' | 'PUBLISHED' | 'REJECTED' = 'PUBLISHED') {
    const contact = await prisma.contactLog.create({
      data: { brokerId, clientId, channel: 'CALL', outcome: 'REACHED' },
    });
    return prisma.review.create({
      data: {
        brokerId,
        contactId: contact.id,
        authorId: clientId,
        rating: 2,
        comment: 'Trop cher',
        moderation,
      },
    });
  }

  describe('reply', () => {
    it('lets the broker the review is about answer it', async () => {
      const review = await createReview();

      const replied = await reviews.reply(review.id, brokerOwnerId, { reply: 'Merci, je vous rappelle.' });

      expect(replied.brokerReply).toBe('Merci, je vous rappelle.');
      const persisted = await prisma.review.findUnique({ where: { id: review.id } });
      expect(persisted?.brokerReply).toBe('Merci, je vous rappelle.');
    });

    it('refuses a broker replying to a review about someone else', async () => {
      const review = await createReview();

      await expect(reviews.reply(review.id, strangerOwnerId, { reply: 'Faux avis' })).rejects.toBeInstanceOf(
        ForbiddenException,
      );

      const persisted = await prisma.review.findUnique({ where: { id: review.id } });
      expect(persisted?.brokerReply).toBeNull();
    });

    it('leaves the rating, the comment and the moderation status untouched', async () => {
      const review = await createReview();

      await reviews.reply(review.id, brokerOwnerId, { reply: 'Bonjour' });

      const persisted = await prisma.review.findUnique({ where: { id: review.id } });
      expect(persisted?.rating).toBe(2);
      expect(persisted?.comment).toBe('Trop cher');
      expect(persisted?.moderation).toBe('PUBLISHED');
    });
  });

  describe('report', () => {
    it('sends a published review back to PENDING and keeps the reason for the operator', async () => {
      const review = await createReview();

      const reported = await reviews.report(review.id, brokerOwnerId, {
        reason: 'Ce client ne m’a jamais appelé',
      });

      expect(reported.moderation).toBe('PENDING');
      expect(reported.isPublic).toBe(false);
      const persisted = await prisma.review.findUnique({ where: { id: review.id } });
      expect(persisted?.reportedReason).toBe('Ce client ne m’a jamais appelé');
    });

    it('accepts a report with no reason', async () => {
      const review = await createReview();

      const reported = await reviews.report(review.id, brokerOwnerId, {});

      expect(reported.moderation).toBe('PENDING');
    });

    it('cannot be used to reject a review — PENDING is the only status it writes', async () => {
      const review = await createReview();

      await reviews.report(review.id, brokerOwnerId, { reason: 'Diffamation' });

      const persisted = await prisma.review.findUnique({ where: { id: review.id } });
      expect(persisted?.moderation).toBe('PENDING');
      expect(persisted?.moderation).not.toBe('REJECTED');
      // The text survives untouched: reporting is not a way to edit criticism.
      expect(persisted?.comment).toBe('Trop cher');
    });

    it('refuses a broker reporting a review about someone else', async () => {
      const review = await createReview();

      await expect(reviews.report(review.id, strangerOwnerId, {})).rejects.toBeInstanceOf(ForbiddenException);

      const persisted = await prisma.review.findUnique({ where: { id: review.id } });
      expect(persisted?.moderation).toBe('PUBLISHED');
    });
  });

  describe('byBroker visibility', () => {
    it('serves only published reviews when no audience is given', async () => {
      await createReview('PUBLISHED');
      await createReview('PENDING');
      await createReview('REJECTED');

      const visible = await reviews.byBroker(brokerId);

      expect(visible).toHaveLength(1);
      expect(visible[0].moderation).toBe('PUBLISHED');
    });

    it('ignores onlyPublic=false from an anonymous caller', async () => {
      await createReview('PUBLISHED');
      await createReview('PENDING');

      const visible = await reviews.byBroker(brokerId, { includeNonPublic: true });

      expect(visible).toHaveLength(1);
      expect(visible.every((review) => review.isPublic)).toBe(true);
    });

    it('ignores onlyPublic=false from a signed-in stranger', async () => {
      await createReview('PUBLISHED');
      await createReview('PENDING');
      await createReview('REJECTED');

      const asClient = await reviews.byBroker(brokerId, { includeNonPublic: true, viewerId: clientId });
      const asOtherBroker = await reviews.byBroker(brokerId, {
        includeNonPublic: true,
        viewerId: strangerOwnerId,
      });

      expect(asClient).toHaveLength(1);
      expect(asOtherBroker).toHaveLength(1);
    });

    it('shows the pending and rejected ones to the broker they are about', async () => {
      await createReview('PUBLISHED');
      await createReview('PENDING');
      await createReview('REJECTED');

      const own = await reviews.byBroker(brokerId, { includeNonPublic: true, viewerId: brokerOwnerId });

      expect(own).toHaveLength(3);
      expect(own.filter((review) => review.isPublic)).toHaveLength(1);
    });

    it('still hides them from the owning broker when the wider view is not asked for', async () => {
      await createReview('PENDING');

      const own = await reviews.byBroker(brokerId, { viewerId: brokerOwnerId });

      expect(own).toHaveLength(0);
    });
  });

  describe('all', () => {
    it('never leaves the published set, whoever asks', async () => {
      await createReview('PUBLISHED');
      await createReview('PENDING');
      await createReview('REJECTED');

      const everything = await reviews.all();

      expect(everything).toHaveLength(1);
      expect(everything[0].isPublic).toBe(true);
    });
  });
});
