# Room 0 : Introduction à l'environnement

##  Objectifs de cette room

À la fin de cette room, vous saurez :
-  Vérifier que votre environnement fonctionne
-  Utiliser les commandes de base de HDFS, HBase et Hive
-  Comprendre ce que fait chaque commande
-  Créer vos premiers fichiers et tables

** Temps estimé :** 1-2 heures (prenez votre temps !)

---

##  Rappels théoriques

### Qu'est-ce que Hadoop ?

**Hadoop** est comme une **énorme bibliothèque** pour stocker et traiter des données très volumineuses.

Imaginez que vous avez des millions de livres. Au lieu de les mettre dans une seule bibliothèque (qui serait trop petite), vous les répartissez dans plusieurs bibliothèques. C'est ce que fait Hadoop !

**Les 3 composants principaux :**

1. **HDFS (Hadoop Distributed File System)**
   - C'est le **système de fichiers** distribué
   - Comme le disque dur de votre ordinateur, mais réparti sur plusieurs machines
   - **Rôle :** Stocker les fichiers de données

2. **YARN (Yet Another Resource Negotiator)**
   - C'est le **gestionnaire de ressources**
   - Comme un chef d'orchestre qui organise qui fait quoi
   - **Rôle :** Organiser le traitement des données

3. **MapReduce**
   - C'est une **méthode de traitement** des données
   - Divise le travail en petites tâches, les exécute en parallèle, puis combine les résultats
   - **Rôle :** Traiter les données efficacement

### Qu'est-ce que HBase ?

**HBase** est une **base de données** spéciale qui fonctionne sur Hadoop.

**Analogie simple :** 
- Une base de données normale (comme MySQL) = un classeur avec des feuilles organisées
- HBase = un classeur GÉANT qui peut contenir des milliards de feuilles, et où vous pouvez trouver n'importe quelle feuille très rapidement

**Caractéristiques principales :**
-  Stocke des **très grandes quantités** de données (milliards de lignes)
-  Accès **très rapide** aux données (même dans une table énorme)
-  **Scalable** : peut grandir indéfiniment en ajoutant des machines
-  **NoSQL** : pas besoin de définir un schéma rigide au départ

**Quand l'utiliser ?**
- Données qui changent souvent (ex: logs en temps réel)
- Besoin d'accès rapide à des données spécifiques
- Volumes de données très importants

### Qu'est-ce que Hive ?

**Hive** est un **entrepôt de données** qui permet d'utiliser du **SQL** sur Hadoop.

**Analogie simple :**
- HDFS = un entrepôt géant plein de boîtes (fichiers)
- Hive = un système qui vous permet de poser des questions en SQL sur ces boîtes
- Au lieu de chercher manuellement, vous dites "donne-moi toutes les boîtes rouges" en SQL

**Caractéristiques principales :**
-  Utilise **HiveQL** (un langage très proche de SQL)
-  Parfait pour **l'analyse** de données
-  Permet de faire des **requêtes complexes** (jointures, agrégations)
-  Compatible avec les outils **BI** (Business Intelligence)

**Quand l'utiliser ?**
- Analyse de données historiques
- Requêtes complexes avec jointures
- Intégration avec des outils de reporting
- Traitement par lots (batch)

---

##  Mise en route - Étape par étape

### Étape 1 : Vérifier que Docker fonctionne

**Avant de commencer, vérifions que tout est prêt !**

**1. Ouvrez votre terminal**

**2. Vérifiez que vous êtes dans le bon dossier**

```bash
pwd
```

**Explication :**
- `pwd` = "print working directory" (afficher le dossier actuel)
- Vous devriez voir quelque chose comme `/chemin/vers/M2DE_Hbase`

**Si vous n'êtes pas dans le bon dossier :**
```bash
cd M2DE_Hbase
```

**3. Vérifiez l'état des conteneurs**

```bash
docker-compose ps
```

**Explication détaillée :**
- `docker-compose` = programme qui gère plusieurs conteneurs ensemble
- `ps` = "process status" (état des processus)
- Cette commande montre tous vos conteneurs et leur état

**Résultat attendu :**

Vous devriez voir quelque chose comme :
```
NAME                              STATUS
hbase-hive-learning-lab-hadoop-1   Up
hbase-hive-learning-lab-hbase-1    Up
hbase-hive-learning-lab-hive-1     Up
...
```

** Si tous sont "Up"** → Parfait ! Passez à l'étape suivante.

