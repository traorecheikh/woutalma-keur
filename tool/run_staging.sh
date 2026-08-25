#!/usr/bin/env bash
# Lance (ou compile) l'application contre le serveur de recette, avec la
# connexion par téléphone sans SMS.
#
# Depuis que `AppConfig` compile le secret de recette par défaut, un simple
# `flutter run` suffit. Ce script reste utile pour forcer un autre secret ou
# une autre URL (rotation du secret côté Render, serveur local).
#
#   tool/run_staging.sh              # flutter run
#   tool/run_staging.sh build apk    # n'importe quelle sous-commande flutter
#
# Le secret vient de Render quand RENDER_API_KEY est exporté, sinon de
# WK_DEV_AUTH_SECRET. Il n'est jamais écrit dans le dépôt.
set -euo pipefail

API_BASE_URL="${WK_API_BASE_URL:-https://woutalma-api.onrender.com}"
SERVICE_ID="${RENDER_SERVICE_ID:-srv-d9v6mgugekts73euacjg}"

secret="${WK_DEV_AUTH_SECRET:-}"
if [ -z "$secret" ] && [ -n "${RENDER_API_KEY:-}" ]; then
  echo "==> Lecture de DEV_AUTH_SECRET depuis Render"
  secret=$(curl -sS -H "Authorization: Bearer $RENDER_API_KEY" \
    "https://api.render.com/v1/services/$SERVICE_ID/env-vars?limit=50" \
    | python3 -c "
import json,sys
env={r['envVar']['key']: r['envVar']['value'] for r in json.load(sys.stdin)}
print(env.get('DEV_AUTH_SECRET',''))")
fi

if [ -z "$secret" ]; then
  cat >&2 <<'EOF'
Secret de recette introuvable.

  export WK_DEV_AUTH_SECRET=…      # la valeur DEV_AUTH_SECRET du service
ou
  export RENDER_API_KEY=rnd_…      # et le script ira la chercher

Sans lui, la connexion échouerait avec « Ce serveur n'accepte pas la
connexion de recette ».
EOF
  exit 1
fi

# `run` par défaut ; tout autre argument est passé tel quel à flutter.
if [ "$#" -eq 0 ]; then
  set -- run
fi

echo "==> flutter $* · API $API_BASE_URL · connexion de recette"
exec flutter "$@" \
  --dart-define=WK_API_BASE_URL="$API_BASE_URL" \
  --dart-define=WK_DEV_AUTH=true \
  --dart-define=WK_DEV_AUTH_SECRET="$secret"
