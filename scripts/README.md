# Scripts Utilitaires - Multi-plateforme

Ce dossier contient des scripts pour Windows, Linux et Mac pour simplifier l'utilisation de l'environnement.

## Scripts de Gestion de l'Environnement

### Démarrer l'environnement

**Windows :**
```powershell
# PowerShell
.\scripts\start.ps1

# Ou Batch
scripts\start.bat
```

**Linux/Mac :**
```bash
chmod +x scripts/start.sh  # Première fois seulement
./scripts/start.sh
```

### Arrêter l'environnement

**Windows :**
```powershell
.\scripts\stop.ps1
# Ou
scripts\stop.bat
```

**Linux/Mac :**
```bash
./scripts/stop.sh
```

### Vérifier l'état

**Windows :**
```powershell
.\scripts\status.ps1
# Ou
scripts\status.bat
```

**Linux/Mac :**
```bash
./scripts/status.sh
```

### Accéder aux Shells

**HBase Shell :**

Windows :
```powershell
.\scripts\hbase-shell.ps1
# Ou
scripts\hbase-shell.bat
```

Linux/Mac :
```bash
./scripts/hbase-shell.sh
```

**Hive CLI :**

Windows :
```powershell
.\scripts\hive-cli.ps1
# Ou
scripts\hive-cli.bat
```

Linux/Mac :
```bash
./scripts/hive-cli.sh
```

## Scripts de Test et Initialisation

### test-environment.sh

Teste que tous les services Docker sont opérationnels.

**Utilisation :**
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

**Utilisation :**
```bash
# Sur Linux/Mac
./scripts/init-hdfs.sh

# Sur Windows (dans Git Bash ou WSL)
bash scripts/init-hdfs.sh

# Ou directement dans Docker
docker exec hbase-hive-learning-lab-hadoop-1 bash /opt/scripts/init-hdfs.sh
```

## Notes par Plateforme

### Windows

Vous avez le choix entre :
- **PowerShell** (.ps1) - Recommandé si disponible
- **Batch** (.bat) - Alternative si PowerShell n'est pas disponible
- **Git Bash** - Pour utiliser les scripts .sh

### Linux/Mac

1. Rendez les scripts exécutables (première fois seulement) :
   ```bash
   chmod +x scripts/*.sh
   ```

2. Utilisez les scripts directement :
   ```bash
   ./scripts/start.sh
   ```

### Toutes les Plateformes

Les scripts sont aussi montés dans les conteneurs Docker et accessibles via `/opt/scripts/` si vous êtes déjà dans un conteneur.
