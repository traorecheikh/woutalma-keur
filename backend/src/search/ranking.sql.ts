import { Prisma } from '@prisma/client';

/// SQL port of lib/app/domain/ranking.dart's RankingService. Constants and
/// formulas below MUST stay bit-for-bit identical to that file — parity is
/// asserted in search.service.spec.ts against the same fixtures
/// test/unit/ranking_test.dart already exercises on the Dart side. If one
/// side changes a weight or curve, change both, and re-run both test
/// suites — that's the actual seam-correctness proof for Phase 1.
export const RANKING_WEIGHTS = {
  rating: 0.45,
  proximity: 0.25,
  volume: 0.15,
  response: 0.15,
} as const;

export const CONFIDENCE_THRESHOLD = 5;
export const GLOBAL_AVERAGE = 3.5;
export const PROXIMITY_HALF_LIFE_METERS = 2000;
export const VOLUME_SATURATION = 50;

/// `avgRating`/`reviewCount`/`distanceMeters`/`responseRate` must each be a
/// `Prisma.Sql` fragment resolving to a numeric expression in the enclosing
/// query (a column, a CTE alias, or a computed sub-expression) — never a
/// bound value, so this composes inside a larger SELECT list.
export function rankingScoreSql(inputs: {
  avgRating: Prisma.Sql;
  reviewCount: Prisma.Sql;
  distanceMeters: Prisma.Sql;
  responseRate: Prisma.Sql;
}): Prisma.Sql {
  const bayesian = Prisma.sql`
    (CASE WHEN ${inputs.reviewCount} <= 0 THEN ${GLOBAL_AVERAGE}
     ELSE
       (${inputs.reviewCount}::float8 / (${inputs.reviewCount}::float8 + ${CONFIDENCE_THRESHOLD})) * ${inputs.avgRating}
       + (1 - (${inputs.reviewCount}::float8 / (${inputs.reviewCount}::float8 + ${CONFIDENCE_THRESHOLD}))) * ${GLOBAL_AVERAGE}
     END)`;

  const proximity = Prisma.sql`
    (CASE WHEN ${inputs.distanceMeters} <= 0 THEN 1
     ELSE 1 / (1 + ${inputs.distanceMeters} / ${PROXIMITY_HALF_LIFE_METERS}::float8)
     END)`;

  const volume = Prisma.sql`
    (CASE WHEN ${inputs.reviewCount} <= 0 THEN 0
     ELSE LEAST(1, ln(1 + ${inputs.reviewCount}::float8) / ln(1 + ${VOLUME_SATURATION}::float8))
     END)`;

  const response = Prisma.sql`LEAST(GREATEST(${inputs.responseRate}, 0), 1)`;

  return Prisma.sql`(
    ${RANKING_WEIGHTS.rating} * (${bayesian} / 5)
    + ${RANKING_WEIGHTS.proximity} * ${proximity}
    + ${RANKING_WEIGHTS.volume} * ${volume}
    + ${RANKING_WEIGHTS.response} * ${response}
  )`;
}
