# Room 9 : Optimisation et Performance

## Introduction

### Contexte

Cette room vous apprend à optimiser les performances de HBase et Hive. Une fois que vous savez créer des tables et exécuter des requêtes, il est essentiel de comprendre comment les rendre efficaces, surtout avec de grandes quantités de données.

### Objectifs mesurables

À la fin de cette room, vous serez capable de :

1. **Optimiser** le design des tables HBase (row keys, familles de colonnes)
2. **Utiliser** les partitions et buckets dans Hive efficacement
3. **Comprendre** les mécanismes d'optimisation (compaction, split, index)
4. **Mesurer** les performances et identifier les goulots d'étranglement
5. **Appliquer** les meilleures pratiques pour de meilleures performances

---

## Prérequis

Avant de commencer cette room, assurez-vous d'avoir :

- Complété les Rooms 1 et 2 (HBase Basics et Advanced)
- Complété les Rooms 3 et 4 (Hive Introduction et Advanced)
- Compris les concepts de base de HBase et Hive
- Un environnement fonctionnel avec des données de test

---

## Section 1 : Optimisation HBase

### Concept 1 : Design des Row Keys

**Pourquoi c'est important :**

Les row keys déterminent comment HBase distribue et accède aux données. Un mauvais design de row key peut causer des hotspots (une seule région reçoit toutes les écritures) et des performances médiocres.

**Rappel : rôle précis**

- Les row keys sont triées par ordre alphabétique
- HBase distribue les données par ranges de row keys dans différentes régions
- Les accès par row key sont très rapides (O(log n))
- Les scans sans row key spécifique sont lents

**Ce que ce n'est PAS :**

- Les row keys ne sont pas des index secondaires
- On ne peut pas faire de requêtes complexes sur les row keys directement
- Les row keys ne peuvent pas être modifiées après insertion

**Erreur fréquente d'étudiant :** Utiliser des row keys séquentielles (1, 2, 3, ...) ou basées sur un timestamp seul. Cela crée des hotspots car toutes les écritures vont dans la même région.

**Exemple concret :**

**Mauvais design :**
```
Row Key: 1
Row Key: 2
Row Key: 3
```
Problème : Toutes les écritures vont dans la même région.

**Bon design :**
```
Row Key: USER_001_20240101
Row Key: USER_002_20240101
Row Key: USER_001_20240102
```
Avantage : Distribution uniforme, préfixe pour les accès par utilisateur.

**Meilleures pratiques :**

1. **Préfixer avec un hash** pour distribution uniforme :
   ```
   Row Key: MD5(user_id)[0:2]_user_id_timestamp
   ```

2. **Inverser les timestamps** pour accès récent en premier :
   ```
   Row Key: user_id_(Long.MAX_VALUE - timestamp)
   ```

3. **Éviter les row keys trop longues** (recommandé : < 100 bytes)

---

### Concept 2 : Familles de colonnes

**Pourquoi c'est important :**

Chaque famille de colonnes est stockée séparément dans HBase. Trop de familles de colonnes peut dégrader les performances.

**Rappel : rôle précis**

- Chaque famille de colonnes est stockée dans un fichier séparé (HFile)
- Les familles de colonnes sont chargées ensemble lors d'un accès
- Modifier une famille de colonnes nécessite de recharger toutes les familles

**Ce que ce n'est PAS :**

- Les familles de colonnes ne sont pas des tables séparées
- On ne peut pas faire de jointures entre familles de colonnes
- Les familles de colonnes ne sont pas des index

**Erreur fréquente d'étudiant :** Créer trop de familles de colonnes (plus de 3-4). Chaque famille de colonnes ajoute de la complexité et peut réduire les performances.

**Meilleures pratiques :**

1. **Limiter à 2-3 familles de colonnes** par table
2. **Grouper les colonnes par pattern d'accès** :
   - Colonnes accédées ensemble → même famille
   - Colonnes accédées séparément → familles différentes
3. **Éviter les familles de colonnes très larges** (beaucoup de colonnes)

**Exemple concret :**

**Mauvais design :**
```
Table: customers
CF1: name, email, phone, address, city, country, zipcode, birthdate, gender, ...
```
Problème : Trop de colonnes dans une seule famille, toutes chargées même si on veut juste le nom.

**Bon design :**
```
Table: customers
CF1: personal (name, email, phone)
CF2: address (address, city, country, zipcode)
CF3: metadata (birthdate, gender, created_at)
```
Avantage : Charger seulement les données nécessaires.

---

### Concept 3 : Compaction et Split

**Pourquoi c'est important :**

HBase stocke les données dans des fichiers (HFiles). Au fil du temps, ces fichiers deviennent nombreux et fragmentés, ce qui ralentit les lectures. La compaction et le split permettent de maintenir de bonnes performances.

