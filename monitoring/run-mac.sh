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

# Alloy's unix exporter has no battery collector on macOS, so pmset feeds its textfile collector.
tf="$HOME/.local/share/libri-alloy/textfile"
mkdir -p "$tf"
(
  while :; do
    pmset -g batt | awk '
      /AC Power/ { ac = 1 }
      match($0, /[0-9]+%/) { pct = substr($0, RSTART, RLENGTH - 1) }
      match($0, /[0-9]+:[0-9]+ remaining/) { split(substr($0, RSTART, RLENGTH), t, /[: ]/); left = t[1] * 3600 + t[2] * 60 }
      END {
        if (pct == "") exit
        printf "libri_battery_percent %s\nlibri_on_ac_power %d\n", pct, ac
        if (left != "") printf "libri_battery_seconds_remaining %d\n", left
      }
    ' > "$tf/battery.prom.tmp" && mv "$tf/battery.prom.tmp" "$tf/battery.prom"
    sleep 30
  done
) &

exec /opt/homebrew/bin/alloy run --disable-reporting \
  --storage.path="$HOME/.local/share/libri-alloy" "$conf"
