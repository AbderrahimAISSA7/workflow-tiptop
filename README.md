# Furious Ducks Workflow

Ce dépôt centralise toute l’infrastructure exigée par Furious Ducks : SCM Git (Gitea), CI/CD Jenkins, registry Docker privé, monitoring (Prometheus/Grafana), sauvegardes (Restic) et environnements applicatifs TipTop (Dev / Préprod / Prod). Les sources front/back (	iptop-front, 	iptop-api) restent dans leurs dépôts respectifs et se branchent sur ce workflow.

## Objectifs couverts

- Dockeriser l’ensemble des briques (workflow + environnements applicatifs) sur un ou plusieurs VPS Linux.
- Publier chaque outil sur un sous-domaine via Traefik + Let’s Encrypt.
- Mettre en œuvre Gitflow + pipelines Jenkins (build, tests, images, déploiement Dev → Préprod → Prod).
- Collecter des métriques (Prometheus/Grafana) et automatiser les sauvegardes (Restic + dumps Postgres).
- Fournir la documentation (architecture, déploiements, sauvegardes, scénarios de tests) pour la soutenance.

## Structure

`
.
├── docs/          # Architecture, processus, scénarios de tests
├── infra/         # Services workflow (Traefik, Gitea, Jenkins, registry, monitoring, backups)
├── app-envs/      # Stacks Docker Compose TipTop (dev / préprod / prod)
├── scripts/       # Utilitaires (deploy.sh appelé par Jenkins)
├── references/    # Jenkinsfile de référence front/back
└── README.md
`

Chaque sous-dossier possède un README décrivant la configuration attendue et les fichiers .env.example à adapter.

## Mise en route (résumé)

1. Réserver les domaines (site + workflow) et créer les entrées DNS listées dans docs/architecture.md.
2. Installer Docker + Docker Compose plugin sur le(s) VPS.
3. Cloner ce dépôt (ex. /opt/workflow/furious-ducks-workflow).
4. Créer les réseaux Docker partagés : workflow_net, pp_dev_net, pp_preprod_net, pp_prod_net.
5. Dans chaque dossier infra/*, copier .env.example -> .env, renseigner les valeurs puis lancer `docker compose up -d` (ou `docker compose -f infra/docker-compose.yml up -d`).
6. Importer les dépôts TipTop dans Gitea, configurer les webhooks Jenkins et utiliser les Jenkinsfile de référence pour créer les pipelines.
7. Jenkins pousse les images dans le registry privé puis exécute scripts/deploy.sh <env> <module> pour mettre à jour pp-envs.

## Documentation

- docs/architecture.md — diagramme logique/physique, DNS, réseaux Docker, flux.
- docs/processus-deploiement.md — pipeline Gitflow → Jenkins → environnements.
- docs/processus-sauvegarde.md — stratégie Restic/Borg + procédure de restauration.
- docs/scenarios-tests.md — plan de tests détaillé (CI/CD, monitoring, backups).

## Conformité Furious Ducks

- ✅ Workflow Linux full Docker avec Jenkins obligatoire.
- ✅ SCM Git (Gitea), registry privé, monitoring (Prometheus + Grafana), backups automatisés.
- ✅ Gitflow + environnements Dev/Préprod/Prod + domaines dédiés / sous-domaines par outil.
- ✅ Documentation opérationnelle (architecture, processus, tests) prête pour la soutenance.

Adapte les domaines, emails ACME et secrets avant mise en production.