**Rappel : rôle précis**

- **Compaction** : Fusionne plusieurs petits HFiles en un seul grand fichier
- **Split** : Divise une région trop grande en deux régions plus petites
- Ces opérations sont automatiques mais peuvent être déclenchées manuellement

**Ce que ce n'est PAS :**

- La compaction n'est pas une sauvegarde
- Le split n'est pas une réplication
- Ces opérations ne sont pas instantanées (peuvent prendre du temps)

**Erreur fréquente d'étudiant :** Essayer de forcer une compaction ou un split trop fréquemment. Ces opérations consomment des ressources et doivent être laissées à HBase en général.

**Quand intervenir manuellement :**

1. **Compaction manuelle** : Si les performances se dégradent significativement
2. **Split manuel** : Si une région devient très grande (> 10 GB)

**Commandes :**

```bash
# Dans HBase shell
# Compaction majeure d'une table
major_compact 'ma_table'

# Split d'une région (rarement nécessaire)
split 'ma_table', 'row_key_separateur'
```

---

## Section 2 : Optimisation Hive

### Concept 1 : Partitions

**Pourquoi c'est important :**

Les partitions permettent de diviser une table en sous-répertoires basés sur les valeurs d'une ou plusieurs colonnes. Cela réduit considérablement la quantité de données scannées lors des requêtes.

**Rappel : rôle précis**

- Chaque partition est stockée dans un répertoire séparé dans HDFS
- Les requêtes avec filtres sur les colonnes de partition ne scannent que les partitions pertinentes
- Les partitions sont définies lors de la création de la table

**Ce que ce n'est PAS :**

- Les partitions ne sont pas des index
- On ne peut pas partitionner sur n'importe quelle colonne (doit être dans le schéma)
- Les partitions ne sont pas automatiques (doit être gérées manuellement)

**Erreur fréquente d'étudiant :** Créer trop de partitions (millions de petites partitions). Chaque partition ajoute de la métadonnée et peut ralentir les requêtes.

**Exemple concret :**

**Table non partitionnée :**
```sql
CREATE TABLE sales (
    id INT,
    product STRING,
    date STRING,
    amount DOUBLE
);
```
Problème : Pour chercher les ventes d'un jour, Hive doit scanner toute la table.

**Table partitionnée :**
```sql
CREATE TABLE sales (
    id INT,
    product STRING,
    amount DOUBLE
)
PARTITIONED BY (date STRING);
```
Avantage : Pour chercher les ventes d'un jour, Hive ne scanne que la partition de ce jour.

**Meilleures pratiques :**

1. **Partitionner sur des colonnes fréquemment utilisées dans WHERE**
2. **Éviter les partitions trop nombreuses** (recommandé : < 10 000 partitions par table)
3. **Utiliser des formats de date cohérents** pour les partitions temporelles

---

### Concept 2 : Buckets (Clustering)

**Pourquoi c'est important :**

Les buckets divisent les données d'une partition en fichiers basés sur un hash d'une colonne. Cela permet des jointures plus efficaces et des échantillonnages rapides.

**Rappel : rôle précis**

- Les buckets sont créés avec `CLUSTERED BY` lors de la création de la table
- Les données sont réparties dans les buckets selon un hash de la colonne spécifiée
- Les jointures sur les colonnes de bucket sont très efficaces

**Ce que ce n'est PAS :**

- Les buckets ne sont pas des partitions
- On ne peut pas filtrer directement sur les buckets
- Les buckets ne sont pas automatiques (doivent être créés explicitement)

**Erreur fréquente d'étudiant :** Utiliser des buckets sans comprendre leur utilité. Les buckets sont utiles pour les jointures, pas pour toutes les tables.

**Exemple concret :**

**Table avec buckets :**
```sql
CREATE TABLE customers (
    id INT,
    name STRING,
    email STRING
)
CLUSTERED BY (id) INTO 10 BUCKETS;
```

**Avantages :**
- Jointures efficaces si les deux tables sont bucketées sur la même colonne
- Échantillonnage rapide (lire seulement quelques buckets)

**Meilleures pratiques :**

1. **Utiliser des buckets pour les tables fréquemment jointes**
2. **Choisir un nombre de buckets approprié** (généralement puissance de 2, comme 4, 8, 16, 32)
3. **Bucketer sur la colonne de jointure**

---

### Concept 3 : Formats de fichiers

**Pourquoi c'est important :**

Le format de fichier utilisé par Hive affecte les performances de lecture/écriture et la compression.

**Formats courants :**

1. **TextFile** (par défaut)
   - Format texte simple
   - Pas de compression
   - Lent pour les grandes tables

2. **SequenceFile**
   - Format binaire
   - Compression possible
   - Meilleures performances que TextFile

