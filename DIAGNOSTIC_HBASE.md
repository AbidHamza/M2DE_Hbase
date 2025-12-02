# Diagnostic HBase "unhealthy"

**Si HBase est "unhealthy" alors que Hadoop et ZooKeeper sont "Healthy"**

## Diagnostic Immédiat

**1. Regardez les logs HBase :**
```bash
docker-compose logs hbase
```

**2. Sauvegardez les logs :**
```bash
docker-compose logs hbase > hbase_erreur.txt
```

## Erreurs Courantes et Solutions

### Erreur 1 : "Connection refused" ou "Cannot connect to Hadoop"

**Cause :** HBase ne peut pas se connecter à HDFS

**Solution :**
```bash
# Vérifiez que Hadoop est bien démarré
docker exec -it hbase-hive-learning-lab-hadoop-1 hdfs dfsadmin -report

# Si Hadoop fonctionne, redémarrez HBase
docker-compose restart hbase
```

### Erreur 2 : "Connection refused" à ZooKeeper

**Cause :** HBase ne peut pas se connecter à ZooKeeper

**Solution :**
```bash
# Vérifiez que ZooKeeper fonctionne
docker exec -it hbase-hive-learning-lab-zookeeper-1 nc -z localhost 2181

# Si ZooKeeper fonctionne, redémarrez HBase
docker-compose restart hbase
```

### Erreur 3 : "JAVA_HOME is not set" dans HBase

**Cause :** JAVA_HOME n'est pas correctement configuré dans HBase

**Solution :**
```bash
# Mettez à jour le dépôt
git pull origin main

# Reconstruisez HBase
docker-compose build --no-cache hbase
docker-compose up -d
```

### Erreur 4 : "HBase directory /hbase does not exist in HDFS"

**Cause :** Le répertoire HBase n'existe pas dans HDFS

**Solution :**
```bash
# Créez le répertoire manuellement
docker exec -it hbase-hive-learning-lab-hadoop-1 hdfs dfs -mkdir -p /hbase

# Redémarrez HBase
docker-compose restart hbase
```

## Solution Générale

**Si aucune des solutions ci-dessus ne fonctionne :**

```bash
# 1. Arrêtez tout
docker-compose down

# 2. Mettez à jour le dépôt
git pull origin main

# 3. Supprimez les volumes HBase
docker volume rm m2de_hbase_hbase-data

# 4. Reconstruisez HBase
docker-compose build --no-cache hbase

# 5. Relancez tout
docker-compose up -d

# 6. Attendez 2-3 minutes puis vérifiez
docker-compose ps
```

## Vérification

**Une fois que HBase est démarré :**

```bash
# Vérifiez l'état
docker-compose ps

# Testez HBase
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell
# Tapez : version
# Puis : exit
```

## Besoin d'Aide ?

**Envoyez :**
1. Les logs HBase : `docker-compose logs hbase`
2. L'état des conteneurs : `docker-compose ps`
3. Les logs Hadoop : `docker-compose logs hadoop` (premières lignes)

---

**Retour au README principal → [README.md](README.md)**

