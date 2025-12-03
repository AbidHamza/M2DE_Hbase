# 🚀 RÉPARATION RAPIDE - TOUT RÉSOUDRE EN 3 ÉTAPES

## Étape 1 : Nettoyer Git

```bash
# Sauvegarder vos modifications (si importantes)
git stash

# OU si vous voulez les perdre et repartir à zéro
git reset --hard origin/main

# Récupérer la dernière version
git pull origin main
```

## Étape 2 : Nettoyer Docker

```bash
# Arrêter et supprimer TOUT
docker-compose down -v

# Nettoyer les images et volumes inutilisés
docker system prune -a -f
```

## Étape 3 : Lancer avec le script setup (FAIT TOUT AUTOMATIQUEMENT)

**Windows PowerShell :**
```powershell
.\scripts\setup.ps1
```

**Linux/Mac :**
```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

**Windows Batch :**
```batch
scripts\setup.bat
```

---

## ✅ Le script setup fait AUTOMATIQUEMENT :

1. ✅ Vérifie Docker et Docker Compose
2. ✅ Lance Docker Desktop si nécessaire
3. ✅ Nettoie tous les conteneurs et volumes
4. ✅ Reconstruit les images proprement
5. ✅ Libère les ports occupés
6. ✅ Récupère les fichiers manquants
7. ✅ Lance l'environnement avec retry automatique
8. ✅ Affiche l'état final

---

## 🎯 RÉSULTAT ATTENDU

Après le script setup, vous devriez voir :

```
✅ Conteneurs démarrés avec succès
✅ Environnement démarré
```

Et tous les conteneurs devraient être "Healthy" ou "Running" :

```
docker-compose ps
```

---

## 🆘 SI ÇA NE MARCHE TOUJOURS PAS

1. **Vérifier Docker Desktop :**
   ```bash
   docker info
   ```
   Doit afficher des informations, pas d'erreur.

2. **Voir les logs :**
   ```bash
   docker-compose logs hadoop
   docker-compose logs hbase
   ```

3. **Réinitialiser complètement :**
   ```bash
   docker-compose down -v
   docker system prune -a -f --volumes
   git reset --hard origin/main
   git pull origin main
   .\scripts\setup.ps1
   ```

