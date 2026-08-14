-- CreateExtension
-- Pinned to public so the `public.unaccent` references in the FTS migrations
-- resolve regardless of which schema the app's own tables live in.
CREATE EXTENSION IF NOT EXISTS "unaccent" WITH SCHEMA public;

