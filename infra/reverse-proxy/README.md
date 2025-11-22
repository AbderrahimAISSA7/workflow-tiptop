# Traefik (reverse proxy)

Expose tous les services du workflow via HTTPS et gère automatiquement les certificats Let’s Encrypt.

## Prérequis

- DNS `A`/`AAAA` pointant `*.wk-...` (wildcard ou sous-domaines) vers ce serveur.
- Réseau Docker `workflow_net` (`docker network create workflow_net`).
- Fichier `.env` basé sur `.env.example`.

## Déploiement

```bash
cp .env.example .env    # renseigner email ACME + domaine workflow
docker compose up -d
```

Traefik écoute les ports 80/443 + 8080 (dashboard) + 9100 (métriques Prometheus). Limiter l’accès au dashboard via firewall ou middleware `default-auth`.

## Ajout d’un service

Exemple de labels à ajouter dans un autre `docker-compose.yml` :

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.jenkins.rule=Host(`jenkins.${TRAEFIK_DOMAIN}`)"
  - "traefik.http.routers.jenkins.entrypoints=websecure"
  - "traefik.http.routers.jenkins.tls.certresolver=letsencrypt"
  - "traefik.http.services.jenkins.loadbalancer.server.port=8080"
```

Les métriques Traefik sont exposées sur `:9100/metrics` et scrutées par Prometheus (`infra/monitoring`).
