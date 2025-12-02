# Structure du Dépôt - Explication Complète

**Ce document explique TOUT ce qui se trouve dans le dépôt et à quoi ça sert.**

---

## Vue d'Ensemble

Ce dépôt contient un **parcours d'apprentissage complet** pour HBase et Hive. Tout est organisé de manière logique pour que vous puissiez apprendre progressivement.

---

## Fichiers à la Racine

### 📄 README.md
**Le fichier principal - À LIRE EN PREMIER !**

Contient :
- Bienvenue et objectifs
- Démarrage rapide en 5 minutes
- Toutes les commandes essentielles
- Instructions complètes pour commencer
- Navigation vers les autres fichiers

**Quand le lire :** Dès que vous clonez le dépôt.

---

### 📄 INSTALLATION_COMPLETE.md
**Guide d'installation pour débutants absolus**

Contient :
- Explication de ce qu'est Docker Desktop (avec analogies simples)
- Explication de ce qu'est Git
- Instructions pas à pas pour installer Docker Desktop (Windows/Mac)
- Instructions pas à pas pour installer Git
- Comment vérifier les ressources de votre ordinateur (RAM, disque)
- Comment vérifier votre connexion Internet
- Tests pour vérifier que tout fonctionne

**Quand le lire :** Si vous ne savez pas installer Docker ou Git, ou si vous avez des problèmes d'installation.

---

### 📄 CHECKLIST_DEPART.md
**Checklist à vérifier AVANT de lancer Docker**

Contient :
- Liste de tous les prérequis obligatoires
- Vérifications à faire avant de commencer
- Guide de lancement
- Temps d'attente normal
- Diagnostic si ça ne fonctionne pas

**Quand le lire :** Avant de lancer `docker-compose up -d` pour la première fois.

---

### 📄 FAQ.md
**Questions fréquentes et leurs réponses**

Contient :
- Problèmes Docker courants
- Erreurs HBase et Hive
- Questions Git
- Solutions détaillées pour chaque problème

**Quand le lire :** Si vous rencontrez un problème spécifique.

---

### 📄 DEPANNAGE_HADOOP.md
**Guide spécialisé pour les erreurs Hadoop**

Contient :
- Solutions pour l'erreur "unhealthy"
- Solutions pour l'erreur "JAVA_HOME is not set"
- Solutions pour l'erreur "exited (127)"
- Diagnostic détaillé
- Solutions de réinitialisation complète

**Quand le lire :** Si Hadoop ne démarre pas ou est en erreur.

---

### 📄 docker-compose.yml
**Configuration Docker - NE PAS MODIFIER**

Ce fichier configure tous les conteneurs Docker :
- **hadoop** : Service Hadoop (HDFS + YARN)
- **zookeeper** : Service ZooKeeper (nécessaire pour HBase)
- **hbase** : Service HBase
- **hive** : Service Hive
- **hive-metastore** : Métastore Hive (base de données des métadonnées)

**Important :** Ne modifiez pas ce fichier sauf instruction explicite.

---

## Dossier `/docker`

**Contient toutes les configurations Docker - NE PAS MODIFIER**

### `/docker/hadoop/`
- **Dockerfile** : Construit l'image Docker pour Hadoop
- **start-hadoop.sh** : Script qui démarre HDFS et YARN
- **core-site.xml, hdfs-site.xml, mapred-site.xml, yarn-site.xml** : Configurations Hadoop

### `/docker/hbase/`
- **Dockerfile** : Construit l'image Docker pour HBase
- **start-hbase.sh** : Script qui démarre HBase
- **hbase-site.xml** : Configuration HBase
- **hbase-env.sh** : Variables d'environnement HBase (JAVA_HOME, etc.)

### `/docker/hive/`
- **Dockerfile** : Construit l'image Docker pour Hive
- **hive-site.xml** : Configuration Hive
- **hive-env.sh** : Variables d'environnement Hive (JAVA_HOME, etc.)

**Important :** Ces fichiers sont utilisés pour construire les images Docker. Ne les modifiez pas.

---

## Dossier `/rooms`

**VOS TRAVAUX ICI - C'est là que vous allez travailler !**

### Structure d'une Room

Chaque room est un dossier avec :
- **README.md** : Instructions complètes de la room
  - Objectifs
  - Rappels théoriques
  - Exercices étape par étape
  - Fichiers à créer
  - Validation

### Liste des Rooms (Dans l'Ordre)

