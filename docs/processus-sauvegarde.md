# Processus de sauvegarde & restauration

## Objectifs

- Sauvegarder automatiquement les données critiques : Gitea, Jenkins, registry, bases Postgres (Dev/Préprod/Prod), fichiers Compose.
- Externaliser les sauvegardes (Object Storage S3 / second VPS).
- Fournir une procédure de restauration éprouvée.

## Fréquence recommandée

| Élément | Données | Fréquence | Outil |
| --- | --- | --- | --- |
| Gitea | `/data` (repos Git) | Quotidienne | Restic |
| Jenkins | `/var/jenkins_home` | Quotidienne | Restic |
| Registry | `/var/lib/registry` | Hebdomadaire | Restic |
| Bases Postgres | Dump SQL | Quotidienne | `pg_dump` + Restic |
| Dépôt workflow | Git | À chaque modif | SCM distant |

## Stack backups

- Voir `infra/backups/`.
- Container `restic` avec cron (supercronic ou systemd).
- Scripts :
  - `dump_postgres.sh` : boucle sur les environnements pour générer les `.sql`.
  - `backup.sh` : exécute `restic backup` + `restic forget --prune`.

### Variables `.env`

```
RESTIC_REPOSITORY=s3:https://s3.example.com/workflow-tiptop
RESTIC_PASSWORD=changeMe
AWS_ACCESS_KEY_ID=XXXX
AWS_SECRET_ACCESS_KEY=YYYY
POSTGRES_HOSTS=dev-postgres,preprod-postgres,prod-postgres
```

## Procédure de restauration

1. Recréer le serveur (Docker installé).
2. Cloner ce dépôt, reconfigurer Traefik/Gitea/Jenkins/etc.
3. Récupérer les secrets Restic + accès S3.
4. Restaurer :
   ```bash
   docker compose -f infra/backups/docker-compose.yml run --rm backup restic restore latest --target /restore
   ```
5. Stopper le service ciblé, remplacer le volume (ex. `/var/lib/docker/volumes/jenkins_home/_data`).
6. Restaurer les dumps Postgres :
   ```bash
   cat /restore/dumps/prod/tiptop-2025-11-22.sql | docker exec -i app-envs_prod-postgres-1 psql -U tiptop_prod
   ```
7. Relancer les stacks (`docker compose up -d`) et vérifier via Grafana.

## Pilotage & alerting

- Exporter l’état Restic (commande `restic stats`) vers Prometheus.
- Dashboard Grafana « Backups » + alerting e-mail/Slack si échec > 24 h.
- Test de restauration mensuel (ou trimestriel) documenté.
