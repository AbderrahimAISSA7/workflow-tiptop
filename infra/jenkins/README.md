# Jenkins (CI/CD)

Ce dossier déploie Jenkins LTS avec le client Docker afin de construire/pousser les images TipTop et d’orchestrer les déploiements.

## Prérequis

- Réseau `workflow_net`.
- Volume persistant `jenkins_home`.
- Docker Engine installé sur l’hôte (socket partagé).

### `.env.example`

```
JENKINS_HOST=jenkins.wk-archi-f24a-15m-g4-2025.fr
TZ=Europe/Paris
```

Copier en `.env` puis adapter le host.

## Déploiement

```bash
cp .env.example .env
docker compose up -d
```

Ouvre `https://jenkins.wk-...` (Traefik) pour finaliser l’installation (admin password dans `jenkins_home/secrets/initialAdminPassword`). Installe les plugins : Git, Gitea, Blue Ocean, Pipeline, Docker Pipeline, SSH Agent.

Pense à :

- Ajouter les credentials (`registry-credentials`, `gitea-token`, `app-server-ssh`).
- Configurer les webhooks Gitea → Jenkins (endpoints multibranch).
- Définir les agents (Docker ou SSH) selon le besoin.
