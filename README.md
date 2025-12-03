# HBase & Hive Learning Lab

Environnement d'apprentissage complet pour HBase et Hive avec Docker. **Tout est automatisé** - vous n'avez qu'à lancer un script.

---

## Démarrage Rapide

### 1. Installer Docker

**Windows/Mac :**
- Téléchargez Docker Desktop : https://www.docker.com/get-started
- Installez et lancez Docker Desktop
- Attendez que l'icône Docker apparaisse dans la barre des tâches

**Linux :**
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl start docker
```

### 2. Cloner le Projet

```bash
git clone https://github.com/AbidHamza/M2DE_Hbase.git
cd M2DE_Hbase
```

### 3. Lancer l'Environnement

**Windows (PowerShell) :**
```powershell
.\scripts\start.ps1
```

**Windows (Invite de commande) :**
```batch
scripts\start.bat
```

**Linux/Mac :**
```bash
./scripts/start.sh
```

**C'est tout !** Le script fait automatiquement :
- Vérifie Docker et Docker Compose
- Lance Docker Desktop si nécessaire
- Nettoie les conteneurs existants
- Libère les ports occupés
- Lance tous les services

**Temps d'attente :** 3-5 minutes pour le premier lancement.

---

## Vérifier que Tout Fonctionne

### Tester HBase

```bash
# Windows PowerShell
.\scripts\hbase-shell.ps1

# Windows Batch
scripts\hbase-shell.bat

# Linux/Mac
./scripts/hbase-shell.sh
```

Dans le shell HBase, tapez :
```
version
```

Vous devriez voir la version de HBase affichée.

### Tester Hive

```bash
# Windows PowerShell
.\scripts\hive-cli.ps1

# Windows Batch
scripts\hive-cli.bat

# Linux/Mac
./scripts/hive-cli.sh
```

Dans le CLI Hive, tapez :
```sql
SHOW DATABASES;
```

### Interfaces Web

Ouvrez votre navigateur :
- **HDFS NameNode** : http://localhost:9870
- **YARN ResourceManager** : http://localhost:8088
- **HBase Master** : http://localhost:16011

---

## Commencer les Rooms

Les **rooms** sont des parcours d'apprentissage guidés. Suivez-les dans l'ordre :

1. **Room 0** : Introduction
2. **Room 1** : HBase Basics
3. **Room 2** : HBase Advanced
4. **Room 3** : Hive Introduction
5. **Room 4** : Hive Advanced
6. **Room 5** : Intégration HBase-Hive
7. **Room 6** : Cas d'usage réels
8. **Room 7** : Projet final

**Comment travailler :**
```bash
# Aller dans une room
cd rooms/room-1_hbase_basics

# Lire le README de la room
cat README.md    # Linux/Mac
notepad README.md    # Windows
```

Chaque room contient :
- Des explications théoriques
- Des exercices pratiques étape par étape
- Des datasets dans `/resources`

---

## Commandes Essentielles

### Accéder aux Conteneurs

**Accéder au shell Hadoop :**
```bash
# Windows PowerShell
.\scripts\hadoop-shell.ps1

# Windows Batch
scripts\hadoop-shell.bat

# Linux/Mac
./scripts/hadoop-shell.sh
```

**Accéder au shell HBase :**
```bash
# Windows PowerShell
.\scripts\hbase-shell.ps1

# Windows Batch
scripts\hbase-shell.bat

# Linux/Mac
./scripts/hbase-shell.sh
```

**Accéder au CLI Hive :**
```bash
# Windows PowerShell
.\scripts\hive-cli.ps1

# Windows Batch
scripts\hive-cli.bat

# Linux/Mac
./scripts/hive-cli.sh
```

**Note :** Ces scripts détectent automatiquement le bon nom de conteneur, même si Docker Compose utilise des noms différents.

### Arrêter l'Environnement

```bash
# Windows PowerShell
.\scripts\stop.ps1

# Windows Batch
scripts\stop.bat

# Linux/Mac
./scripts/stop.sh
```

### Vérifier l'État

```bash
# Windows PowerShell
.\scripts\status.ps1

# Windows Batch
scripts\status.bat

# Linux/Mac
./scripts/status.sh
```

### Voir les Logs

```bash
docker compose logs
docker compose logs hadoop
docker compose logs hbase
```

### Trouver le Nom Exact d'un Conteneur

Si vous avez besoin d'exécuter `docker exec` manuellement, trouvez d'abord le nom exact :

```bash
# Voir tous les conteneurs avec leurs noms
docker compose ps