3. **ORC (Optimized Row Columnar)**
   - Format colonnaire optimisé
   - Compression excellente
   - Index intégré
   - **Recommandé pour la plupart des cas**

4. **Parquet**
   - Format colonnaire
   - Compression excellente
   - Compatible avec d'autres outils (Spark, Impala)

**Exemple concret :**

**Table avec format TextFile (défaut) :**
```sql
CREATE TABLE sales (
    id INT,
    product STRING,
    amount DOUBLE
)
STORED AS TEXTFILE;
```
Problème : Pas de compression, lectures lentes.

**Table avec format ORC :**
```sql
CREATE TABLE sales (
    id INT,
    product STRING,
    amount DOUBLE
)
STORED AS ORC;
```
Avantage : Compression ~70%, lectures 3-5x plus rapides.

**Meilleures pratiques :**

1. **Utiliser ORC pour la plupart des tables** (meilleur compromis)
2. **Utiliser Parquet si vous utilisez aussi Spark ou Impala**
3. **Éviter TextFile pour les grandes tables**

---

## Section 3 : Mesure des performances

### Outils de mesure

**1. EXPLAIN dans Hive**

```sql
-- Voir le plan d'exécution d'une requête
EXPLAIN SELECT * FROM sales WHERE date = '2024-01-01';

-- Voir le plan détaillé
EXPLAIN EXTENDED SELECT * FROM sales WHERE date = '2024-01-01';
```

**2. Interface web HBase Master**

- URL : http://localhost:16011
- Affiche : État des régions, taille des tables, statistiques

**3. Interface web YARN ResourceManager**

- URL : http://localhost:8088
- Affiche : Utilisation des ressources, temps d'exécution des jobs

**4. Logs Docker**

```bash
# Voir les logs en temps réel
docker compose logs -f hive

# Voir les dernières lignes
docker compose logs --tail=100 hbase
```

---

## Section 4 : Exercices pratiques

### Exercice 1 : Optimiser une table HBase

Vous avez une table `logs` avec des millions d'entrées. Les requêtes sont lentes.

**Données actuelles :**
- Row Key : timestamp seul (ex: `1640995200000`)
- Une seule famille de colonnes avec toutes les données

**Réponse de l'étudiant :**

1. Quel est le problème avec le design actuel ?
   - 

2. Comment redessinez-vous les row keys ?
   - 

3. Comment réorganisez-vous les familles de colonnes ?
   - 

4. Quelles améliorations de performance attendez-vous ?
   - 

---

### Exercice 2 : Optimiser une table Hive

Vous avez une table `sales` non partitionnée avec des millions de lignes. Les requêtes filtrant par date sont très lentes.

**Réponse de l'étudiant :**

1. Quelle optimisation proposez-vous ?
   - 

2. Comment créez-vous la table optimisée ?
   - 

3. Comment migrez-vous les données existantes ?
   - 

4. Quel format de fichier choisissez-vous et pourquoi ?
   - 

---

### Exercice 3 : Mesurer les performances

Comparez les performances d'une requête avant et après optimisation.

**Réponse de l'étudiant :**

1. Quelle requête testez-vous ?
   - 

2. Quel est le temps d'exécution avant optimisation ?
   - 

3. Quelles optimisations appliquez-vous ?
   - 

4. Quel est le temps d'exécution après optimisation ?
   - 

5. Quel est le gain de performance obtenu ?
   - 

---

## Section 5 : Checklist d'optimisation

Utilisez cette checklist pour optimiser vos tables :

### Pour HBase

- [ ] Row keys sont bien conçues (distribution uniforme, pas de hotspots)
- [ ] Nombre de familles de colonnes limité (2-3 maximum)
- [ ] Colonnes groupées par pattern d'accès
- [ ] Compaction régulière (automatique ou manuelle si nécessaire)
- [ ] Régions de taille raisonnable (pas trop grandes, pas trop petites)

### Pour Hive

- [ ] Tables partitionnées sur les colonnes fréquemment filtrées
- [ ] Format de fichier optimisé (ORC ou Parquet)
- [ ] Buckets utilisés pour les tables fréquemment jointes
- [ ] Requêtes utilisent les filtres sur les partitions
- [ ] Éviter SELECT * sur de grandes tables

---

## Validation

Pour valider cette room, vous devez :

1. Avoir optimisé au moins une table HBase et une table Hive
2. Avoir mesuré les performances avant et après optimisation
3. Avoir complété les exercices pratiques
4. Comprendre quand et comment utiliser chaque technique d'optimisation

---

## Prochaine étape

Une fois cette room validée, vous pouvez :
- Appliquer ces optimisations dans vos projets précédents
- Passer au projet final (Room 7) avec des connaissances d'optimisation
- Continuer à expérimenter avec différentes stratégies d'optimisation

Cette room vous donne les outils pour créer des systèmes performants et évolutifs.

