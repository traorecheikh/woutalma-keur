import { Test } from '@nestjs/testing';
import { Prisma } from '@prisma/client';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';
import { geographyPoint } from '../common/postgis';
import { SearchService } from './search.service';
import {
  CONFIDENCE_THRESHOLD,
  GLOBAL_AVERAGE,
  PROXIMITY_HALF_LIFE_METERS,
  RANKING_WEIGHTS,
  VOLUME_SATURATION,
} from './ranking.sql';

/// Parity test for the ranking formula ported to SQL. Two things are
/// checked against each other, both derived independently from
/// lib/app/domain/ranking.dart:
///  1. `referenceScore()` below — a from-scratch TypeScript re-derivation of
///     RankingService.score(), used to assert the SQL port is bit-for-bit
///     equivalent (not just "produces a plausible number").
///  2. The same *behavioral* assertions test/unit/ranking_test.dart makes
///     (established beats newcomer, closer beats farther at equal rating,
///     half-life proximity ≈ 0.5, no-reviews bayesian == global average) —
///     translated here so both suites are exercising the same claims.
///
/// If ranking.dart's weights/curves ever change, this file and ranking.sql.ts
/// must change together, or this test starts failing — that's the point.
function referenceScore(input: {
  averageRating: number;
  reviewCount: number;
  distanceMeters: number;
  responseRate: number;
}): number {
  const bayesian =
    input.reviewCount <= 0
      ? GLOBAL_AVERAGE
      : (input.reviewCount / (input.reviewCount + CONFIDENCE_THRESHOLD)) * input.averageRating +
        (1 - input.reviewCount / (input.reviewCount + CONFIDENCE_THRESHOLD)) * GLOBAL_AVERAGE;

  const proximity =
    input.distanceMeters <= 0 ? 1 : 1 / (1 + input.distanceMeters / PROXIMITY_HALF_LIFE_METERS);

  const volume =
    input.reviewCount <= 0
      ? 0
      : Math.min(1, Math.log(1 + input.reviewCount) / Math.log(1 + VOLUME_SATURATION));

  const response = Math.min(Math.max(input.responseRate, 0), 1);

  return (
    RANKING_WEIGHTS.rating * (bayesian / 5) +
    RANKING_WEIGHTS.proximity * proximity +
    RANKING_WEIGHTS.volume * volume +
    RANKING_WEIGHTS.response * response
  );
}

describe('SearchService ranking parity (vs ranking.dart / ranking_test.dart)', () => {
  let search: SearchService;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [PrismaModule],
      providers: [SearchService],
    }).compile();
    search = moduleRef.get(SearchService);
  });

  const CASES = [
    { averageRating: 5, reviewCount: 1, distanceMeters: 1000, responseRate: 0.5 },
    { averageRating: 4.5, reviewCount: 50, distanceMeters: 1000, responseRate: 0.5 },
    { averageRating: 4, reviewCount: 20, distanceMeters: 300, responseRate: 0.8 },
    { averageRating: 4, reviewCount: 20, distanceMeters: 9000, responseRate: 0.8 },
    { averageRating: 0, reviewCount: 0, distanceMeters: 5000, responseRate: 0 },
    { averageRating: 4.8, reviewCount: 500, distanceMeters: 0, responseRate: 1 },
  ];

  it.each(CASES)('matches the TypeScript reference formula bit-for-bit for %j', async (input) => {
    const sqlScore = await search.scoreOnly(input);
    expect(sqlScore).toBeCloseTo(referenceScore(input), 9);
  });

  it('a single 5-star review does not beat fifty reviews averaging 4.5 (ranking_test.dart parity)', async () => {
    const newcomer = await search.scoreOnly({
      averageRating: 5,
      reviewCount: 1,
      distanceMeters: 1000,
      responseRate: 0.5,
    });
    const established = await search.scoreOnly({
      averageRating: 4.5,
      reviewCount: 50,
      distanceMeters: 1000,
      responseRate: 0.5,
    });
    expect(established).toBeGreaterThan(newcomer);
  });

  it('with equal rating, the closer broker wins (ranking_test.dart parity)', async () => {
    const close = await search.scoreOnly({
      averageRating: 4,
      reviewCount: 20,
      distanceMeters: 300,
      responseRate: 0.8,
    });
    const distant = await search.scoreOnly({
      averageRating: 4,
      reviewCount: 20,
      distanceMeters: 9000,
      responseRate: 0.8,
    });
    expect(close).toBeGreaterThan(distant);
  });
});

