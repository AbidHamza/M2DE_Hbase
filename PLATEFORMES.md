# Support Multi-plateforme

Ce dépôt fonctionne sur **Windows, Linux et Mac**. Voici comment utiliser les scripts selon votre système d'exploitation.

## Windows

### Option 1 : PowerShell (Recommandé)

Si vous avez PowerShell disponible :

```powershell
# Démarrer
.\scripts\start.ps1

# Arrêter
.\scripts\stop.ps1

# Vérifier l'état
.\scripts\status.ps1

# HBase Shell
.\scripts\hbase-shell.ps1

# Hive CLI
.\scripts\hive-cli.ps1
```

### Option 2 : Batch (.bat)

Si PowerShell n'est pas disponible, utilisez les scripts Batch :

```batch
REM Démarrer
scripts\start.bat

REM Arrêter
scripts\stop.bat

REM Vérifier l'état
scripts\status.bat

REM HBase Shell
scripts\hbase-shell.bat

REM Hive CLI
scripts\hive-cli.bat
```

### Option 3 : Git Bash

Si vous avez Git Bash installé, vous pouvez utiliser les scripts Bash :

```bash
# Rendre exécutables (première fois)
chmod +x scripts/*.sh

# Utiliser
./scripts/start.sh
./scripts/stop.sh
./scripts/status.sh
./scripts/hbase-shell.sh
./scripts/hive-cli.sh
```

## Linux

### Utilisation des Scripts Bash

```bash
# Rendre les scripts exécutables (première fois seulement)
chmod +x scripts/*.sh

# Démarrer
./scripts/start.sh

# Arrêter
./scripts/stop.sh

# Vérifier l'état
./scripts/status.sh

# HBase Shell
./scripts/hbase-shell.sh

# Hive CLI
./scripts/hive-cli.sh
```

### Commandes Manuelles

Si vous préférez utiliser les commandes directement :

```bash
# Démarrer
docker-compose up -d

# Vérifier l'état
docker-compose ps

# HBase Shell
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell

# Hive CLI
docker exec -it hbase-hive-learning-lab-hive-1 hive
```

## Mac

### Utilisation des Scripts Bash

Identique à Linux :

```bash
# Rendre les scripts exécutables (première fois seulement)
chmod +x scripts/*.sh

# Démarrer
./scripts/start.sh

# Arrêter
./scripts/stop.sh

# Vérifier l'état
./scripts/status.sh

# HBase Shell
./scripts/hbase-shell.sh

# Hive CLI
./scripts/hive-cli.sh
```

### Commandes Manuelles

```bash
# Démarrer
docker-compose up -d

# Vérifier l'état
docker-compose ps

# HBase Shell
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell

# Hive CLI
docker exec -it hbase-hive-learning-lab-hive-1 hive
```

## Dépannage par Plateforme

### Windows

**Problème : "Execution Policy" avec PowerShell**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Problème : Les scripts .bat ne fonctionnent pas**
- Vérifiez que vous êtes dans le bon dossier
- Utilisez `cd` pour aller dans le dossier du projet
- Essayez avec le chemin complet

### Linux/Mac

**Problème : "Permission denied"**
```bash
chmod +x scripts/*.sh
```

**Problème : "No such file or directory"**
- Vérifiez que vous êtes dans le dossier du projet : `pwd`
- Utilisez le chemin relatif : `./scripts/start.sh` (avec le point)

## Commandes Universelles

Ces commandes fonctionnent sur **toutes les plateformes** :

```bash
# Démarrer (toutes plateformes)
docker-compose up -d

# Arrêter (toutes plateformes)
docker-compose down

# Vérifier l'état (toutes plateformes)
docker-compose ps

# Voir les logs (toutes plateformes)
docker-compose logs
```

## Interfaces Web

Les interfaces Web fonctionnent sur **toutes les plateformes** :

- **HDFS NameNode** : http://localhost:9870
- **YARN ResourceManager** : http://localhost:8088
- **HBase Master** : http://localhost:16010

Ouvrez simplement ces URLs dans votre navigateur, quel que soit votre système d'exploitation.

## Résumé Rapide

| Action | Windows (PS) | Windows (Batch) | Linux/Mac |
|--------|--------------|-----------------|-----------|
| Démarrer | `.\scripts\start.ps1` | `scripts\start.bat` | `./scripts/start.sh` |
| Arrêter | `.\scripts\stop.ps1` | `scripts\stop.bat` | `./scripts/stop.sh` |
| État | `.\scripts\status.ps1` | `scripts\status.bat` | `./scripts/status.sh` |
| HBase | `.\scripts\hbase-shell.ps1` | `scripts\hbase-shell.bat` | `./scripts/hbase-shell.sh` |
| Hive | `.\scripts\hive-cli.ps1` | `scripts\hive-cli.bat` | `./scripts/hive-cli.sh` |

**Toutes les plateformes peuvent aussi utiliser directement les commandes Docker :**
```bash
docker-compose up -d
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell
docker exec -it hbase-hive-learning-lab-hive-1 hive
```

