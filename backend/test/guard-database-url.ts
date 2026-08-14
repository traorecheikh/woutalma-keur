/**
 * Every *.spec.ts in this project talks to a real PostGIS database and begins
 * by deleting every row in all five tables. Pointed at a deployed database
 * that is not a test fixture, it is a data-loss event with no undo.
 *
 * Wired as a jest `setupFiles` entry so it runs before any test file is even
 * imported.
 */
const url = process.env.DATABASE_URL ?? '';

const REMOTE_HOST_PATTERNS = [/render\.com/i, /\.rds\.amazonaws\.com/i, /supabase\.co/i, /neon\.tech/i];

const offender = REMOTE_HOST_PATTERNS.find((pattern) => pattern.test(url));
if (offender) {
  throw new Error(
    `Refusing to run tests: DATABASE_URL points at a managed host (${offender}). ` +
      'These specs truncate every table. Run them against docker-compose Postgres on localhost:5433.',
  );
}
