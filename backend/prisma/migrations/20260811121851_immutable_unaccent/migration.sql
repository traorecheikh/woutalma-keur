-- unaccent() is STABLE, not IMMUTABLE, so Postgres refuses to use it inside
-- a functional/generated expression. This wrapper is the standard fix,
-- backing text-match.sql.ts's tsvector-based search (to_tsvector needs an
-- IMMUTABLE input expression).
CREATE OR REPLACE FUNCTION immutable_unaccent(value text)
RETURNS text AS
$$
  SELECT public.unaccent('public.unaccent', value)
$$ LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT;
