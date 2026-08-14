/**
 * Postgres port of lib/app/data/seed/demo_seed.dart.
 *
 * The Dart file is the source of truth for the demo data; this script exists
 * so the deployed API shows the same six brokers, ten properties, four contact
 * logs and eight reviews the local app has always shown. Determinism carries
 * over: the reference date is frozen at 2026-07-01T09:00:00Z and every date is
 * derived from it, so a reference screenshot stays comparable.
 *
 * Two things the Dart seed does not have, and why they are here:
 *
 * 1. `users`. Prisma's `Broker.ownerId` is a required unique FK and there is no
 *    counterpart in Dart. Ids are readable rather than cuid so the seed stays
 *    traceable. Only two carry a `googleSub`, matching DevAuthProvider's
 *    personas — signing in as a persona therefore finds the seeded row instead
 *    of creating a bare one.
 *
 * 2. `ctc-900`..`ctc-906`. Reviews rev-002..rev-008 in the Dart seed point at
 *    contact ids that `contacts()` never produces, and `Review.contactId` is a
 *    unique FK here. These seven rows are not invented data: they are the
 *    contacts that must have existed for those reviews to be legal under the
 *    rule ReviewsService.create() enforces. They are owned by seven distinct
 *    `usr-reviewer-NN` accounts, deliberately not by the demo client, so that
 *    `GET /contacts` as the demo client still returns exactly the four Dart
 *    contacts and `ctc-002` remains the single reached-but-unreviewed row that
 *    opens C05.
 *
 * Run against the Render database from a developer machine — the free tier has
 * no job runner:
 *
 *   DATABASE_URL="$EXTERNAL_URL?sslmode=require" npm run db:seed
 *
 * Idempotent: every write is an upsert and re-running changes nothing. Pass
 * SEED_RESET=true to truncate first (explicit on purpose — anything less
 * explicit eventually wipes data someone cared about).
 */
