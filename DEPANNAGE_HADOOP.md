# Dépannage : Erreur Hadoop "unhealthy"

**Si vous voyez cette erreur : `dependency failed to start: container hbase-hive-learning-lab-hadoop is unhealthy`**

## Solution Rapide (À Essayer en Premier)

**Étape 1 : Arrêtez tout**
```bash
docker-compose down
```

**Étape 2 : Supprimez les volumes et relancez**
```bash
docker-compose down -v
docker-compose up -d
```

**Étape 3 : Attendez 2-3 minutes puis vérifiez**
```bash
docker-compose ps
```

Tous les conteneurs doivent être "Up" et "healthy".

---

## Si Ça Ne Fonctionne Toujours Pas

### Solution 1 : Vérifier les Logs Hadoop

Regardez ce qui ne va pas :
```bash
docker-compose logs hadoop
```

**Erreurs courantes :**

**Si vous voyez "Port already in use" :**
- Un autre programme utilise le port 9870, 8088 ou 9000
- Arrêtez ce programme ou modifiez les ports dans `docker-compose.yml`

**Si vous voyez "Permission denied" :**
- Problème de permissions Docker
- Sur Windows : Vérifiez que Docker Desktop a les permissions nécessaires
- Sur Linux/Mac : Essayez avec `sudo` (non recommandé, mais peut aider)

**Si vous voyez "Cannot format" ou erreur HDFS :**
- Le système de fichiers HDFS est corrompu
- Solution : `docker-compose down -v` puis `docker-compose up -d`

**Si vous voyez "/start-hadoop.sh: cannot execute: required file not found" :**
- Problème de fin de ligne Windows (CRLF vs LF)
- Solution : Mettez à jour le dépôt avec `git pull origin main`, puis :
  ```bash
  docker-compose down
  docker-compose build --no-cache hadoop
  docker-compose up -d
  ```

### Solution 2 : Reconstruire l'Image Hadoop

Si le problème persiste, reconstruisez l'image :
```bash
docker-compose down
docker-compose build --no-cache hadoop
docker-compose up -d
```

### Solution 3 : Vérifier les Ressources

Hadoop a besoin de ressources suffisantes :
- **RAM minimum :** 4GB disponible
- **Espace disque :** Au moins 10GB libre

Vérifiez dans Docker Desktop (Windows/Mac) ou avec `docker stats`.

### Solution 4 : Problème de Connexion Internet

Si les images ne se téléchargent pas correctement :
```bash
# Testez votre connexion Docker
docker pull eclipse-temurin:8-jdk

# Si ça bloque, vérifiez votre connexion Internet
```

---

## Vérification Finale

Une fois que tout est démarré, vérifiez :

**1. État des conteneurs :**
```bash
docker-compose ps
```
Tous doivent être "Up" et "healthy".

**2. Test Hadoop :**
```bash
docker exec -it hbase-hive-learning-lab-hadoop-1 hdfs dfsadmin -report
```
Vous devriez voir un rapport HDFS.

**3. Interface Web :**
Ouvrez dans votre navigateur : http://localhost:9870
Vous devriez voir l'interface HDFS.

---

## Si Rien Ne Fonctionne

**Dernière solution : Réinitialisation complète**

```bash
# Arrêtez tout
docker-compose down -v

# Supprimez toutes les images
docker rmi $(docker images -q m2de_hbase*)

# Reconstruisez tout depuis le début
docker-compose build --no-cache
docker-compose up -d
```

**ATTENTION :** Cela supprimera toutes les données et prendra 15-20 minutes.

---

## Besoin d'Aide ?

1. Consultez la [FAQ.md](FAQ.md) pour d'autres problèmes
2. Vérifiez les logs : `docker-compose logs`
3. Vérifiez votre connexion Internet
4. Vérifiez que Docker Desktop est bien lancé (Windows/Mac)

---

## Message pour le Professeur

Si aucune solution ne fonctionne, envoyez :
- Les logs Hadoop : `docker-compose logs hadoop > hadoop_logs.txt`
- L'état des conteneurs : `docker-compose ps`
- Votre système d'exploitation et version Docker : `docker --version`

