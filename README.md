# HBase & Hive Learning Lab

**Parcours d'apprentissage complet et guidé pour maîtriser HBase et Hive**

---

## 📋 Table des Matières

1. [Démarrage Complet - Guide Étape par Étape](#démarrage-complet)
2. [Comment Travailler dans les Rooms](#comment-travailler-dans-les-rooms)
3. [Structure du Dépôt](#structure-du-dépôt)
4. [Scripts Utilitaires](#scripts-utilitaires)
5. [Ressources et Datasets](#ressources-et-datasets)
6. [En Cas de Problème](#en-cas-de-problème)
7. [Commandes Essentielles](#commandes-essentielles)
8. [Instructions Git](#instructions-git)

---

## 🚀 Démarrage Complet - Guide Étape par Étape

### ⚠️ IMPORTANT : Lisez cette section ENTIÈREMENT avant de commencer !

---

### ÉTAPE 0 : Prérequis (À faire UNE SEULE FOIS)

**1. Installer Docker et Git**

**Installation rapide :**
- **Docker** : https://www.docker.com/get-started
- **Git** : https://git-scm.com/downloads

**2. Vérifier l'installation**
```bash
docker --version
git --version
```

Si ces commandes ne fonctionnent pas, installez Docker et Git d'abord.

**3. Lancer Docker Desktop (Windows/Mac UNIQUEMENT)**

⚠️ **OBLIGATOIRE** : Docker Desktop DOIT être lancé avant toute commande Docker !

- **Windows** : Menu Démarrer → Rechercher "Docker Desktop" → Lancer
- **Mac** : Applications → Docker Desktop → Lancer
- **Attendez** que l'icône Docker apparaisse dans la barre des tâches (1-2 minutes)

**Vérifiez que Docker fonctionne :**
```bash
docker info
```

Si ça affiche une erreur, Docker Desktop n'est pas lancé. Relancez-le.

---

### ÉTAPE 1 : Cloner le Dépôt (Première fois uniquement)

**Si vous n'avez PAS encore cloné le dépôt :**

```bash
git clone https://github.com/AbidHamza/M2DE_Hbase.git
cd M2DE_Hbase
```

**Si vous avez DÉJÀ cloné le dépôt :**

```bash
cd M2DE_Hbase
git pull origin main
```

**Si vous avez des modifications locales non commitées et que git pull échoue :**

```bash
# Sauvegarder vos modifications (si importantes)
git stash

# OU réinitialiser complètement (ATTENTION : supprime vos modifications locales)
git reset --hard origin/main

# Puis mettre à jour
git pull origin main
```

---

### ÉTAPE 2 : Lancer l'Environnement

**⚠️ IMPORTANT : Les scripts effectuent automatiquement une vérification complète avant de démarrer.**

**Windows PowerShell :**
```powershell
.\scripts\start.ps1
```

**Windows Batch (si PowerShell ne fonctionne pas) :**
```batch
scripts\start.bat
```

**Linux/Mac :**
```bash
chmod +x scripts/*.sh
./scripts/start.sh
```

**Ce qui se passe :**
1. ✅ Vérification automatique de 15 points (Docker, ports, fichiers, etc.)
2. ✅ Si tout est OK → démarrage automatique des conteneurs
3. ✅ Si erreur → message clair pour corriger

**Attendez 3-5 minutes** que tous les services démarrent complètement.

---

### ÉTAPE 3 : Vérifier que Tout Fonctionne

**1. Vérifier l'état des conteneurs :**
```bash
docker-compose ps
```

**Résultat attendu :**
- Tous les conteneurs doivent être "Up" (pas "unhealthy" ou "Exited")
- Si un conteneur est "unhealthy", attendez encore 1-2 minutes
- Si après 5 minutes c'est toujours "unhealthy", voir la section "En Cas de Problème"

**2. Tester HBase Shell :**
```bash
# Windows PowerShell
.\scripts\hbase-shell.ps1

# Linux/Mac
./scripts/hbase-shell.sh
```

Dans le shell HBase, tapez :
```
version
exit
```

Si ça fonctionne, HBase est opérationnel ! ✅

**3. Tester Hive CLI :**
```bash
# Windows PowerShell
.\scripts\hive-cli.ps1

# Linux/Mac
./scripts/hive-cli.sh
```

Dans le shell Hive, tapez :
```sql
SHOW DATABASES;
exit;
```

Si ça fonctionne, Hive est opérationnel ! ✅

---

### ÉTAPE 4 : Commencer les Rooms

**1. Aller dans la première room :**
```bash
cd rooms/room-0_introduction
```

**2. Lire le README.md de cette room :**
- Ouvrez le fichier `README.md` avec votre éditeur de texte préféré
- Lisez-le **ENTIÈREMENT** avant de commencer
- Comprenez les objectifs et les prérequis

**3. Suivre les instructions étape par étape :**
- Lisez les rappels théoriques
- Exécutez les commandes **UNE PAR UNE** dans l'ordre
- Ne sautez pas d'étapes
- Créez les fichiers demandés dans le dossier de la room
- Documentez votre travail

**4. Utiliser les scripts pour accéder aux shells :**

**Pour HBase :**
```bash
# Windows PowerShell
.\scripts\hbase-shell.ps1

# Linux/Mac
./scripts/hbase-shell.sh
```

**Pour Hive :**
```bash
# Windows PowerShell
.\scripts\hive-cli.ps1

# Linux/Mac
./scripts/hive-cli.sh
```

**5. Enregistrer votre travail (après chaque room) :**
```bash
# Retourner à la racine du projet
cd ../..

# Ajouter les fichiers modifiés
git add rooms/room-0_introduction/*

# Créer un commit
git commit -m "Room 0 terminée"

# Envoyer sur GitHub
git push origin main
```

**6. Passer à la room suivante :**
```bash
cd rooms/room-1_hbase_basics
# Répétez les étapes 2-5
```

---

## 📚 Comment Travailler dans les Rooms

### Qu'est-ce qu'une Room ?

Une **room** est un parcours d'apprentissage guidé qui vous apprend progressivement HBase et Hive. Chaque room contient :
- Un **README.md** avec les instructions complètes, les rappels théoriques, et les exercices
- Des **explications détaillées** de chaque commande (pour débutants)
- Des **exercices pratiques** à réaliser étape par étape
- Des **datasets** fournis dans `/resources` (accessibles depuis les conteneurs Docker)

### Ordre des Rooms

Suivez les rooms dans l'ordre numérique :

1. **Room 0** : `rooms/room-0_introduction/` - Introduction - Prise en main
2. **Room 1** : `rooms/room-1_hbase_basics/` - HBase Basics - Opérations de base
3. **Room 2** : `rooms/room-2_hbase_advanced/` - HBase Advanced - Filtres et optimisation
4. **Room 3** : `rooms/room-3_hive_introduction/` - Hive Introduction - Premières requêtes SQL
5. **Room 4** : `rooms/room-4_hive_advanced/` - Hive Advanced - Jointures et partitions
6. **Room 5** : `rooms/room-5_hbase_hive_integration/` - Intégration HBase-Hive
7. **Room 6** : `rooms/room-6_real_world_scenarios/` - Cas d'usage réels
8. **Room 7** : `rooms/room-7_final_project/` - Projet final

**Règle d'or :** Ne passez pas à la room suivante tant que vous n'avez pas terminé la précédente.

### Structure d'une Room

Chaque room contient :
- **README.md** : instructions complètes, rappels théoriques, exercices
- **Vos fichiers de travail** : vous les créez au fur et à mesure

### Fichiers à Créer

Dans chaque room, vous devrez créer des fichiers comme :
- `room-X_exercices.md` : documentation de vos exercices
- `room-X_commandes.hbase` ou `.hql` : vos commandes
- `room-X_observations.md` : vos réflexions

**Template disponible :** `rooms/template_exercices.md` - Copiez-le pour commencer.

Les noms exacts sont indiqués dans le README de chaque room.

### Règles Importantes

⚠️ **RÈGLE ABSOLUE :** Ne modifiez JAMAIS les fichiers en dehors des dossiers `/rooms`. Vous travaillez uniquement dans les rooms.

✅ **Ce que vous POUVEZ faire :**
- Créer des fichiers dans les dossiers `/rooms/room-X_*/`
- Modifier vos propres fichiers de travail
- Documenter votre progression

❌ **Ce que vous NE POUVEZ PAS faire :**
- Modifier les fichiers Docker (`/docker/`)
- Modifier les scripts (`/scripts/`)
- Modifier les ressources (`/resources/`)
- Modifier le README principal ou autres fichiers de documentation

---

## 📁 Structure du Dépôt

```
M2DE_Hbase/
├── README.md              ← Vous êtes ici (tout l'essentiel)
├── docker-compose.yml     ← Configuration Docker (NE PAS MODIFIER)
│
├── docker/                ← Configurations Docker (NE PAS MODIFIER)
│   ├── hadoop/           ← Configuration Hadoop
│   ├── hbase/            ← Configuration HBase
│   └── hive/             ← Configuration Hive
│
├── scripts/              ← Scripts d'aide (utilisez-les !)
│   ├── start.ps1/.sh/.bat    ← Démarrer l'environnement
│   ├── stop.ps1/.sh/.bat     ← Arrêter l'environnement
│   ├── status.ps1/.sh/.bat   ← Vérifier l'état
│   ├── hbase-shell.ps1/.sh/.bat  ← Ouvrir HBase Shell
│   └── hive-cli.ps1/.sh/.bat     ← Ouvrir Hive CLI
│
├── resources/            ← Datasets pour les exercices (NE PAS MODIFIER)
│   ├── customers/       ← Données clients (CSV)
│   ├── iot-logs/        ← Logs IoT (CSV)
│   ├── sales/           ← Données de ventes (CSV)
│   └── sensors/         ← Données de capteurs (JSON)
│
└── rooms/                ← VOS TRAVAUX ICI !
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

## 🛠️ Scripts Utilitaires

### Scripts de Démarrage/Arrêt

**Démarrer l'environnement :**
```bash
# Windows PowerShell
.\scripts\start.ps1

# Linux/Mac
./scripts/start.sh
```

**Arrêter l'environnement :**
```bash
# Windows PowerShell
.\scripts\stop.ps1

# Linux/Mac
./scripts/stop.sh
```

**Vérifier l'état :**
```bash
# Windows PowerShell
.\scripts\status.ps1

# Linux/Mac
./scripts/status.sh
```

### Scripts d'Accès aux Shells

**HBase Shell :**
```bash
# Windows PowerShell
.\scripts\hbase-shell.ps1

# Linux/Mac
./scripts/hbase-shell.sh
```

**Hive CLI :**
```bash
# Windows PowerShell
.\scripts\hive-cli.ps1

# Linux/Mac
./scripts/hive-cli.sh
```

### Script de Vérification Pré-Lancement

**Exécutez ce script AVANT de lancer l'environnement pour éviter les erreurs :**

```bash
# Windows PowerShell
.\scripts\check-before-start.ps1

# Linux/Mac
./scripts/check-before-start.sh
```

**Ce script vérifie automatiquement :**
- ✅ Docker et docker-compose installés
- ✅ Docker Desktop lancé (Windows/Mac)
- ✅ Fichiers de configuration présents
- ✅ Syntaxe docker-compose.yml valide
- ✅ JAVA_HOME configuré correctement
- ✅ Ports disponibles
- ✅ Dépôt Git à jour
- ✅ Espace disque et mémoire suffisants
- ✅ Aucun conflit de conteneurs

**Note :** Les scripts `start.ps1`, `start.sh`, et `start.bat` exécutent automatiquement cette vérification avant de démarrer.

---

## 📊 Ressources et Datasets

Les datasets sont automatiquement montés dans les conteneurs Docker et accessibles via `/data/resources/`.

**Datasets disponibles :**
- **customers/** : Données clients (CSV) - Utilisé dans Room 1, 3, 4
- **iot-logs/** : Logs IoT (CSV) - Utilisé dans Room 2, 6
- **sales/** : Données de ventes (CSV) - Utilisé dans Room 4, 6
- **sensors/** : Données de capteurs (JSON) - Utilisé dans Room 2, 5, 6

**Accès depuis un conteneur :**
```bash
# Depuis le conteneur Hadoop
docker exec -it hbase-hive-learning-lab-hadoop-1 ls /data/resources/

# Depuis HBase Shell ou Hive CLI
# Les fichiers sont accessibles via /data/resources/
```

---

## 🔧 En Cas de Problème

### Problèmes Courants

**1. Docker Desktop n'est pas lancé (Windows/Mac)**

**Symptôme :** `docker: command not found` ou `Cannot connect to Docker`

**Solution :**
- Lancez Docker Desktop depuis le menu Démarrer
- Attendez que l'icône Docker apparaisse dans la barre des tâches
- Vérifiez : `docker info`

**2. Les conteneurs ne démarrent pas**

**Solution :**
```bash
docker-compose down
docker-compose ps
docker-compose up -d
```

**3. Conteneur "unhealthy"**

**Si Hadoop est "unhealthy" :**
```bash
# Regardez les logs
docker-compose logs hadoop

# Réinitialisez complètement
docker-compose down -v
docker-compose up -d
```

**Si HBase est "unhealthy" :**
```bash
# Regardez les logs
docker-compose logs hbase

# Vérifiez que Hadoop et ZooKeeper sont "Healthy"
docker-compose ps

# Si Hadoop et ZooKeeper sont OK, attendez encore 2-3 minutes
# Le healthcheck HBase peut prendre jusqu'à 3 minutes
```

**4. "Port already in use" ou "access forbidden by its access permissions"**

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

**5. "JAVA_HOME is not set"**

**Solution :**
```bash
# Mettez à jour le dépôt
git pull origin main

# Reconstruisez les conteneurs
docker-compose build --no-cache
docker-compose up -d
```

**6. Les conteneurs sont "Exited" (arrêtés)**

**Solution :**
```bash
# Regardez les logs pour voir pourquoi
docker-compose logs

# Redémarrez
docker-compose restart
```

**7. Git pull échoue avec "Your local changes would be overwritten"**

**Solution :**
```bash
# Sauvegarder vos modifications (si importantes)
git stash

# OU réinitialiser complètement (ATTENTION : supprime vos modifications locales)
git reset --hard origin/main

# Puis mettre à jour
git pull origin main
```

### Diagnostic Détaillé

**Vérifier les logs d'un service spécifique :**
```bash
docker-compose logs hadoop
docker-compose logs hbase
docker-compose logs hive
docker-compose logs zookeeper
```

**Vérifier l'état de tous les conteneurs :**
```bash
docker-compose ps
```

**Tester HBase manuellement :**
```bash
# Si le healthcheck échoue mais que HBase fonctionne
.\scripts\hbase-shell.ps1    # Windows
./scripts/hbase-shell.sh      # Linux/Mac

# Tapez : version
# Si ça fonctionne, HBase est opérationnel même si marqué "unhealthy"
```

**Réinitialiser complètement (ATTENTION : supprime les données) :**
```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

---

## 💻 Commandes Essentielles

### Docker

```bash
docker-compose up -d          # Démarrer
docker-compose down            # Arrêter
docker-compose ps              # Vérifier l'état
docker-compose logs            # Voir les logs
docker-compose restart         # Redémarrer
docker-compose down -v         # Arrêter et supprimer les volumes
```

### HBase Shell

```bash
# Accéder au shell
.\scripts\hbase-shell.ps1     # Windows
./scripts/hbase-shell.sh        # Linux/Mac

# Commandes HBase de base
create 'table', 'cf'           # Créer une table
put 'table', 'row', 'cf:col', 'value'  # Insérer une donnée
get 'table', 'row'             # Récupérer une ligne
scan 'table'                   # Voir toutes les données
count 'table'                  # Compter les lignes
delete 'table', 'row'          # Supprimer une ligne
exit                           # Quitter
```

### Hive CLI

```bash
# Accéder au CLI
.\scripts\hive-cli.ps1         # Windows
./scripts/hive-cli.sh           # Linux/Mac

# Commandes Hive de base
SHOW DATABASES;                # Lister les bases
CREATE DATABASE nom_db;        # Créer une base
USE nom_db;                    # Utiliser une base
SHOW TABLES;                   # Lister les tables
CREATE TABLE nom_table (...);  # Créer une table
SELECT * FROM table;           # Voir les données
DROP TABLE table;              # Supprimer une table
exit;                          # Quitter (avec ;)
```

**Note importante :** Hive nécessite un point-virgule `;` à la fin. HBase non.

### Interfaces Web

- **HDFS** : http://localhost:9870
- **YARN** : http://localhost:8088
- **HBase** : http://localhost:16011 (port changé pour éviter conflit Windows)

---

## 📝 Instructions Git

### Configuration Initiale (Première fois uniquement)

```bash
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"
```

### Enregistrer son Travail (Après Chaque Room)

**1. Ajouter les fichiers modifiés**
```bash
git add rooms/room-X_nom/*
```

**2. Créer un commit**
```bash
git commit -m "Room X terminée"
```

**3. Envoyer sur GitHub**
```bash
git push origin main
```

### Exemple Complet

```bash
# Après avoir terminé la Room 1
git add rooms/room-1_hbase_basics/*
git commit -m "Room 1 : bases de HBase complétées"
git push origin main
```

**Conseil :** Faites un commit après chaque room terminée.

### Mettre à Jour le Dépôt

```bash
git pull origin main
```

**Si conflit :**
```bash
# Sauvegarder vos modifications
git stash

# OU réinitialiser (ATTENTION : supprime vos modifications locales)
git reset --hard origin/main

# Puis mettre à jour
git pull origin main
```

---

## ✅ Règles de Travail

### Règles Importantes

1. **Travaillez uniquement dans `/rooms`** - Ne modifiez pas `/docker`, `/scripts`, `/resources`
2. **Un commit par room minimum** - Validez régulièrement votre travail
3. **Suivez l'ordre des rooms** - Chaque room prépare la suivante
4. **Documentez votre travail** - Créez les fichiers demandés dans chaque room

### Bonnes Pratiques

- Lisez attentivement chaque README de room
- Testez vos commandes avant de les documenter
- Notez vos difficultés et comment vous les avez résolues
- Demandez de l'aide si vous êtes bloqué plus de 30 minutes

---

## 🎯 Objectifs du Module

À la fin de ce parcours, vous serez capable de :

- Comprendre Hadoop, HBase et Hive et leur rôle dans le Big Data
- Créer et manipuler des tables HBase (CRUD complet)
- Analyser des données avec Hive (requêtes SQL)
- Intégrer HBase et Hive dans un workflow analytique
- Appliquer ces notions à des datasets réels

**Aucun prérequis avancé nécessaire** - Tout est fourni et expliqué étape par étape.

---

**Bon apprentissage ! 🚀**
