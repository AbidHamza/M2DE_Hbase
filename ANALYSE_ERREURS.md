# 🔍 ANALYSE DES ERREURS ET SOLUTIONS

## ❌ ERREUR 1 : Git Pull Bloqué

**Message d'erreur :**
```
error: Your local changes to the following files would be overwritten by merge:
  docker-compose.yml
  docker/hadoop/Dockerfile
  scripts/hbase-shell.sh
  ...
Please commit your changes or stash them before you merge.
```

**Cause :**
- Vous avez des modifications locales non sauvegardées
- Git ne peut pas fusionner car vos changements seraient écrasés

**Solutions :**

### Option 1 : Sauvegarder vos modifications (RECOMMANDÉ)
```bash
# Sauvegarder vos modifications
git stash

# Récupérer les dernières modifications
git pull origin main

# Récupérer vos modifications sauvegardées
git stash pop
```

### Option 2 : Commiter vos modifications
```bash
# Ajouter tous les fichiers modifiés
git add -A

# Créer un commit
git commit -m "Mes modifications locales"

# Récupérer les dernières modifications
git pull origin main
```

### Option 3 : Écraser vos modifications (ATTENTION : perte de données)
```bash
# Réinitialiser complètement (SUPPRIME vos modifications locales)
git reset --hard origin/main

# Récupérer les dernières modifications
git pull origin main
```

---

## ❌ ERREUR 2 : Docker Build Échoue - COPY ./scripts

**Message d'erreur :**
```
ERROR [3/3] COPY ./scripts /opt/scripts
failed to solve: failed to compute cache key: failed to calculate checksum of ref
"/scripts": not found
```

**Cause :**
- Le Dockerfile essaie de copier `./scripts` mais le **contexte de build** est `./docker/hadoop`
- Le répertoire `scripts` est à la racine du projet, pas dans `docker/hadoop/`
- Docker ne peut pas accéder aux fichiers en dehors du contexte de build

**Explication technique :**
```yaml
# Dans docker-compose.yml
hadoop:
  build:
    context: ./docker/hadoop  # ← Contexte limité à ce dossier
    dockerfile: Dockerfile
```

Quand le contexte est `./docker/hadoop`, Docker ne voit QUE les fichiers dans ce dossier. Il ne peut pas accéder à `../scripts/`.

**Solution :**
Les scripts sont déjà montés comme **volume** dans `docker-compose.yml` :
```yaml
volumes:
  - ./scripts:/opt/scripts:ro  # ← Les scripts sont montés ici
```

**Donc il ne faut PAS copier les scripts dans le Dockerfile !**

Si vous avez un Dockerfile avec `COPY ./scripts`, **supprimez cette ligne**.

---

## ❌ ERREUR 3 : Container Hadoop "unhealthy"

**Message d'erreur :**
```
dependency failed to start: container hbase-hive-learning-lab-hadoop is unhealthy
```

**Cause :**
- Le container Hadoop ne démarre pas correctement
- Le healthcheck échoue
- Souvent causé par l'erreur de build précédente

**Solutions :**

### Solution 1 : Nettoyer et reconstruire
```bash
# Arrêter tous les conteneurs
docker-compose down -v

# Reconstruire sans cache
docker-compose build --no-cache

# Relancer
docker-compose up -d
```

### Solution 2 : Vérifier les logs
```bash
# Voir les logs Hadoop
docker-compose logs hadoop

# Voir les logs de tous les services
docker-compose logs
```

### Solution 3 : Utiliser le script setup (RECOMMANDÉ)
```bash
# Windows PowerShell
.\scripts\setup.ps1

# Linux/Mac
./scripts/setup.sh
```

Le script `setup` fait automatiquement :
- ✅ Nettoyage complet
- ✅ Reconstruction des images
- ✅ Lancement avec vérifications

---

## ⚠️ AVERTISSEMENT : Version obsolète dans docker-compose.yml

**Message :**
```
WARN [0000] docker-compose.yml: the attribute `version` is obsolete
```

**Cause :**
- Docker Compose V2 n'utilise plus l'attribut `version`
- C'est juste un avertissement, pas une erreur bloquante

**Solution :**
Supprimer la ligne `version: '3.8'` ou `version: '3'` du début de `docker-compose.yml` si elle existe.

---

## 🎯 SOLUTION COMPLÈTE ET RAPIDE

**Pour résoudre TOUS les problèmes d'un coup :**

```bash
# 1. Sauvegarder vos modifications locales (si importantes)
git stash

# 2. Récupérer la dernière version
git pull origin main

# 3. Utiliser le script setup qui fait TOUT automatiquement
# Windows PowerShell:
.\scripts\setup.ps1

# Linux/Mac:
./scripts/setup.sh
```

Le script `setup` va :
1. ✅ Vérifier Docker et Docker Compose
2. ✅ Nettoyer tous les conteneurs et volumes
3. ✅ Reconstruire les images proprement
4. ✅ Lancer l'environnement avec auto-réparation
5. ✅ Gérer automatiquement les ports, fichiers manquants, etc.

---

## 📋 CHECKLIST DE VÉRIFICATION

Avant de lancer, vérifiez :

- [ ] Docker Desktop est lancé (Windows/Mac)
- [ ] Docker daemon fonctionne : `docker info`
- [ ] Pas de modifications locales non commitées (ou stashées)
- [ ] Vous êtes dans le bon répertoire : `M2DE_Hbase`
- [ ] Le fichier `docker-compose.yml` existe
- [ ] Le répertoire `scripts/` existe

---

## 🆘 SI RIEN NE MARCHE

1. **Nettoyer complètement :**
   ```bash
   docker-compose down -v
   docker system prune -a -f
   ```

2. **Vérifier les fichiers essentiels :**
   ```bash
   ls docker-compose.yml
   ls scripts/setup.*
   ls docker/hadoop/Dockerfile
   ```

3. **Relancer avec le script setup :**
   ```bash
   .\scripts\setup.ps1  # Windows
   # ou
   ./scripts/setup.sh   # Linux/Mac
   ```

4. **Si ça ne marche toujours pas, voir les logs :**
   ```bash
   docker-compose logs hadoop
   docker-compose logs hbase
   ```

