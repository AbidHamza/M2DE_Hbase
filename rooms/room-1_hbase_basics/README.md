# Room 1 : Les bases de HBase

##  Objectifs de cette room

À la fin de cette room, vous saurez :
-  Comprendre le modèle de données HBase en profondeur
-  Créer des tables avec plusieurs familles de colonnes
-  Insérer, lire, mettre à jour et supprimer des données (CRUD complet)
-  Utiliser des filtres de base pour interroger vos données
-  Structurer vos données efficacement

** Temps estimé :** 2-3 heures (prenez votre temps pour bien comprendre !)

---

##  Rappels théoriques - EXPLICATION APPROFONDIE

### Le modèle de données HBase - Comprendre en profondeur

**HBase est très différent d'une base de données SQL classique !**

#### Analogie simple

Imaginez une **énorme feuille Excel** avec des milliards de lignes :
- Chaque ligne a un **identifiant unique** (row key)
- Les colonnes ne sont pas fixes : vous pouvez ajouter n'importe quelle colonne à n'importe quelle ligne
- Les colonnes sont organisées en **familles** (comme des dossiers)
- Chaque cellule peut avoir plusieurs **versions** (historique)

#### Concepts clés expliqués

**1. Row Key (Clé de ligne)**

**Qu'est-ce que c'est ?**
- C'est l'**identifiant unique** de chaque ligne
- Comme une clé primaire en SQL, mais **obligatoire** et **unique**
- C'est la **seule façon** d'accéder directement à une ligne

**Exemple :**
```
Row Key: CUST001
Row Key: CUST002
Row Key: DEVICE_20240101_100000
```

** IMPORTANT :**
- Les row keys sont **sensibles à la casse** : `CUST001` ≠ `cust001`
- Elles sont **triées** : HBase organise les données par ordre alphabétique des row keys
- Choisissez-les **bien** : elles déterminent les performances !

**2. Famille de colonnes (Column Family)**

**Qu'est-ce que c'est ?**
- Un **groupe logique** de colonnes
- Comme un dossier qui contient plusieurs fichiers liés
- **Définie à la création** de la table (vous ne pouvez pas en ajouter après facilement)

**Pourquoi utiliser des familles ?**
- **Organisation** : regrouper les colonnes liées
- **Performance** : HBase stocke les familles séparément
- **Permissions** : vous pouvez donner des permissions par famille

**Exemple :**
```
Famille 'info' : info:name, info:age, info:city
Famille 'contact' : contact:email, contact:phone, contact:address
```

** RÈGLE D'OR :** Ne créez pas trop de familles ! 1-3 familles est optimal.

**3. Colonne (Column)**

**Qu'est-ce que c'est ?**
- Identifiée par `FAMILLE:QUALIFIER`
- `FAMILLE` = le nom de la famille
- `QUALIFIER` = le nom spécifique de la colonne
- Le `:` (deux-points) sépare la famille du qualifier

**Exemples :**
```
info:name        → famille 'info', colonne 'name'
info:age         → famille 'info', colonne 'age'
contact:email    → famille 'contact', colonne 'email'
contact:phone    → famille 'contact', colonne 'phone'
```

**4. Version (Versioning)**

**Qu'est-ce que c'est ?**
- HBase garde **plusieurs versions** de chaque cellule
- Par défaut : **3 versions**
- Chaque modification crée une nouvelle version avec un **timestamp**

**Pourquoi c'est utile ?**
- Voir l'**historique** des modifications
- Récupérer une valeur à un **moment précis**
- **Auditer** les changements

**5. Timestamp**

**Qu'est-ce que c'est ?**
- Horodatage **automatique** de chaque modification
- Format : nombre de millisecondes depuis le 1er janvier 1970
- Vous pouvez aussi le spécifier manuellement

---

### Structure d'une table HBase - Exemple visuel

**Table `customers` :**

