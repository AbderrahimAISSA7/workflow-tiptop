#!/usr/bin/env bash
set -euo pipefail

mkdir -p /dumps/dev /dumps/preprod /dumps/prod

timestamp="$(date +%F-%H%M)"

echo "[dump] Dev..."
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump -h "${POSTGRES_HOST_DEV}" -U "${POSTGRES_USER}" tiptop_dev > "/dumps/dev/tiptop-${timestamp}.sql"

echo "[dump] Préprod..."
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump -h "${POSTGRES_HOST_PREPROD}" -U "${POSTGRES_USER}" tiptop_preprod > "/dumps/preprod/tiptop-${timestamp}.sql"

echo "[dump] Prod..."
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump -h "${POSTGRES_HOST_PROD}" -U "${POSTGRES_USER}" tiptop_prod > "/dumps/prod/tiptop-${timestamp}.sql"
