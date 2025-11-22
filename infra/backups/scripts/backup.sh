#!/usr/bin/env bash
set -euo pipefail

export RESTIC_PASSWORD
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

/scripts/dump_postgres.sh

restic backup \
  /backup/gitea \
  /backup/jenkins \
  /backup/registry \
  /dumps

restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
