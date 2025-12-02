# Commandes Rapides - Aide-Mémoire

Ce fichier contient toutes les commandes essentielles pour un accès rapide.

## Docker

```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Vérifier l'état
docker-compose ps

# Voir les logs
docker-compose logs
docker-compose logs hbase
```

## HBase Shell

```bash
# Ouvrir le shell
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell

# Commandes HBase
version
status
list
create 'table', 'famille'
describe 'table'
put 'table', 'row', 'colonne', 'valeur'
get 'table', 'row'
scan 'table'
count 'table'
delete 'table', 'row'
exit
```

## Hive CLI

```bash
# Ouvrir Hive
docker exec -it hbase-hive-learning-lab-hive-1 hive

# Commandes Hive (N'OUBLIEZ PAS LE ;)
SHOW DATABASES;
USE database_name;
SHOW TABLES;
CREATE TABLE ...;
SELECT * FROM table;
exit;
```

## HDFS

```bash
# Entrer dans Hadoop
docker exec -it hbase-hive-learning-lab-hadoop-1 bash

# Commandes HDFS
hdfs dfs -ls /
hdfs dfs -mkdir /dossier
hdfs dfs -put fichier /destination
hdfs dfs -cat /fichier
hdfs dfsadmin -report
```

## Scripts d'Aide

### Windows

**PowerShell :**
```powershell
.\scripts\start.ps1
.\scripts\stop.ps1
.\scripts\status.ps1
.\scripts\hbase-shell.ps1
.\scripts\hive-cli.ps1
```

**Batch (Alternative) :**
```batch
scripts\start.bat
scripts\stop.bat
scripts\status.bat
scripts\hbase-shell.bat
scripts\hive-cli.bat
```

### Linux/Mac

```bash
# Rendre exécutables (première fois seulement)
chmod +x scripts/*.sh

# Utiliser les scripts
./scripts/start.sh
./scripts/stop.sh
./scripts/status.sh
./scripts/hbase-shell.sh
./scripts/hive-cli.sh
```

## Interfaces Web

- HDFS : http://localhost:9870
- YARN : http://localhost:8088
- HBase : http://localhost:16010

## Git

```bash
git add .
git commit -m "Room X terminée"
git push origin main
git status
git pull origin main
```