1. **room-0_introduction/**
   - Prise en main de l'environnement
   - Premières commandes HDFS, HBase, Hive
   - Création de vos premiers fichiers

2. **room-1_hbase_basics/**
   - Modèle de données HBase
   - Opérations CRUD (Create, Read, Update, Delete)
   - Familles de colonnes

3. **room-2_hbase_advanced/**
   - Versions et historique
   - Filtres avancés
   - Optimisation

4. **room-3_hive_introduction/**
   - Introduction à Hive
   - Premières requêtes SQL
   - Création de tables

5. **room-4_hive_advanced/**
   - Jointures
   - Partitions
   - Formats de fichiers

6. **room-5_hbase_hive_integration/**
   - Intégrer HBase et Hive
   - Utiliser Hive pour interroger HBase

7. **room-6_real_world_scenarios/**
   - Cas d'usage réels
   - Scénarios pratiques

8. **room-7_final_project/**
   - Projet final autonome
   - Application complète

### `/rooms/README.md`
Guide général sur les rooms et comment travailler dedans.

### `/rooms/template_exercices.md`
Template à copier pour documenter vos exercices.

**Règle importante :** Travaillez UNIQUEMENT dans `/rooms`. Ne modifiez pas les autres dossiers.

---

## Dossier `/resources`

**Datasets pour les exercices - NE PAS MODIFIER**

Contient les fichiers de données utilisés dans les rooms :
- **customers/** : Données clients (CSV)
- **iot-logs/** : Logs IoT (CSV)
- **sales/** : Données de ventes (CSV)
- **sensors/** : Données de capteurs (JSON)

Ces fichiers sont automatiquement montés dans les conteneurs Docker et accessibles via `/data/resources/`.

---

## Dossier `/scripts`

**Scripts d'aide pour simplifier les commandes**

### Scripts Windows
- **start.ps1** / **start.bat** : Démarrer l'environnement
- **stop.ps1** / **stop.bat** : Arrêter l'environnement
- **status.ps1** / **status.bat** : Vérifier l'état
- **hbase-shell.ps1** / **hbase-shell.bat** : Ouvrir HBase Shell
- **hive-cli.ps1** / **hive-cli.bat** : Ouvrir Hive CLI

### Scripts Linux/Mac
- **start.sh** : Démarrer l'environnement
- **stop.sh** : Arrêter l'environnement
- **status.sh** : Vérifier l'état
- **hbase-shell.sh** : Ouvrir HBase Shell
- **hive-cli.sh** : Ouvrir Hive CLI

### Scripts Utilitaires
- **test-environment.sh** : Tester que tout fonctionne
- **init-hdfs.sh** : Initialiser HDFS

### `/scripts/README.md`
Documentation complète des scripts.

---

## Fichiers Cachés

### `.gitignore`
Liste des fichiers que Git doit ignorer (logs, données temporaires, etc.).

---

## Résumé - Par Où Commencer ?

### Si vous êtes nouveau :

1. **Lisez** [README.md](README.md) - Vue d'ensemble
2. **Installez** Docker et Git → [INSTALLATION_COMPLETE.md](INSTALLATION_COMPLETE.md)
3. **Vérifiez** la checklist → [CHECKLIST_DEPART.md](CHECKLIST_DEPART.md)
4. **Lancez** l'environnement
5. **Commencez** Room 0 → `rooms/room-0_introduction/README.md`

### Si vous avez un problème :

1. **Erreur Hadoop** → [DEPANNAGE_HADOOP.md](DEPANNAGE_HADOOP.md)
2. **Question générale** → [FAQ.md](FAQ.md)
3. **Problème d'installation** → [INSTALLATION_COMPLETE.md](INSTALLATION_COMPLETE.md)

### Si vous travaillez dans une room :

1. **Lisez** le README.md de la room
2. **Suivez** les instructions étape par étape
3. **Créez** les fichiers demandés
4. **Validez** que vous avez tout fait
5. **Passez** à la room suivante

---

## Règles Importantes

1. **Ne modifiez JAMAIS** :
   - `/docker/` (configurations Docker)
   - `/resources/` (datasets)
   - `docker-compose.yml`

2. **Travaillez UNIQUEMENT dans** :
   - `/rooms/` (vos travaux)

3. **Commitez régulièrement** :
   - Au moins une fois par room terminée

4. **Mettez à jour le dépôt** :
   - `git pull origin main` régulièrement

---

## Navigation Rapide

- **Débuter** → [README.md](README.md)
- **Installer** → [INSTALLATION_COMPLETE.md](INSTALLATION_COMPLETE.md)
- **Vérifier** → [CHECKLIST_DEPART.md](CHECKLIST_DEPART.md)
- **Problème** → [FAQ.md](FAQ.md) ou [DEPANNAGE_HADOOP.md](DEPANNAGE_HADOOP.md)
- **Room 0** → `rooms/room-0_introduction/README.md`

---

**Cette structure a été conçue pour être intuitive et progressive. Suivez l'ordre indiqué et tout se passera bien !**

