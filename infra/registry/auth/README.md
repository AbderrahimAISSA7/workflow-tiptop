Générer le fichier `htpasswd` avant de lancer le stack :

```bash
docker run --rm httpd:2.4-alpine htpasswd -Bbn registry ChangeMe123 > infra/registry/auth/htpasswd
```

Le couple utilisateur/mot de passe doit correspondre aux variables `REGISTRY_USERNAME` / `REGISTRY_PASSWORD` déclarées dans `.env`.
