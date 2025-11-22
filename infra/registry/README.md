# Registry Docker privé

Stocke les images construites par Jenkins avant leur déploiement sur les environnements Dev/Préprod/Prod.

## Prérequis

- Réseau `workflow_net`.
- DNS `registry.wk-...`.
- Traefik pour exposer`https://registry.wk-...`.

## Déploiement

```bash
cp .env.example .env   # définir REGISTRY_USERNAME / REGISTRY_PASSWORD
docker compose up -d
```

Ajoute l’utilisateur/mot de passe dans Jenkins (credentials `registry-credentials`). Les développeurs peuvent se connecter :

```bash
docker login registry.wk-... -u registry
```

Pense à sauvegarder `/var/lib/registry` (voir `infra/backups`).
