# TipTop Environments

Chaque sous-dossier (dev, preprod, prod) contient :

- un docker-compose.yml décrivant le front React, l'API Spring Boot et Postgres (pgAdmin uniquement en dev) ;
- un fichier .env.example à copier en .env puis à personnaliser (ports, identifiants DB, secrets JWT, tag d'image).

Les images 	iptop-front et 	iptop-api sont tirées depuis le registry privé du workflow. Les variables SPRING_PROFILES_ACTIVE, TIPTOP_SECURITY_JWT_SECRET et VITE_API_BASE_URL sont alignées avec les configurations du projet existant (	iptop-front / 	iptop-api).

## Commandes utiles

`ash
# Déployer un environnement localement
cp app-envs/dev/.env.example app-envs/dev/.env
docker compose -f app-envs/dev/docker-compose.yml --env-file app-envs/dev/.env up -d

# Mettre à jour après un nouveau tag d'image (utilisé par Jenkins)
IMAGE_TAG=develop-42 ./scripts/deploy.sh dev tiptop-api

# Consulter les logs d'un service
docker compose -f app-envs/preprod/docker-compose.yml logs -f api
`

Jenkins exécute automatiquement ces commandes via le script scripts/deploy.sh depuis les pipelines (
eferences/Jenkinsfile-*).
