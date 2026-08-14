#!/usr/bin/env bash
# Regenerates packages/woutalma_api_client from the backend's live OpenAPI
# spec. Run this after any change to a backend controller/DTO — never
# hand-edit anything under packages/woutalma_api_client, CI diffs it against
# a fresh run of this script and fails on drift.
#
# Requires: node + npm (backend deps installed), a JVM (openapi-generator-cli
# is a Java tool), and the Dart SDK.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
CLIENT_DIR="$ROOT_DIR/packages/woutalma_api_client"

echo "==> Emitting OpenAPI spec"
# The emitter boots AppModule, which reads JWT_* through ConfigService. These
# placeholders keep the script runnable without a populated backend/.env; they
# never leave this process and no token is signed here.
(cd "$BACKEND_DIR" && \
  SKIP_PRISMA_CONNECT=true \
  JWT_SECRET="${JWT_SECRET:-openapi-emit-placeholder}" \
  JWT_ACCESS_TOKEN_TTL="${JWT_ACCESS_TOKEN_TTL:-15m}" \
  JWT_REFRESH_TOKEN_TTL="${JWT_REFRESH_TOKEN_TTL:-30d}" \
  npm run --silent emit:openapi)

echo "==> Generating Dart client (dart-dio) into packages/woutalma_api_client"
rm -rf "$CLIENT_DIR"
npx --yes @openapitools/openapi-generator-cli generate \
  -i "$BACKEND_DIR/openapi.json" \
  -g dart-dio \
  -o "$CLIENT_DIR" \
  --additional-properties=pubName=woutalma_api_client,pubAuthor=Woutalma \
  --global-property=apiTests=false,modelTests=false

# dart-dio emits built_value sources: every model is a partial class whose
# real implementation, and the serializers index, live in .g.dart files that
# only build_runner can produce. Without this step the package has no
# serializers.g.dart and will not compile — which is why packages/ sat empty.
echo "==> Running build_runner inside the generated package"
(cd "$CLIENT_DIR" && dart pub get >/dev/null && \
  dart run build_runner build --delete-conflicting-outputs >/dev/null)

echo "==> Formatting generated output"
(cd "$ROOT_DIR" && dart format "$CLIENT_DIR" >/dev/null)

echo "==> Done. Review the diff under packages/woutalma_api_client before committing."