** Si certains sont "Exited" ou "Restarting"** → Il y a un problème. Regardez les logs :
```bash
docker-compose logs
```

---

### Étape 2 : Tester HDFS (Hadoop) - EXPLICATION DÉTAILLÉE

**HDFS est le système de fichiers de Hadoop. Testons-le !**

#### 2.1 Entrer dans le conteneur Hadoop

**Commande :**
```bash
docker exec -it hbase-hive-learning-lab-hadoop-1 bash
```

**Explication MOT PAR MOT :**
- `docker` = le programme Docker
- `exec` = exécuter une commande dans un conteneur
- `-it` = deux options combinées :
  - `-i` = mode interactif (vous pouvez taper)
  - `-t` = terminal (affichage formaté)
- `hbase-hive-learning-lab-hadoop-1` = le nom exact du conteneur Hadoop
- `bash` = le programme à lancer (un shell Linux)

**Ce qui se passe :**
1. Docker trouve le conteneur nommé `hbase-hive-learning-lab-hadoop-1`
2. Il lance un shell `bash` à l'intérieur
3. Vous êtes maintenant "connecté" au conteneur

**Résultat :** Votre prompt change ! Vous voyez quelque chose comme :
```
root@hadoop:/#
```

** Vous êtes maintenant DANS le conteneur Hadoop !**

#### 2.2 Vérifier que HDFS fonctionne

**Une fois dans le conteneur, tapez :**

```bash
hdfs dfsadmin -report
```

**Explication détaillée :**
- `hdfs` = le programme Hadoop pour le système de fichiers
- `dfsadmin` = commande d'administration de HDFS
- `-report` = option pour obtenir un rapport

**Ce que fait cette commande :**
Elle affiche des informations sur l'état de HDFS :
- Nombre de DataNodes (machines qui stockent les données)
- Espace disque disponible
- Espace disque utilisé
- État de santé du système

**Résultat attendu :**

Vous devriez voir quelque chose comme :
```
Configured Capacity: ...
Present Capacity: ...
DFS Used: ...
DFS Remaining: ...
Live datanodes (1): ...
```

** Si vous voyez ces informations** → HDFS fonctionne !

#### 2.3 Lister les fichiers dans HDFS

**Commande :**
```bash
hdfs dfs -ls /
```

