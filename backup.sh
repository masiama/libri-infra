#!/bin/sh
# Nightly Postgres dump, kept 14 days locally and mirrored to $BACKUP_REMOTE with rclone
set -eu
set -o pipefail
cd "$(dirname "$0")"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

: "${BACKUP_REMOTE:?set BACKUP_REMOTE, e.g. r2:libri-backups}"

dir="$HOME/libri-backups"
mkdir -p "$dir"

out="$dir/libri-$(date +%Y-%m-%d).sql.gz"
docker compose -f docker-compose.prod.yml exec -T postgres pg_dump -U libri libri | gzip > "$out.tmp"
mv "$out.tmp" "$out"

find "$dir" -name 'libri-*.sql.gz' -mtime +14 -delete

rclone sync "$dir" "$BACKUP_REMOTE"
