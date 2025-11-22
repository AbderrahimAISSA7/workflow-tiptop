# Furious Ducks Workflow

Ce dépôt centralise toute l’infrastructure exigée par Furious Ducks : SCM Git (Gitea), CI/CD Jenkins, registry Docker privé, monitoring (Prometheus/Grafana), sauvegardes (Restic) et environnements applicatifs TipTop (Dev / Préprod / Prod). Les sources front/back restent dans leurs dépôts respectifs (	iptop-front, 	iptop-api) et se branchent sur ce workflow.

## Objectifs couverts

- Dockeriser l’ensemble des briques (workflow + environnements applicatifs) sur un ou plusieurs VPS Linux.
- Publier chaque outil sur un sous-domaine du domaine workflow via Traefik + Let’s Encrypt.
- Mettre en œuvre Gitflow + pipelines Jenkins (build, tests, images, déploiement Dev → Préprod → Prod).
- Assurer la supervision (Prometheus, Grafana) et les sauvegardes automatisées (Restic + dumps Postgres).
- Documenter architecture, processus de déploiement et procédures de sauvegarde/restauration pour la soutenance.

## Structure

`
.
├── docs/                # Architecture, processus de déploiement/sauvegarde
├── infra/               # Services workflow (Traefik, Jenkins, Gitea, registry, monitoring, backups)
├── app-envs/            # Stacks Docker Compose TipTop (dev / préprod / prod)
├── scripts/             # Utilitaires (deploy.sh appelé par Jenkins)
├── references/          # Jenkinsfile de référence front/back
└── README.md
`

Chaque sous-dossier possède un README décrivant la configuration attendue et les fichiers .env.example à adapter.

## Mise en route résumée

1. Réserver les domaines (site + workflow) et créer les entrées DNS listées dans docs/architecture.md.
2. Installer Docker + Docker Compose plugin sur le(s) VPS.
3. Cloner ce dépôt (ex. /opt/workflow/furious-ducks-workflow).
4. Créer les réseaux Docker : workflow_net, pp_dev_net, pp_preprod_net, pp_prod_net.
5. Dans chaque dossier infra/*, copier .env.example → .env, ajuster les valeurs puis lancer docker compose up -d.
6. Importer les dépôts TipTop dans Gitea, configurer les webhooks Jenkins et utiliser les Jenkinsfile de référence pour générer les pipelines.
7. Jenkins pousse les images dans le registry privé, puis exécute scripts/deploy.sh <env> <module> pour mettre à jour pp-envs.

## Documentation

- docs/architecture.md — diagramme logique/physique, DNS, réseaux Docker, flux.
- docs/processus-deploiement.md — Gitflow + Jenkins + promotions Dev/Préprod/Prod.
- docs/processus-sauvegarde.md — stratégie Restic + procédures de restauration.

## Conformité Furious Ducks

- ✅ Workflow Linux full Docker avec Jenkins obligatoire.
- ✅ SCM Git (Gitea), registry privé, monitoring (Prometheus + Grafana), backups automatisés.
- ✅ Gitflow + environnements multiples Dev/Préprod/Prod + domaines dédiés et sous-domaines par outil.
- ✅ Documentation opérationnelle prête pour la soutenance.

Adaptation des variables (domaines, emails ACME, secrets) avant mise en production est obligatoire 
