# Scénarios de tests

## 1. Build & tests locaux
1. Cloner 	iptop-front et 	iptop-api depuis Gitea.
2. Lancer 
pm ci && npm test dans le front; vérifier les snapshots et lint.
3. Lancer mvn -B test dans l'API; vérifier que la base PostgreSQL embarquée démarre (profil dev).
4. Construire les images Docker localement :
   `ash
   docker build -t registry.wk-.../tiptop-front:test .
   docker build -t registry.wk-.../tiptop-api:test .
   `
5. Pousser dans le registry privé (docker login registry.wk-...).

## 2. Déploiement Dev (branch feature/*)
1. Créer une branche eature/xyz et pousser sur Gitea.
2. Jenkins déclenche le pipeline (références eferences/Jenkinsfile-*).
3. Stages attendus : checkout → tests → build → docker build → push → deploy_dev.
4. Vérifier via docker compose -f app-envs/dev/docker-compose.yml ps que les conteneurs tournent avec le nouveau tag.
5. Tester le front (https://dev.dsp5-...) et l’API (https://api.dev.../actuator/health).

## 3. Promotion Préprod (merge develop)
1. Merger la branche vers develop.
2. Jenkins rejoue le pipeline avec tag develop-<build> et exécute deploy_preprod.
3. Contrôler les variables SPRING_PROFILES_ACTIVE=preprod dans les logs API (docker compose ... logs -f api).
4. Lancer la suite de tests fonctionnels (manuelle ou Postman) sur https://preprod.dsp5-....

## 4. Mise en production contrôlée
1. Merger develop vers main.
2. Jenkins s’arrête sur l’étape input « Confirmer la mise en production ».
3. Après validation, deploy_prod met à jour pp-envs/prod.
4. Vérifier :
   - docker compose -f app-envs/prod/docker-compose.yml ps
   - Dashboard Grafana (panneau API latence).
5. Tester un rollback en changeant IMAGE_TAG dans pp-envs/prod/.env puis IMAGE_TAG=prod-prev ./scripts/deploy.sh prod all.

## 5. Monitoring
1. Ouvrir Grafana (https://grafana.wk-...) → dashboard "Workflow Furious Ducks".
2. Débrancher un conteneur (ex. docker compose -f infra/jenkins/docker-compose.yml stop jenkins).
3. Vérifier que Prometheus détecte l'absence (target down) et que l’alerte configurée se déclenche (mail/Slack si branché).
4. Redémarrer le service (docker compose ... start jenkins).

## 6. Sauvegardes & restauration
1. Forcer un backup manuel : cd infra/backups && docker compose run --rm backup /scripts/backup.sh.
2. Vérifier estic snapshots pour voir l’entrée du jour.
3. Simuler un incident : supprimer le volume Gitea (docker volume rm workflow-tiptop_gitea_data).
4. Restaurer :
   `ash
   docker compose -f infra/backups/docker-compose.yml run --rm backup restic restore latest --target /restore
   rsync -a /restore/backup/gitea/ /var/lib/docker/volumes/workflow-tiptop_gitea_data/_data/
   `
5. Relancer Gitea (docker compose -f infra/gitea/docker-compose.yml up -d) et vérifier l’intégrité des dépôts.

## 7. Tests réseau / DNS
1. Modifier le fichier hosts local pour mapper les sous-domaines (jenkins.wk-..., gitea.wk-..., etc.) vers l’IP du VPS.
2. Vérifier que Traefik applique bien les certificats Let’s Encrypt (ou auto-signés en local) et route vers chaque service.

Chaque scénario doit être consigné (captures Grafana, logs Jenkins) pour la soutenance Furious Ducks.
