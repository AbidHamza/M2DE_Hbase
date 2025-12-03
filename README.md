# Guide Complet - HBase & Hive Learning Lab

Parcours d'apprentissage étape par étape pour maîtriser HBase et Hive dans l'écosystème Hadoop.

---

## 📋 Table des Matières

1. [Introduction](#introduction)
2. [Étape 1 : Installation des Prérequis](#étape-1--installation-des-prérequis)
3. [Étape 2 : Récupération du Projet](#étape-2--récupération-du-projet)
4. [Étape 3 : Lancement de l'Environnement](#étape-3--lancement-de-lenvironnement)
5. [Étape 4 : Vérification que Tout Fonctionne](#étape-4--vérification-que-tout-fonctionne)
6. [Étape 5 : Commencer les Rooms](#étape-5--commencer-les-rooms)
7. [Commandes Essentielles](#commandes-essentielles)
8. [Résolution de Problèmes](#résolution-de-problèmes)

---

## Introduction

Ce projet vous permet d'apprendre HBase et Hive dans un environnement Docker pré-configuré. **Vous n'avez pas besoin d'installer Hadoop, HBase ou Hive manuellement** - tout est automatisé.

**Ce que vous allez apprendre :**
- HBase : Base de données NoSQL pour le Big Data
- Hive : Requêtes SQL sur Hadoop
- Intégration HBase-Hive
- Cas d'usage réels

**Temps estimé pour le setup initial :** 10-15 minutes

---

## Étape 1 : Installation des Prérequis

### 1.1 Installer Docker

**Sur Windows ou Mac :**
1. Allez sur https://www.docker.com/get-started
2. Téléchargez Docker Desktop
3. Installez Docker Desktop
4. Lancez Docker Desktop depuis le menu Démarrer
5. Attendez que l'icône Docker apparaisse dans la barre des tâches (1-2 minutes)

**Vérification :**
Ouvrez un terminal et tapez :
```bash
docker --version
```
Vous devriez voir quelque chose comme : `Docker version 24.0.0` ou similaire.

**Sur Linux (Ubuntu/Debian) :**
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

**Vérification :**
```bash
docker --version
docker info
```

### 1.2 Vérifier Docker Compose

Docker Compose est généralement inclus avec Docker Desktop. Vérifiez :

```bash
docker-compose --version
# OU
docker compose version
```

Si les deux commandes fonctionnent, c'est parfait. Le projet supporte les deux versions.

### 1.3 Installer Git (Recommandé)

**Windows/Mac :**
- Téléchargez depuis https://git-scm.com/downloads
- Installez avec les options par défaut

**Linux :**
```bash
sudo apt-get install git
```

**Vérification :**
```bash
git --version
```

---

## Étape 2 : Récupération du Projet

### 2.1 Première Fois : Cloner le Dépôt

Ouvrez un terminal et allez dans le dossier où vous voulez travailler (par exemple `Desktop` ou `Documents`).

```bash
# Cloner le projet
git clone https://github.com/AbidHamza/M2DE_Hbase.git

# Aller dans le dossier du projet
cd M2DE_Hbase
```

### 2.2 Mise à Jour (Si Déjà Cloné)

Si vous avez déjà cloné le projet avant :

```bash
# Aller dans le dossier du projet
cd M2DE_Hbase

# Récupérer les dernières modifications
git pull origin main
```

**Si vous avez des erreurs Git :**
```bash
# Sauvegarder vos modifications locales
git stash

# Récupérer les dernières modifications
git pull origin main

# Récupérer vos modifications sauvegardées (si besoin)
git stash pop
```

---

## Étape 3 : Lancement de l'Environnement

### 3.1 Méthode Simple : Script `setup` (RECOMMANDÉ)

**Cette méthode fait TOUT automatiquement :**
- Vérifie que Docker fonctionne
- Lance Docker Desktop si nécessaire
- Nettoie les anciens conteneurs
- Reconstruit les images
- Lance l'environnement

**Sur Windows (PowerShell) :**
```powershell
.\scripts\setup.ps1
```

**Sur Windows (Invite de commande) :**
```batch
scripts\setup.bat
```

**Sur Linux ou Mac :**
```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

**Ce qui se passe :**
1. Le script vérifie Docker (et le lance si nécessaire)
2. Nettoie les conteneurs existants
3. Reconstruit les images Docker (5-10 minutes la première fois)
4. Lance tous les services automatiquement
5. Affiche l'état final

**Attendez 2-3 minutes** après la fin du script pour que tous les services démarrent complètement.

### 3.2 Méthode Alternative : Script `run`

Si vous avez déjà lancé l'environnement avant et que vous voulez juste relancer :

**Sur Windows (PowerShell) :**
```powershell
.\scripts\run.ps1
```

**Sur Windows (Invite de commande) :**
```batch
scripts\run.bat
```

**Sur Linux ou Mac :**
```bash
./scripts/run.sh
```

**Ce script :**
- Vérifie que Docker fonctionne
- Vérifie que les fichiers sont présents
- Nettoie les conteneurs existants
- Lance l'environnement

### 3.3 Vérifier que l'Environnement est Lancé

Après avoir lancé le script, vérifiez l'état :

```bash
docker compose ps
# OU
docker-compose ps
```

**Résultat attendu :**
Vous devriez voir tous les conteneurs avec le statut "Up" et "healthy" (ou au moins "Up") :

```
NAME                              STATUS
hbase-hive-learning-lab-hadoop    Up X minutes (healthy)
hbase-hive-learning-lab-zookeeper  Up X minutes (healthy)
hbase-hive-learning-lab-hbase     Up X minutes (healthy)
hbase-hive-learning-lab-hive      Up X minutes
hbase-hive-learning-lab-hive-metastore Up X minutes
```

**Si un conteneur est "unhealthy" :**
- Attendez encore 1-2 minutes (les services peuvent prendre du temps)
- Si après 5 minutes c'est toujours "unhealthy", consultez la section Résolution de Problèmes

---

## Étape 4 : Vérification que Tout Fonctionne

### 4.1 Tester HBase

**Ouvrir le shell HBase :**

**Sur Windows (PowerShell) :**
```powershell
.\scripts\hbase-shell.ps1
```

**Sur Windows (Invite de commande) :**
```batch
scripts\hbase-shell.bat
```

**Sur Linux ou Mac :**
```bash
./scripts/hbase-shell.sh
```

**Dans le shell HBase, tapez :**
```
version
```

**Résultat attendu :**
Vous devriez voir la version de HBase affichée, par exemple :
```
HBase 2.5.0
```

**Si ça fonctionne :** Tapez `exit` pour quitter.

**Si vous avez une erreur "Server is not running yet" :**
- Attendez encore 1-2 minutes
- HBase Master peut prendre du temps à démarrer complètement

### 4.2 Tester Hive

**Ouvrir le CLI Hive :**

**Sur Windows (PowerShell) :**
```powershell
.\scripts\hive-cli.ps1
```

**Sur Windows (Invite de commande) :**
```batch
scripts\hive-cli.bat
```

**Sur Linux ou Mac :**
```bash
./scripts/hive-cli.sh
```

**Dans le CLI Hive, tapez :**
```sql
SHOW DATABASES;
```

**Résultat attendu :**
Vous devriez voir une liste de bases de données (même si elle est vide).

**Si ça fonctionne :** Tapez `exit;` pour quitter (notez le point-virgule).

### 4.3 Accéder aux Interfaces Web

Ouvrez votre navigateur et allez sur :

- **HDFS NameNode** : http://localhost:9870
  - Vous devriez voir l'interface web de Hadoop HDFS
  
- **YARN ResourceManager** : http://localhost:8088
  - Vous devriez voir l'interface web de YARN
  
- **HBase Master** : http://localhost:16011
  - Vous devriez voir l'interface web de HBase

**Si les pages se chargent :** Tout fonctionne correctement !

---

## Étape 5 : Commencer les Rooms

### 5.1 Qu'est-ce qu'une Room ?

Une **room** est un parcours d'apprentissage guidé. Chaque room contient :
- Des explications théoriques
- Des exercices pratiques étape par étape
- Des datasets fournis dans `/resources`

### 5.2 Ordre des Rooms

Suivez les rooms dans l'ordre numérique :

1. **Room 0** : Introduction - Prise en main de l'environnement
2. **Room 1** : HBase Basics - Opérations de base (créer, lire, modifier, supprimer)
3. **Room 2** : HBase Advanced - Filtres et optimisation
4. **Room 3** : Hive Introduction - Premières requêtes SQL
5. **Room 4** : Hive Advanced - Jointures et partitions
6. **Room 5** : Intégration HBase-Hive
7. **Room 6** : Cas d'usage réels
8. **Room 7** : Projet final

**Règle importante :** Ne passez pas à la room suivante tant que vous n'avez pas terminé la précédente.

### 5.3 Comment Travailler dans une Room

**Exemple avec Room 1 :**

1. **Aller dans la room :**
   ```bash
   cd rooms/room-1_hbase_basics
   ```

2. **Lire le README.md de la room :**
   ```bash
   # Sur Windows
   notepad README.md
   # OU sur Mac/Linux
   cat README.md
   ```

3. **Suivre les instructions étape par étape**

4. **Créer les fichiers demandés** dans le dossier de la room

5. **Tester vos commandes** avec les scripts fournis :
   ```bash
   # Pour tester HBase
   ../../scripts/hbase-shell.sh    # Linux/Mac
   ..\..\scripts\hbase-shell.ps1   # Windows
   ```

6. **Documenter votre travail** dans les fichiers demandés

7. **Enregistrer votre travail** avec Git (après chaque room) :
   ```bash
   # Retourner à la racine
   cd ../..
   
   # Ajouter vos fichiers
   git add rooms/room-1_hbase_basics/*
   
   # Créer un commit
   git commit -m "Room 1 terminée"
   
   # Envoyer sur GitHub
   git push origin main
   ```

### 5.4 Règles Importantes

**Ce que vous POUVEZ faire :**
- Créer et modifier des fichiers dans `/rooms/room-X_*/`
- Documenter votre progression
- Tester vos commandes

**Ce que vous NE POUVEZ PAS faire :**
- Modifier les fichiers Docker (`/docker/`)
- Modifier les scripts (`/scripts/`)
- Modifier les ressources (`/resources/`)
- Modifier le README principal

---

## Commandes Essentielles

### Arrêter l'Environnement

**Sur Windows (PowerShell) :**
```powershell
.\scripts\stop.ps1
```

**Sur Windows (Invite de commande) :**
```batch
scripts\stop.bat
```

**Sur Linux ou Mac :**
```bash
./scripts/stop.sh
```

**Ou manuellement :**
```bash
docker compose down
```

### Vérifier l'État

**Sur Windows (PowerShell) :**
```powershell
.\scripts\status.ps1
```

**Sur Windows (Invite de commande) :**
```batch
scripts\status.bat
```

**Sur Linux ou Mac :**
```bash
./scripts/status.sh
```

**Ou manuellement :**
```bash
docker compose ps
```

### Voir les Logs

Si quelque chose ne fonctionne pas, regardez les logs :

```bash
# Tous les services
docker compose logs

# Un service spécifique
docker compose logs hadoop
docker compose logs hbase
docker compose logs hive
```

### Redémarrer un Service

```bash
docker compose restart hadoop
docker compose restart hbase
```

---

## Résolution de Problèmes

### Problème 1 : Docker Desktop n'est pas lancé

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

# Relancer
docker compose up -d

# OU utiliser le script setup
.\scripts\setup.ps1    # Windows
./scripts/setup.sh     # Linux/Mac
```

### Problème 3 : Conteneur "unhealthy"

**Si Hadoop est "unhealthy" :**
```bash
# Regarder les logs
docker compose logs hadoop

# Réinitialiser complètement (ATTENTION : supprime les données)
docker compose down -v
docker compose build --no-cache hadoop
docker compose up -d
```

**Si HBase est "unhealthy" :**
```bash
# Regarder les logs
docker compose logs hbase

# Vérifier que Hadoop et ZooKeeper sont "healthy"
docker compose ps

# Si Hadoop et ZooKeeper sont OK, attendez encore 2-3 minutes
# HBase peut prendre jusqu'à 3 minutes pour démarrer complètement
```

**Si HBase affiche "Server is not running yet" :**
- C'est normal au début, attendez 1-2 minutes supplémentaires
- Le Master HBase peut prendre du temps à initialiser

### Problème 4 : Port déjà utilisé

**Symptôme :** `Port already in use` ou `access forbidden by its access permissions`

**Solution automatique :**
Le script `setup` ou `run` nettoie automatiquement les ports occupés. Si le problème persiste :

**Sur Windows :**
```powershell
# Vérifier quel programme utilise le port
netstat -ano | findstr :16011

# Arrêter le processus (remplacez <PID> par le numéro trouvé)
taskkill /PID <PID> /F
```

**Sur Linux/Mac :**
```bash
# Trouver le processus
lsof -i :16011

# Arrêter le processus
kill -9 <PID>
```

### Problème 5 : "JAVA_HOME is not set"

**Solution :**
```bash
# Mettre à jour le dépôt
git pull origin main

# Reconstruire les conteneurs
docker compose build --no-cache
docker compose up -d
```

### Problème 6 : Git pull échoue

**Symptôme :** `Your local changes would be overwritten by merge`

**Solution :**
```bash
# Option 1 : Sauvegarder vos modifications
git stash
git pull origin main
git stash pop

# Option 2 : Réinitialiser complètement (ATTENTION : supprime vos modifications locales)
git reset --hard origin/main
git pull origin main
```

### Problème 7 : Les conteneurs sont "Exited" (arrêtés)

**Solution :**
```bash
# Regarder les logs pour voir pourquoi
docker compose logs

# Redémarrer
docker compose restart

# OU relancer complètement
.\scripts\setup.ps1    # Windows
./scripts/setup.sh     # Linux/Mac
```

### Réinitialiser Complètement (Dernier Recours)

Si rien ne fonctionne, réinitialisez tout :

```bash
# Arrêter et supprimer TOUT
docker compose down -v

# Nettoyer Docker
docker system prune -a -f

# Mettre à jour le code
git pull origin main

# Relancer avec setup
.\scripts\setup.ps1    # Windows
./scripts/setup.sh     # Linux/Mac
```

---

## Structure du Projet

```
M2DE_Hbase/
├── README.md                 # Ce fichier (guide complet)
├── docker-compose.yml        # Configuration Docker
│
├── docker/                   # Configurations Docker (NE PAS MODIFIER)
│   ├── hadoop/              # Configuration Hadoop
│   ├── hbase/               # Configuration HBase
│   └── hive/                # Configuration Hive
│
├── scripts/                  # Scripts utilitaires
│   ├── setup.*              # Script principal (RECOMMANDÉ)
│   ├── run.*                # Script de lancement
│   ├── stop.*               # Arrêter l'environnement
│   ├── status.*              # Vérifier l'état
│   ├── hbase-shell.*         # Accéder à HBase Shell
│   └── hive-cli.*            # Accéder à Hive CLI
│
├── resources/                # Datasets pour les exercices
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

## Commandes de Référence Rapide

### Docker Compose

```bash
# Démarrer
docker compose up -d

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
```

### HBase Shell

**Ouvrir le shell :**
```bash
.\scripts\hbase-shell.ps1    # Windows PowerShell
scripts\hbase-shell.bat      # Windows Batch
./scripts/hbase-shell.sh     # Linux/Mac
```

**Commandes de base :**
```
create 'table', 'cf'                    # Créer une table
put 'table', 'row', 'cf:col', 'value'  # Insérer une donnée
get 'table', 'row'                      # Récupérer une ligne
scan 'table'                            # Voir toutes les données
count 'table'                           # Compter les lignes
delete 'table', 'row'                   # Supprimer une ligne
drop 'table'                            # Supprimer la table
list                                    # Lister toutes les tables
describe 'table'                        # Décrire une table
exit                                    # Quitter
```

### Hive CLI

**Ouvrir le CLI :**
```bash
.\scripts\hive-cli.ps1    # Windows PowerShell
scripts\hive-cli.bat      # Windows Batch
./scripts/hive-cli.sh     # Linux/Mac
```

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

**Note importante :** Hive nécessite un point-virgule `;` à la fin de chaque commande. HBase non.

---

## Interfaces Web

Une fois l'environnement lancé, vous pouvez accéder à :

- **HDFS NameNode** : http://localhost:9870
- **YARN ResourceManager** : http://localhost:8088
- **HBase Master** : http://localhost:16011

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

## Support

Si vous rencontrez un problème :

1. Vérifiez que vous avez bien suivi toutes les étapes
2. Consultez les logs : `docker compose logs`
3. Vérifiez que votre dépôt est à jour : `git pull origin main`
4. Utilisez le script `setup` pour réinitialiser : `.\scripts\setup.ps1`

**Bon apprentissage !**
