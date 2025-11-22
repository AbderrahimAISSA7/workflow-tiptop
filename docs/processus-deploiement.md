# Processus de déploiement TipTop

## Pré-requis

- Branches Gitflow : `main` (prod), `develop` (préprod), `feature/*`, `hotfix/*`.
- Jenkinsfile intégrés à `tiptop-front` et `tiptop-api` (cf. `references/`).
- Credentials Jenkins :
  - `gitea-token`
  - `registry-credentials`
  - `app-server-ssh` (clé vers le serveur qui héberge `app-envs`)
- Script `scripts/deploy.sh` disponible sur le serveur cible.

## Chaîne cible

```
Dev push -> Gitea -> webhook -> Jenkins (MultiBranch)
   -> Tests -> Build -> Docker build -> Push (registry privé)
   -> Deploy Dev (feature + develop)
   -> Deploy Préprod (develop)
   -> Deploy Prod (main + validation humaine)
```

## Déroulé détaillé

1. **Feature branch**
   - Jenkins récupère le commit.
   - Exécute tests/lint.
   - Construit l’artifact (JAR ou build React).
   - Construit l’image Docker `registry.wk-.../<module>:feature-<sha>`.
   - Pousse l’image, met à jour Dev via `scripts/deploy.sh dev <module>`.

2. **Merge → develop**
   - Pipeline relancé.
   - Tag image `develop-<build-number>`.
   - Déploiement préprod (`scripts/deploy.sh preprod <module>`).
   - Tests fonctionnels / validation métier.

3. **Merge → main**
   - Pipeline relancé avec tag `prod-<version>`.
   - Étape `input` Jenkins pour valider la prod.
   - `scripts/deploy.sh prod <module>` applique la nouvelle image.

4. **Hotfix**
   - Branche depuis `main`, pipeline identique au flux prod.
   - Une fois en prod, merge vers `develop`.

## Rollback

- Mettre à jour `app-envs/<env>/.env` avec l’ancien `IMAGE_TAG`.
- Lancer `scripts/deploy.sh <env> <module>` pour recharger l’image précédente.

## Contrôles qualité

- Tests unitaires obligatoires avant build image.
- Possibilité d’ajouter un stage SAST/Dependency-Check.
- Notifications (mail/Slack) sur succès/échec.
- Tableaux de bord Grafana pour vérifier la santé post-déploiement.
