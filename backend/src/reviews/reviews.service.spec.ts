import { Test } from '@nestjs/testing';
import { Prisma } from '@prisma/client';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';
import { ReviewsService } from './reviews.service';
import { ReviewRefusalReason, ReviewRefusedException } from './review-refusal';
import { geographyPoint } from '../common/postgis';

async function expectRefusal(promise: Promise<unknown>, reason: ReviewRefusalReason): Promise<void> {
  await expect(promise).rejects.toBeInstanceOf(ReviewRefusedException);
  try {
    await promise;
    throw new Error('expected promise to reject');
  } catch (error) {
    expect(error).toBeInstanceOf(ReviewRefusedException);
    const response = (error as ReviewRefusedException).getResponse() as { reason: ReviewRefusalReason };
    expect(response.reason).toBe(reason);
  }
}

/// Proves ReviewsService enforces every ReviewRefusal branch from
/// lib/app/domain/review_eligibility.dart server-side — not just as a UI
/// pre-check, per PRODUCT.md §10's "Fraude malgré le lien entre contact et
/// avis" risk. Each case is exercised as a raw service call (the same path
/// a modified/curl client would hit), not through any client-side gate.
describe('ReviewsService — server-side eligibility (review_eligibility.dart parity)', () => {
  let prisma: PrismaService;
  let reviews: ReviewsService;

  let clientId: string;
  let strangerId: string;
  let brokerOwnerId: string;
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
    const stranger = await prisma.user.create({ data: { email: 'stranger@example.sn' } });
    const owner = await prisma.user.create({ data: { email: 'broker@example.sn' } });
    clientId = client.id;
    strangerId = stranger.id;
    brokerOwnerId = owner.id;

    const [broker] = await prisma.$queryRaw<{ id: string }[]>(Prisma.sql`
      INSERT INTO "brokers" ("id", "ownerId", "kind", "name", "phone", "position", "coverage", "updatedAt")
      VALUES (gen_random_uuid()::text, ${brokerOwnerId}, 'INDIVIDUAL', 'Moussa', '+221770000000',
              ${geographyPoint(14.69, -17.44)}, ARRAY[]::text[], now())
      RETURNING "id"
    `);
    brokerId = broker.id;
  });

  async function createContact(outcome: 'ATTEMPTED' | 'REACHED', clientOverride?: string) {
    return prisma.contactLog.create({
      data: {
        brokerId,
        clientId: clientOverride ?? clientId,
        channel: 'CALL',
        outcome,
      },
    });
  }

  it('rejects with noContact when the contactId does not exist', async () => {
    await expectRefusal(reviews.create({ contactId: 'does-not-exist', rating: 5 }, clientId), 'noContact');
  });

  it('rejects with notOwner when the contact belongs to a different user', async () => {
    const contact = await createContact('REACHED');
    await expectRefusal(reviews.create({ contactId: contact.id, rating: 5 }, strangerId), 'notOwner');
  });

  it('rejects with notReached when the contact was never confirmed as a successful exchange', async () => {
    const contact = await createContact('ATTEMPTED');
    await expectRefusal(reviews.create({ contactId: contact.id, rating: 5 }, clientId), 'notReached');
  });

  it('rejects with alreadyReviewed when this contact already has a review', async () => {
    const contact = await createContact('REACHED');
    await reviews.create({ contactId: contact.id, rating: 4 }, clientId);

    await expectRefusal(reviews.create({ contactId: contact.id, rating: 2 }, clientId), 'alreadyReviewed');
  });

  it('allows exactly one review for a reached, unreviewed, owned contact', async () => {
    const contact = await createContact('REACHED');
    const review = await reviews.create({ contactId: contact.id, rating: 5, comment: 'Excellent' }, clientId);

    expect(review.brokerId).toBe(brokerId);
    expect(review.contactId).toBe(contact.id);
    expect(review.moderation).toBe('PENDING');
  });
});