```
Row Key    | info:name      | info:age  | info:city    | contact:email              | contact:phone
-----------|----------------|-----------|--------------|---------------------------|---------------
CUST001    | Jean Dupont    | 30        | Paris        | jean.dupont@email.com     | 0612345678
CUST002    | Marie Martin   | 25        | Lyon         | marie.martin@email.com    | 0698765432
CUST003    | Pierre Durand  | 35        | Marseille    | pierre.durand@email.com  | (null)
```

**Décodage :**
- **2 familles** : `info` et `contact`
- **5 colonnes** : `info:name`, `info:age`, `info:city`, `contact:email`, `contact:phone`
- **3 lignes** avec des row keys : `CUST001`, `CUST002`, `CUST003`

---

### Opérations CRUD - Explication complète

**CRUD = Create, Read, Update, Delete**

#### CREATE (Créer)

**En HBase :** Créer une table avec ses familles de colonnes

**Syntaxe :**
```hbase
create 'NOM_TABLE', 'FAMILLE1', 'FAMILLE2', ...
```

**Exemple :**
```hbase
create 'customers', 'info', 'contact'
```

**Ce qui se passe :**
1. HBase crée une nouvelle table nommée `customers`
2. Deux familles de colonnes sont créées : `info` et `contact`
3. La table est vide (aucune ligne)

