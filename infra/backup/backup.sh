#!/usr/bin/env bash
set -euo pipefail
TS=$(date +%Y%m%d-%H%M)
mkdir -p /backups
cd /data
for dir in *; do
  if [ -d "$dir" ]; then
    tar czf /backups/${dir}-${TS}.tar.gz "$dir"
  fi
done
