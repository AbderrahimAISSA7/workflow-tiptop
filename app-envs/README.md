# Environnements applicatifs TipTop

Chaque sous-dossier (`dev`, `preprod`, `prod`) contient :

- un `docker-compose.yml` décrivant les services (front, API, Postgres, éventuel pgAdmin) ;
- un fichier `.env.example` à copier en `.env` et à ajuster (ports, mots de passe, tags d’images).

Les images `tiptop-front` / `tiptop-api` sont tirées depuis le registry privé (cf. pipelines Jenkins).

## Commandes utiles

```bash
# Déployer un environnement
docker compose -f app-envs/dev/docker-compose.yml --env-file app-envs/dev/.env up -d

# Mettre à jour après une nouvelle image
IMAGE_TAG=develop-42 ./scripts/deploy.sh dev tiptop-api

# Consulter les logs
docker compose -f app-envs/preprod/docker-compose.yml logs -f api
```

L’exécution des commandes est automatisée par Jenkins (`references/Jenkinsfile-*`) via SSH.