** IMPORTANT :**
- Vous **ne pouvez pas** ajouter de familles après la création (c'est très difficile)
- Choisissez bien vos familles dès le début !

#### READ (Lire)

**En HBase :** Récupérer des données

**Deux méthodes principales :**

**1. GET** : Récupérer une ligne spécifique
```hbase
get 'customers', 'CUST001'
```

**2. SCAN** : Parcourir plusieurs lignes
```hbase
scan 'customers'
```

#### UPDATE (Mettre à jour)

**En HBase :** Utilise la même commande que l'insertion !

**Syntaxe :**
```hbase
put 'customers', 'CUST001', 'contact:email', 'nouveau.email@email.com'
```

**Ce qui se passe :**
- Si la colonne existe → elle est mise à jour
- Si la colonne n'existe pas → elle est créée
- Une nouvelle version est créée avec un nouveau timestamp

#### DELETE (Supprimer)

**En HBase :** Supprimer une cellule ou une ligne entière

**Supprimer une colonne :**
```hbase
delete 'customers', 'CUST001', 'contact:phone'
```

**Supprimer une ligne entière :**
```hbase
delete 'customers', 'CUST001'
```

---

##  Exercices pratiques - GUIDE PAS À PAS DÉTAILLÉ

### Exercice 1 : Créer une table pour les clients

**Objectif :** Créer votre première table avec plusieurs familles de colonnes

#### Étape 1.1 : Entrer dans le shell HBase

```bash
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell
```

** Vous voyez le prompt `hbase(main):001:0>`**

#### Étape 1.2 : Vérifier qu'il n'y a pas de table existante

**Avant de créer, vérifions qu'elle n'existe pas déjà :**

```hbase
list
```

**Résultat attendu :** Liste des tables (probablement vide ou avec d'autres tables)

**Si la table `customers` existe déjà :**
```hbase
disable 'customers'
drop 'customers'
```

**Explication :**
- `disable` = désactiver la table (obligatoire avant suppression)
- `drop` = supprimer la table

#### Étape 1.3 : Créer la table `customers`

**Commande :**
```hbase
create 'customers', 'info', 'contact'
```

**Explication MOT PAR MOT :**
- `create` = commande pour créer une table
- `'customers'` = nom de la table (entre guillemets simples)
- `'info'` = première famille de colonnes
- `'contact'` = deuxième famille de colonnes
- Les familles sont séparées par des virgules

**Résultat attendu :**

```
0 row(s) in 1.2345 seconds

=> Hbase::Table - customers
```

** Table créée avec succès !**

**Ce qui s'est passé :**
- HBase a créé une table nommée `customers`
- Deux familles de colonnes ont été créées : `info` et `contact`
- La table est vide (0 lignes)

#### Étape 1.4 : Vérifier la structure de la table

**Commande :**
```hbase
describe 'customers'
```

**Explication :**
- `describe` = afficher la description/structure d'une table
- `'customers'` = nom de la table

**Résultat attendu :**

```
Table customers is ENABLED
customers
COLUMN FAMILIES DESCRIPTION
{NAME => 'contact', VERSIONS => '1', KEEP_DELETED_CELLS => 'FALSE', ...
{NAME => 'info', VERSIONS => '1', KEEP_DELETED_CELLS => 'FALSE', ...
2 row(s) in 0.1234 seconds
```

**Décodage du résultat :**
- `ENABLED` = la table est active (vous pouvez l'utiliser)
- `COLUMN FAMILIES DESCRIPTION` = description des familles
- `NAME => 'contact'` = nom de la famille
- `VERSIONS => '1'` = nombre de versions gardées (par défaut, mais peut être changé)
- `2 row(s)` = 2 familles trouvées

** Vous voyez bien les deux familles `info` et `contact` !**

#### Étape 1.5 : Vérifier que la table est vide

**Commandes :**
```hbase
scan 'customers'
count 'customers'
```

**Explication :**
- `scan` = parcourir toutes les lignes
- `count` = compter le nombre de lignes

**Résultat attendu :**
- `scan` : rien (table vide)
- `count` : `0 row(s)`

** Table créée et vide, prête à recevoir des données !**

---

### Exercice 2 : Insérer des données clients - GUIDE COMPLET

**Objectif :** Insérer 5 clients avec toutes leurs informations

#### Étape 2.1 : Comprendre la structure des données

**Pour chaque client, nous avons :**
- **Row Key** : identifiant unique (ex: `CUST001`)
- **Famille `info`** : informations personnelles
  - `info:name` = nom
  - `info:city` = ville
  - `info:country` = pays
- **Famille `contact`** : informations de contact
  - `contact:email` = email

#### Étape 2.2 : Insérer le premier client (CUST001)

**Client 1 :**
- Row Key : `CUST001`
- Nom : `Jean Dupont`
- Ville : `Paris`
- Pays : `France`
- Email : `jean.dupont@email.com`

**Commandes à exécuter :**

```hbase
put 'customers', 'CUST001', 'info:name', 'Jean Dupont'
```

**Explication DÉTAILLÉE :**
- `put` = commande pour insérer/mettre à jour
- `'customers'` = nom de la table
- `'CUST001'` = row key (identifiant de la ligne)
- `'info:name'` = colonne (famille `info` + qualifier `name`)
- `'Jean Dupont'` = valeur à stocker

**Résultat attendu :** Pas de message d'erreur = succès !

**Continuons avec les autres colonnes :**

```hbase
put 'customers', 'CUST001', 'info:city', 'Paris'
put 'customers', 'CUST001', 'info:country', 'France'
put 'customers', 'CUST001', 'contact:email', 'jean.dupont@email.com'
```

** IMPORTANT :**
- Même row key `'CUST001'` pour toutes les commandes
- Chaque `put` ajoute/modifie une colonne
- L'ordre n'a pas d'importance !

**Vérifions que tout est bien inséré :**

```hbase
get 'customers', 'CUST001'
```

**Résultat attendu :**

```
COLUMN                    CELL
 contact:email           timestamp=..., value=jean.dupont@email.com
 info:city               timestamp=..., value=Paris
 info:country            timestamp=..., value=France
 info:name               timestamp=..., value=Jean Dupont
4 row(s) in 0.1234 seconds
```

** Client 1 inséré avec succès !**

#### Étape 2.3 : Insérer les 4 autres clients

**Client 2 :**
```hbase
put 'customers', 'CUST002', 'info:name', 'Marie Martin'
put 'customers', 'CUST002', 'info:city', 'Lyon'
put 'customers', 'CUST002', 'info:country', 'France'
put 'customers', 'CUST002', 'contact:email', 'marie.martin@email.com'
```

**Client 3 :**
```hbase
put 'customers', 'CUST003', 'info:name', 'Pierre Durand'
put 'customers', 'CUST003', 'info:city', 'Marseille'
put 'customers', 'CUST003', 'info:country', 'France'
put 'customers', 'CUST003', 'contact:email', 'pierre.durand@email.com'
```

**Client 4 :**
```hbase
put 'customers', 'CUST004', 'info:name', 'Sophie Bernard'
put 'customers', 'CUST004', 'info:city', 'Toulouse'
put 'customers', 'CUST004', 'info:country', 'France'
put 'customers', 'CUST004', 'contact:email', 'sophie.bernard@email.com'
```

**Client 5 :**
```hbase
put 'customers', 'CUST005', 'info:name', 'Luc Moreau'
put 'customers', 'CUST005', 'info:city', 'Nice'
put 'customers', 'CUST005', 'info:country', 'France'
put 'customers', 'CUST005', 'contact:email', 'luc.moreau@email.com'
```

**Vérifions que tous les clients sont bien là :**

```hbase
count 'customers'
```

**Résultat attendu :** `5 row(s)` (5 lignes)

**Voir toutes les données :**

```hbase
scan 'customers'
```

** Tous les clients sont insérés !**

---

### Exercice 3 : Interroger les données - EXPLICATION COMPLÈTE

**Objectif :** Apprendre à récupérer des données de différentes façons

#### Étape 3.1 : Récupérer toutes les données (SCAN)

**Commande :**
```hbase
scan 'customers'
```

**Explication :**
- `scan` = parcourir toutes les lignes d'une table
- `'customers'` = nom de la table

**Résultat attendu :**

```
ROW                      COLUMN+CELL
 CUST001                 column=contact:email, timestamp=..., value=jean.dupont@email.com
 CUST001                 column=info:city, timestamp=..., value=Paris
 CUST001                 column=info:country, timestamp=..., value=France
 CUST001                 column=info:name, timestamp=..., value=Jean Dupont
 CUST002                 column=contact:email, timestamp=..., value=marie.martin@email.com
 CUST002                 column=info:city, timestamp=..., value=Lyon
 ...
5 row(s) in 0.1234 seconds
```

**Décodage :**
- `ROW` = la row key
- `COLUMN+CELL` = la colonne et sa valeur
- Les lignes sont **triées** par row key (ordre alphabétique)
- `5 row(s)` = 5 lignes au total

** ATTENTION :** `scan` peut être **lent** sur de très grandes tables ! Utilisez-le avec précaution.

#### Étape 3.2 : Récupérer un client spécifique (GET)

**Commande :**
```hbase
get 'customers', 'CUST002'
```

**Explication :**
- `get` = récupérer une ligne spécifique
- `'customers'` = nom de la table
- `'CUST002'` = row key de la ligne à récupérer

**Résultat attendu :**

```
COLUMN                   CELL
 contact:email          timestamp=..., value=marie.martin@email.com
 info:city               timestamp=..., value=Lyon
 info:country            timestamp=..., value=France
 info:name               timestamp=..., value=Marie Martin
4 row(s) in 0.1234 seconds
```

** Seulement les données de CUST002 !**

**Avantage de GET :**
- **Beaucoup plus rapide** que `scan` pour une ligne spécifique
- Utilise la row key directement (accès direct)

#### Étape 3.3 : Récupérer une colonne spécifique

**Récupérons seulement l'email du client CUST003 :**

```hbase
get 'customers', 'CUST003', {COLUMN => 'contact:email'}
```

**Explication DÉTAILLÉE :**
- `get` = récupérer
- `'customers'` = table
- `'CUST003'` = row key
- `{COLUMN => 'contact:email'}` = filtre pour ne récupérer que cette colonne
  - `{}` = syntaxe spéciale HBase (accolades)
  - `COLUMN =>` = mot-clé pour spécifier la colonne
  - `'contact:email'` = nom de la colonne

**Résultat attendu :**

```
COLUMN                   CELL
 contact:email          timestamp=..., value=pierre.durand@email.com
1 row(s) in 0.1234 seconds
```

** Seulement l'email !**

**Récupérer toutes les colonnes d'une famille :**

```hbase
get 'customers', 'CUST003', {COLUMN => 'info'}
```

**Résultat attendu :** Toutes les colonnes de la famille `info` (name, city, country)

#### Étape 3.4 : Compter le nombre de lignes

**Commande :**
```hbase
count 'customers'
```

**Explication :**
- `count` = compter
- `'customers'` = nom de la table

**Résultat attendu :** `5 row(s)`

** ATTENTION :** `count` peut être **lent** sur de très grandes tables car il doit scanner toute la table.

---

### Exercice 4 : Mettre à jour et supprimer - GUIDE COMPLET

**Objectif :** Modifier et supprimer des données

#### Étape 4.1 : Mettre à jour l'email d'un client

**Mettons à jour l'email de CUST001 :**

```hbase
put 'customers', 'CUST001', 'contact:email', 'nouveau.email@email.com'
```

**Explication :**
- Même syntaxe que pour l'insertion !
- Si la colonne existe → elle est mise à jour
- Si la colonne n'existe pas → elle est créée

**Vérifions la mise à jour :**

```hbase
get 'customers', 'CUST001', {COLUMN => 'contact:email'}
```

**Résultat attendu :** `nouveau.email@email.com`

** Email mis à jour !**

**Note importante :** L'ancienne valeur est toujours là (dans une version précédente). HBase garde l'historique !

#### Étape 4.2 : Ajouter une nouvelle colonne

**Ajoutons un numéro de téléphone au client CUST002 :**

```hbase
put 'customers', 'CUST002', 'contact:phone', '0612345678'
```

**Explication :**
- Même commande `put`
- Nouvelle colonne `contact:phone` (n'existait pas avant)
- Elle est créée automatiquement

**Vérifions :**

```hbase
get 'customers', 'CUST002'
```

**Résultat attendu :** Vous devriez maintenant voir `contact:phone` dans la liste !

** Nouvelle colonne ajoutée !**

#### Étape 4.3 : Supprimer une colonne spécifique

**Supprimons le téléphone que nous venons d'ajouter :**

```hbase
delete 'customers', 'CUST002', 'contact:phone'
```

**Explication :**
- `delete` = supprimer
- `'customers'` = table
- `'CUST002'` = row key
- `'contact:phone'` = colonne à supprimer

**Vérifions :**

```hbase
get 'customers', 'CUST002', {COLUMN => 'contact:phone'}
```

**Résultat attendu :** Rien (colonne supprimée)

** Colonne supprimée !**

#### Étape 4.4 : Supprimer un client entier

**Supprimons le client CUST004 :**

```hbase
delete 'customers', 'CUST004'
```

**Explication :**
- Même commande `delete`
- Mais **sans spécifier de colonne** → supprime toute la ligne

**Vérifions :**

```hbase
get 'customers', 'CUST004'
```

**Résultat attendu :** Rien (ligne supprimée)

**Comptons les lignes :**

```hbase
count 'customers'
```

**Résultat attendu :** `4 row(s)` (au lieu de 5)

** Client supprimé !**

---

### Exercice 5 : Filtrer les résultats - GUIDE COMPLET

**Objectif :** Utiliser des filtres pour interroger efficacement

#### Étape 5.1 : Filtrer par valeur (ValueFilter)

**Trouvons tous les clients de Paris :**

```hbase
scan 'customers', {FILTER => "ValueFilter(=, 'binary:Paris')"}
```

**Explication DÉTAILLÉE :**
- `scan` = parcourir
- `'customers'` = table
- `{FILTER => ...}` = syntaxe pour appliquer un filtre
- `ValueFilter` = filtre qui cherche dans les valeurs
- `(=, 'binary:Paris')` = égal à "Paris"
  - `=` = opérateur d'égalité
  - `'binary:Paris'` = valeur à chercher (format binaire)

**Résultat attendu :**

```
ROW                      COLUMN+CELL
 CUST001                 column=info:city, timestamp=..., value=Paris
1 row(s) in 0.1234 seconds
```

** Seulement les clients de Paris !**

** ATTENTION :** Ce filtre scanne **toute la table** et vérifie chaque valeur. Sur de grandes tables, c'est lent !

#### Étape 5.2 : Filtrer par famille de colonnes

**Affichons uniquement les colonnes de la famille `info` :**

```hbase
scan 'customers', {COLUMNS => 'info'}
```

**Explication :**
- `COLUMNS => 'info'` = ne récupérer que les colonnes de la famille `info`

**Résultat attendu :**

```
ROW                      COLUMN+CELL
 CUST001                 column=info:city, timestamp=..., value=Paris
 CUST001                 column=info:country, timestamp=..., value=France
 CUST001                 column=info:name, timestamp=..., value=Jean Dupont
 CUST002                 column=info:city, timestamp=..., value=Lyon
 ...
```

** Seulement les colonnes `info` !**

**Avantage :** Plus rapide car HBase ne lit que les données de cette famille.

#### Étape 5.3 : Limiter le nombre de résultats

**Affichons seulement les 3 premiers clients :**

```hbase
scan 'customers', {LIMIT => 3}
```

**Explication :**
- `LIMIT => 3` = limiter à 3 résultats

**Résultat attendu :** Seulement les 3 premières lignes (par ordre de row key)

** Utile pour tester sans charger toute la table !**

#### Étape 5.4 : Combiner plusieurs filtres

**Affichons les 2 premiers clients, mais seulement leurs colonnes `info` :**

```hbase
scan 'customers', {COLUMNS => 'info', LIMIT => 2}
```

**Explication :** On combine `COLUMNS` et `LIMIT`

**Résultat attendu :** 2 premières lignes, seulement colonnes `info`

** Filtres combinés !**

---

##  Fichiers à compléter

### Fichier 1 : `room-1_exercices.md`

**Créez ce fichier dans le dossier `rooms/room-1_hbase_basics/`**

**Structure suggérée :**

```markdown
# Room 1 - Mes exercices HBase

## Exercice 1 : Création de la table

### Commandes exécutées :
1. `create 'customers', 'info', 'contact'`
   - **Explication :** Création d'une table avec 2 familles de colonnes
   - **Résultat :** Table créée avec succès
   - **Observation :** Les familles sont définies à la création

2. `describe 'customers'`
   - **Explication :** Vérification de la structure
   - **Résultat :** 2 familles visibles (info et contact)

### Difficultés rencontrées :
- Aucune

## Exercice 2 : Insertion de données

### Commandes exécutées :
[Listez toutes vos commandes PUT]

### Résultats :
- 5 clients insérés avec succès
- Vérifié avec `count 'customers'` → 5 row(s)

### Observations :
- La syntaxe PUT est simple mais répétitive
- L'ordre des PUT n'a pas d'importance
- Chaque PUT crée une nouvelle version avec timestamp

## Exercice 3 : Interrogation des données

### Commandes testées :
1. `scan 'customers'` → Toutes les données
2. `get 'customers', 'CUST002'` → Un client spécifique
3. `get 'customers', 'CUST003', {COLUMN => 'contact:email'}` → Une colonne
4. `count 'customers'` → Nombre de lignes

### Observations :
- GET est beaucoup plus rapide que SCAN pour une ligne
- SCAN peut être lent sur de grandes tables
- La syntaxe avec accolades pour les filtres est importante

## Exercice 4 : Mise à jour et suppression

### Commandes exécutées :
[Listez vos commandes DELETE et PUT de mise à jour]

### Observations :
- PUT fonctionne pour créer ET mettre à jour
- DELETE peut supprimer une colonne ou une ligne entière
- Les suppressions sont définitives (mais les versions peuvent être gardées)

## Exercice 5 : Filtres

### Commandes testées :
1. ValueFilter pour trouver Paris
2. COLUMNS pour filtrer par famille
3. LIMIT pour limiter les résultats

### Observations :
- Les filtres peuvent être combinés
- ValueFilter scanne toute la table (peut être lent)
- COLUMNS est plus efficace car HBase lit moins de données

## Réflexions sur le design

### Choix des row keys :
- J'ai utilisé CUST001, CUST002, etc.
- Avantage : Simple et séquentiel
- Inconvénient : Peut créer des hotspots si beaucoup d'insertions simultanées

### Choix des familles :
- `info` pour les données personnelles
- `contact` pour les informations de contact
- Bonne séparation logique

### Améliorations possibles :
- Pourrait ajouter une famille `orders` pour les commandes
- Pourrait utiliser des row keys plus complexes (ex: CUST_FRANCE_001)
```

### Fichier 2 : `room-1_commandes.hbase`

**Créez ce fichier avec toutes vos commandes HBase**

**Format suggéré :**

```hbase
# Room 1 - Commandes HBase

# Exercice 1 : Création de la table
create 'customers', 'info', 'contact'
describe 'customers'

# Exercice 2 : Insertion des clients
put 'customers', 'CUST001', 'info:name', 'Jean Dupont'
put 'customers', 'CUST001', 'info:city', 'Paris'
put 'customers', 'CUST001', 'info:country', 'France'
put 'customers', 'CUST001', 'contact:email', 'jean.dupont@email.com'

# [Continuez avec tous vos PUT...]

# Exercice 3 : Interrogation
scan 'customers'
get 'customers', 'CUST002'
count 'customers'

# Exercice 4 : Mise à jour et suppression
put 'customers', 'CUST001', 'contact:email', 'nouveau.email@email.com'
delete 'customers', 'CUST004'

# Exercice 5 : Filtres
scan 'customers', {FILTER => "ValueFilter(=, 'binary:Paris')"}
scan 'customers', {COLUMNS => 'info'}
scan 'customers', {LIMIT => 3}
```

---

##  Validation

**Vous avez terminé cette room quand :**

- [ ]  Vous avez créé la table `customers` avec les familles `info` et `contact`
- [ ]  Vous avez inséré au moins 5 clients complets
- [ ]  Vous avez utilisé `scan` pour voir toutes les données
- [ ]  Vous avez utilisé `get` pour récupérer un client spécifique
- [ ]  Vous avez utilisé `get` avec filtre pour récupérer une colonne spécifique
- [ ]  Vous avez compté les lignes avec `count`
- [ ]  Vous avez mis à jour l'email d'un client
- [ ]  Vous avez ajouté une nouvelle colonne (téléphone)
- [ ]  Vous avez supprimé une colonne
- [ ]  Vous avez supprimé un client entier
- [ ]  Vous avez testé au moins 3 types de filtres différents
- [ ]  Vous avez créé `room-1_exercices.md` avec toutes vos notes
- [ ]  Vous avez créé `room-1_commandes.hbase` avec toutes vos commandes

**Si toutes les cases sont cochées → Félicitations !**

---

##  Prochaine étape

Une fois cette room terminée, vous pouvez passer à **Room 2 : HBase avancé**.

Dans la Room 2, vous apprendrez :
- Les versions et l'historique des données
- Les filtres avancés
- L'optimisation des performances
- Le travail avec des données temporelles

**Bon courage ! **

---

##  Aide mémoire rapide

### Commandes principales
- `create 'table', 'famille1', 'famille2'` = créer table
- `put 'table', 'row', 'colonne', 'valeur'` = insérer/mettre à jour
- `get 'table', 'row'` = récupérer une ligne
- `scan 'table'` = voir toutes les lignes
- `delete 'table', 'row'` = supprimer une ligne
- `count 'table'` = compter les lignes

### Syntaxe des filtres
- `{COLUMN => 'famille:colonne'}` = une colonne
- `{COLUMNS => 'famille'}` = une famille
- `{LIMIT => nombre}` = limiter les résultats
- `{FILTER => "..."}` = filtre avancé

**Gardez ce fichier ouvert pendant vos exercices ! **
