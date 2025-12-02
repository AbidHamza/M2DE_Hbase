# HBase & Hive Learning Lab

## Table des Matières

1. [Bienvenue](#bienvenue)
2. [Objectifs du Module](#objectifs-du-module)
3. [Mise en Route Complète](#mise-en-route-complète)
4. [Référence des Commandes](#référence-des-commandes)
5. [Fonctionnement des Rooms](#fonctionnement-des-rooms)
6. [Instructions Git](#instructions-git)
7. [Règles de Travail](#règles-de-travail)
8. [Structure du Dépôt](#structure-du-dépôt)
9. [En Cas de Problème](#en-cas-de-problème)

---

## Bienvenue

Bienvenue dans ce parcours d'apprentissage complet sur **HBase** et **Hive** !

Ce module a été conçu pour vous accompagner pas à pas dans la découverte et la maîtrise de ces deux technologies essentielles de l'écosystème Hadoop. Vous progresserez à travers des exercices concrets, des scénarios réels et une progression guidée qui vous permettra de construire vos compétences de manière structurée et autonome.

Chaque étape de ce parcours vous propose :
- Des rappels théoriques clairs et concis
- Des explications détaillées des concepts
- Des exercices pratiques avec des datasets réels
- Une progression naturelle du simple au complexe

Aucun prérequis avancé n'est nécessaire : tout l'environnement est fourni et prêt à l'emploi. Vous n'avez qu'à suivre les instructions et vous lancer !

---

## Objectifs du Module

À la fin de ce parcours, vous serez capable de :

- **Comprendre les bases** de Hadoop, HBase et Hive et leur rôle dans l'écosystème Big Data
- **Créer, manipuler et interroger** des tables HBase avec des opérations CRUD
- **Charger, structurer et analyser** des données dans Hive avec HiveQL
- **Intégrer HBase et Hive** dans un workflow analytique complet
- **Appliquer les notions** à des datasets réels (logs IoT, données clients, métriques)
- **Suivre une progression structurée** et travailler de manière autonome

Ces compétences vous permettront de manipuler efficacement des données massives et de construire des solutions analytiques robustes.

---

## Mise en Route Complète

### Étape 0 : Vérifier les Prérequis

**1. Docker est-il installé ?**

Ouvrez votre terminal et tapez :
```bash
docker --version
```

**Résultat attendu :** Vous devriez voir quelque chose comme `Docker version 20.10.x`

**Si ça ne marche pas :** Téléchargez Docker depuis https://www.docker.com/get-started

**2. Git est-il installé ?**

Tapez dans votre terminal :
```bash
git --version
```

**Résultat attendu :** Vous devriez voir quelque chose comme `git version 2.x.x`

**Si ça ne marche pas :** Téléchargez Git depuis https://git-scm.com/downloads

### Étape 1 : Cloner le Dépôt

**Qu'est-ce que "cloner" ?**

Cloner signifie **copier** tout le projet depuis GitHub vers votre ordinateur.

**Comment faire :**

1. Ouvrez votre terminal
2. Allez dans le dossier où vous voulez mettre le projet (ex: `cd Desktop`)
3. Clonez le dépôt :
   ```bash
   git clone https://github.com/AbidHamza/M2DE_Hbase.git
   ```
4. Entrez dans le dossier créé :
   ```bash
   cd M2DE_Hbase
   ```

**Explication :**
- `git` = le programme Git
- `clone` = la commande pour copier un dépôt
- `https://github.com/...` = l'adresse du dépôt sur Internet

### Étape 2 : Lancer l'Environnement Docker

**Qu'est-ce que Docker ?**

Docker permet de créer des **conteneurs** (comme des boîtes) qui contiennent tous les programmes nécessaires (Hadoop, HBase, Hive).

**Comment lancer tout l'environnement :**

1. Vérifiez que vous êtes dans le bon dossier :
   ```bash
   pwd
   ```
   Sur Windows PowerShell : `Get-Location`

2. Lancez tous les services :
   ```bash
   docker-compose up -d
   ```

**Explication détaillée :**
- `docker-compose` = programme qui lance plusieurs conteneurs ensemble
- `up` = commande pour démarrer les conteneurs
- `-d` = option qui signifie "en arrière-plan" (detached), vous gardez votre terminal libre

**Ce qui se passe :**
1. Docker télécharge les images nécessaires (si pas déjà fait)
2. Docker crée les conteneurs
3. Docker démarre tous les services (Hadoop, HBase, Hive, ZooKeeper, etc.)

**Temps d'attente :** 2 à 5 minutes la première fois (téléchargement des images)

3. Attendez que tout soit prêt. Vous verrez des messages comme :
   ```
   Creating hbase-hive-learning-lab-hadoop-1 ... done
   Creating hbase-hive-learning-lab-zookeeper-1 ... done
   ...
   ```

4. Vérifiez que tout fonctionne :
   ```bash
   docker-compose ps
   ```

**Résultat attendu :** Tous les services doivent être "Up"

**Exemple de résultat :**
```
NAME                              STATUS
hbase-hive-learning-lab-hadoop-1   Up
hbase-hive-learning-lab-hbase-1    Up
hbase-hive-learning-lab-hive-1     Up
...
```

### Étape 3 : Tester que Tout Fonctionne

#### Test 1 : Vérifier HDFS (Hadoop)

1. Entrez dans le conteneur Hadoop :
   ```bash
   docker exec -it hbase-hive-learning-lab-hadoop-1 bash
   ```

2. Testez HDFS :
   ```bash
   hdfs dfsadmin -report
   hdfs dfs -ls /
   ```

3. Sortez du conteneur :
   ```bash
   exit
   ```

#### Test 2 : Vérifier HBase

1. Entrez dans le shell HBase :
   ```bash
   docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell
   ```

2. Testez HBase :
   ```hbase
   version
   status
   list
   ```

3. Sortez du shell :
   ```hbase
   exit
   ```

#### Test 3 : Vérifier Hive

1. Entrez dans Hive :
   ```bash
   docker exec -it hbase-hive-learning-lab-hive-1 hive
   ```

2. Testez Hive :
   ```sql
   SHOW DATABASES;
   ```
   **IMPORTANT :** Notez le point-virgule `;` à la fin !

3. Sortez de Hive :
   ```sql
   exit;
   ```

### Étape 4 : Accéder aux Interfaces Web

- **HDFS NameNode** : http://localhost:9870
- **YARN ResourceManager** : http://localhost:8088
- **HBase Master** : http://localhost:16010

### Étape 5 : Commencer les Rooms

1. Allez dans le dossier des rooms :
   ```bash
   cd rooms/room-0_introduction
   ```

2. Ouvrez et lisez le **README.md** de cette room

3. Suivez les instructions étape par étape

---

## Référence des Commandes

### Commandes Docker

**docker-compose ps**
- Affiche l'état de tous les conteneurs
- Utilisation : `docker-compose ps`

**docker-compose up -d**
- Démarre tous les services en arrière-plan
- Utilisation : `docker-compose up -d`

**docker exec -it NOM_CONTAINER COMMANDE**
- Exécute une commande dans un conteneur
- Exemples :
  ```bash
  docker exec -it hbase-hive-learning-lab-hadoop-1 bash
  docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell
  docker exec -it hbase-hive-learning-lab-hive-1 hive
  ```

**docker-compose down**
- Arrête et supprime tous les conteneurs
- Utilisation : `docker-compose down`

**docker-compose logs**
- Affiche les logs de tous les services
- Utilisation : `docker-compose logs` ou `docker-compose logs hbase`

### Commandes HDFS (Hadoop)

**hdfs dfs -ls [CHEMIN]**
- Liste les fichiers et dossiers dans HDFS
- Exemples :
  ```bash
  hdfs dfs -ls /
  hdfs dfs -ls /data
  ```

**hdfs dfs -mkdir -p [CHEMIN]**
- Crée un dossier dans HDFS
- Exemples :
  ```bash
  hdfs dfs -mkdir /data
  hdfs dfs -mkdir -p /data/test/exercices
  ```

**hdfs dfs -put [FICHIER_LOCAL] [CHEMIN_HDFS]**
- Copie un fichier vers HDFS
- Exemple :
  ```bash
  hdfs dfs -put /data/resources/customers/customers.csv /data/
  ```

**hdfs dfs -get [CHEMIN_HDFS] [FICHIER_LOCAL]**
- Télécharge un fichier de HDFS
- Exemple :
  ```bash
  hdfs dfs -get /data/monfichier.txt ./monfichier.txt
  ```

**hdfs dfs -cat [CHEMIN]**
- Affiche le contenu d'un fichier
- Exemple :
  ```bash
  hdfs dfs -cat /data/monfichier.txt
  ```

**hdfs dfs -rm [CHEMIN]**
- Supprime un fichier ou dossier
- Exemples :
  ```bash
  hdfs dfs -rm /data/monfichier.txt
  hdfs dfs -rm -r /data/test
  ```

**hdfs dfsadmin -report**
- Affiche un rapport sur l'état de HDFS
- Utilisation : `hdfs dfsadmin -report`

### Commandes HBase

**Accéder au shell HBase :**
```bash
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell
```

**version**
- Affiche la version de HBase
- Utilisation : `version`

**status**
- Affiche l'état de HBase
- Utilisation : `status`

**list**
- Liste toutes les tables
- Utilisation : `list`

**create 'TABLE', 'FAMILLE1', 'FAMILLE2', ...**
- Crée une nouvelle table
- Exemple :
  ```hbase
  create 'customers', 'info', 'contact'
  ```

**describe 'TABLE'**
- Affiche la structure d'une table
- Exemple :
  ```hbase
  describe 'customers'
  ```

**put 'TABLE', 'ROW_KEY', 'FAMILLE:COLONNE', 'VALEUR'**
- Insère ou met à jour une valeur
- Exemple :
  ```hbase
  put 'customers', 'CUST001', 'info:name', 'Jean Dupont'
  put 'customers', 'CUST001', 'info:age', '30'
  ```

**get 'TABLE', 'ROW_KEY'**
- Récupère une ligne complète
- Exemple :
  ```hbase
  get 'customers', 'CUST001'
  ```

**get 'TABLE', 'ROW_KEY', {COLUMN => 'FAMILLE:COLONNE'}**
- Récupère une colonne spécifique
- Exemple :
  ```hbase
  get 'customers', 'CUST001', {COLUMN => 'info:name'}
  ```

**scan 'TABLE'**
- Affiche toutes les lignes d'une table
- Exemple :
  ```hbase
  scan 'customers'
  ```

**scan 'TABLE', {LIMIT => NOMBRE}**
- Affiche un nombre limité de lignes
- Exemple :
  ```hbase
  scan 'customers', {LIMIT => 5}
  ```

**count 'TABLE'**
- Compte le nombre de lignes
- Exemple :
  ```hbase
  count 'customers'
  ```

**delete 'TABLE', 'ROW_KEY'**
- Supprime une ligne entière
- Exemple :
  ```hbase
  delete 'customers', 'CUST001'
  ```

**delete 'TABLE', 'ROW_KEY', 'FAMILLE:COLONNE'**
- Supprime une colonne spécifique
- Exemple :
  ```hbase
  delete 'customers', 'CUST001', 'contact:email'
  ```

**disable 'TABLE'** puis **drop 'TABLE'**
- Supprime une table (doit être désactivée avant)
- Exemple :
  ```hbase
  disable 'customers'
  drop 'customers'
  ```

**exit**
- Quitte le shell HBase
- Utilisation : `exit`

### Commandes Hive

**Accéder à Hive :**
```bash
docker exec -it hbase-hive-learning-lab-hive-1 hive
```

**SHOW DATABASES;**
- Liste toutes les bases de données
- **IMPORTANT :** Point-virgule `;` obligatoire !
- Utilisation : `SHOW DATABASES;`

**CREATE DATABASE [IF NOT EXISTS] NOM_DB;**
- Crée une base de données
- Exemple :
  ```sql
  CREATE DATABASE IF NOT EXISTS learning_db;
  ```

**USE NOM_DB;**
- Sélectionne une base de données
- Exemple :
  ```sql
  USE learning_db;
  ```

**SHOW TABLES;**
- Liste toutes les tables de la base actuelle
- Utilisation : `SHOW TABLES;`

**CREATE TABLE NOM_TABLE (...);**
- Crée une table
- Exemple :
  ```sql
  CREATE TABLE customers (
      customer_id STRING,
      name STRING,
      email STRING,
      city STRING
  ) ROW FORMAT DELIMITED
  FIELDS TERMINATED BY ','
  STORED AS TEXTFILE;
  ```

**LOAD DATA INPATH 'CHEMIN_HDFS' INTO TABLE NOM_TABLE;**
- Charge des données depuis HDFS dans une table
- **ATTENTION :** Le fichier est DÉPLACÉ (pas copié) !
- Exemple :
  ```sql
  LOAD DATA INPATH '/data/customers.csv' INTO TABLE customers;
  ```

**SELECT * FROM NOM_TABLE;**
- Affiche toutes les colonnes
- Exemple :
  ```sql
  SELECT * FROM customers;
  ```

**SELECT COLONNE1, COLONNE2 FROM NOM_TABLE;**
- Affiche des colonnes spécifiques
- Exemple :
  ```sql
  SELECT name, email FROM customers;
  ```

**SELECT * FROM NOM_TABLE WHERE CONDITION;**
- Filtre les résultats
- Exemple :
  ```sql
  SELECT * FROM customers WHERE city = 'Paris';
  ```

**SELECT * FROM NOM_TABLE LIMIT NOMBRE;**
- Limite le nombre de résultats
- Exemple :
  ```sql
  SELECT * FROM customers LIMIT 10;
  ```

**SELECT COLONNE, COUNT(*) FROM NOM_TABLE GROUP BY COLONNE;**
- Groupe et compte
- Exemple :
  ```sql
  SELECT city, COUNT(*) as nb_customers 
  FROM customers 
  GROUP BY city;
  ```

**DROP TABLE NOM_TABLE;**
- Supprime une table
- Exemple :
  ```sql
  DROP TABLE customers;
  ```

**exit;**
- Quitte Hive
- **N'oubliez pas le point-virgule !**
- Utilisation : `exit;`

### Notes Importantes

1. **HBase** : Pas de point-virgule à la fin des commandes
2. **Hive** : Point-virgule `;` OBLIGATOIRE à la fin de chaque commande SQL
3. **Guillemets** : En HBase, utilisez des guillemets simples `'...'`
4. **Sensibilité à la casse** : Les noms de tables sont sensibles à la casse !

---

## Fonctionnement des Rooms

### Structure d'une Room

Chaque room est un dossier indépendant contenant :
- **README.md** : instructions complètes, rappels théoriques, exercices
- **Fichiers exemples** (si disponibles)
- **Vos fichiers de travail** : vous les créez au fur et à mesure

### Progression

1. **Lire** le README de la room attentivement
2. **Comprendre** les rappels théoriques et concepts
3. **Exécuter** les commandes et exemples fournis
4. **Remplir** les fichiers demandés (scripts, réponses, notes)
5. **Valider** votre compréhension avec les exercices
6. **Passer** à la room suivante une fois terminée

### Liste des Rooms

Suivez-les dans l'ordre :

- **Room 0 : Introduction** - Prise en main de l'environnement
- **Room 1 : HBase Basics** - Opérations CRUD de base
- **Room 2 : HBase Advanced** - Versions, filtres, optimisation
- **Room 3 : Hive Introduction** - Premières requêtes SQL
- **Room 4 : Hive Advanced** - Jointures, partitions, formats
- **Room 5 : Intégration HBase-Hive** - Combiner les deux technologies
- **Room 6 : Cas d'usage réels** - Scénarios pratiques
- **Room 7 : Projet final** - Projet complet autonome

---

## Instructions Git

### Configuration Initiale (Première Utilisation)

Si c'est votre première utilisation de Git sur cette machine :

```bash
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"
```

### Enregistrer et Pousser son Travail

**1. Préparer les fichiers**

Modifiez uniquement les fichiers prévus dans la room :
- Notes dans les fichiers markdown
- Scripts que vous avez créés ou modifiés
- Réponses aux exercices
- Commandes que vous avez exécutées

**2. Enregistrer les modifications**

```bash
git add .
```

Ou plus précisément :
```bash
git add rooms/room-2_hbase_advanced/*
```

**3. Valider le travail**

```bash
git commit -m "Room 2 terminée"
```

Ou avec plus de détails :
```bash
git commit -m "Room 2 : travaux complétés - exercices HBase avancés"
```

**4. Envoyer dans le dépôt**

```bash
git push origin main
```

Si c'est la première fois, Git vous demandera peut-être vos identifiants GitHub.

**5. Mettre à jour en cas de problème**

Si vous rencontrez une erreur lors du `git push` :

```bash
git pull origin main
```

Si des conflits apparaissent :
- Ouvrez les fichiers concernés
- Résolvez les conflits (supprimez les marqueurs `<<<<<<<`, `=======`, `>>>>>>>`)
- Sauvegardez les fichiers
- Refaites `git add .`, `git commit -m "Résolution des conflits"`, puis `git push origin main`

### Exemples Concrets

**Exemple 1 : Room 2 terminée**

```bash
git add rooms/room-2_hbase_advanced/*
git commit -m "Room 2 : travaux complétés"
git push origin main
```

**Exemple 2 : Vérifier l'état avant de commit**

```bash
git status
git diff
git add .
git commit -m "Room X terminée"
git push origin main
```

### Conseils

- **Faites des commits réguliers** : un commit par room minimum
- **Utilisez des messages clairs** : "Room X terminée" plutôt que "modifs"
- **Vérifiez avant de push** : `git status` pour voir ce qui sera envoyé

---

## Règles de Travail

### Règles Générales

1. **Un commit par room minimum**
   - Validez votre travail à la fin de chaque room
   - Utilisez des messages de commit clairs et descriptifs

2. **Aucun changement dans l'infrastructure**
   - Ne modifiez pas les fichiers dans `/docker` ou `/scripts` sauf mention explicite
   - Ces fichiers sont partagés et doivent rester intacts

3. **Progression linéaire**
   - Suivez l'ordre des rooms (room-0 → room-1 → room-2 → ...)
   - Chaque room prépare la suivante

4. **Tout le travail est centralisé dans Git**
   - Ne gardez pas de fichiers locaux non versionnés
   - Tous vos exercices et réponses doivent être dans le dépôt

5. **Respecter la structure**
   - Travaillez uniquement dans les dossiers `/rooms`
   - Ne créez pas de fichiers à la racine du projet

### Bonnes Pratiques

- **Lisez attentivement** chaque README de room avant de commencer
- **Testez vos commandes** avant de les noter dans vos réponses
- **Documentez votre progression** : notes, difficultés rencontrées, solutions trouvées
- **Demandez de l'aide** si vous êtes bloqué plus de 30 minutes sur un exercice

---

## Structure du Dépôt

```
M2DE_Hbase/
├── README.md              # Ce fichier (documentation complète)
├── docker-compose.yml     # Configuration Docker (ne pas modifier)
├── .gitignore            # Fichiers à ignorer par Git
│
├── rooms/                 # Parcours d'apprentissage
│   ├── room-0_introduction/
│   ├── room-1_hbase_basics/
│   ├── room-2_hbase_advanced/
│   ├── room-3_hive_introduction/
│   ├── room-4_hive_advanced/
│   ├── room-5_hbase_hive_integration/
│   ├── room-6_real_world_scenarios/
│   └── room-7_final_project/
│
├── resources/             # Datasets partagés
│   ├── customers/        # Données clients (CSV)
│   ├── iot-logs/         # Logs IoT (CSV)
│   ├── sales/            # Données de ventes (CSV)
│   └── sensors/          # Données de capteurs (JSON)
│
├── docker/                # Dockerfiles (ne pas modifier)
│   ├── hadoop/           # Configuration Hadoop
│   ├── hbase/            # Configuration HBase
│   └── hive/             # Configuration Hive
│
└── scripts/               # Scripts utilitaires (ne pas modifier)
    ├── test-environment.sh
    └── init-hdfs.sh
```

### Description des Dossiers

**/rooms** : Vos travaux ici. Chaque room contient un README.md avec les instructions.

**/resources** : Datasets utilisés dans les exercices. Automatiquement montés dans les conteneurs Docker.

**/docker** : Configuration Docker. Ne pas modifier sauf mention explicite.

**/scripts** : Scripts utilitaires pour tester et initialiser l'environnement.

---

## En Cas de Problème

### Problème : "docker-compose : command not found"

**Solution :** Vérifiez que Docker Desktop est bien lancé sur votre machine.

### Problème : Les conteneurs ne démarrent pas

**Solution :**
```bash
docker-compose down
docker-compose up -d
```

### Problème : "Port already in use"

**Solution :** Un autre programme utilise le même port. Arrêtez-le ou changez les ports dans `docker-compose.yml`.

### Problème : Les conteneurs sont "Exited" (arrêtés)

**Solution :** Regardez les logs :
```bash
docker-compose logs
docker-compose logs hbase
docker-compose logs hive
```

### Problème : Réinitialiser complètement

**Attention :** Cela supprimera toutes les données !

```bash
docker-compose down -v
docker-compose up -d
```

### Checklist de Démarrage

Avant de commencer les rooms, vérifiez :

- [ ] Docker est installé et fonctionne (`docker --version`)
- [ ] Git est installé (`git --version`)
- [ ] Le dépôt est cloné
- [ ] `docker-compose up -d` a fonctionné
- [ ] Tous les conteneurs sont "Up" (`docker-compose ps`)
- [ ] Vous avez testé HDFS, HBase et Hive
- [ ] Vous êtes dans le dossier `rooms/room-0_introduction`

**Si toutes les cases sont cochées → Vous êtes prêt !**

---

## Prochaines Étapes

1. Lisez ce README.md en entier
2. Suivez les instructions de mise en route
3. Commencez par **Room 0 : Introduction**
4. Suivez les rooms dans l'ordre
5. Documentez votre travail dans les fichiers demandés

**Bon apprentissage !**

Si vous avez des questions ou rencontrez des difficultés, n'hésitez pas à consulter la documentation ou à demander de l'aide.
