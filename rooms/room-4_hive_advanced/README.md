# Room 4 : Hive avancé

## Objectifs de cette room

- Maîtriser les jointures (JOIN) dans Hive
- Comprendre les partitions et leur utilisation
- Travailler avec différents formats de données
- Optimiser les performances des requêtes

## Rappels théoriques

### Jointures (JOIN)

Hive supporte plusieurs types de jointures :
- **INNER JOIN** : lignes présentes dans les deux tables
- **LEFT JOIN** : toutes les lignes de la table gauche
- **RIGHT JOIN** : toutes les lignes de la table droite
- **FULL OUTER JOIN** : toutes les lignes des deux tables

**Performance** : les jointures peuvent être coûteuses. Assurez-vous d'avoir des clés de jointure bien indexées.

### Partitions

Les **partitions** permettent de diviser une table en sous-dossiers basés sur les valeurs de certaines colonnes. Cela améliore les performances en limitant les données scannées.

**Exemple** : partitionner une table de ventes par année et mois
```
/user/hive/warehouse/sales/
  year=2024/
    month=01/
    month=02/
```

**Avantages** :
- Réduction du volume de données scannées
- Amélioration des performances des requêtes
- Organisation logique des données

### Formats de données

**Parquet** : format colonnaire optimisé pour l'analytique
- Compression efficace
- Projection de colonnes
- Support du schéma

**ORC** : Optimized Row Columnar, format natif Hive
- Compression encore meilleure
- Index intégré
- Support des types complexes

## Exercices pratiques

### Exercice 1 : Créer des tables pour les ventes

1. Créez une table `sales` avec les colonnes suivantes :
   - `sale_id` (STRING)
   - `product_id` (STRING)
   - `customer_id` (STRING)
   - `sale_date` (STRING)
   - `quantity` (INT)
   - `unit_price` (DOUBLE)
   - `total_amount` (DOUBLE)
   - `region` (STRING)

2. Chargez les données depuis `/data/resources/sales/sales-data.csv`

3. Créez une table `products` avec :
   - `product_id` (STRING)
   - `product_name` (STRING)
   - `category` (STRING)
   - `supplier` (STRING)

4. Insérez quelques produits de test

**Commandes** :
```sql
CREATE TABLE sales (
    sale_id STRING,
    product_id STRING,
    customer_id STRING,
    sale_date STRING,
    quantity INT,
    unit_price DOUBLE,
    total_amount DOUBLE,
    region STRING
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ('skip.header.line.count'='1');
```

### Exercice 2 : Jointures

1. Effectuez une jointure entre `sales` et `customers` pour afficher les ventes avec les noms des clients
2. Effectuez une jointure entre `sales` et `products` pour afficher les ventes avec les noms des produits
3. Créez une requête qui affiche : sale_id, customer_name, product_name, total_amount, sale_date
4. Calculez le total des ventes par client

**Requêtes à écrire** :
```sql
-- Exemple de jointure
SELECT s.sale_id, c.name as customer_name, s.total_amount, s.sale_date
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id;
```

### Exercice 3 : Partitions

1. Créez une table `sales_partitioned` partitionnée par `region`
2. Chargez les données en spécifiant les partitions
3. Comparez les performances entre la table normale et la table partitionnée

**Syntaxe** :
```sql
CREATE TABLE sales_partitioned (
    sale_id STRING,
    product_id STRING,
    customer_id STRING,
    sale_date STRING,
    quantity INT,
    unit_price DOUBLE,
    total_amount DOUBLE
) PARTITIONED BY (region STRING)
STORED AS TEXTFILE;

-- Charger avec partition
LOAD DATA INPATH '/data/sales-data.csv' 
INTO TABLE sales_partitioned
PARTITION (region='North');
```

### Exercice 4 : Requêtes analytiques avancées

1. Calculez le total des ventes par région
2. Trouvez le top 5 des clients par montant total d'achat
3. Calculez la moyenne des ventes par mois (extrayez le mois de `sale_date`)
4. Trouvez les produits les plus vendus (par quantité)
5. Calculez le chiffre d'affaires total par région et par mois

**Fonctions utiles** :
- `SUBSTRING(date, 1, 7)` pour extraire année-mois
- `SUM()`, `AVG()`, `MAX()`, `MIN()`
- `RANK()`, `ROW_NUMBER()` pour le ranking
- `GROUP BY` avec plusieurs colonnes

### Exercice 5 : Format Parquet

1. Créez une table `sales_parquet` avec le même schéma que `sales` mais stockée en Parquet
2. Insérez les données de `sales` dans `sales_parquet`
3. Comparez la taille des fichiers entre TEXTFILE et Parquet
4. Testez les performances d'une requête sur les deux tables

**Syntaxe** :
```sql
CREATE TABLE sales_parquet (
    sale_id STRING,
    product_id STRING,
    customer_id STRING,
    sale_date STRING,
    quantity INT,
    unit_price DOUBLE,
    total_amount DOUBLE,
    region STRING
) STORED AS PARQUET;

INSERT INTO TABLE sales_parquet SELECT * FROM sales;
```

## Fichiers à compléter

Créez les fichiers suivants dans ce dossier :

1. **room-4_exercices.md** : documentation complète
2. **room-4_requetes.hql** : toutes vos requêtes HiveQL
3. **room-4_analyse.md** : analyse des performances et observations sur :
   - L'impact des partitions sur les performances
   - La différence entre TEXTFILE et Parquet
   - Les optimisations possibles

## Validation

Vous avez terminé cette room quand :

-  Vous avez créé plusieurs tables et effectué des jointures
-  Vous avez créé et utilisé des tables partitionnées
-  Vous avez comparé différents formats de stockage
-  Vous avez écrit des requêtes analytiques complexes
-  Vous avez documenté vos observations sur les performances

## Prochaine étape

Une fois cette room terminée, vous pouvez passer à **Room 5 : Intégration HBase-Hive**.

