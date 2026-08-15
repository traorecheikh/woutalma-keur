import { Test } from '@nestjs/testing';
import { Prisma } from '@prisma/client';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';
import { ContactsService } from './contacts.service';
import { geographyPoint } from '../common/postgis';

/// PRODUCT.md §4 rule 7: a broker never learns who the client is. The broker
/// activity screen needs the contacts it *received* — a list `GET /contacts`
/// cannot produce, since it filters on clientId — and it must get them
/// without a single client-identifying field riding along.
describe('ContactsService — the broker-side view of received contacts', () => {
  let prisma: PrismaService;
  let contacts: ContactsService;

  let clientId: string;
  let otherClientId: string;
  let brokerOwnerId: string;
  let brokerId: string;
  let otherBrokerId: string;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [PrismaModule],
      providers: [ContactsService],
    }).compile();
    prisma = moduleRef.get(PrismaService);
    contacts = moduleRef.get(ContactsService);
  });

  beforeEach(async () => {
    await prisma.review.deleteMany();
    await prisma.contactLog.deleteMany();
    await prisma.property.deleteMany();
    await prisma.broker.deleteMany();
    await prisma.user.deleteMany();

    const client = await prisma.user.create({ data: { email: 'client@example.sn' } });
    const otherClient = await prisma.user.create({ data: { email: 'client2@example.sn' } });
    const owner = await prisma.user.create({ data: { email: 'broker@example.sn' } });
    const otherOwner = await prisma.user.create({ data: { email: 'broker2@example.sn' } });
    clientId = client.id;
    otherClientId = otherClient.id;
    brokerOwnerId = owner.id;

    const [broker] = await prisma.$queryRaw<{ id: string }[]>(Prisma.sql`
      INSERT INTO "brokers" ("id", "ownerId", "kind", "name", "phone", "position", "coverage", "updatedAt")
      VALUES (gen_random_uuid()::text, ${owner.id}, 'INDIVIDUAL', 'Fatou', '+221770000001',
              ${geographyPoint(14.69, -17.44)}, ARRAY[]::text[], now())
      RETURNING "id"
    `);
    brokerId = broker.id;

    const [otherBroker] = await prisma.$queryRaw<{ id: string }[]>(Prisma.sql`
      INSERT INTO "brokers" ("id", "ownerId", "kind", "name", "phone", "position", "coverage", "updatedAt")
      VALUES (gen_random_uuid()::text, ${otherOwner.id}, 'INDIVIDUAL', 'Awa', '+221770000002',
              ${geographyPoint(14.7, -17.45)}, ARRAY[]::text[], now())
      RETURNING "id"
    `);
    otherBrokerId = otherBroker.id;
  });

  it('returns the contacts the broker received, which GET /contacts cannot', async () => {
    await contacts.log({ brokerId, channel: 'CALL' }, clientId);
    await contacts.log({ brokerId, channel: 'WHATSAPP' }, otherClientId);

    // What the broker's own account sees through GET /contacts: nothing.
    // That endpoint answers "who did I contact as a client", which is why the
    // broker activity screen kept counting zero.
    const asClientOfTheirOwnAccount = await contacts.all(brokerOwnerId);
    const received = await contacts.byBrokerForOwner(brokerId);

    expect(asClientOfTheirOwnAccount).toHaveLength(0);
    expect(received).toHaveLength(2);
    expect(received.map((row) => row.channel).sort()).toEqual(['CALL', 'WHATSAPP']);
  });

  it('exposes no client-identifying field', async () => {
    await contacts.log({ brokerId, channel: 'CALL' }, clientId);

    const [row] = await contacts.byBrokerForOwner(brokerId);

    expect(Object.keys(row).sort()).toEqual(
      ['brokerId', 'channel', 'createdAt', 'hasReview', 'id', 'outcome', 'propertyId'].sort(),
    );
    expect(row).not.toHaveProperty('clientId');
    expect(JSON.stringify(row)).not.toContain(clientId);
  });

  it('reports whether a review exists without naming it', async () => {
    const withoutReview = await contacts.log({ brokerId, channel: 'CALL' }, clientId);
    const withReview = await contacts.log({ brokerId, channel: 'SMS' }, otherClientId);
    await contacts.updateOutcome(withReview.id, otherClientId, { outcome: 'REACHED' });
    await prisma.review.create({
      data: { brokerId, contactId: withReview.id, authorId: otherClientId, rating: 5 },
    });

    const received = await contacts.byBrokerForOwner(brokerId);
    const reviewed = received.find((row) => row.id === withReview.id);
    const plain = received.find((row) => row.id === withoutReview.id);

    expect(reviewed?.hasReview).toBe(true);
    expect(plain?.hasReview).toBe(false);
    expect(reviewed).not.toHaveProperty('reviewId');
  });

  it('is scoped to the one broker asked for', async () => {
    await contacts.log({ brokerId, channel: 'CALL' }, clientId);
    await contacts.log({ brokerId: otherBrokerId, channel: 'CALL' }, clientId);

    const received = await contacts.byBrokerForOwner(brokerId);

    expect(received).toHaveLength(1);
    expect(received[0].brokerId).toBe(brokerId);
  });
});