import { Prisma, PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/// Matches DemoSeed.reference — DateTime.utc(2026, 7, 1, 9).
const REFERENCE = new Date(Date.UTC(2026, 6, 1, 9, 0, 0));

function daysAgo(days: number): Date {
  return new Date(REFERENCE.getTime() - days * 24 * 60 * 60 * 1000);
}

/// Columns are TIMESTAMP(3) *without* time zone. Binding a JS Date sends a
/// timestamptz parameter that Postgres coerces using the session TimeZone,
/// which would make the result depend on where the seed was run from — and
/// determinism is the entire point of this data.
function ts(date: Date): Prisma.Sql {
  return Prisma.sql`${date.toISOString()}::timestamp(3)`;
}

/// `text[]` needs an explicit array literal; the empty case needs its own cast
/// or Postgres cannot infer the element type.
function textArray(values: string[]): Prisma.Sql {
  if (values.length === 0) {
    return Prisma.sql`ARRAY[]::text[]`;
  }
  return Prisma.sql`ARRAY[${Prisma.join(values.map((value) => Prisma.sql`${value}`))}]::text[]`;
}

/// Schema-qualified for the same reason as src/common/postgis.ts: Prisma pins
/// search_path to the `schema=` parameter, so PostGIS in `public` is otherwise
/// invisible.
function geographyPoint(latitude: number, longitude: number): Prisma.Sql {
  return Prisma.sql`public.ST_SetSRID(public.ST_MakePoint(${longitude}, ${latitude}), 4326)::public.geography`;
}

// ---------------------------------------------------------------------------
// Users
// ---------------------------------------------------------------------------

interface SeedUser {
  id: string;
  email: string;
  role: 'CLIENT' | 'BROKER';
  googleSub?: string;
}

const BROKER_OWNERS: Record<string, string> = {
  'brk-moussa': 'usr-owner-brk-moussa',
  'brk-teranga': 'usr-owner-brk-teranga',
  'brk-fatou': 'usr-owner-brk-fatou',
  'brk-ibrahima': 'usr-owner-brk-ibrahima',
  'brk-awa': 'usr-owner-brk-awa',
  'brk-keur-massar': 'usr-owner-brk-keur-massar',
};

const DEMO_CLIENT = 'usr-demo-client';

const USERS: SeedUser[] = [
  // DevAuthProvider persona 'broker' resolves here.
  { id: 'usr-owner-brk-moussa', email: 'moussa.owner@demo.woutalma.sn', role: 'BROKER', googleSub: 'dev:broker-moussa' },
  { id: 'usr-owner-brk-teranga', email: 'teranga.owner@demo.woutalma.sn', role: 'BROKER' },
  { id: 'usr-owner-brk-fatou', email: 'fatou.owner@demo.woutalma.sn', role: 'BROKER' },
  { id: 'usr-owner-brk-ibrahima', email: 'ibrahima.owner@demo.woutalma.sn', role: 'BROKER' },
  { id: 'usr-owner-brk-awa', email: 'awa.owner@demo.woutalma.sn', role: 'BROKER' },
  { id: 'usr-owner-brk-keur-massar', email: 'keurmassar.owner@demo.woutalma.sn', role: 'BROKER' },
  // DevAuthProvider persona 'client' resolves here. Owns ctc-001..004.
  { id: DEMO_CLIENT, email: 'demo.client@demo.woutalma.sn', role: 'CLIENT', googleSub: 'dev:client' },
  // Authors of rev-002..rev-008 and owners of the derived ctc-900..906.
  ...Array.from({ length: 7 }, (_, index) => {
    const suffix = String(index + 1).padStart(2, '0');
    return {
      id: `usr-reviewer-${suffix}`,
      email: `reviewer.${suffix}@demo.woutalma.sn`,
      role: 'CLIENT' as const,
    };
  }),
];

// ---------------------------------------------------------------------------
// Brokers — DemoSeed.brokers()
// ---------------------------------------------------------------------------

interface SeedBroker {
  id: string;
  kind: 'INDIVIDUAL' | 'AGENCY';
  name: string;
  phone: string;
  whatsapp: string | null;
  latitude: number;
  longitude: number;
  coverage: string[];
  verification: 'NONE' | 'PENDING' | 'VERIFIED' | 'REJECTED';
  responseRate: number;
  pinned: boolean;
}

const BROKERS: SeedBroker[] = [
  {
    id: 'brk-moussa',
    kind: 'INDIVIDUAL',
    name: 'Moussa Ndiaye',
    phone: '+221771234567',
    whatsapp: '+221771234567',
    latitude: 14.6712,
    longitude: -17.4395,
    coverage: ['Plateau', 'Médina', 'Fann'],
    verification: 'VERIFIED',
    responseRate: 0.92,
    pinned: false,
  },
  {
    id: 'brk-teranga',
    kind: 'AGENCY',
    name: 'Agence Teranga Immo',
    phone: '+221338211234',
    whatsapp: '+221771112233',
    latitude: 14.6935,
    longitude: -17.457,
    coverage: ['Sacré-Cœur', 'Mermoz', 'Point E'],
    verification: 'VERIFIED',
    responseRate: 0.78,
    pinned: true,
  },
  {
    // No WhatsApp: the button must disappear, not sit there dead.
    id: 'brk-fatou',
    kind: 'INDIVIDUAL',
    name: 'Fatou Sarr',
    phone: '+221775558899',
    whatsapp: null,
    latitude: 14.6805,
    longitude: -17.4462,
    coverage: ['Grand Dakar', 'Liberté 6'],
    verification: 'VERIFIED',
    responseRate: 0.61,
    pinned: false,
  },
  {
    // Unverified: the badge must not appear.
    id: 'brk-ibrahima',
    kind: 'INDIVIDUAL',
    name: 'Ibrahima Diop',
    phone: '+221776667788',
    whatsapp: '+221776667788',
    latitude: 14.7448,
    longitude: -17.5098,
    coverage: ['Almadies', 'Ngor', 'Yoff'],
    verification: 'NONE',
    responseRate: 0.35,
    pinned: false,
  },
  {
    id: 'brk-awa',
    kind: 'INDIVIDUAL',
    name: 'Awa Bâ',
    phone: '+221773334455',
    whatsapp: '+221773334455',
    latitude: 14.7691,
    longitude: -17.392,
    coverage: ['Parcelles Assainies', 'Yoff'],
    verification: 'PENDING',
    responseRate: 0.5,
    pinned: false,
  },
  {
    id: 'brk-keur-massar',
    kind: 'AGENCY',
    name: 'Keur Massar Habitat',
    phone: '+221338990011',
    whatsapp: null,
    latitude: 14.781,
    longitude: -17.316,
    coverage: ['Keur Massar', 'Yeumbeul'],
    verification: 'VERIFIED',
    responseRate: 0.44,
    pinned: false,
  },
];

// ---------------------------------------------------------------------------
// Properties — DemoSeed.properties()
// ---------------------------------------------------------------------------

interface SeedProperty {
  id: string;
  brokerId: string;
  kind: 'APARTMENT' | 'HOUSE' | 'LAND' | 'STUDIO' | 'ROOM';
  transaction: 'RENT' | 'SALE';
  title: string;
  description: string;
  price: number;
  surface: number | null;
  rooms: number | null;
  latitude: number;
  longitude: number;
  neighbourhood: string;
  photoAssets: string[];
  status: 'AVAILABLE' | 'RESERVED' | 'CLOSED';
  createdAt: Date;
}

const PROPERTIES: SeedProperty[] = [
  {
    id: 'prp-001',
    brokerId: 'brk-moussa',
    kind: 'HOUSE',
    transaction: 'RENT',
    title: 'Maison 4 pièces à Médina',
    description: 'Maison familiale avec cour, proche du marché.',
    price: 350000,
    surface: 120,
    rooms: 4,
    latitude: 14.679,
    longitude: -17.451,
    neighbourhood: 'Médina',
    photoAssets: ['demo:house:medina:front', 'demo:room:medina:cour', 'demo:house:medina:street'],
    status: 'AVAILABLE',
    createdAt: daysAgo(4),
  },
  {
    id: 'prp-002',
    brokerId: 'brk-moussa',
    kind: 'STUDIO',
    transaction: 'RENT',
    title: 'Studio meublé au Plateau',
    description: '',
    price: 180000,
    surface: 32,
    rooms: 1,
    latitude: 14.6668,
    longitude: -17.4342,
    neighbourhood: 'Plateau',
    photoAssets: ['demo:studio:plateau:room', 'demo:studio:plateau:kitchen'],
    status: 'RESERVED',
    createdAt: daysAgo(9),
  },
  {
    id: 'prp-003',
    brokerId: 'brk-teranga',
    kind: 'APARTMENT',
    transaction: 'RENT',
    title: 'Appartement 3 pièces à Mermoz',
    description: 'Deuxième étage, balcon, eau et courant réguliers.',
    price: 425000,
    surface: 85,
    rooms: 3,
    latitude: 14.6952,
    longitude: -17.4611,
    neighbourhood: 'Mermoz',
    photoAssets: ['demo:apartment:mermoz:balcony', 'demo:room:mermoz:salon', 'demo:apartment:mermoz:street'],
    status: 'AVAILABLE',
    createdAt: daysAgo(2),
  },
  {
    id: 'prp-004',
    brokerId: 'brk-teranga',
    kind: 'APARTMENT',
    transaction: 'SALE',
    title: 'Appartement à vendre, Point E',
    description: '',
    price: 78000000,
    surface: 110,
    rooms: 4,
    latitude: 14.6889,
    longitude: -17.464,
    neighbourhood: 'Point E',
    photoAssets: ['demo:apartment:pointe:front', 'demo:room:pointe:salon'],
    status: 'AVAILABLE',
    createdAt: daysAgo(21),
  },
  {
    id: 'prp-005',
    brokerId: 'brk-fatou',
    kind: 'ROOM',
    transaction: 'RENT',
    title: 'Chambre à Grand Dakar',
    description: '',
    price: 75000,
    surface: 16,
    rooms: 1,
    latitude: 14.6821,
    longitude: -17.4455,
    neighbourhood: 'Grand Dakar',
    photoAssets: ['demo:room:grand-dakar:bed', 'demo:room:grand-dakar:window'],
    status: 'AVAILABLE',
    createdAt: daysAgo(1),
  },
  {
    // Already rented: must drop out of discovery.
    id: 'prp-006',
    brokerId: 'brk-fatou',
    kind: 'HOUSE',
    transaction: 'RENT',
    title: 'Maison 3 pièces à Liberté 6',
    description: '',
    price: 300000,
    surface: 95,
    rooms: 3,
    latitude: 14.7115,
    longitude: -17.4602,
    neighbourhood: 'Liberté 6',
    photoAssets: ['demo:house:liberte:front', 'demo:room:liberte:salon'],
    status: 'CLOSED',
    createdAt: daysAgo(30),
  },
  {
    id: 'prp-007',
    brokerId: 'brk-ibrahima',
    kind: 'APARTMENT',
    transaction: 'RENT',
    title: 'Appartement vue mer, Ngor',
    description: '',
    price: 900000,
    surface: 140,
    rooms: 4,
    latitude: 14.75,
    longitude: -17.514,
    neighbourhood: 'Ngor',
    photoAssets: ['demo:apartment:ngor:coast', 'demo:room:ngor:salon', 'demo:apartment:ngor:balcony'],
    status: 'AVAILABLE',
    createdAt: daysAgo(6),
  },
  {
    id: 'prp-008',
    brokerId: 'brk-awa',
    kind: 'LAND',
    transaction: 'SALE',
    title: 'Terrain 300 m² aux Parcelles',
    description: '',
    price: 22000000,
    surface: 300,
    rooms: null,
    latitude: 14.7702,
    longitude: -17.3955,
    neighbourhood: 'Parcelles Assainies',
    photoAssets: ['demo:land:parcelles:plot', 'demo:land:parcelles:road'],
    status: 'AVAILABLE',
    createdAt: daysAgo(14),
  },
  {
    id: 'prp-009',
    brokerId: 'brk-keur-massar',
    kind: 'LAND',
    transaction: 'SALE',
    title: 'Terrain 200 m² à Keur Massar',
    description: '',
    price: 9500000,
    surface: 200,
    rooms: null,
    latitude: 14.7822,
    longitude: -17.3188,
    neighbourhood: 'Keur Massar',
    photoAssets: ['demo:land:keur-massar:plot', 'demo:land:keur-massar:access'],
    status: 'AVAILABLE',
    createdAt: daysAgo(11),
  },
  {
    id: 'prp-010',
    brokerId: 'brk-keur-massar',
    kind: 'HOUSE',
    transaction: 'SALE',
    title: 'Maison inachevée à Yeumbeul',
    description: '',
    price: 31000000,
    surface: 150,
    rooms: 5,
    latitude: 14.776,
    longitude: -17.34,
    neighbourhood: 'Yeumbeul',
    photoAssets: ['demo:house:yeumbeul:unfinished', 'demo:land:yeumbeul:yard'],
    status: 'AVAILABLE',
    createdAt: daysAgo(45),
  },
];

// ---------------------------------------------------------------------------
// Contacts and reviews
// ---------------------------------------------------------------------------

interface SeedContact {
  id: string;
  brokerId: string;
  clientId: string;
  propertyId: string | null;
  channel: 'CALL' | 'SMS' | 'WHATSAPP' | 'VOICE_MESSAGE';
  outcome: 'ATTEMPTED' | 'REACHED' | 'NO_ANSWER';
  createdAt: Date;
}

interface SeedReview {
  id: string;
  brokerId: string;
  contactId: string;
  authorId: string;
  rating: number;
  responsiveness: number | null;
  accuracy: number | null;
  courtesy: number | null;
  comment: string | null;
  moderation: 'PENDING' | 'PUBLISHED' | 'REJECTED';
  brokerReply: string | null;
  createdAt: Date;
}

/// DemoSeed.contacts() — the four the demo client owns and the app displays.
const CLIENT_CONTACTS: SeedContact[] = [
  {
    id: 'ctc-001',
    brokerId: 'brk-moussa',
    clientId: DEMO_CLIENT,
    propertyId: 'prp-001',
    channel: 'CALL',
    outcome: 'REACHED',
    createdAt: daysAgo(12),
  },
  // Reached, no review yet: this is the row that opens C05.
  {
    id: 'ctc-002',
    brokerId: 'brk-teranga',
    clientId: DEMO_CLIENT,
    propertyId: 'prp-003',
    channel: 'WHATSAPP',
    outcome: 'REACHED',
    createdAt: daysAgo(3),
  },
  // No answer: the log stays, the review does not open.
  {
    id: 'ctc-003',
    brokerId: 'brk-ibrahima',
    clientId: DEMO_CLIENT,
    propertyId: null,
    channel: 'CALL',
    outcome: 'NO_ANSWER',
    createdAt: daysAgo(2),
  },
  // Channel opened, outcome not declared yet.
  {
    id: 'ctc-004',
    brokerId: 'brk-fatou',
    clientId: DEMO_CLIENT,
    propertyId: 'prp-005',
    channel: 'SMS',
    outcome: 'ATTEMPTED',
    createdAt: daysAgo(1),
  },
];

/// DemoSeed.reviews(), each paired with the contact it requires. rev-001 rides
/// on the real ctc-001; the rest get a derived contact (see the header).
const REVIEWS: SeedReview[] = [
  {
    id: 'rev-001',
    brokerId: 'brk-moussa',
    contactId: 'ctc-001',
    authorId: DEMO_CLIENT,
    rating: 5,
    responsiveness: 5,
    accuracy: 5,
    courtesy: 5,
    comment: 'Très rapide, les informations correspondaient à la visite.',
    moderation: 'PUBLISHED',
    brokerReply: null,
    createdAt: daysAgo(11),
  },
  {
    id: 'rev-002',
    brokerId: 'brk-moussa',
    contactId: 'ctc-900',
    authorId: 'usr-reviewer-01',
    rating: 4,
    responsiveness: 4,
    accuracy: 4,
    courtesy: 5,
    comment: null,
    moderation: 'PUBLISHED',
    brokerReply: null,
    createdAt: daysAgo(25),
  },
  {
    id: 'rev-003',
    brokerId: 'brk-moussa',
    contactId: 'ctc-901',
    authorId: 'usr-reviewer-02',
    rating: 5,
    responsiveness: null,
    accuracy: null,
    courtesy: null,
    comment: null,
    moderation: 'PUBLISHED',
    brokerReply: null,
    createdAt: daysAgo(40),
  },
  {
    id: 'rev-004',
    brokerId: 'brk-teranga',
    contactId: 'ctc-902',
    authorId: 'usr-reviewer-03',
    rating: 4,
    responsiveness: null,
    accuracy: null,
    courtesy: null,
    comment: 'Bon accueil, un peu lent pour rappeler.',
    moderation: 'PUBLISHED',
    brokerReply: 'Merci, nous renforçons notre équipe téléphonique.',
    createdAt: daysAgo(8),
  },
  {
    id: 'rev-005',
    brokerId: 'brk-teranga',
    contactId: 'ctc-903',
    authorId: 'usr-reviewer-04',
    rating: 3,
    responsiveness: null,
    accuracy: null,
    courtesy: null,
    comment: null,
    moderation: 'PUBLISHED',
    brokerReply: null,
    createdAt: daysAgo(33),
  },
  {
    id: 'rev-006',
    brokerId: 'brk-fatou',
    contactId: 'ctc-904',
    authorId: 'usr-reviewer-05',
    rating: 5,
    responsiveness: null,
    accuracy: null,
    courtesy: null,
    comment: 'Elle connaît très bien le quartier.',
    moderation: 'PUBLISHED',
    brokerReply: null,
    createdAt: daysAgo(5),
  },
  {
    // In moderation: invisible to clients, visible to the broker. This is what
    // makes brk-fatou report reviewCount 1 rather than 2 in /search/brokers.
    id: 'rev-007',
    brokerId: 'brk-fatou',
    contactId: 'ctc-905',
    authorId: 'usr-reviewer-06',
    rating: 2,
    responsiveness: null,
    accuracy: null,
    courtesy: null,
    comment: "Le prix annoncé n'était pas le bon.",
    moderation: 'PENDING',
    brokerReply: null,
    createdAt: daysAgo(1),
  },
  {
    // A single 5-star must not hoist Awa above established profiles — the
    // Bayesian term in ranking.sql.ts is what this row exercises.
    id: 'rev-008',
    brokerId: 'brk-awa',
    contactId: 'ctc-906',
    authorId: 'usr-reviewer-07',
    rating: 5,
    responsiveness: null,
    accuracy: null,
    courtesy: null,
    comment: null,
    moderation: 'PUBLISHED',
    brokerReply: null,
    createdAt: daysAgo(7),
  },
];

/// The contacts rev-002..rev-008 imply. Derived rather than hand-written so
/// they cannot drift out of agreement with the reviews they support.
const DERIVED_CONTACTS: SeedContact[] = REVIEWS.filter(
  (review) => review.contactId !== 'ctc-001',
).map((review) => ({
  id: review.contactId,
  brokerId: review.brokerId,
  clientId: review.authorId,
  propertyId: null,
  channel: 'CALL',
  outcome: 'REACHED',
  createdAt: new Date(review.createdAt.getTime() - 24 * 60 * 60 * 1000),
}));

const CONTACTS: SeedContact[] = [...CLIENT_CONTACTS, ...DERIVED_CONTACTS];

// ---------------------------------------------------------------------------
// Invariants
// ---------------------------------------------------------------------------

/// These are the rules ReviewsService.create() enforces at runtime. If the
/// seed cannot satisfy them, the seed is wrong — not the rule. Checked before
/// any write so a bad edit fails loudly instead of landing half a dataset.
function assertInvariants(): void {
  const contactsById = new Map(CONTACTS.map((contact) => [contact.id, contact]));
  const brokerIds = new Set(BROKERS.map((broker) => broker.id));
  const userIds = new Set(USERS.map((user) => user.id));

  for (const broker of BROKERS) {
    if (!BROKER_OWNERS[broker.id]) {
      throw new Error(`Broker ${broker.id} has no owner user`);
    }
  }
  for (const property of PROPERTIES) {
    if (!brokerIds.has(property.brokerId)) {
      throw new Error(`Property ${property.id} references unknown broker ${property.brokerId}`);
    }
  }
  for (const contact of CONTACTS) {
    if (!brokerIds.has(contact.brokerId)) {
      throw new Error(`Contact ${contact.id} references unknown broker ${contact.brokerId}`);
    }
    if (!userIds.has(contact.clientId)) {
      throw new Error(`Contact ${contact.id} references unknown user ${contact.clientId}`);
    }
  }
  for (const review of REVIEWS) {
    const contact = contactsById.get(review.contactId);
    if (!contact) {
      throw new Error(`Review ${review.id} references missing contact ${review.contactId}`);
    }
    if (contact.brokerId !== review.brokerId) {
      throw new Error(`Review ${review.id} broker ${review.brokerId} != contact broker ${contact.brokerId}`);
    }
    if (contact.clientId !== review.authorId) {
      throw new Error(`Review ${review.id} author ${review.authorId} != contact client ${contact.clientId}`);
    }
    if (contact.outcome !== 'REACHED') {
      throw new Error(`Review ${review.id} sits on contact ${contact.id} with outcome ${contact.outcome}`);
    }
  }

  const emails = USERS.map((user) => user.email);
  if (new Set(emails).size !== emails.length) {
    throw new Error('Duplicate user email in seed');
  }
}

// ---------------------------------------------------------------------------
// Writes
// ---------------------------------------------------------------------------

/// Schema our tables live in. This deployment shares a Postgres instance with
/// an unrelated project whose tables sit in `public`, so TRUNCATE must never
/// be left to resolve through search_path — an unqualified name that misses in
/// our schema would fall through and truncate someone else's table.
const SCHEMA = (() => {
  const match = /[?&]schema=([^&]+)/.exec(process.env.DATABASE_URL ?? '');
  return match ? decodeURIComponent(match[1]) : 'public';
})();

async function reset(): Promise<void> {
  if (!/^[a-z_][a-z0-9_]*$/i.test(SCHEMA)) {
    throw new Error(`Refusing to truncate: schema name ${SCHEMA} is not a plain identifier`);
  }
  const qualified = ['reviews', 'contact_logs', 'property_photos', 'properties', 'brokers', 'users']
    .map((table) => `"${SCHEMA}"."${table}"`)
    .join(', ');
  // FK-safe via CASCADE. property_photos is included so a reset does not
  // strand uploaded bytes behind a deleted property.
  await prisma.$executeRawUnsafe(`TRUNCATE TABLE ${qualified} CASCADE`);
  console.log(`SEED_RESET: truncated ${qualified}`);
}

async function seed(): Promise<void> {
  assertInvariants();

  await prisma.$transaction(
    async (tx) => {
      for (const user of USERS) {
        await tx.user.upsert({
          where: { id: user.id },
          update: { email: user.email, activeRole: user.role, googleSub: user.googleSub ?? null },
          create: {
            id: user.id,
            email: user.email,
            activeRole: user.role,
            googleSub: user.googleSub ?? null,
            createdAt: REFERENCE,
          },
        });
      }

      for (const broker of BROKERS) {
        // Raw because `position` is Unsupported("geography(...)"), and raw
        // means supplying updatedAt by hand: Prisma's @updatedAt is
        // client-side only and the column has no SQL default.
        await tx.$executeRaw(Prisma.sql`
          INSERT INTO "brokers" (
            "id", "ownerId", "kind", "name", "phone", "whatsapp", "position", "coverage",
            "logoAsset", "verification", "responseRate", "pinned", "createdAt", "updatedAt"
          ) VALUES (
            ${broker.id}, ${BROKER_OWNERS[broker.id]}, ${broker.kind}::"BrokerKind",
            ${broker.name}, ${broker.phone}, ${broker.whatsapp},
            ${geographyPoint(broker.latitude, broker.longitude)}, ${textArray(broker.coverage)},
            NULL, ${broker.verification}::"VerificationStatus", ${broker.responseRate},
            ${broker.pinned}, ${ts(REFERENCE)}, now()
          )
          ON CONFLICT ("id") DO UPDATE SET
            "kind" = EXCLUDED."kind", "name" = EXCLUDED."name", "phone" = EXCLUDED."phone",
            "whatsapp" = EXCLUDED."whatsapp", "position" = EXCLUDED."position",
            "coverage" = EXCLUDED."coverage", "verification" = EXCLUDED."verification",
            "responseRate" = EXCLUDED."responseRate", "pinned" = EXCLUDED."pinned",
            "updatedAt" = now()
        `);
      }

      for (const property of PROPERTIES) {
        await tx.$executeRaw(Prisma.sql`
          INSERT INTO "properties" (
            "id", "brokerId", "kind", "transaction", "title", "description", "price",
            "surface", "rooms", "position", "neighbourhood", "photoAssets", "status",
            "createdAt", "updatedAt"
          ) VALUES (
            ${property.id}, ${property.brokerId}, ${property.kind}::"PropertyKind",
            ${property.transaction}::"TransactionKind", ${property.title}, ${property.description},
            ${property.price}, ${property.surface}, ${property.rooms},
            ${geographyPoint(property.latitude, property.longitude)}, ${property.neighbourhood},
            ${textArray(property.photoAssets)}, ${property.status}::"PropertyStatus",
            ${ts(property.createdAt)}, now()
          )
          ON CONFLICT ("id") DO UPDATE SET
            "brokerId" = EXCLUDED."brokerId", "kind" = EXCLUDED."kind",
            "transaction" = EXCLUDED."transaction", "title" = EXCLUDED."title",
            "description" = EXCLUDED."description", "price" = EXCLUDED."price",
            "surface" = EXCLUDED."surface", "rooms" = EXCLUDED."rooms",
            "position" = EXCLUDED."position", "neighbourhood" = EXCLUDED."neighbourhood",
            "photoAssets" = EXCLUDED."photoAssets", "status" = EXCLUDED."status",
            "createdAt" = EXCLUDED."createdAt", "updatedAt" = now()
        `);
      }

      for (const contact of CONTACTS) {
        await tx.contactLog.upsert({
          where: { id: contact.id },
          update: {
            brokerId: contact.brokerId,
            clientId: contact.clientId,
            propertyId: contact.propertyId,
            channel: contact.channel,
            outcome: contact.outcome,
            createdAt: contact.createdAt,
          },
          create: {
            id: contact.id,
            brokerId: contact.brokerId,
            clientId: contact.clientId,
            propertyId: contact.propertyId,
            channel: contact.channel,
            outcome: contact.outcome,
            createdAt: contact.createdAt,
          },
        });
      }

      for (const review of REVIEWS) {
        await tx.review.upsert({
          where: { id: review.id },
          update: {
            brokerId: review.brokerId,
            contactId: review.contactId,
            authorId: review.authorId,
            rating: review.rating,
            responsiveness: review.responsiveness,
            accuracy: review.accuracy,
            courtesy: review.courtesy,
            comment: review.comment,
            moderation: review.moderation,
            brokerReply: review.brokerReply,
            createdAt: review.createdAt,
          },
          create: {
            id: review.id,
            brokerId: review.brokerId,
            contactId: review.contactId,
            authorId: review.authorId,
            rating: review.rating,
            responsiveness: review.responsiveness,
            accuracy: review.accuracy,
            courtesy: review.courtesy,
            comment: review.comment,
            moderation: review.moderation,
            brokerReply: review.brokerReply,
            createdAt: review.createdAt,
          },
        });
      }
    },
    // The default interactive-transaction timeout is 5 s, which a few dozen
    // round trips to a remote database can exceed.
    { maxWait: 15_000, timeout: 120_000 },
  );
}

async function report(): Promise<void> {
  const [users, brokers, properties, contacts, reviews, photos] = await Promise.all([
    prisma.user.count(),
    prisma.broker.count(),
    prisma.property.count(),
    prisma.contactLog.count(),
    prisma.review.count(),
    prisma.propertyPhoto.count(),
  ]);
  console.log(
    `seeded: users=${users} brokers=${brokers} properties=${properties} ` +
      `contacts=${contacts} reviews=${reviews} property_photos=${photos}`,
  );
  console.log(`expected after a clean run: users=14 brokers=6 properties=10 contacts=11 reviews=8`);

  // Photo bytes live in Postgres on this deployment (no object storage on the
  // free tier). Printed every run so the growth stays visible rather than
  // quietly eating a 1 GB database.
  const [size] = await prisma.$queryRaw<{ total: string }[]>`
    SELECT pg_size_pretty(pg_total_relation_size('property_photos')) AS total
  `;
  console.log(`property_photos on-disk size: ${size?.total ?? 'unknown'}`);
}

async function main(): Promise<void> {
  const url = process.env.DATABASE_URL ?? '';
  console.log(`seeding ${url.replace(/\/\/[^@]*@/, '//***@') || '(DATABASE_URL unset)'}`);

  if (process.env.SEED_RESET === 'true') {
    await reset();
  }
  await seed();
  await report();
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
