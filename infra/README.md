# Services d'infrastructure

Chaque sous-dossier contient un stack Docker Compose dÃ©diÃ© :

| Dossier | Service | Description |
| --- | --- | --- |
| `reverse-proxy/` | Traefik | Reverse proxy + TLS + routage + metrics |
| `jenkins/` | Jenkins LTS | CI/CD, pipelines Gitflow |
| `gitea/` | Gitea | SCM Git, webhooks vers Jenkins |
| `registry/` | Registry Docker | Stockage des images construites |
| `monitoring/` | Prometheus, cAdvisor, node-exporter, Grafana | Supervision du workflow et des apps |
| `backups/` | Restic + cron | Sauvegardes automatisÃ©es (Gitea, Jenkins, Postgres, registry) |

ProcÃ©dure gÃ©nÃ©rique :

1. Copier `.env.example` en `.env` dans chaque dossier.
2. Adapter les valeurs (domaines, emails, identifiants).
3. Lancer `docker compose up -d`.
4. VÃ©rifier via les sous-domaines (Traefik route `https://service.wk-...`).

Alternativement : `docker compose -f infra/docker-compose.yml up -d` depuis la racine pour démarrer/arrêter toutes les briques en une fois.
