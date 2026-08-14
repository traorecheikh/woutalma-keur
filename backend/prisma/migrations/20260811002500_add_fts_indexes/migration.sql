-- Full-text search support for /search.
--
-- Postgres marks unaccent(text) stable, so expression indexes cannot use it
-- directly. This wrapper is safe here because the extension dictionary is a
-- deployment constant for this app.
CREATE OR REPLACE FUNCTION immutable_unaccent(value text)
RETURNS text
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
  SELECT public.unaccent('public.unaccent', value)
$$;

CREATE OR REPLACE FUNCTION immutable_text_array_to_string(value text[])
RETURNS text
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
  SELECT array_to_string(value, ' ')
$$;

CREATE INDEX "properties_search_fts_idx" ON "properties" USING GIN (
  (
    setweight(to_tsvector('simple', immutable_unaccent(coalesce("title", ''))), 'A') ||
    setweight(to_tsvector('simple', immutable_unaccent(coalesce("neighbourhood", ''))), 'A') ||
    setweight(to_tsvector('simple', immutable_unaccent(coalesce("description", ''))), 'C') ||
    setweight(to_tsvector('simple', immutable_unaccent(
      CASE "kind"
        WHEN 'APARTMENT'::"PropertyKind" THEN 'appartement appart'
        WHEN 'HOUSE'::"PropertyKind" THEN 'maison villa'
        WHEN 'LAND'::"PropertyKind" THEN 'terrain parcelle'
        WHEN 'STUDIO'::"PropertyKind" THEN 'studio'
        WHEN 'ROOM'::"PropertyKind" THEN 'chambre'
        ELSE ''
      END
    )), 'B') ||
    setweight(to_tsvector('simple', immutable_unaccent(
      CASE "transaction"
        WHEN 'RENT'::"TransactionKind" THEN 'location louer loue'
        WHEN 'SALE'::"TransactionKind" THEN 'vente vendre acheter achat'
        ELSE ''
      END
    )), 'B')
  )
);

CREATE INDEX "brokers_search_fts_idx" ON "brokers" USING GIN (
  (
    setweight(to_tsvector('simple', immutable_unaccent(coalesce("name", ''))), 'A') ||
    setweight(to_tsvector('simple', immutable_unaccent(immutable_text_array_to_string("coverage"))), 'A')
  )
);
