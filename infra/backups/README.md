# Sauvegardes (Restic)

Automatise les sauvegardes des volumes critiques (Gitea, Jenkins, registry) et des dumps Postgres. Repose sur Restic + un cron (supercronic) exécuté dans un conteneur dédié.

## Prérequis

- Accès à un backend Restic (S3, minio, autre VPS via SSH).
- Variables d’environnement définies dans `.env`.
- Les volumes à sauvegarder sont montés en lecture seule dans le container `backup`.

## Déploiement

```bash
cp .env.example .env
docker compose up -d
```

Les scripts :

- `scripts/dump_postgres.sh` : génère des dumps SQL pour dev / préprod / prod.
- `scripts/backup.sh` : lance Restic backup + rotation.

Les logs sont visibles avec `docker compose logs -f backup`. Intègre cette stack dans Prometheus via un exporter Restic (optionnel).