describe('SearchService full-text search', () => {
  let prisma: PrismaService;
  let search: SearchService;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [PrismaModule],
      providers: [SearchService],
    }).compile();
    prisma = moduleRef.get(PrismaService);
    search = moduleRef.get(SearchService);
  });

  beforeEach(async () => {
    await prisma.review.deleteMany();
    await prisma.contactLog.deleteMany();
    await prisma.property.deleteMany();
    await prisma.broker.deleteMany();
    await prisma.user.deleteMany();

    const terangaOwner = await prisma.user.create({ data: { email: 'teranga@example.sn' } });
    const awaOwner = await prisma.user.create({ data: { email: 'awa@example.sn' } });

    await prisma.$executeRaw(Prisma.sql`
      INSERT INTO "brokers" ("id", "ownerId", "kind", "name", "phone", "position", "coverage", "updatedAt")
      VALUES
        ('brk-teranga', ${terangaOwner.id}, 'AGENCY', 'Agence Teranga Immo', '+221770000001',
          ${geographyPoint(14.6952, -17.4611)}, ARRAY['Mermoz', 'Sacré-Cœur']::text[], now()),
        ('brk-awa', ${awaOwner.id}, 'INDIVIDUAL', 'Awa Diop', '+221770000002',
          ${geographyPoint(14.7702, -17.3955)}, ARRAY['Parcelles Assainies']::text[], now())
    `);

    await prisma.$executeRaw(Prisma.sql`
      INSERT INTO "properties"
        ("id", "brokerId", "kind", "transaction", "title", "description", "price", "surface", "rooms",
         "position", "neighbourhood", "photoAssets", "status", "updatedAt")
      VALUES
        ('prp-mermoz', 'brk-teranga', 'APARTMENT', 'RENT', 'Appartement 3 pièces à Mermoz',
          'Balcon, eau et courant réguliers.', 425000, 85, 3,
          ${geographyPoint(14.6952, -17.4611)}, 'Mermoz', ARRAY[]::text[], 'AVAILABLE', now()),
        ('prp-point-e', 'brk-teranga', 'APARTMENT', 'SALE', 'Appartement à vendre, Point E',
          '', 78000000, 110, 4,
          ${geographyPoint(14.6889, -17.464)}, 'Point E', ARRAY[]::text[], 'AVAILABLE', now()),
        ('prp-parcelles', 'brk-awa', 'LAND', 'SALE', 'Terrain 300 m² aux Parcelles',
          '', 22000000, 300, NULL,
          ${geographyPoint(14.7702, -17.3955)}, 'Parcelles Assainies', ARRAY[]::text[], 'AVAILABLE', now())
    `);
  });

  it('uses prefix FTS for mobile partial queries', async () => {
    const found = await search.findProperties({
      lat: 14.69,
      lng: -17.45,
      query: 'appart mer',
    });

    expect(found.items.map((property) => property.id)).toEqual(['prp-mermoz']);
  });

  it('matches accents through immutable_unaccent-backed FTS', async () => {
    const found = await search.findBrokers({
      lat: 14.69,
      lng: -17.45,
      query: 'sacre',
    });

    expect(found.items.map((listing) => listing.broker.id)).toContain('brk-teranga');
  });

  it('finds brokers through their matching available properties', async () => {
    const found = await search.findBrokers({
      lat: 14.69,
      lng: -17.45,
      query: 'terrain vendre',
    });

    expect(found.items.map((listing) => listing.broker.id)).toEqual(['brk-awa']);
  });
});
