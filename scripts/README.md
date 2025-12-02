# Scripts utilitaires

Ce dossier contient les scripts utilitaires pour gérer l'environnement.

## Scripts disponibles

### test-environment.sh

Teste que tous les services Docker sont opérationnels.

**Utilisation** :
```bash
# Sur Linux/Mac
./scripts/test-environment.sh

# Sur Windows (dans Git Bash ou WSL)
bash scripts/test-environment.sh

# Ou directement dans Docker
docker exec hbase-hive-learning-lab-hadoop-1 bash /opt/scripts/test-environment.sh
```

### init-hdfs.sh

Initialise les répertoires HDFS nécessaires pour les rooms.

**Utilisation** :
```bash
# Sur Linux/Mac
./scripts/init-hdfs.sh

# Sur Windows (dans Git Bash ou WSL)
bash scripts/init-hdfs.sh

# Ou directement dans Docker
docker exec hbase-hive-learning-lab-hadoop-1 bash /opt/scripts/init-hdfs.sh
```

## Notes pour Windows

Sur Windows, vous pouvez :
1. Utiliser **Git Bash** (inclus avec Git)
2. Utiliser **WSL** (Windows Subsystem for Linux)
3. Exécuter les commandes directement dans les conteneurs Docker

Les scripts sont automatiquement montés dans les conteneurs Docker et accessibles via `/opt/scripts/`.

