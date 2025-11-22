# Monitoring (Prometheus + Grafana)

Supervise le workflow (Traefik, Jenkins, Gitea, registry) ainsi que les environnements applicatifs (via cAdvisor + node-exporter).

## Prérequis

- Réseau `workflow_net`.
- DNS `prometheus.wk-...` et `grafana.wk-...`.
- Docker metrics exposées (Traefik, etc.).

## Composition

- Prometheus (scrape Traefik, Jenkins, cAdvisor, node-exporter, Restic exporter).
- cAdvisor (métriques containers).
- node-exporter (métriques système hôte).
- Grafana (dashboards Workflow / TipTop).

## Déploiement

```bash
cp .env.example .env  # renseigner domaines
docker compose up -d
```

Ajouter les dashboards :

- `dashboards/workflow.json` (exemple à créer) pour Jenkins/Gitea/registry.
- `dashboards/app.json` pour TipTop (latence, CPU, status HTTP).

Authentifie Grafana (admin/admin → changer) et configure les alertes (email/Slack).