**Explication détaillée :**
- `hdfs dfs` = commandes pour manipuler les fichiers dans HDFS
- `-ls` = "list" (lister les fichiers)
- `/` = la racine du système de fichiers HDFS (comme `C:\` sur Windows)

**Ce que fait cette commande :**
Elle liste tous les fichiers et dossiers à la racine de HDFS.

**Résultat attendu :**

Au début, vous pourriez voir :
```
drwxr-xr-x   - root supergroup          0 2024-01-01 10:00 /tmp
```

Ou une liste vide, ou d'autres dossiers.

**Décodage du résultat :**
- `drwxr-xr-x` = permissions (d = dossier, rwx = lire/écrire/exécuter)
- `root` = propriétaire
- `supergroup` = groupe
- `0` = taille (0 pour un dossier)
- Date et heure de création
- Nom du dossier/fichier

#### 2.4 Créer un dossier de test

**Créons un dossier pour tester :**

```bash
hdfs dfs -mkdir /test
```

**Explication :**
- `-mkdir` = "make directory" (créer un dossier)
- `/test` = le nom du dossier à créer

**Vérifions qu'il a été créé :**

```bash
hdfs dfs -ls /
```

**Résultat attendu :** Vous devriez maintenant voir `/test` dans la liste !

#### 2.5 Sortir du conteneur

**Quand vous avez fini avec HDFS :**

```bash
exit
```

**Explication :** Cette commande vous fait quitter le conteneur et revenir à votre terminal normal.

**Résultat :** Votre prompt redevient normal.

---

### Étape 3 : Tester HBase - EXPLICATION DÉTAILLÉE

**HBase est une base de données NoSQL. Testons-la !**

#### 3.1 Entrer dans le shell HBase

**Commande :**
```bash
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell
```

**Explication :**
- Même principe que pour Hadoop
- `hbase shell` = lance le shell interactif de HBase (un programme spécial pour HBase)

**Résultat :** Vous voyez un prompt spécial :
```
HBase Shell
Use "help" to get list of supported commands.
Use "exit" to quit this shell.
Version 2.5.0, ...

hbase(main):001:0>
```

** Vous êtes maintenant dans le shell HBase !**

**Note :** Le prompt `hbase(main):001:0>` signifie :
- `hbase` = vous êtes dans HBase
- `main` = contexte principal
- `001` = numéro de la commande
- `0` = numéro de la ligne

#### 3.2 Vérifier la version de HBase

**Commande :**
```hbase
version
```

**Explication :**
- `version` = commande simple qui affiche la version installée
- ** IMPORTANT :** Pas de guillemets, pas de point-virgule, juste le mot `version`

**Résultat attendu :**

```
2.5.0, r...
```

** Vous voyez la version** → HBase fonctionne !

#### 3.3 Vérifier le statut de HBase

**Commande :**
```hbase
status
```

**Explication :**
- `status` = affiche l'état général de HBase
- Montre combien de RegionServers sont actifs, combien de tables existent, etc.

**Résultat attendu :**

Vous verrez quelque chose comme :
```
1 active master, 0 backup masters, 1 servers, 0 dead, ...
```

**Décodage :**
- `active master` = le serveur principal fonctionne
- `servers` = nombre de RegionServers (servent les données)
- `dead` = serveurs qui ne fonctionnent pas (devrait être 0)

** Si vous voyez "1 active master"** → HBase fonctionne correctement !

#### 3.4 Lister les tables existantes

**Commande :**
```hbase
list
```

**Explication :**
- `list` = liste toutes les tables dans HBase
- Au début, il n'y en a probablement aucune

**Résultat attendu :**

Au début :
```
TABLE
0 row(s) in 0.1234 seconds
```

Cela signifie : "0 tables trouvées"

** C'est normal au début !** Vous créerez vos premières tables dans les exercices.

#### 3.5 Obtenir de l'aide

**Si vous êtes perdu, demandez de l'aide :**

```hbase
help
```

**Résultat :** Liste de toutes les commandes disponibles avec leur description.

**Pour l'aide sur une commande spécifique :**

```hbase
help 'create'
```

**Explication :** Affiche l'aide détaillée sur la commande `create`.

#### 3.6 Sortir du shell HBase

**Quand vous avez fini :**

```hbase
exit
```

**Explication :** Quitte le shell HBase et revient à votre terminal.

**Résultat :** Vous revenez à votre terminal normal.

---

### Étape 4 : Tester Hive - EXPLICATION DÉTAILLÉE

**Hive permet d'utiliser SQL sur Hadoop. Testons-le !**

#### 4.1 Entrer dans Hive

**Commande :**
```bash
docker exec -it hbase-hive-learning-lab-hive-1 hive
```

**Explication :**
- Même principe que pour HBase
- `hive` = lance le CLI (Command Line Interface) de Hive

**Résultat :** Vous voyez un prompt Hive :

```
Logging initialized using configuration in ...
Hive Session ID = ...
hive>
```

** Vous êtes maintenant dans Hive !**

#### 4.2 Lister les bases de données

**Commande :**
```sql
SHOW DATABASES;
```

** ATTENTION TRÈS IMPORTANTE :**
- **Point-virgule `;` OBLIGATOIRE** à la fin de chaque commande SQL !
- En Hive, toutes les commandes SQL se terminent par `;`
- Si vous oubliez le `;`, Hive attendra que vous le tapiez

**Explication détaillée :**
- `SHOW` = afficher
- `DATABASES` = les bases de données
- `;` = fin de la commande (OBLIGATOIRE !)

**Résultat attendu :**

```
OK
default
Time taken: 0.123 seconds, Fetched: 1 row(s)
```

**Décodage :**
- `OK` = la commande a réussi
- `default` = nom de la base de données par défaut (elle existe toujours)
- `Time taken` = temps d'exécution
- `Fetched: 1 row(s)` = 1 ligne retournée (1 base de données)

** Si vous voyez "default"** → Hive fonctionne !

#### 4.3 Utiliser la base de données par défaut

**Commande :**
```sql
USE default;
```

**Explication :**
- `USE` = utiliser/sélectionner
- `default` = nom de la base de données
- `;` = fin de commande

**Ce que fait cette commande :**
Elle sélectionne la base de données `default` comme base de travail. Toutes les commandes suivantes s'appliqueront à cette base.

**Résultat attendu :**

```
OK
Time taken: 0.045 seconds
```

#### 4.4 Lister les tables

**Commande :**
```sql
SHOW TABLES;
```

**Explication :**
- `SHOW TABLES` = afficher les tables
- Au début, il n'y en a probablement aucune

**Résultat attendu :**

```
OK
Time taken: 0.123 seconds
```

(Aucune table listée, c'est normal !)

#### 4.5 Obtenir de l'aide

**Pour voir toutes les commandes disponibles :**

```sql
SHOW FUNCTIONS;
```

**Résultat :** Liste de toutes les fonctions disponibles (SUM, COUNT, AVG, etc.)

#### 4.6 Sortir de Hive

**Quand vous avez fini :**

```sql
exit;
```

** N'oubliez pas le point-virgule !**

**Résultat :** Vous revenez à votre terminal.

---

##  Exercices pratiques - GUIDE PAS À PAS

### Exercice 1 : Exploration HDFS

**Objectif :** Créer des dossiers et copier des fichiers dans HDFS

#### Étape 1.1 : Entrer dans le conteneur Hadoop

```bash
docker exec -it hbase-hive-learning-lab-hadoop-1 bash
```

** Vous êtes dans le conteneur quand votre prompt change.**

#### Étape 1.2 : Créer un dossier de test

```bash
hdfs dfs -mkdir /data/test
```

**Explication :**
- `/data/test` = le chemin complet du dossier à créer
- `/data` = dossier parent
- `test` = sous-dossier

**Si le dossier parent n'existe pas, créez-le d'abord :**

```bash
hdfs dfs -mkdir -p /data/test
```

**Explication de `-p` :**
- `-p` = créer les dossiers parents si nécessaire
- Si `/data` n'existe pas, il sera créé automatiquement

#### Étape 1.3 : Vérifier que le dossier existe

```bash
hdfs dfs -ls /data
```

**Résultat attendu :** Vous devriez voir `test` dans la liste.

#### Étape 1.4 : Créer un fichier local de test

**Créons un fichier texte simple :**

```bash
echo "Ceci est un test" > /tmp/test.txt
```

**Explication :**
- `echo` = affiche du texte
- `>` = redirige la sortie vers un fichier
- `/tmp/test.txt` = le fichier à créer

**Vérifions le contenu :**

```bash
cat /tmp/test.txt
```

**Résultat attendu :** `Ceci est un test`

#### Étape 1.5 : Copier le fichier dans HDFS

```bash
hdfs dfs -put /tmp/test.txt /data/test/
```

**Explication détaillée :**
- `-put` = commande pour uploader/copier un fichier
- `/tmp/test.txt` = fichier source (sur le conteneur)
- `/data/test/` = destination dans HDFS

**Ce qui se passe :**
Le fichier est copié du système de fichiers local vers HDFS.

#### Étape 1.6 : Vérifier que le fichier est dans HDFS

```bash
hdfs dfs -ls /data/test/
```

**Résultat attendu :** Vous devriez voir `test.txt` dans la liste.

**Voir le contenu du fichier dans HDFS :**

```bash
hdfs dfs -cat /data/test/test.txt
```

**Résultat attendu :** `Ceci est un test`

#### Étape 1.7 : Sortir du conteneur

```bash
exit
```

** Exercice 1 terminé !**

---

### Exercice 2 : Première table HBase

**Objectif :** Créer une table, insérer des données, les lire

#### Étape 2.1 : Entrer dans le shell HBase

```bash
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell
```

** Vous voyez le prompt `hbase(main):001:0>`**

#### Étape 2.2 : Créer une table

**Commande :**
```hbase
create 'test_table', 'info'
```

**Explication DÉTAILLÉE :**
- `create` = commande pour créer une table
- `'test_table'` = nom de la table (entre guillemets simples)
- `'info'` = nom d'une **famille de colonnes**

**Qu'est-ce qu'une famille de colonnes ?**
- En HBase, les colonnes sont organisées en **familles**
- C'est comme des dossiers qui regroupent des colonnes liées
- Exemple : famille `info` peut contenir `info:name`, `info:age`, `info:city`
- La syntaxe est `FAMILLE:COLONNE`

**Résultat attendu :**

```
0 row(s) in 1.2345 seconds

=> Hbase::Table - test_table
```

** Table créée avec succès !**

#### Étape 2.3 : Vérifier la structure de la table

```hbase
describe 'test_table'
```

**Explication :**
- `describe` = affiche la description/structure
- `'test_table'` = nom de la table

**Résultat attendu :**

Vous verrez la structure de la table avec :
- Le nom de la famille de colonnes (`info`)
- Les propriétés (VERSIONS, TTL, etc.)

#### Étape 2.4 : Insérer des données

**Insérons une ligne avec plusieurs colonnes :**

```hbase
put 'test_table', 'row1', 'info:name', 'Test'
```

**Explication MOT PAR MOT :**
- `put` = commande pour insérer/mettre à jour une valeur
- `'test_table'` = nom de la table
- `'row1'` = **row key** (clé de la ligne, identifiant unique)
- `'info:name'` = nom de la colonne (famille `info` + colonne `name`)
- `'Test'` = la valeur à stocker

**Insérons une autre colonne pour la même ligne :**

```hbase
put 'test_table', 'row1', 'info:age', '25'
```

**Explication :**
- Même row key `'row1'` (même ligne)
- Colonne différente `'info:age'`
- Valeur `'25'`

** Maintenant la ligne `row1` a deux colonnes : `info:name` et `info:age`**

#### Étape 2.5 : Voir toutes les données (SCAN)

```hbase
scan 'test_table'
```

**Explication :**
- `scan` = parcourir toutes les lignes d'une table
- `'test_table'` = nom de la table

**Résultat attendu :**

```
ROW                    COLUMN+CELL
 row1                  column=info:age, timestamp=..., value=25
 row1                  column=info:name, timestamp=..., value=Test
1 row(s) in 0.1234 seconds
```

**Décodage :**
- `ROW` = la row key
- `COLUMN+CELL` = la colonne et sa valeur
- `timestamp` = horodatage automatique de chaque modification
- `value` = la valeur stockée

** Vous voyez vos données !**

#### Étape 2.6 : Récupérer une ligne spécifique (GET)

```hbase
get 'test_table', 'row1'
```

**Explication :**
- `get` = récupérer une ligne spécifique
- `'test_table'` = nom de la table
- `'row1'` = la row key de la ligne à récupérer

**Résultat attendu :**

Même résultat que `scan`, mais seulement pour la ligne `row1`.

**Récupérer une colonne spécifique :**

```hbase
get 'test_table', 'row1', {COLUMN => 'info:name'}
```

**Explication :**
- `{COLUMN => 'info:name'}` = filtre pour ne récupérer que cette colonne
- Syntaxe spéciale HBase avec accolades et `=>`

**Résultat attendu :** Seulement la colonne `info:name` de la ligne `row1`.

#### Étape 2.7 : Sortir du shell HBase

```hbase
exit
```

** Exercice 2 terminé !**

---

### Exercice 3 : Première base de données Hive

**Objectif :** Créer une base de données, l'utiliser, la supprimer

#### Étape 3.1 : Entrer dans Hive

```bash
docker exec -it hbase-hive-learning-lab-hive-1 hive
```

** Vous voyez le prompt `hive>`**

#### Étape 3.2 : Créer une base de données

```sql
CREATE DATABASE test_db;
```

**Explication détaillée :**
- `CREATE DATABASE` = commande SQL pour créer une base de données
- `test_db` = nom de la base de données
- `;` = **OBLIGATOIRE** à la fin !

**Résultat attendu :**

```
OK
Time taken: 0.123 seconds
```

** Base de données créée !**

#### Étape 3.3 : Utiliser cette base de données

```sql
USE test_db;
```

**Explication :**
- `USE` = sélectionner une base de données
- `test_db` = nom de la base
- Toutes les commandes suivantes s'appliqueront à cette base

**Résultat attendu :**

```
OK
Time taken: 0.045 seconds
```

#### Étape 3.4 : Lister les tables

```sql
SHOW TABLES;
```

**Explication :**
- `SHOW TABLES` = afficher les tables de la base actuelle
- Au début, elle devrait être vide

**Résultat attendu :**

```
OK
Time taken: 0.123 seconds
```

(Aucune table, c'est normal !)

#### Étape 3.5 : Vérifier que vous êtes dans la bonne base

```sql
SELECT current_database();
```

**Résultat attendu :** `test_db`

#### Étape 3.6 : Supprimer la base de données

** ATTENTION :** La base doit être vide (pas de tables) !

```sql
DROP DATABASE test_db;
```

**Explication :**
- `DROP DATABASE` = supprimer une base de données
- `test_db` = nom de la base à supprimer

**Résultat attendu :**

```
OK
Time taken: 0.123 seconds
```

**Vérifions qu'elle n'existe plus :**

```sql
SHOW DATABASES;
```

**Résultat attendu :** `test_db` ne devrait plus apparaître (seulement `default`).

#### Étape 3.7 : Sortir de Hive

```sql
exit;
```

** N'oubliez pas le point-virgule !**

** Exercice 3 terminé !**

---

##  Fichiers à compléter

**Créez un fichier `room-0_exercices.md` dans ce dossier** (`rooms/room-0_introduction/`)

**Structure suggérée :**

```markdown
# Room 0 - Mes exercices

## Exercice 1 : Exploration HDFS

### Commandes exécutées :
1. `hdfs dfs -mkdir /data/test`
   - **Explication :** Création d'un dossier de test
   - **Résultat :** Dossier créé avec succès

2. `hdfs dfs -put /tmp/test.txt /data/test/`
   - **Explication :** Copie d'un fichier dans HDFS
   - **Résultat :** Fichier copié

### Difficultés rencontrées :
- Aucune

### Observations :
- HDFS fonctionne correctement
- Les commandes sont simples à utiliser

## Exercice 2 : Première table HBase

### Commandes exécutées :
1. `create 'test_table', 'info'`
   - **Explication :** Création d'une table avec une famille de colonnes
   - **Résultat :** Table créée

2. `put 'test_table', 'row1', 'info:name', 'Test'`
   - **Explication :** Insertion d'une valeur
   - **Résultat :** Donnée insérée

### Difficultés rencontrées :
- J'ai oublié les guillemets au début
- J'ai compris que la syntaxe est `FAMILLE:COLONNE`

### Observations :
- HBase est très différent d'une base SQL classique
- Les row keys sont importantes

## Exercice 3 : Première base de données Hive

### Commandes exécutées :
1. `CREATE DATABASE test_db;`
   - **Explication :** Création d'une base de données
   - **Résultat :** Base créée

### Difficultés rencontrées :
- J'ai oublié le point-virgule plusieurs fois
- Hive m'a rappelé de le mettre

### Observations :
- Hive utilise du SQL, c'est plus familier
- Le point-virgule est obligatoire

## Conclusion

J'ai réussi à :
-  Utiliser HDFS pour stocker des fichiers
-  Créer une table HBase et y insérer des données
-  Créer une base de données Hive

Je suis prêt pour la Room 1 !
```

---

##  Validation

**Vous avez terminé cette room quand :**

- [ ]  Tous les services Docker sont opérationnels (vérifié avec `docker-compose ps`)
- [ ]  Vous avez créé un dossier dans HDFS et copié un fichier
- [ ]  Vous avez créé une table HBase (`test_table`) avec la famille `info`
- [ ]  Vous avez inséré au moins 2 colonnes dans cette table
- [ ]  Vous avez utilisé `scan` et `get` pour voir vos données
- [ ]  Vous avez créé une base de données Hive (`test_db`)
- [ ]  Vous avez utilisé `USE` pour sélectionner cette base
- [ ]  Vous avez supprimé la base de données
- [ ]  Vous avez créé le fichier `room-0_exercices.md` avec toutes vos notes

**Si toutes les cases sont cochées → Félicitations !**

---

##  Prochaine étape

Une fois cette room terminée, vous pouvez passer à **Room 1 : Les bases de HBase**.

Dans la Room 1, vous apprendrez :
- Comment structurer vos données HBase efficacement
- Les opérations CRUD complètes
- Comment travailler avec plusieurs tables
- Les bonnes pratiques

**Bon courage ! **

---

##  Aide mémoire rapide

### Commandes HDFS
- `hdfs dfs -ls /` = lister
- `hdfs dfs -mkdir /dossier` = créer dossier
- `hdfs dfs -put fichier /destination` = copier fichier
- `hdfs dfs -cat /fichier` = voir contenu

### Commandes HBase
- `create 'table', 'famille'` = créer table
- `put 'table', 'row', 'colonne', 'valeur'` = insérer
- `scan 'table'` = voir tout
- `get 'table', 'row'` = voir une ligne
- `exit` = quitter

### Commandes Hive
- `SHOW DATABASES;` = lister bases
- `CREATE DATABASE nom;` = créer base
- `USE nom;` = utiliser base
- `SHOW TABLES;` = lister tables
- `exit;` = quitter (avec `;` !)

**Gardez ce fichier ouvert pendant vos exercices ! **
