# Architecture Furious Ducks Workflow

## Vue physique

| Élément | Specs conseillées | Rôle |
| --- | --- | --- |
| VPS Workflow | Debian 12, 4 vCPU / 8 Go RAM / 80 Go SSD | Héberge Traefik, Jenkins, Gitea, registry, monitoring, backups |
| VPS App (option) | Debian 12, 4 vCPU / 8 Go RAM / 80 Go SSD | Héberge les environnements TipTop (Dev / Préprod / Prod) |
| Stockage externe | Object Storage S3 / second VPS | Cible Restic pour les sauvegardes quotidiennes |

> Pour réduire les coûts, un seul VPS puissant peut exécuter workflow + app, isolés via des réseaux Docker.

## DNS

- Domaine applicatif : `dsp5-archi-f24a-15m-g4-2025.fr`
- Domaine workflow : `wk-archi-f24a-15m-g4-2025.fr`
- Sous-domaines (A/CNAME → IP du VPS workflow) :
  - `jenkins.wk-...`
  - `gitea.wk-...`
  - `registry.wk-...`
  - `prometheus.wk-...`
  - `grafana.wk-...`
  - `backup.wk-...`
  - `dev.dsp5-...`
  - `preprod.dsp5-...`
  - `www.dsp5-...`

## Réseaux Docker

```
workflow_net      -> Traefik, Jenkins, Gitea, registry, Prometheus, Grafana, backups
app_dev_net       -> TipTop Dev  (front, API, Postgres, pgAdmin)
app_preprod_net   -> TipTop Préprod
app_prod_net      -> TipTop Prod
```

Traefik se connecte à `workflow_net` et expose 80/443. Les stacks applicatives ne publient que les ports nécessaires (sinon, passer par Traefik).

## Briques principales

1. **Traefik** (reverse proxy + ACME Let’s Encrypt + métriques Prometheus + routage par sous-domaines).
2. **Gitea** (SCM Git, webhooks vers Jenkins, stockage des dépôts TipTop).
3. **Jenkins** (CI/CD, agents Docker, pipelines déclaratifs, interactions Compose).
4. **Registry Docker privé** (stockage des images, authentification Basic).
5. **Monitoring** (Prometheus + cAdvisor + node-exporter + Grafana + métriques Traefik/Jenkins).
6. **Backups** (Restic/Borg + dumps Postgres + export vers stockage externe).
7. **App-envs** (Compose Dev/Préprod/Prod, images issues du registry, orchestrées par Jenkins).

## Flux CI/CD

1. Dev pousse sur `feature/*` → Gitea envoie un webhook Jenkins.
2. Pipeline Jenkins (front ou API) :
   - checkout
   - tests (npm/mvn)
   - build (npm build / mvn package)
   - docker build + push (registry privé, tag = branche/version)
   - deploy dev (branches feature & develop) → `docker compose -f app-envs/dev/...`
3. Merge → `develop` → image tag `develop-<build>` → déploiement préprod.
4. Merge → `main` → étape manuelle Jenkins → déploiement prod.
5. Monitoring + alerting via Grafana/Prometheus.

## Sécurité

- Traefik + Let’s Encrypt : HTTPS partout, redirection HTTP → HTTPS.
- Authentification Basic (ou OAuth2 Proxy) pour Jenkins, registry, Prometheus.
- Accès SSH via clés pour Jenkins → serveur d’hébergement.
- Secrets (Restic, Postgres, registry) fournis via fichiers `.env` + Docker secrets.
- Backups chiffrés Restic + rotation `forget/prune`.
