# Services d'infrastructure

Chaque sous-dossier contient un stack Docker Compose dédié :

| Dossier | Service | Description |
| --- | --- | --- |
| `reverse-proxy/` | Traefik | Reverse proxy + TLS + routage + metrics |
| `jenkins/` | Jenkins LTS | CI/CD, pipelines Gitflow |
| `gitea/` | Gitea | SCM Git, webhooks vers Jenkins |
| `registry/` | Registry Docker | Stockage des images construites |
| `monitoring/` | Prometheus, cAdvisor, node-exporter, Grafana | Supervision du workflow et des apps |
| `backups/` | Restic + cron | Sauvegardes automatisées (Gitea, Jenkins, Postgres, registry) |

Procédure générique :

1. Copier `.env.example` en `.env` dans chaque dossier.
2. Adapter les valeurs (domaines, emails, identifiants).
3. Lancer `docker compose up -d`.
4. Vérifier via les sous-domaines (Traefik route `https://service.wk-...`).
