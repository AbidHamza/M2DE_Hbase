# HBase & Hive Learning Lab

Parcours d'apprentissage complet et guidé pour maîtriser HBase et Hive dans l'écosystème Hadoop.

---

## Table des Matières

1. [Démarrage Rapide](#démarrage-rapide)
2. [Prérequis](#prérequis)
3. [Installation et Configuration](#installation-et-configuration)
4. [Lancement de l'Environnement](#lancement-de-lenvironnement)
5. [Vérification et Tests](#vérification-et-tests)
6. [Structure du Projet](#structure-du-projet)
7. [Scripts Disponibles](#scripts-disponibles)
8. [Travail dans les Rooms](#travail-dans-les-rooms)
9. [Résolution de Problèmes](#résolution-de-problèmes)
10. [Commandes de Référence](#commandes-de-référence)

---

## Démarrage Rapide

Pour démarrer rapidement, **une seule commande suffit** :

**Linux/Mac :**
```bash
chmod +x scripts/*.sh && ./scripts/setup.sh
```

**Windows PowerShell :**
```powershell
.\scripts\setup.ps1
```

**Windows Batch :**
```batch
scripts\setup.bat
```

Le script `setup` va :
1. ✅ Vérifier et installer automatiquement les dépendances manquantes
2. ✅ Lancer Docker Desktop si nécessaire (Windows/Mac)
3. ✅ Lancer automatiquement l'environnement
4. ✅ Afficher l'état des services

**Ensuite :**
- Attendez 2-3 minutes que tous les services démarrent
- Vérifiez l'état : `docker compose ps` ou `docker-compose ps`
- Commencez la Room 0 : `cd rooms/room-0_introduction`

---

## Prérequis

### Logiciels Requis

- **Docker** : Version 20.10 ou supérieure
  - Installation : https://www.docker.com/get-started
  - Vérification : `docker --version`
- **Docker Compose** : Version 1.29 ou supérieure (ou Docker Compose V2)
  - Généralement inclus avec Docker Desktop
  - Vérification : `docker-compose --version` ou `docker compose version`
- **Git** : Version 2.0 ou supérieure
  - Installation : https://git-scm.com/downloads
  - Vérification : `git --version`

### Ressources Système Recommandées

- **RAM** : Minimum 4GB, recommandé 8GB
- **Espace disque** : Minimum 5GB, recommandé 10GB
- **CPU** : 2 cœurs minimum

### Plateformes Supportées

- Windows 10/11 (avec Docker Desktop)
- macOS 10.15+ (avec Docker Desktop)
- Linux (Ubuntu 20.04+, Debian 10+, CentOS 7+)

---

## Installation et Configuration

### Étape 1 : Installer Docker

**Windows/Mac :**
1. Téléchargez Docker Desktop depuis https://www.docker.com/get-started
2. Installez et lancez Docker Desktop
3. Attendez que l'icône Docker apparaisse dans la barre des tâches
4. Vérifiez : `docker info` (ne doit pas afficher d'erreur)

**Linux :**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker

# CentOS/RHEL
sudo yum install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

### Étape 2 : Cloner le Dépôt

**Première fois :**
```bash
git clone https://github.com/AbidHamza/M2DE_Hbase.git
cd M2DE_Hbase
```

**Mise à jour (si déjà cloné) :**
```bash
cd M2DE_Hbase
git pull origin main
```

**En cas de conflit Git :**
```bash
# Option 1 : Sauvegarder vos modifications
git stash
git pull origin main

# Option 2 : Réinitialiser complètement (ATTENTION : supprime vos modifications locales)
git reset --hard origin/main
git pull origin main
```

---

## Lancement de l'Environnement

### Méthode la Plus Simple : Script `setup` (UNE SEULE COMMANDE)

Le script `setup` vérifie et installe automatiquement les dépendances manquantes, puis lance l'environnement. **C'est la méthode recommandée pour démarrer rapidement.**

**Linux/Mac :**
```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

**Windows PowerShell :**
```powershell
.\scripts\setup.ps1
```

**Windows Batch :**
```batch
scripts\setup.bat
```

**Ce que fait le script `setup` :**
1. ✅ Vérifie Docker (et tente de l'installer sur Linux si possible)
2. ✅ Vérifie Docker Desktop (et le lance automatiquement sur Windows/Mac)
3. ✅ Vérifie Docker Compose (et l'installe si nécessaire sur Linux)
4. ✅ Vérifie Git (optionnel, installation automatique sur Linux)
5. ✅ Lance automatiquement l'environnement

### Méthode Alternative : Script `run`

Le script `run` effectue toutes les vérifications nécessaires avant de lancer l'environnement (sans installation automatique).

**Linux/Mac :**
```bash
chmod +x scripts/*.sh
./scripts/run.sh
```

**Windows PowerShell :**
```powershell
.\scripts\run.ps1
```

**Windows Batch :**
```batch
scripts\run.bat
```

### Méthode Alternative : Scripts `start`

Les scripts `start` effectuent également une vérification automatique :

**Linux/Mac :**
```bash
./scripts/start.sh
```

**Windows PowerShell :**
```powershell
.\scripts\start.ps1
```

**Windows Batch :**
```batch
scripts\start.bat
```

### Méthode Manuelle : Docker Compose Direct

Si vous préférez lancer manuellement :

```bash
# Détecter automatiquement docker-compose V1 ou V2
docker-compose up -d
# OU
docker compose up -d
```

**Note :** Le projet supporte automatiquement Docker Compose V1 (`docker-compose`) et V2 (`docker compose`).

### Ce qui se passe lors du lancement

1. Vérification automatique des prérequis (Docker, ports, fichiers, etc.)
2. Démarrage des conteneurs dans l'ordre :
   - Hadoop (HDFS, YARN)
   - ZooKeeper
   - HBase (dépend de Hadoop et ZooKeeper)
   - Hive Metastore (dépend de Hadoop)
   - Hive (dépend de Hadoop, HBase et Hive Metastore)
3. Attente du démarrage complet (2-3 minutes)

---

## Vérification et Tests

### Vérifier l'État des Services

```bash
# Avec docker-compose V1
docker-compose ps

# Avec docker compose V2
docker compose ps
```

**Résultat attendu :** Tous les conteneurs doivent être "Up" et "healthy" (ou au moins "Up" si le healthcheck n'est pas encore passé).

**Si un conteneur est "unhealthy" :**
- Attendez encore 1-2 minutes (les healthchecks peuvent prendre du temps)
- Si après 5 minutes c'est toujours "unhealthy", consultez la section Résolution de Problèmes

### Tester HBase

```bash
# Linux/Mac
./scripts/hbase-shell.sh

# Windows PowerShell
.\scripts\hbase-shell.ps1

# Windows Batch
scripts\hbase-shell.bat
```

Dans le shell HBase, tapez :
```
version
exit
```

Si la commande `version` affiche la version de HBase, HBase fonctionne correctement.

### Tester Hive

```bash
# Linux/Mac
./scripts/hive-cli.sh

# Windows PowerShell
.\scripts\hive-cli.ps1

# Windows Batch
scripts\hive-cli.bat
```

Dans le shell Hive, tapez :
```sql
SHOW DATABASES;
exit;
```

Si la commande affiche les bases de données (même si la liste est vide), Hive fonctionne correctement.

### Interfaces Web

- **HDFS NameNode** : http://localhost:9870
- **YARN ResourceManager** : http://localhost:8088
- **HBase Master** : http://localhost:16011

---

## Structure du Projet

```
M2DE_Hbase/
├── README.md                 # Ce fichier
├── docker-compose.yml        # Configuration Docker (NE PAS MODIFIER)
│
├── docker/                   # Configurations Docker (NE PAS MODIFIER)
│   ├── hadoop/              # Configuration Hadoop
│   ├── hbase/               # Configuration HBase
│   └── hive/                # Configuration Hive
│
├── scripts/                  # Scripts utilitaires
│   ├── run.sh/.ps1/.bat     # Script principal (recommandé)
│   ├── start.sh/.ps1/.bat   # Script de démarrage
│   ├── stop.sh/.ps1/.bat    # Script d'arrêt
│   ├── status.sh/.ps1/.bat  # Vérifier l'état
│   ├── check-prereqs.*      # Vérification des prérequis
│   ├── hbase-shell.*        # Accéder à HBase Shell
│   └── hive-cli.*           # Accéder à Hive CLI
│
├── resources/                # Datasets pour les exercices (NE PAS MODIFIER)
│   ├── customers/           # Données clients (CSV)
│   ├── iot-logs/            # Logs IoT (CSV)
│   ├── sales/               # Données de ventes (CSV)
│   └── sensors/             # Données de capteurs (JSON)
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

## Scripts Disponibles

### Scripts Principaux

**setup.sh/.ps1/.bat** : Script de configuration et lancement (RECOMMANDÉ)
- **UNE SEULE COMMANDE** pour tout faire
- Vérifie et installe automatiquement les dépendances manquantes
- Lance Docker Desktop automatiquement si nécessaire (Windows/Mac)
- Lance automatiquement l'environnement
- **C'est la méthode la plus simple pour démarrer**

**run.sh/.ps1/.bat** : Script principal
- Exécute automatiquement `check-prereqs`
- Lance `docker compose up -d`
- Affiche un résumé de l'état
- (Sans installation automatique des dépendances)

**start.sh/.ps1/.bat** : Script de démarrage
- Exécute automatiquement `check-before-start`
- Lance `docker compose up -d`

**stop.sh/.ps1/.bat** : Arrêter l'environnement
```bash
./scripts/stop.sh
# Arrête tous les conteneurs
```

**status.sh/.ps1/.bat** : Vérifier l'état
```bash
./scripts/status.sh
# Affiche l'état de tous les conteneurs
```

### Scripts de Vérification

**check-prereqs.sh/.ps1/.bat** : Vérification complète des prérequis
- Détecte automatiquement docker-compose V1 ou V2
- Vérifie Docker, ports, fichiers, Git, etc.
- Affiche des messages d'erreur clairs avec solutions

**check-before-start.sh/.ps1/.bat** : Vérification avant démarrage (ancien script, toujours fonctionnel)

### Scripts d'Accès aux Shells

**hbase-shell.sh/.ps1/.bat** : Accéder à HBase Shell
```bash
./scripts/hbase-shell.sh
```

**hive-cli.sh/.ps1/.bat** : Accéder à Hive CLI
```bash
./scripts/hive-cli.sh
```

---

## Travail dans les Rooms

### Qu'est-ce qu'une Room ?

Une **room** est un parcours d'apprentissage guidé qui vous apprend progressivement HBase et Hive. Chaque room contient :
- Un **README.md** avec les instructions complètes
- Des **rappels théoriques** et **explications détaillées**
- Des **exercices pratiques** à réaliser étape par étape
- Des **datasets** fournis dans `/resources` (accessibles depuis les conteneurs)

### Ordre des Rooms

Suivez les rooms dans l'ordre numérique :

1. **Room 0** : Introduction - Prise en main
2. **Room 1** : HBase Basics - Opérations de base
3. **Room 2** : HBase Advanced - Filtres et optimisation
4. **Room 3** : Hive Introduction - Premières requêtes SQL
5. **Room 4** : Hive Advanced - Jointures et partitions
6. **Room 5** : Intégration HBase-Hive
7. **Room 6** : Cas d'usage réels
8. **Room 7** : Projet final

**Règle importante :** Ne passez pas à la room suivante tant que vous n'avez pas terminé la précédente.

### Comment Travailler dans une Room

1. **Aller dans la room** : `cd rooms/room-0_introduction`
2. **Lire le README.md** de la room entièrement
3. **Suivre les instructions** étape par étape
4. **Créer les fichiers demandés** dans le dossier de la room
5. **Tester vos commandes** avec les scripts fournis
6. **Documenter votre travail** dans les fichiers demandés
7. **Enregistrer votre travail** avec Git (après chaque room)

### Règles Importantes

**Ce que vous POUVEZ faire :**
- Créer et modifier des fichiers dans `/rooms/room-X_*/`
- Documenter votre progression
- Tester vos commandes

**Ce que vous NE POUVEZ PAS faire :**
- Modifier les fichiers Docker (`/docker/`)
- Modifier les scripts (`/scripts/`)
- Modifier les ressources (`/resources/`)
- Modifier le README principal ou autres fichiers de documentation

### Enregistrer son Travail

Après chaque room terminée :

```bash
# Retourner à la racine du projet
cd ../..

# Ajouter les fichiers modifiés
git add rooms/room-X_nom/*

# Créer un commit
git commit -m "Room X terminée"

# Envoyer sur GitHub
git push origin main
```

---

## Résolution de Problèmes

### Problème 1 : Docker Desktop n'est pas lancé (Windows/Mac)

**Symptôme :** `docker: command not found` ou `Cannot connect to Docker`

**Solution :**
1. Lancez Docker Desktop depuis le menu Démarrer
2. Attendez que l'icône Docker apparaisse dans la barre des tâches (1-2 minutes)
3. Vérifiez : `docker info` (ne doit pas afficher d'erreur)

### Problème 2 : Les conteneurs ne démarrent pas

**Solution :**
```bash
# Arrêter tous les conteneurs
docker compose down
# OU
docker-compose down

# Vérifier l'état
docker compose ps

# Relancer
docker compose up -d
```

### Problème 3 : Conteneur "unhealthy"

**Si Hadoop est "unhealthy" :**
```bash
# Regarder les logs
docker compose logs hadoop

# Réinitialiser complètement (ATTENTION : supprime les données)
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

**Si HBase est "unhealthy" :**
```bash
# Regarder les logs
docker compose logs hbase

# Vérifier que Hadoop et ZooKeeper sont "healthy"
docker compose ps

# Si Hadoop et ZooKeeper sont OK, attendez encore 2-3 minutes
# Le healthcheck HBase peut prendre jusqu'à 3 minutes
```

### Problème 4 : Port déjà utilisé

**Symptôme :** `Port already in use` ou `access forbidden by its access permissions`

**Sur Windows :**
```powershell
# Vérifier quel programme utilise le port
netstat -ano | findstr :16011

# Arrêter le processus (remplacez <PID> par le numéro trouvé)
taskkill /PID <PID> /F
```

**Ou changer le port dans docker-compose.yml :**
- Trouvez la section `hbase` → `ports`
- Changez `"16011:16010"` par `"16012:16010"` (ou un autre port libre)

### Problème 5 : "JAVA_HOME is not set"

**Solution :**
```bash
# Mettre à jour le dépôt
git pull origin main

# Reconstruire les conteneurs
docker compose build --no-cache
docker compose up -d
```

### Problème 6 : Les conteneurs sont "Exited" (arrêtés)

**Solution :**
```bash
# Regarder les logs pour voir pourquoi
docker compose logs

# Redémarrer
docker compose restart
```

### Problème 7 : Git pull échoue avec "Your local changes would be overwritten"

**Solution :**
```bash
# Option 1 : Sauvegarder vos modifications
git stash
git pull origin main

# Option 2 : Réinitialiser complètement (ATTENTION : supprime vos modifications locales)
git reset --hard origin/main
git pull origin main
```

### Diagnostic Détaillé

**Vérifier les logs d'un service spécifique :**
```bash
docker compose logs hadoop
docker compose logs hbase
docker compose logs hive
docker compose logs zookeeper
```

**Vérifier l'état de tous les conteneurs :**
```bash
docker compose ps
```

**Tester HBase manuellement :**
```bash
# Si le healthcheck échoue mais que HBase fonctionne
./scripts/hbase-shell.sh    # Linux/Mac
.\scripts\hbase-shell.ps1    # Windows

# Tapez : version
# Si ça fonctionne, HBase est opérationnel même si marqué "unhealthy"
```

**Réinitialiser complètement (ATTENTION : supprime les données) :**
```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

---

## Commandes de Référence

### Docker Compose

```bash
# Démarrer
docker compose up -d
# OU
docker-compose up -d

# Arrêter
docker compose down

# Vérifier l'état
docker compose ps

# Voir les logs
docker compose logs
docker compose logs hadoop
docker compose logs hbase

# Redémarrer
docker compose restart

# Arrêter et supprimer les volumes (ATTENTION : supprime les données)
docker compose down -v
```

### HBase Shell

**Accéder au shell :**
```bash
./scripts/hbase-shell.sh    # Linux/Mac
.\scripts\hbase-shell.ps1    # Windows
```

**Commandes HBase de base :**
```
create 'table', 'cf'                              # Créer une table
put 'table', 'row', 'cf:col', 'value'            # Insérer une donnée
get 'table', 'row'                                # Récupérer une ligne
scan 'table'                                      # Voir toutes les données
count 'table'                                     # Compter les lignes
delete 'table', 'row'                             # Supprimer une ligne
deleteall 'table', 'row'                          # Supprimer toute la ligne
drop 'table'                                      # Supprimer la table
list                                              # Lister toutes les tables
describe 'table'                                  # Décrire une table
exit                                              # Quitter
```

### Hive CLI

**Accéder au CLI :**
```bash
./scripts/hive-cli.sh    # Linux/Mac
.\scripts\hive-cli.ps1   # Windows
```

**Commandes Hive de base :**
```sql
SHOW DATABASES;                    # Lister les bases
CREATE DATABASE nom_db;            # Créer une base
USE nom_db;                        # Utiliser une base
SHOW TABLES;                       # Lister les tables
CREATE TABLE nom_table (...);      # Créer une table
SELECT * FROM table;               # Voir les données
DROP TABLE table;                  # Supprimer une table
DROP DATABASE nom_db;              # Supprimer une base
exit;                              # Quitter (avec ;)
```

**Note importante :** Hive nécessite un point-virgule `;` à la fin de chaque commande. HBase non.

---

## Objectifs du Module

À la fin de ce parcours, vous serez capable de :

- Comprendre Hadoop, HBase et Hive et leur rôle dans le Big Data
- Créer et manipuler des tables HBase (CRUD complet)
- Analyser des données avec Hive (requêtes SQL)
- Intégrer HBase et Hive dans un workflow analytique
- Appliquer ces notions à des datasets réels

**Aucun prérequis avancé nécessaire** - Tout est fourni et expliqué étape par étape.

---

## Support et Aide

Si vous rencontrez un problème non résolu dans cette documentation :

1. Vérifiez que vous avez bien suivi toutes les étapes
2. Consultez les logs : `docker compose logs`
3. Vérifiez que votre dépôt est à jour : `git pull origin main`
4. Réinitialisez complètement si nécessaire : `docker compose down -v && docker compose up -d`

---

**Bon apprentissage !**
