import { Injectable } from '@nestjs/common';
import { Prisma, PropertyStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { distanceMetersSql, selectLatLng } from '../common/postgis';
import { mapBrokerRow, BrokerRow } from '../brokers/broker-row.mapper';
import { mapPropertyRow, PropertyRow } from '../properties/property-row.mapper';
import { SearchQueryDto } from './dto/search-query.dto';
import { rankingScoreSql } from './ranking.sql';
import { textSearchQuerySql, textSearchRankSql, textSearchVectorSql } from './text-match.sql';
import {
  BrokerSearchResultsDto,
  PropertySearchResultsDto,
  SearchSuggestionsDto,
} from './dto/search-results.dto';

@Injectable()
export class SearchService {
  constructor(private readonly prisma: PrismaService) {}

  /// Server-side port of DiscoveryService.findBrokers +
  /// RankingService.score/sort (lib/app/domain/discovery.dart,
  /// lib/app/domain/ranking.dart). See ranking.sql.ts for why the score
  /// formula must stay bit-for-bit identical to the Dart original.
  async findBrokers(filters: SearchQueryDto): Promise<BrokerSearchResultsDto> {
    const limit = filters.limit ?? 20;
    const offset = filters.offset ?? 0;
    const query = filters.query?.trim() || null;
    const hasQuery = query !== null && query.length > 0;
    const filtersProperties = !!(filters.transaction || filters.kind || filters.maxPrice);
    const propertyVector = propertySearchVectorSql();
    const brokerVector = brokerSearchVectorSql();
    const propertyRank = query ? textSearchRankSql(propertyVector, query) : Prisma.raw('0');
    const brokerRank = query ? textSearchRankSql(brokerVector, query) : Prisma.raw('0');

    const propertyFilterConditions = Prisma.sql`
      "status" != ${PropertyStatus.CLOSED}::"PropertyStatus"
      AND (${filters.transaction ?? null}::"TransactionKind" IS NULL OR "transaction" = ${filters.transaction ?? null}::"TransactionKind")
      AND (${filters.kind ?? null}::"PropertyKind" IS NULL OR "kind" = ${filters.kind ?? null}::"PropertyKind")
      AND (${filters.maxPrice ?? null}::int IS NULL OR "price" <= ${filters.maxPrice ?? null}::int)
      AND (${filters.radiusMeters ?? null}::float8 IS NULL
           OR ${distanceMetersSql(Prisma.raw('"position"'), filters.lat, filters.lng)} <= ${filters.radiusMeters ?? null}::float8)
      AND (${hasQuery ? Prisma.raw('false') : Prisma.raw('true')} OR ${propertyVector} @@ ${textSearchQuerySql(query ?? '')})
    `;

    const rows = await this.prisma.$queryRaw<
      (BrokerRow & {
        distanceMeters: number;
        averageRating: number;
        reviewCount: number;
        availableProperties: number;
        score: number;
      })[]
    >(Prisma.sql`
      WITH matching_properties AS (
        SELECT "brokerId", COUNT(*)::int AS property_count, MAX(${propertyRank})::float8 AS property_rank
        FROM "properties"
        WHERE ${propertyFilterConditions}
        GROUP BY "brokerId"
      ),
      broker_reviews AS (
        SELECT "brokerId",
               AVG("rating")::float8 AS average_rating,
               COUNT(*)::int AS review_count
        FROM "reviews"
        WHERE "moderation" = 'PUBLISHED'
        GROUP BY "brokerId"
      )
      SELECT
        b."id", b."kind", b."name", b."phone", b."whatsapp", b."coverage", b."logoAsset",
        b."verification", b."responseRate", b."pinned",
        ${selectLatLng(Prisma.raw('b."position"'))},
        ${distanceMetersSql(Prisma.raw('b."position"'), filters.lat, filters.lng)} AS "distanceMeters",
        COALESCE(br.average_rating, 0) AS "averageRating",
        COALESCE(br.review_count, 0) AS "reviewCount",
        COALESCE(mp.property_count, 0) AS "availableProperties",
        ${rankingScoreSql({
          avgRating: Prisma.raw('COALESCE(br.average_rating, 0)'),
          reviewCount: Prisma.raw('COALESCE(br.review_count, 0)'),
          distanceMeters: distanceMetersSql(Prisma.raw('b."position"'), filters.lat, filters.lng),
          responseRate: Prisma.raw('b."responseRate"'),
        })} + COALESCE(mp.property_rank, 0) + ${brokerRank} AS "score"
      FROM "brokers" b
      LEFT JOIN broker_reviews br ON br."brokerId" = b."id"
      LEFT JOIN matching_properties mp ON mp."brokerId" = b."id"
      WHERE
        (${filters.radiusMeters ?? null}::float8 IS NULL
         OR ${distanceMetersSql(Prisma.raw('b."position"'), filters.lat, filters.lng)} <= ${filters.radiusMeters ?? null}::float8)
        AND (${filtersProperties ? Prisma.raw('false') : Prisma.raw('true')} OR COALESCE(mp.property_count, 0) > 0)
        AND (${hasQuery ? Prisma.raw('false') : Prisma.raw('true')}
             OR ${brokerVector} @@ ${textSearchQuerySql(query ?? '')}
             OR COALESCE(mp.property_count, 0) > 0)
      ORDER BY b."pinned" DESC, "score" DESC, "distanceMeters" ASC, b."id" ASC
      LIMIT ${limit} OFFSET ${offset}
    `);

    return {
      items: rows.map((row) => ({
        broker: mapBrokerRow(row),
        distanceMeters: row.distanceMeters,
        averageRating: row.averageRating,
        reviewCount: row.reviewCount,
        availableProperties: row.availableProperties,
        score: row.score,
      })),
      totalCount: await this.countBrokers(filters),
      limit,
      offset,
    };
  }

  /// Server-side port of DiscoveryService.findProperties — filtered,
  /// distance-sorted, no ranking score (properties aren't scored, only
  /// brokers are).
  async findProperties(filters: SearchQueryDto): Promise<PropertySearchResultsDto> {
    const limit = filters.limit ?? 20;
    const offset = filters.offset ?? 0;
    const query = filters.query?.trim() || null;
    const hasQuery = query !== null && query.length > 0;
    const propertyVector = propertySearchVectorSql();
    const propertyRank = query ? textSearchRankSql(propertyVector, query) : Prisma.raw('0');

    const rows = await this.prisma.$queryRaw<(PropertyRow & { distance: number })[]>(Prisma.sql`
      SELECT
        "id", "brokerId", "kind", "transaction", "title", "description", "price",
        "surface", "rooms", "neighbourhood", "photoAssets", "voiceAsset", "status", "createdAt",
        ${selectLatLng(Prisma.raw('"position"'))},
        ${distanceMetersSql(Prisma.raw('"position"'), filters.lat, filters.lng)} AS "distance",
        ${propertyRank} AS "searchRank"
      FROM "properties"
      WHERE
        "status" != ${PropertyStatus.CLOSED}::"PropertyStatus"
        AND (${filters.transaction ?? null}::"TransactionKind" IS NULL OR "transaction" = ${filters.transaction ?? null}::"TransactionKind")
        AND (${filters.kind ?? null}::"PropertyKind" IS NULL OR "kind" = ${filters.kind ?? null}::"PropertyKind")
        AND (${filters.maxPrice ?? null}::int IS NULL OR "price" <= ${filters.maxPrice ?? null}::int)
        AND (${filters.radiusMeters ?? null}::float8 IS NULL
             OR ${distanceMetersSql(Prisma.raw('"position"'), filters.lat, filters.lng)} <= ${filters.radiusMeters ?? null}::float8)
        AND (${hasQuery ? Prisma.raw('false') : Prisma.raw('true')} OR ${propertyVector} @@ ${textSearchQuerySql(query ?? '')})
      ORDER BY "searchRank" DESC, "distance" ASC, "id" ASC
      LIMIT ${limit} OFFSET ${offset}
    `);

    return {
      items: rows.map(mapPropertyRow),
      totalCount: await this.countProperties(filters),
      limit,
      offset,
    };
  }

  async suggestions(filters: SearchQueryDto): Promise<SearchSuggestionsDto> {
    const query = filters.query?.trim();
    if (!query) return { items: [] };
    const limit = Math.min(filters.limit ?? 5, 10);
    const rows = await this.prisma.$queryRaw<{ label: string }[]>(Prisma.sql`
      WITH labels AS (
        SELECT "name" AS label FROM "brokers"
        UNION ALL SELECT unnest("coverage") FROM "brokers"
        UNION ALL SELECT "title" FROM "properties" WHERE "status" != 'CLOSED'::"PropertyStatus"
        UNION ALL SELECT "neighbourhood" FROM "properties" WHERE "status" != 'CLOSED'::"PropertyStatus"
      )
      SELECT DISTINCT "label"
      FROM labels
      WHERE immutable_unaccent("label") ILIKE immutable_unaccent(${query}) || '%'
      ORDER BY "label"
      LIMIT ${limit}
    `);
    return { items: rows.map((row) => row.label) };
  }

  private async countBrokers(filters: SearchQueryDto): Promise<number> {
    const result = await this.findBrokersCount(filters);
    return result;
  }

  private async findBrokersCount(filters: SearchQueryDto): Promise<number> {
    const query = filters.query?.trim() || null;
    const hasQuery = query !== null && query.length > 0;
    const filtersProperties = !!(filters.transaction || filters.kind || filters.maxPrice);
    const propertyVector = propertySearchVectorSql();
    const brokerVector = brokerSearchVectorSql();
    const propertyFilter = Prisma.sql`
      "status" != 'CLOSED'::"PropertyStatus"
      AND (${filters.transaction ?? null}::"TransactionKind" IS NULL OR "transaction" = ${filters.transaction ?? null}::"TransactionKind")
      AND (${filters.kind ?? null}::"PropertyKind" IS NULL OR "kind" = ${filters.kind ?? null}::"PropertyKind")
      AND (${filters.maxPrice ?? null}::int IS NULL OR "price" <= ${filters.maxPrice ?? null}::int)
      AND (${filters.radiusMeters ?? null}::float8 IS NULL OR ${distanceMetersSql(Prisma.raw('"position"'), filters.lat, filters.lng)} <= ${filters.radiusMeters ?? null}::float8)
      AND (${hasQuery ? Prisma.raw('false') : Prisma.raw('true')} OR ${propertyVector} @@ ${textSearchQuerySql(query ?? '')})`;
    const rows = await this.prisma.$queryRaw<{ count: bigint }[]>(Prisma.sql`
      WITH matching_properties AS (
        SELECT "brokerId", COUNT(*) AS property_count FROM "properties" WHERE ${propertyFilter} GROUP BY "brokerId"
      )
      SELECT COUNT(*)::bigint AS count FROM "brokers" b
      LEFT JOIN matching_properties mp ON mp."brokerId" = b."id"
      WHERE (${filters.radiusMeters ?? null}::float8 IS NULL OR ${distanceMetersSql(Prisma.raw('b."position"'), filters.lat, filters.lng)} <= ${filters.radiusMeters ?? null}::float8)
        AND (${filtersProperties ? Prisma.raw('false') : Prisma.raw('true')} OR COALESCE(mp.property_count, 0) > 0)
        AND (${hasQuery ? Prisma.raw('false') : Prisma.raw('true')} OR ${brokerVector} @@ ${textSearchQuerySql(query ?? '')} OR COALESCE(mp.property_count, 0) > 0)`);
    return Number(rows[0]?.count ?? 0);
  }

  private async countProperties(filters: SearchQueryDto): Promise<number> {
    const query = filters.query?.trim() || null;
    const hasQuery = query !== null && query.length > 0;
    const vector = propertySearchVectorSql();
    const rows = await this.prisma.$queryRaw<{ count: bigint }[]>(Prisma.sql`
      SELECT COUNT(*)::bigint AS count FROM "properties"
      WHERE "status" != 'CLOSED'::"PropertyStatus"
        AND (${filters.transaction ?? null}::"TransactionKind" IS NULL OR "transaction" = ${filters.transaction ?? null}::"TransactionKind")
        AND (${filters.kind ?? null}::"PropertyKind" IS NULL OR "kind" = ${filters.kind ?? null}::"PropertyKind")
        AND (${filters.maxPrice ?? null}::int IS NULL OR "price" <= ${filters.maxPrice ?? null}::int)
        AND (${filters.radiusMeters ?? null}::float8 IS NULL OR ${distanceMetersSql(Prisma.raw('"position"'), filters.lat, filters.lng)} <= ${filters.radiusMeters ?? null}::float8)
        AND (${hasQuery ? Prisma.raw('false') : Prisma.raw('true')} OR ${vector} @@ ${textSearchQuerySql(query ?? '')})`);
    return Number(rows[0]?.count ?? 0);
  }

  /// Exposed for search.service.spec.ts's parity test — computes the score
  /// alone, without a broker row, so it can replay ranking_test.dart's exact
  /// input/output fixtures.
  async scoreOnly(input: {
    averageRating: number;
    reviewCount: number;
    distanceMeters: number;
    responseRate: number;
  }): Promise<number> {
    const rows = await this.prisma.$queryRaw<{ score: number }[]>(Prisma.sql`
      SELECT ${rankingScoreSql({
        avgRating: Prisma.raw(input.averageRating.toString()),
        reviewCount: Prisma.raw(input.reviewCount.toString()),
        distanceMeters: Prisma.raw(input.distanceMeters.toString()),
        responseRate: Prisma.raw(input.responseRate.toString()),
      })} AS score
    `);
    return rows[0].score;
  }
}

function propertySearchVectorSql(): Prisma.Sql {
  return textSearchVectorSql([
    { value: Prisma.raw('"title"'), weight: 'A' },
    { value: Prisma.raw('"neighbourhood"'), weight: 'A' },
    { value: Prisma.raw('"description"'), weight: 'C' },
    { value: propertyKindLexemeSql(Prisma.raw('"kind"')), weight: 'B' },
    { value: transactionLexemeSql(Prisma.raw('"transaction"')), weight: 'B' },
  ]);
}

function brokerSearchVectorSql(): Prisma.Sql {
  return textSearchVectorSql([
    { value: Prisma.raw('b."name"'), weight: 'A' },
    { value: Prisma.sql`immutable_text_array_to_string(b."coverage")`, weight: 'A' },
  ]);
}

function propertyKindLexemeSql(kind: Prisma.Sql): Prisma.Sql {
  return Prisma.sql`CASE ${kind}
    WHEN 'APARTMENT'::"PropertyKind" THEN 'appartement appart'
    WHEN 'HOUSE'::"PropertyKind" THEN 'maison villa'
    WHEN 'LAND'::"PropertyKind" THEN 'terrain parcelle'
    WHEN 'STUDIO'::"PropertyKind" THEN 'studio'
    WHEN 'ROOM'::"PropertyKind" THEN 'chambre'
    ELSE ''
  END`;
}

function transactionLexemeSql(transaction: Prisma.Sql): Prisma.Sql {
  return Prisma.sql`CASE ${transaction}
    WHEN 'RENT'::"TransactionKind" THEN 'location louer loue'
    WHEN 'SALE'::"TransactionKind" THEN 'vente vendre acheter achat'
    ELSE ''
  END`;
}
