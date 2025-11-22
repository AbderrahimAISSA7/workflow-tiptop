# Gitea (SCM)

Instance Git auto-hébergée pour les dépôts TipTop (`tiptop-front`, `tiptop-api`, doc, etc.). Légère et rapide à mettre en place.

## Prérequis

- Réseau `workflow_net`.
- DNS `gitea.wk-...`.
- Volume `gitea_data`.

## Déploiement

```bash
cp .env.example .env   # modifie GITEA_DB_PASSWORD / domaine
docker compose up -d
```

L’interface est accessible via Traefik : `https://gitea.wk-...`. Configure :

1. Admin initial (utilisateur `devops` par ex.).
2. Organisations / dépôts Mirror (`tiptop-*`).
3. Webhooks (Settings → Webhooks) vers Jenkins.
4. Rétention des artefacts (cleanup) si besoin.

Pense à sauvegarder le volume `/data` (voir `infra/backups`).
