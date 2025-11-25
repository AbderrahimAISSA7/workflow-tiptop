# Workflow TipTop

Plateforme CI/CD légère hébergeant Jenkins, Gitea, Prometheus, Grafana, un registre Docker privé et un service de backup.  
Les services sont exposés via Nginx et pointent vers le domaine `*.dsp5-archi-f24a-15m-g4-2025-akf.fr`.

## Déploiement
```bash
git clone https://github.com/AbderrahimAISSA7/workflow-tiptop.git
cd workflow-tiptop/infra
docker network create workflow_net 2>/dev/null
docker compose -f infra/docker-compose.yml up -d --build
```
Crée au préalable les dossiers `data/jenkins`, `data/gitea`, `data/gitea-db`, `data/prometheus`, `data/grafana`, `data/registry` et `backups`, puis donne-les à ton utilisateur (`chown -R $(id -u):$(id -g) data backups`).  
Depuis ta VM, vérifie l’accès via `curl -H "Host: jenkins.dsp5-archi-f24a-15m-g4-2025-akf.fr" http://127.0.0.1 -I`.

## Services exposés
- **Jenkins** : `http://jenkins.dsp5-archi-f24a-15m-g4-2025-akf.fr`
- **Gitea** : `http://gitea.dsp5-archi-f24a-15m-g4-2025-akf.fr`
- **Prometheus** : `http://prometheus.dsp5-archi-f24a-15m-g4-2025-akf.fr`
- **Grafana** : `http://grafana.dsp5-archi-f24a-15m-g4-2025-akf.fr`
- **Registry Docker** : `http://registry.dsp5-archi-f24a-15m-g4-2025-akf.fr` (proxy vers `registry:5000`)

Le registre stocke ses données dans `data/registry` et permet à Jenkins de pousser des images avec `docker login registry.dsp5-...`.

## Fichiers importants
- `infra/docker-compose.yml` — définition de toute la stack (Nginx, Jenkins, Gitea + Postgres, Registry, Prometheus, Grafana, backup, blackbox-exporter).
- `infra/nginx/conf.d/default.conf` — virtual hosts pointant vers chaque service du réseau Docker.
- `infra/monitoring/prometheus.yml` — jobs Prometheus (Prometheus/Jenkins/Gitea).
- `infra/backup/` — image contenant le script de sauvegarde des dossiers `data/*`.

Adapte ces fichiers (domaines, mots de passe, jobs Prometheus) avant de lancer `docker compose` sur la VM. Ensuite configure Jenkins (pipelines front/back), crée tes dépôts Gitea et ajoute, si besoin, des webhooks pour déclencher les pipelines. Une fois le registre en place, Jenkins peut builder et pousser ses images sur `registry.dsp5-archi-f24a-15m-g4-2025-akf.fr/tiptop/<image>`.
