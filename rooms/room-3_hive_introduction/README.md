# Room 3 : Introduction à Hive

## Objectifs de cette room

- Comprendre le modèle de données Hive (tables, partitions, buckets)
- Maîtriser les commandes HiveQL de base
- Créer des tables et charger des données
- Effectuer des requêtes SQL simples

## Rappels théoriques

### Qu'est-ce que Hive ?

**Hive** est un entrepôt de données qui permet d'interroger des données stockées dans HDFS en utilisant **HiveQL**, un langage similaire à SQL.

**Avantages** :
- Syntaxe SQL familière
- Intégration avec des outils BI
- Support de différents formats de données (CSV, JSON, Parquet, etc.)
- Optimisations automatiques via MapReduce ou Tez

### Modèle de données Hive

**Base de données** : conteneur logique pour organiser les tables
**Table** : structure similaire à une table SQL avec colonnes typées
**Partition** : division logique d'une table basée sur des valeurs de colonnes
**Bucket** : subdivision d'une partition pour améliorer les performances

### Types de données Hive

- **Primitifs** : INT, BIGINT, FLOAT, DOUBLE, STRING, BOOLEAN, TIMESTAMP
- **Complexes** : ARRAY, MAP, STRUCT

### Formats de stockage

- **TextFile** : format texte (CSV, TSV)
- **SequenceFile** : format binaire Hadoop
- **Parquet** : format colonnaire optimisé
- **ORC** : format optimisé pour Hive

## Exercices pratiques

### Exercice 1 : Première base de données et table

1. Créez une base de données `learning_db`
2. Utilisez cette base de données
3. Créez une table `customers` avec les colonnes suivantes :
   - `customer_id` (STRING)
   - `name` (STRING)
   - `email` (STRING)
   - `city` (STRING)
   - `country` (STRING)
   - `registration_date` (STRING)
   - `status` (STRING)
4. Vérifiez que la table a été créée

**Commandes HiveQL** :
```sql
CREATE DATABASE IF NOT EXISTS learning_db;
USE learning_db;

CREATE TABLE customers (
    customer_id STRING,
    name STRING,
    email STRING,
    city STRING,
    country STRING,
    registration_date STRING,
    status STRING
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ('skip.header.line.count'='1');
```

### Exercice 2 : Charger des données depuis HDFS

1. Copiez le fichier `/data/resources/customers/customers.csv` dans HDFS
2. Chargez les données dans la table `customers`
3. Vérifiez que les données ont été chargées correctement

**Étapes** :

1. Depuis le conteneur Hadoop :
```bash
hdfs dfs -put /data/resources/customers/customers.csv /data/
```

2. Dans Hive :
```sql
LOAD DATA INPATH '/data/customers.csv' INTO TABLE customers;
SELECT COUNT(*) FROM customers;
SELECT * FROM customers LIMIT 5;
```

### Exercice 3 : Requêtes SELECT de base

Sur la table `customers`, exécutez les requêtes suivantes :

1. Affichez tous les clients
2. Affichez uniquement les clients actifs
3. Comptez le nombre de clients par ville
4. Trouvez les clients de Paris
5. Affichez les 10 premiers clients par ordre alphabétique de nom

**Requêtes à écrire** :
```sql
-- Exemple pour la requête 3
SELECT city, COUNT(*) as nb_customers
FROM customers
GROUP BY city
ORDER BY nb_customers DESC;
```

### Exercice 4 : Fonctions et agrégations

1. Comptez le nombre total de clients
2. Comptez le nombre de clients actifs vs inactifs
3. Trouvez les villes uniques
4. Calculez le nombre de clients par pays
5. Utilisez des fonctions de chaîne (UPPER, LOWER, SUBSTRING) sur les noms

**Fonctions utiles** :
- `COUNT()`, `SUM()`, `AVG()`, `MAX()`, `MIN()`
- `UPPER()`, `LOWER()`, `SUBSTRING()`, `CONCAT()`
- `CASE WHEN ... THEN ... ELSE ... END`

### Exercice 5 : Créer une table depuis une requête

1. Créez une nouvelle table `active_customers` contenant uniquement les clients actifs
2. Créez une table `customers_by_city` avec le nombre de clients par ville
3. Vérifiez le contenu de ces nouvelles tables

**Syntaxe** :
```sql
CREATE TABLE active_customers AS
SELECT * FROM customers WHERE status = 'active';
```

## Fichiers à compléter

Créez les fichiers suivants dans ce dossier :

1. **room-3_exercices.md** : documentation de tous vos exercices
2. **room-3_requetes.hql** : toutes vos requêtes HiveQL (une par ligne, commentées)
3. **room-3_observations.md** : vos réflexions sur :
   - Les différences entre HBase et Hive
   - Les avantages de chaque approche
   - Les cas d'usage appropriés

## Validation

Vous avez terminé cette room quand :

-  Vous avez créé une base de données et des tables Hive
-  Vous avez chargé des données depuis HDFS
-  Vous avez exécuté des requêtes SELECT avec filtres et agrégations
-  Vous avez créé des tables à partir de requêtes
-  Vous avez documenté votre travail dans les fichiers demandés

## Prochaine étape

Une fois cette room terminée, vous pouvez passer à **Room 4 : Hive avancé**.

