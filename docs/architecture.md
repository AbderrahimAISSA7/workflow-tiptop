# Architecture Furious Ducks Workflow

## Vue physique

| Élément | Specs conseillées | Rôle |
| --- | --- | --- |
| VPS Workflow | Debian 12, 4 vCPU / 8 Go RAM / 80 Go SSD | Traefik, Jenkins, Gitea, registry, monitoring, backups |
| VPS App (option) | Debian 12, 4 vCPU / 8 Go RAM / 80 Go SSD | Environnements TipTop (Dev / Préprod / Prod) |
| Stockage externe | Object Storage S3 / second VPS | Cible Restic pour les sauvegardes |

> Un seul VPS peut héberger workflow + environnements, isolés via des réseaux Docker.

## DNS

- Domaine applicatif : dsp5-archi-f24a-15m-g4-2025.fr
- Domaine workflow : wk-archi-f24a-15m-g4-2025.fr
- Sous-domaines :
  - jenkins.wk-..., gitea.wk-..., egistry.wk-...
  - prometheus.wk-..., grafana.wk-..., ackup.wk-...
  - dev.dsp5-..., preprod.dsp5-..., www.dsp5-...

## Réseaux Docker

`
workflow_net    -> Traefik, Jenkins, Gitea, registry, Prometheus, Grafana, backups
app_dev_net     -> TipTop Dev (front, API, Postgres, pgAdmin)
app_preprod_net -> TipTop Préprod
app_prod_net    -> TipTop Prod
`

Traefik écoute workflow_net et expose 80/443. Les stacks applicatives n’exposent que les ports nécessaires (sinon, passer par Traefik).

## Briques principales

1. **Traefik** — reverse proxy, certificats Let’s Encrypt, métriques Prometheus, routage par sous-domaines.
2. **Gitea** — SCM Git, webhooks Jenkins, stockage des dépôts TipTop.
3. **Jenkins** — CI/CD, agents Docker, pipelines déclaratifs, interactions Compose.
4. **Registry Docker** — stockage des images, authentification Basic, utilisé par Jenkins pour les push/pull.
5. **Monitoring** — Prometheus + cAdvisor + node-exporter + Grafana, dashboards Workflow & Appli.
6. **Backups** — Restic/Borg + dumps Postgres + export vers stockage externe.
7. **App-envs** — Compose Dev/Préprod/Prod, images issues du registry, orchestrées par Jenkins.

## Configurations applicatives

- Front (	iptop-front) : build Node 20/React, variable VITE_API_BASE_URL transmise par Jenkins selon l’environnement.
- API (	iptop-api) : Spring Boot, profil actif (SPRING_PROFILES_ACTIVE=dev|preprod|prod), secret TIPTOP_SECURITY_JWT_SECRET, datasource Postgres jdbc:postgresql://postgres:5432/<DB>.
- Base de données : Postgres 15, utilisateurs/mots de passe distincts par environnement, healthcheck pg_isready, volumes dédiés.
- pgAdmin (dev) : image dpage/pgadmin4, exposée uniquement en Dev pour inspection BDD.

## Flux CI/CD

1. Push eature/* → webhook Gitea → Jenkins (pipeline front ou API).
2. Stages : checkout → tests (
pm test / mvn test) → build → docker build + docker push (tag branch/version) → deploy_dev (docker compose -f app-envs/dev ...).
3. Merge vers develop → tag develop-<build> → deploy_preprod.
4. Merge vers main → étape manuelle Jenkins → deploy_prod.
5. Monitoring + alertes via Grafana/Prometheus.

## Sécurité

- Traefik + Let’s Encrypt : HTTPS obligatoire.
- Authentification Basic/OAuth2 sur Jenkins, registry, Prometheus/Grafana.
- Accès SSH via clés pour Jenkins → serveur applicatif.
- Secrets Restic/Postgres/registry dans les .env + gestion via Docker secrets possible.
- Backups Restic chiffrés + rotation (daily/weekly/monthly) + tests de restauration réguliers.
