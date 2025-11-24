# Workflow TipTop

Nouvelle plateforme CI/CD simplifiée (Nginx + Jenkins + Gitea + Prometheus + Grafana + backup).

## Déploiement rapide
1. `docker network create workflow_net`
2. `docker compose -f infra/docker-compose.yml up -d`
3. Ajoute les entrées DNS ou hosts (`jenkins.local`, `gitea.local`, etc.)

## Services
- **Jenkins** : http://jenkins.local
- **Gitea** : http://gitea.local
- **Prometheus** : http://prometheus.local
- **Grafana** : http://grafana.local
- **Backup** : archive les dossiers `data/`

Adapte les fichiers `infra/nginx/conf.d/default.conf` et `infra/monitoring/prometheus.yml` selon tes besoins, puis pousse sur la VM.
