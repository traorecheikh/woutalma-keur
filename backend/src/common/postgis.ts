import { Prisma } from '@prisma/client';

/// Prisma's client can't read or write `Unsupported("geography(...)")`
/// columns through its normal query builder — every path that touches
/// `position` goes through `$queryRaw`/`$executeRaw` instead. These helpers
/// keep that raw SQL consistent and injection-safe (values are bound through
/// `Prisma.sql`, never string-concatenated).
///
/// Every PostGIS name is schema-qualified. Prisma pins the connection's
/// `search_path` to the single schema given by the `schema=` URL parameter and
/// ignores any `options=-c search_path=...` you try to pass alongside it, so
/// an unqualified `ST_MakePoint` or `::geography` only resolves when the app
/// happens to own `public`. Qualifying costs nothing in a plain deployment
/// (PostGIS installs into `public` there too) and is what lets these tables
/// live in a schema of their own on a shared instance.
const PG = 'public';

/// SQL fragment constructing a geography point from separate lat/lng
/// parameters, for use inside an INSERT/UPDATE's VALUES/SET clause.
export function geographyPoint(latitude: number, longitude: number): Prisma.Sql {
  return Prisma.sql`${Prisma.raw(PG)}.ST_SetSRID(${Prisma.raw(PG)}.ST_MakePoint(${longitude}, ${latitude}), 4326)::${Prisma.raw(PG)}.geography`;
}

/// SQL fragment re-projecting a geography column back to
/// `{ latitude, longitude }` in a SELECT list. `columnRef` must be a raw
/// identifier fragment (e.g. `Prisma.raw('"position"')`), not a bound value.
export function selectLatLng(columnRef: Prisma.Sql): Prisma.Sql {
  return Prisma.sql`${Prisma.raw(PG)}.ST_Y(${columnRef}::${Prisma.raw(PG)}.geometry) AS latitude, ${Prisma.raw(PG)}.ST_X(${columnRef}::${Prisma.raw(PG)}.geometry) AS longitude`;
}

/// Great-circle distance in meters between a geography column and a given
/// point, matching `distanceMeters()` in lib/app/domain/ranking.dart —
/// PostGIS does this natively instead of the app-side haversine.
export function distanceMetersSql(columnRef: Prisma.Sql, latitude: number, longitude: number): Prisma.Sql {
  return Prisma.sql`${Prisma.raw(PG)}.ST_Distance(${columnRef}, ${geographyPoint(latitude, longitude)})`;
}
