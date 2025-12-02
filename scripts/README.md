# Scripts Utilitaires - Multi-plateforme

**Ce fichier explique comment utiliser les scripts d'aide.**

**Retour au README principal → [README.md](../README.md)**

---

## Scripts Disponibles

### Démarrer l'environnement

**Windows PowerShell :**
```powershell
.\scripts\start.ps1
```

**Windows Batch :**
```batch
scripts\start.bat
```

**Linux/Mac :**
```bash
chmod +x scripts/start.sh  # Première fois seulement
./scripts/start.sh
```

### Arrêter l'environnement

**Windows PowerShell :**
```powershell
.\scripts\stop.ps1
```

**Windows Batch :**
```batch
scripts\stop.bat
```

**Linux/Mac :**
```bash
./scripts/stop.sh
```

### Vérifier l'état

**Windows PowerShell :**
```powershell
.\scripts\status.ps1
```

**Windows Batch :**
```batch
scripts\status.bat
```

**Linux/Mac :**
```bash
./scripts/status.sh
```

### Accéder aux Shells

**HBase Shell :**

Windows PowerShell : `.\scripts\hbase-shell.ps1`
Windows Batch : `scripts\hbase-shell.bat`
Linux/Mac : `./scripts/hbase-shell.sh`

**Hive CLI :**

Windows PowerShell : `.\scripts\hive-cli.ps1`
Windows Batch : `scripts\hive-cli.bat`
Linux/Mac : `./scripts/hive-cli.sh`

---

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

---

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

---

## Dépannage

**Problème avec PowerShell sur Windows :**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Problème "Permission denied" sur Linux/Mac :**
```bash
chmod +x scripts/*.sh
```

**Pour plus d'aide → [FAQ.md](../FAQ.md)**