# Ou avec docker directement
docker ps --format "{{.Names}}\t{{.Status}}"
```

**Exemple de sortie :**
```
NAME                                STATUS
hbase-hive-learning-lab-hadoop     Up 5 minutes (healthy)
hbase-hive-learning-lab-hbase      Up 5 minutes (healthy)
```

**Utilisez ensuite le nom exact :**
```bash
docker exec -it hbase-hive-learning-lab-hadoop bash
```

**OU utilisez les scripts fournis** (recommandé - détection automatique) :
```bash
.\scripts\hadoop-shell.ps1    # Windows PowerShell
.\scripts\hbase-shell.ps1     # Windows PowerShell
.\scripts\hive-cli.ps1        # Windows PowerShell
```

---

## Résolution de Problèmes

### Docker Desktop n'est pas lancé

**Symptôme :** `Cannot connect to Docker` ou `docker: command not found`

**Solution :**
1. Lancez Docker Desktop depuis le menu Démarrer
2. Attendez 1-2 minutes que Docker démarre complètement
3. Vérifiez : `docker info` (ne doit pas afficher d'erreur)

### Conteneur "unhealthy"

**Solution :**
1. Attendez encore 1-2 minutes (les services peuvent prendre du temps)
2. Si ça persiste :
   ```bash
   docker compose logs hadoop
   docker compose logs hbase
   ```
3. Pour réinitialiser complètement :
   ```bash
   docker compose down -v
   .\scripts\start.ps1    # Relancer
   ```

### Erreur "No such container"

**Symptôme :** `Error response from daemon: No such container: hbase-hive-learning-lab-hadoop-1`

**Cause :** Le nom exact du conteneur peut varier selon votre version de Docker Compose.

**Solution :**
1. **Utilisez les scripts fournis** (recommandé) :
   ```bash
   .\scripts\hadoop-shell.ps1    # Au lieu de docker exec manuel
   .\scripts\hbase-shell.ps1
   .\scripts\hive-cli.ps1
   ```
   Ces scripts détectent automatiquement le bon nom de conteneur.

2. **Ou trouvez le nom exact manuellement :**
   ```bash
   docker compose ps
   # Utilisez le nom exact affiché dans la colonne NAME
   ```

### Port déjà utilisé

**Solution :**
Le script `start` libère automatiquement les ports. Si le problème persiste :

**Windows :**
```powershell
netstat -ano | findstr :16011
taskkill /PID <PID> /F
```

**Linux/Mac :**
```bash
lsof -i :16011
kill -9 <PID>
```

### "JAVA_HOME is not set"

**Solution :**
```bash
git pull origin main
.\scripts\start.ps1    # Relancer
```

### Réinitialiser Complètement

Si rien ne fonctionne :
```bash
docker compose down -v
docker system prune -a -f
.\scripts\start.ps1    # Relancer
```

---

## Commandes de Référence

### HBase Shell

**Commandes de base :**
```
create 'table', 'cf'                    # Créer une table
put 'table', 'row', 'cf:col', 'value'  # Insérer
get 'table', 'row'                      # Récupérer
scan 'table'                            # Voir toutes les données
count 'table'                           # Compter
delete 'table', 'row'                   # Supprimer
drop 'table'                            # Supprimer la table
list                                    # Lister les tables
exit                                    # Quitter
```

### Hive CLI

**Commandes de base :**
```sql
SHOW DATABASES;              # Lister les bases
CREATE DATABASE nom_db;      # Créer une base
USE nom_db;                  # Utiliser une base
SHOW TABLES;                 # Lister les tables
CREATE TABLE nom_table (...); # Créer une table
SELECT * FROM table;         # Voir les données
DROP TABLE table;            # Supprimer une table
exit;                        # Quitter (avec ;)
```

**Note :** Hive nécessite un point-virgule `;` à la fin de chaque commande. HBase non.

---

## Structure du Projet

```
M2DE_Hbase/
├── README.md                 # Ce fichier
├── docker-compose.yml        # Configuration Docker
│
├── docker/                   # Configurations Docker
│   ├── hadoop/
│   ├── hbase/
│   └── hive/
│
├── scripts/                  # Scripts utilitaires
│   ├── start.*              # Lancer l'environnement (RECOMMANDÉ)
│   ├── stop.*               # Arrêter l'environnement
│   ├── status.*             # Vérifier l'état
│   ├── hbase-shell.*        # Accéder à HBase Shell
│   └── hive-cli.*           # Accéder à Hive CLI
│
├── resources/                # Datasets pour les exercices
│   ├── customers/
│   ├── iot-logs/
│   ├── sales/
│   └── sensors/
│
└── rooms/                    # VOS TRAVAUX ICI
    ├── room-0_introduction/
    ├── room-1_hbase_basics/
    ├── room-2_hbase_advanced/
    ├── room-3_hive_introduction/
    ├── room-4_hive_advanced/
    ├── room-5_hbase_hive_integration/
    ├── room-6_real_world_scenarios/
    └── room-7_final_project/
```

---

## Objectifs du Module

À la fin de ce parcours, vous serez capable de :
- Comprendre Hadoop, HBase et Hive
- Créer et manipuler des tables HBase (CRUD complet)
- Analyser des données avec Hive (requêtes SQL)
- Intégrer HBase et Hive dans un workflow analytique
- Appliquer ces notions à des datasets réels

**Aucun prérequis avancé nécessaire** - Tout est fourni et expliqué étape par étape.

---

## Support

Si vous rencontrez un problème :

1. Vérifiez que vous avez bien suivi toutes les étapes
2. Consultez les logs : `docker compose logs`
3. Vérifiez que votre dépôt est à jour : `git pull origin main`
4. Utilisez le script `start` pour réinitialiser : `.\scripts\start.ps1`

**Bon apprentissage !**
