#!/bin/sh
# Runs alloy natively on the mac with mac.alloy, api.alloy and db.alloy, reading ~/libri/.env.
set -eu
cd "$(dirname "$0")"

set -a
. ../.env
set +a

export ALLOY_HOST="${ALLOY_HOST:-mac}"
export API_METRICS_ADDR=127.0.0.1:8081
export POSTGRES_DSN="postgresql://libri:${DB_PASS}@127.0.0.1:5433/libri?sslmode=disable"
export REDIS_ADDR=127.0.0.1:6379

conf="$HOME/.config/libri-alloy"
mkdir -p "$conf"
cp -f mac.alloy api.alloy db.alloy "$conf/"

exec /opt/homebrew/bin/alloy run --disable-reporting \
  --storage.path="$HOME/.local/share/libri-alloy" "$conf"
