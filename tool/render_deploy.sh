#!/usr/bin/env bash
# Bring-up of the Render deployment, step by step.
#
# render.yaml is the reviewable record of what runs; this script is what
# actually creates it. Render's REST API has no endpoint that instantiates a
# Blueprint (only GET /v1/blueprints exists), so the bring-up is imperative.
# Keep the two in sync.
#
# Not idempotent by design: it prints what it would create and stops if the
# resource already exists. Creating a second web service by accident is easy
# to do and annoying to undo.
#
# Usage:
#   RENDER_API_KEY=rnd_… tool/render_deploy.sh
set -euo pipefail

: "${RENDER_API_KEY:?set RENDER_API_KEY}"
API=https://api.render.com/v1
AUTH=(-H "Authorization: Bearer $RENDER_API_KEY")
SERVICE_NAME=${SERVICE_NAME:-woutalma-api}
REPO=${REPO:-https://github.com/traorecheikh/woutalma-keur}
REGION=${REGION:-frankfurt}

echo "==> Workspace"
OWNER_ID=$(curl -sS "${AUTH[@]}" "$API/owners?limit=20" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["owner"]["id"])')
echo "    $OWNER_ID"

echo "==> Database"
# The free tier allows exactly one free Postgres per workspace. This
# deployment shares an existing instance and keeps its tables in their own
# schema; DATABASE_URL therefore carries ?schema=woutalma. Point DATABASE_URL
# at whichever instance you mean to use before running this.
: "${DATABASE_URL:?set DATABASE_URL to the internal connection string (add ?schema=… when sharing an instance)}"

echo "==> Schema and extensions (idempotent)"
# PostGIS and unaccent are pinned to public: PostGIS expects to live there, and
# the migrations reference public.unaccent by name. Render's ordinary database
# user may create both on PG13+ — no superuser, no support ticket.
if [ -n "${DATABASE_URL_EXTERNAL:-}" ]; then
  psql "$DATABASE_URL_EXTERNAL" -v ON_ERROR_STOP=1 <<'SQL'
CREATE SCHEMA IF NOT EXISTS woutalma;
CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;
SQL
  echo "==> Migrate + seed (from here — the free tier has no job runner)"
  (cd "$(dirname "$0")/../backend" \
    && DATABASE_URL="$DATABASE_URL_EXTERNAL" npx prisma migrate deploy \
    && DATABASE_URL="$DATABASE_URL_EXTERNAL" npm run db:seed)
else
  echo "    skipped (set DATABASE_URL_EXTERNAL to run migrations and the seed)"
fi

echo "==> Web service"
EXISTING=$(curl -sS "${AUTH[@]}" "$API/services?limit=50&ownerId=$OWNER_ID" \
  | python3 -c "import json,sys; print(next((r['service']['id'] for r in json.load(sys.stdin) if r['service']['name']=='$SERVICE_NAME'), ''))")
if [ -n "$EXISTING" ]; then
  echo "    $SERVICE_NAME already exists ($EXISTING) — triggering a deploy instead"
  curl -sS -X POST "${AUTH[@]}" "$API/services/$EXISTING/deploys" \
    -H 'Content-Type: application/json' -d '{"clearCache":"do_not_clear"}' >/dev/null
  echo "    deploy triggered"
  exit 0
fi

JWT_SECRET=$(openssl rand -base64 48 | tr -d '\n')
DEV_AUTH_SECRET=$(openssl rand -hex 32)

python3 - "$OWNER_ID" "$REPO" "$REGION" "$SERVICE_NAME" "$DATABASE_URL" "$JWT_SECRET" "$DEV_AUTH_SECRET" > /tmp/wk-service.json <<'PY'
import json, sys
owner, repo, region, name, db, jwt, dev = sys.argv[1:8]
print(json.dumps({
  "type": "web_service", "name": name, "ownerId": owner, "repo": repo,
  "branch": "main", "rootDir": "backend", "autoDeploy": "yes",
  "envVars": [
    {"key": "DATABASE_URL", "value": db},
    {"key": "JWT_SECRET", "value": jwt},
    {"key": "JWT_ACCESS_TOKEN_TTL", "value": "15m"},
    {"key": "JWT_REFRESH_TOKEN_TTL", "value": "30d"},
    {"key": "DEV_AUTH_ENABLED", "value": "true"},
    {"key": "DEV_AUTH_SECRET", "value": dev},
    {"key": "NODE_VERSION", "value": "22.11.0"},
  ],
  "serviceDetails": {
    "runtime": "node", "plan": "free", "region": region,
    # Liveness, not readiness: a failing health check during a rollout is
    # treated as a failed deploy, and a database blip must not roll back a
    # good build.
    "healthCheckPath": "/healthz",
    "envSpecificDetails": {
      "buildCommand": "npm ci && npx prisma generate && npm run build",
      "startCommand": "npx prisma migrate deploy && node dist/main.js",
    },
  },
}))
PY

curl -sS -X POST "${AUTH[@]}" -H 'Content-Type: application/json' \
  "$API/services" -d @/tmp/wk-service.json \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); s=d.get("service",{}); print("   ", s.get("id"), s.get("serviceDetails",{}).get("url"))'
rm -f /tmp/wk-service.json

echo "==> Done. DEV_AUTH_SECRET is readable via GET /services/<id>/env-vars."
