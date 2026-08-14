#!/usr/bin/env bash
# Regenerates packages/woutalma_api_client from the backend's live OpenAPI
# spec. Run this after any change to a backend controller/DTO — never
# hand-edit anything under packages/woutalma_api_client, CI diffs it against
# a fresh run of this script and fails on drift.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
CLIENT_DIR="$ROOT_DIR/packages/woutalma_api_client"

echo "==> Emitting OpenAPI spec"
(cd "$BACKEND_DIR" && npm run --silent emit:openapi)

echo "==> Generating Dart client (dart-dio) into packages/woutalma_api_client"
rm -rf "$CLIENT_DIR"
npx --yes @openapitools/openapi-generator-cli generate \
  -i "$BACKEND_DIR/openapi.json" \
  -g dart-dio \
  -o "$CLIENT_DIR" \
  --additional-properties=pubName=woutalma_api_client,pubAuthor=Woutalma \
  --global-property=apiTests=false,modelTests=false

echo "==> Formatting generated output"
(cd "$ROOT_DIR" && dart format "$CLIENT_DIR" >/dev/null)

echo "==> Done. Review the diff under packages/woutalma_api_client before committing."
