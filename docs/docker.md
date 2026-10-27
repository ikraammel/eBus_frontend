# Fichiers Docker du frontend

Ces fichiers sont préparés pour la racine Git du dépôt [eBus_frontend](https://github.com/ikraammel/eBus_frontend), au même niveau que son dossier `eBus_front/` :

```text
eBus_frontend/
  Dockerfile
  .dockerignore
  nginx.conf
  eBus_front/
    pubspec.yaml
    lib/
```

Le projet Flutter lit `API_BASE_URL` avec `String.fromEnvironment` dans `lib/constants/constants.dart`. Cette adaptation est déjà présente dans la version distante récupérée le 27 octobre 2026. Le Dockerfile refuse de construire avec l'ancienne constante d'émulateur.

Depuis la racine du dépôt frontend :

```powershell
docker build --build-arg API_BASE_URL=https://ebus-backend-ao2u.onrender.com -t ebus-frontend:local .
docker run --rm -p 127.0.0.1:18082:8080 ebus-frontend:local
```

Ouvrir `http://127.0.0.1:18082`. L'URL API est publique et compilée dans le JavaScript ; aucun secret ne doit être transmis par argument de build. Le backend doit autoriser cette origine pour les appels navigateur authentifiés. Une image configurée avec l'API Render reste liée à Render même si une image backend a également été construite.

La base Flutter utilise le tag `stable`, configurable avec `FLUTTER_IMAGE`. Après une première construction validée, figer un tag ou digest adapté au SDK du projet pour améliorer la reproductibilité. Le build et l'exécution de cette image frontend restent à valider.
