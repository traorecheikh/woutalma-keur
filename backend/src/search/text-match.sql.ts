import { Prisma } from '@prisma/client';

type SearchWeight = 'A' | 'B' | 'C' | 'D';

export function textSearchVectorSql(fields: { value: Prisma.Sql; weight: SearchWeight }[]): Prisma.Sql {
  return fields.reduce(
    (vector, field, index) => Prisma.sql`
      ${index === 0 ? Prisma.empty : Prisma.sql`${vector} || `}
      setweight(
        to_tsvector('simple', immutable_unaccent(coalesce(${field.value}, ''))),
        ${field.weight}::"char"
      )
    `,
    Prisma.empty,
  );
}

/// Builds a prefix tsquery from user text: "appart mer" -> 'appart':* & 'mer':*.
/// `websearch_to_tsquery` is nicer for desktop syntax, but prefix tokens matter
/// more on mobile because users stop typing as soon as suggestions look right.
export function textSearchQuerySql(query: string): Prisma.Sql {
  return Prisma.sql`to_tsquery(
    'simple',
    (
      SELECT string_agg(quote_literal(token) || ':*', ' & ')
      FROM unnest(regexp_split_to_array(immutable_unaccent(lower(${query})), '[^[:alnum:]]+')) AS token
      WHERE length(token) > 1
    )
  )`;
}

export function textSearchRankSql(vector: Prisma.Sql, query: string): Prisma.Sql {
  const tsquery = textSearchQuerySql(query);
  return Prisma.sql`ts_rank_cd(${vector}, ${tsquery}, 32)`;
}
