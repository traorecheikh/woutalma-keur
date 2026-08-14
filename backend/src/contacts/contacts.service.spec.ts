import { Test } from '@nestjs/testing';
import { Prisma } from '@prisma/client';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';
import { ContactsService } from './contacts.service';
import { geographyPoint } from '../common/postgis';

/// PRODUCT.md §3: "Journal local avant l'ouverture du canal externe" — the
/// ContactLog row must exist before the client is allowed to open
/// tel:/sms:/wa.me. Server-side that just means: by the time log() resolves
/// (the point at which the Flutter RemoteContactRepository.log() call
/// returns and ContactLauncher.open() runs next), the row is already
/// durably committed — proven here by re-reading it back via a second,
/// independent query right after await.
describe('ContactsService — log-before-respond ordering', () => {
  let prisma: PrismaService;
  let contacts: ContactsService;
  let clientId: string;
  let brokerId: string;

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
    const owner = await prisma.user.create({ data: { email: 'broker@example.sn' } });
    clientId = client.id;

    const [broker] = await prisma.$queryRaw<{ id: string }[]>(Prisma.sql`
      INSERT INTO "brokers" ("id", "ownerId", "kind", "name", "phone", "position", "coverage", "updatedAt")
      VALUES (gen_random_uuid()::text, ${owner.id}, 'INDIVIDUAL', 'Fatou', '+221770000001',
              ${geographyPoint(14.69, -17.44)}, ARRAY[]::text[], now())
      RETURNING "id"
    `);
    brokerId = broker.id;
  });

  it('commits the row before log() resolves', async () => {
    const result = await contacts.log({ brokerId, channel: 'CALL' }, clientId);

    const persisted = await prisma.contactLog.findUnique({ where: { id: result.id } });
    expect(persisted).not.toBeNull();
    expect(persisted?.brokerId).toBe(brokerId);
    expect(persisted?.outcome).toBe('ATTEMPTED');
  });

  it('lets the outcome be updated to reached, unlocking review eligibility', async () => {
    const logged = await contacts.log({ brokerId, channel: 'WHATSAPP' }, clientId);
    expect(logged.allowsReview).toBe(false);

    const updated = await contacts.updateOutcome(logged.id, clientId, { outcome: 'REACHED' });
    expect(updated.allowsReview).toBe(true);
  });
});
