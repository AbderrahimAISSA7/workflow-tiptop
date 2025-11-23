# Processus de déploiement TipTop

## Pré-requis

- Branches Gitflow : main (prod), develop (préprod), eature/*, hotfix/*.
- Jenkinsfile intégrés à 	iptop-front et 	iptop-api (cf. eferences/).
- Credentials Jenkins : gitea-token, egistry-credentials, pp-server-ssh.
- Script scripts/deploy.sh disponible sur le serveur cible (utilisé via SSH).

## Chaîne cible

`
Dev push -> Gitea -> webhook -> Jenkins (MultiBranch)
   -> Tests -> Build -> Docker build -> Push (registry privé)
   -> Deploy Dev (feature + develop)
   -> Deploy Préprod (develop)
   -> Deploy Prod (main + validation humaine)
`

## Déroulé détaillé

1. **Feature branch**
   - Jenkins récupère le commit.
   - Exécute npm/mvn tests + lint.
   - Front : docker build --build-arg VITE_API_BASE_URL=https://api.dev....
   - API : build JAR (mvn package) puis image Docker.
   - Push des images egistry.wk-.../<module>:feature-<sha>.
   - Déploiement Dev (scripts/deploy.sh dev <module>), services configurés avec SPRING_PROFILES_ACTIVE=dev et secret JWT dev.

2. **Merge vers develop**
   - Pipeline relancé.
   - Tag develop-<build-number>.
   - Front reconstruit avec VITE_API_BASE_URL=https://api.preprod....
   - Déploiement préprod (scripts/deploy.sh preprod <module>), API en profil preprod.
   - Tests fonctionnels / validation métier sur preprod.dsp5-....

3. **Merge vers main**
   - Pipeline relancé avec tag prod-<version>.
   - Étape input Jenkins pour valider la mise en production.
   - deploy_prod applique l’image (SPRING_PROFILES_ACTIVE=prod, secrets prod).
   - Vérifications Grafana + smoke tests front/API.

4. **Hotfix**
   - Branche depuis main, pipeline identique au flux prod.
   - Après mise en prod, merge vers develop pour réaligner.

## Rollback

1. Modifier IMAGE_TAG dans pp-envs/<env>/.env (tag précédent).
2. Exécuter IMAGE_TAG=<tag> ./scripts/deploy.sh <env> all.
3. Vérifier l’état (docker compose ... ps) et la santé applicative.

## Contrôles qualité

- Tests unitaires obligatoires avant build image.
- Possibilité d’ajouter un stage SAST / dependency-check.
- Notifications (mail/Slack) sur succès/échec.
- Supervision Grafana/Prometheus après chaque déploiement.
