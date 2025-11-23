#!/usr/bin/env bash
set -euo pipefail

CRON_FILE="/tmp/supercronic.cron"
SCHEDULE="${CRON_SCHEDULE:-0 2 * * *}"

cat <<EOF > "${CRON_FILE}"
${SCHEDULE} /scripts/backup.sh
EOF

exec /usr/local/bin/supercronic "${CRON_FILE}"