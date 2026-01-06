# Room 2 : HBase avancé

## Objectifs de cette room

À la fin de cette room, vous saurez :
- Comprendre et utiliser les versions et l'historique des données HBase
- Maîtriser les filtres avancés pour interroger efficacement vos données
- Apprendre à optimiser les performances avec un bon design de row keys
- Travailler avec des données temporelles (logs IoT) de manière efficace


---

## Rappels théoriques - EXPLICATION APPROFONDIE

### Versions et historique - Comprendre en profondeur

**HBase stocke plusieurs versions de chaque cellule !**

#### Qu'est-ce qu'une version ?

Imaginez que vous modifiez la température d'un capteur plusieurs fois :
- **Version 1** : 22.5°C à 10:00
- **Version 2** : 22.8°C à 10:05
- **Version 3** : 23.1°C à 10:10
- **Version 4** : 22.9°C à 10:15

HBase garde **toutes ces versions** avec leurs timestamps ! Par défaut, il garde **3 versions**, mais vous pouvez changer cela.

#### Pourquoi c'est utile ?

1. **Audit** : Voir qui a modifié quoi et quand
2. **Récupération** : Récupérer une valeur à un moment précis dans le passé
3. **Analyse** : Analyser l'évolution des données dans le temps
4. **Sécurité** : Détecter des modifications suspectes

#### Comment ça fonctionne ?

Chaque `put` crée une **nouvelle version** avec un **timestamp** automatique. Les versions sont triées par timestamp décroissant (la plus récente en premier).

**Exemple concret :**
```hbase
put 'sensor_data', 'SENSOR001', 'readings:temperature', '22.5'
# Attendre quelques secondes...
put 'sensor_data', 'SENSOR001', 'readings:temperature', '22.8'
# Attendre quelques secondes...
put 'sensor_data', 'SENSOR001', 'readings:temperature', '23.1'
```

Maintenant, la cellule `readings:temperature` a **3 versions** :
- Version 1 (la plus récente) : 23.1°C
- Version 2 : 22.8°C
- Version 3 (la plus ancienne) : 22.5°C

**Par défaut, `get` retourne seulement la version la plus récente !**

### Filtres avancés - Guide complet

HBase propose de nombreux filtres pour interroger efficacement vos données. Voici les principaux :

#### 1. RowFilter - Filtrer sur les row keys

**Utilité** : Trouver toutes les lignes dont la row key correspond à un pattern.

**Exemple** : Trouver tous les logs du device DEV001
```hbase
import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.RowFilter
import org.apache.hadoop.hbase.filter.RegexStringComparator
import org.apache.hadoop.hbase.util.Bytes

scan 'iot_logs', {
  FILTER => RowFilter.new(
    CompareFilter::CompareOp.valueOf('EQUAL'),
    RegexStringComparator.new('DEV001_.*')
  )
}
```

**Explication** :
- `RowFilter` = filtre sur les row keys
- `RegexStringComparator` = utilise une expression régulière
- `'DEV001_.*'` = commence par "DEV001_" suivi de n'importe quoi

#### 2. ValueFilter - Filtrer sur les valeurs

**Utilité** : Trouver toutes les lignes où une valeur correspond à un critère.

**Exemple** : Trouver tous les logs où la température dépasse 23°C
```hbase
import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.ValueFilter
import org.apache.hadoop.hbase.filter.BinaryComparator
import org.apache.hadoop.hbase.util.Bytes

scan 'iot_logs', {
  FILTER => ValueFilter.new(
    CompareFilter::CompareOp.valueOf('GREATER'),
    BinaryComparator.new(Bytes.toBytes('23'))
  )
}
```

**ATTENTION** : `ValueFilter` scanne **toutes les colonnes** de toutes les lignes. C'est très lent sur de grandes tables !

#### 3. SingleColumnValueFilter - Filtrer sur une colonne spécifique

**Utilité** : Filtrer sur la valeur d'une colonne précise (beaucoup plus efficace que ValueFilter).

**Exemple** : Trouver tous les logs où `data:temperature` > 23
```hbase
import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.SingleColumnValueFilter
import org.apache.hadoop.hbase.filter.BinaryComparator
import org.apache.hadoop.hbase.util.Bytes

scan 'iot_logs', {
  FILTER => SingleColumnValueFilter.new(
    Bytes.toBytes('data'),
    Bytes.toBytes('temperature'),
    CompareFilter::CompareOp.valueOf('GREATER'),
    BinaryComparator.new(Bytes.toBytes('23'))
  )
}
```

**Avantage** : HBase lit seulement la colonne spécifiée, pas toutes les colonnes !

#### 4. ColumnPrefixFilter - Filtrer sur le préfixe des colonnes

**Utilité** : Récupérer seulement les colonnes qui commencent par un préfixe.

**Exemple** : Récupérer toutes les colonnes commençant par "temp"
```hbase
import org.apache.hadoop.hbase.filter.ColumnPrefixFilter
import org.apache.hadoop.hbase.util.Bytes

scan 'iot_logs', {
  FILTER => ColumnPrefixFilter.new(Bytes.toBytes('temp'))
}
```

#### 5. PageFilter - Limiter le nombre de résultats

**Utilité** : Limiter le nombre de lignes retournées (pagination).

**Exemple** : Récupérer seulement les 10 premières lignes
```hbase
import org.apache.hadoop.hbase.filter.PageFilter

scan 'iot_logs', {
  FILTER => PageFilter.new(10)
}
```

### Optimisation - Design des row keys

**Le design des row keys est CRUCIAL pour les performances !**

#### Mauvais design : Row keys séquentielles

```hbase
# MAUVAIS
put 'table', '1', 'cf:col', 'value'
put 'table', '2', 'cf:col', 'value'
put 'table', '3', 'cf:col', 'value'
```

**Problème** : Toutes les insertions vont au même RegionServer → **hotspot** !

#### Bon design : Row keys avec préfixes

```hbase
# BON
put 'table', 'REGION1_001', 'cf:col', 'value'
put 'table', 'REGION2_001', 'cf:col', 'value'
put 'table', 'REGION3_001', 'cf:col', 'value'
```

**Avantage** : Les données sont distribuées sur plusieurs RegionServers.

#### Excellent design : Row keys temporelles inversées

Pour les données temporelles, utilisez des timestamps inversés :

```hbase
# EXCELLENT pour données temporelles
put 'table', 'DEV001_20240101100000', 'cf:col', 'value'  # Format normal
put 'table', 'DEV001_99999999999999_20240101100000', 'cf:col', 'value'  # Inversé
```

**Avantage** : Les données les plus récentes sont accessibles rapidement.

**Format suggéré pour données IoT** :
- `DEVICEID_TIMESTAMP` : `DEV001_20240101100000`
- Permet de filtrer par device ET par période avec `STARTROW` et `STOPROW`

---

## Exercices pratiques - GUIDE PAS À PAS DÉTAILLÉ

### Exercice 1 : Travailler avec les versions - GUIDE COMPLET

**Objectif** : Comprendre comment HBase gère les versions et l'historique.

#### Étape 1.1 : Créer une table avec plusieurs versions

**Entrez dans le shell HBase :**
```bash
docker exec -it $(docker compose ps -q hbase) hbase shell
```

**Créez une table avec 5 versions conservées :**
```hbase
create 'sensor_data', {NAME => 'readings', VERSIONS => 5}
```

**Explication DÉTAILLÉE :**
- `create` = créer une table
- `'sensor_data'` = nom de la table
- `{NAME => 'readings', VERSIONS => 5}` = syntaxe spéciale HBase
  - `NAME => 'readings'` = nom de la famille de colonnes
  - `VERSIONS => 5` = garder 5 versions au lieu de 3 (par défaut)

**Résultat attendu :**
```
0 row(s) in 1.2345 seconds

=> Hbase::Table - sensor_data
```

#### Étape 1.2 : Insérer plusieurs valeurs avec des timestamps différents

**Insérez la première valeur :**
```hbase
put 'sensor_data', 'SENSOR001_20240101_100000', 'readings:temperature', '22.5'
```

**Attendez 2-3 secondes, puis insérez une nouvelle valeur :**
```hbase
put 'sensor_data', 'SENSOR001_20240101_100000', 'readings:temperature', '22.8'
```

**Attendez encore 2-3 secondes, puis insérez une troisième valeur :**
```hbase
put 'sensor_data', 'SENSOR001_20240101_100000', 'readings:temperature', '23.1'
```

**Et une quatrième :**
```hbase
put 'sensor_data', 'SENSOR001_20240101_100000', 'readings:temperature', '22.9'
```

**Explication :**
- Même row key (`SENSOR001_20240101_100000`)
- Même colonne (`readings:temperature`)
- Valeurs différentes à des moments différents
- Chaque `put` crée une nouvelle version avec un nouveau timestamp

#### Étape 1.3 : Voir seulement la version la plus récente (comportement par défaut)

**Commande :**
```hbase
get 'sensor_data', 'SENSOR001_20240101_100000', {COLUMN => 'readings:temperature'}
```

**Résultat attendu :**
```
COLUMN                   CELL
 readings:temperature    timestamp=..., value=22.9
1 row(s) in 0.1234 seconds
```

**Observation :** Seule la version la plus récente (22.9) est affichée !

#### Étape 1.4 : Voir toutes les versions

**Commande :**
```hbase
get 'sensor_data', 'SENSOR001_20240101_100000', {COLUMN => 'readings:temperature', VERSIONS => 5}
```

**Explication DÉTAILLÉE :**
- `get` = récupérer
- `'sensor_data'` = table
- `'SENSOR001_20240101_100000'` = row key
- `{COLUMN => 'readings:temperature', VERSIONS => 5}` = options
  - `COLUMN => 'readings:temperature'` = colonne spécifique
  - `VERSIONS => 5` = afficher jusqu'à 5 versions

**Résultat attendu :**
```
COLUMN                   CELL
 readings:temperature    timestamp=1704110400000, value=22.9
 readings:temperature    timestamp=1704110370000, value=23.1
 readings:temperature    timestamp=1704110340000, value=22.8
 readings:temperature    timestamp=1704110310000, value=22.5
4 row(s) in 0.1234 seconds
```

**Observation :** Vous voyez maintenant toutes les versions, triées par timestamp décroissant (plus récent en premier) !

#### Étape 1.5 : Récupérer une valeur à un timestamp spécifique

**Notez un timestamp de la sortie précédente (par exemple : `1704110340000`), puis :**

```hbase
get 'sensor_data', 'SENSOR001_20240101_100000', {
  COLUMN => 'readings:temperature',
  TIMESTAMP => 1704110340000
}
```

**Résultat attendu :** Seulement la valeur correspondant à ce timestamp exact (22.8 dans cet exemple).

**🎉 Exercice 1 terminé !** Vous comprenez maintenant comment fonctionnent les versions dans HBase.

---

### Exercice 2 : Charger des données IoT - GUIDE COMPLET

**Objectif** : Charger des données réelles depuis un fichier CSV dans HBase.

#### Étape 2.1 : Examiner le fichier source

**Accédez au conteneur Hadoop :**
```bash
docker exec -it $(docker compose ps -q hadoop) bash
```

**Vérifiez que le fichier existe :**
```bash
cat /data/resources/iot-logs/sample-logs.csv | head -5
```

**Résultat attendu :**
```
timestamp,device_id,temperature,humidity,location,status
2024-01-01 10:00:00,DEV001,22.5,65.2,Paris,active
2024-01-01 10:05:00,DEV002,23.1,63.8,Lyon,active
2024-01-01 10:10:00,DEV001,22.8,65.5,Paris,active
2024-01-01 10:15:00,DEV003,21.9,67.1,Marseille,active
```

**Structure du fichier :**
- Colonne 1 : `timestamp` (format : YYYY-MM-DD HH:MM:SS)
- Colonne 2 : `device_id` (ex: DEV001)
- Colonne 3 : `temperature` (décimal)
- Colonne 4 : `humidity` (décimal)
- Colonne 5 : `location` (ville)
- Colonne 6 : `status` (active/inactive)

#### Étape 2.2 : Créer la table HBase

**Retournez dans le shell HBase :**
```bash
exit  # Sortir du conteneur Hadoop
docker exec -it $(docker compose ps -q hbase) hbase shell
```

**Créez la table `iot_logs` :**
```hbase
create 'iot_logs', 'data'
```

**Explication :**
- Une seule famille `data` pour toutes les colonnes
- Row key sera construite manuellement : `DEVICEID_TIMESTAMP`

#### Étape 2.3 : Charger les données manuellement (méthode simple)

**Pour chaque ligne du CSV, créez une row key et insérez les données :**

**Ligne 1 :**
```hbase
put 'iot_logs', 'DEV001_20240101100000', 'data:temperature', '22.5'
put 'iot_logs', 'DEV001_20240101100000', 'data:humidity', '65.2'
put 'iot_logs', 'DEV001_20240101100000', 'data:location', 'Paris'
put 'iot_logs', 'DEV001_20240101100000', 'data:status', 'active'
```

**Ligne 2 :**
```hbase
put 'iot_logs', 'DEV002_20240101100500', 'data:temperature', '23.1'
put 'iot_logs', 'DEV002_20240101100500', 'data:humidity', '63.8'
put 'iot_logs', 'DEV002_20240101100500', 'data:location', 'Lyon'
put 'iot_logs', 'DEV002_20240101100500', 'data:status', 'active'
```

**Continuez pour au moins 10 lignes...**

**Format de row key :**
- `DEVICEID_YYYYMMDDHHMMSS`
- Exemple : `DEV001_20240101100000` = Device DEV001 le 2024-01-01 à 10:00:00

**Conversion du timestamp :**
- `2024-01-01 10:00:00` → `20240101100000`
- `2024-01-01 10:05:00` → `20240101100500`
- `2024-01-01 10:10:00` → `20240101101000`

#### Étape 2.4 : Vérifier les données chargées

**Comptez les lignes :**
```hbase
count 'iot_logs'
```

**Résultat attendu :** Au moins 10 lignes.

**Voir quelques exemples :**
```hbase
scan 'iot_logs', {LIMIT => 5}
```

**🎉 Exercice 2 terminé !** Vous avez chargé des données IoT dans HBase.

---

### Exercice 3 : Filtres avancés - GUIDE COMPLET

**Objectif** : Maîtriser les différents types de filtres HBase.

#### Étape 3.1 : RowFilter - Filtrer par device

**Trouvez tous les logs du device DEV001 :**

```hbase
import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.RowFilter
import org.apache.hadoop.hbase.filter.RegexStringComparator
import org.apache.hadoop.hbase.util.Bytes

scan 'iot_logs', {
  FILTER => RowFilter.new(
    CompareFilter::CompareOp.valueOf('EQUAL'),
    RegexStringComparator.new('DEV001_.*')
  )
}
```

**Explication DÉTAILLÉE :**
- `import` = importer les classes nécessaires (une seule fois par session)
- `RowFilter` = filtre sur les row keys
- `RegexStringComparator` = utilise une expression régulière
- `'DEV001_.*'` = pattern qui signifie "commence par DEV001_ suivi de n'importe quoi"
- `EQUAL` = correspondance exacte avec le pattern

**Résultat attendu :** Tous les logs du device DEV001.

#### Étape 3.2 : ValueFilter - Filtrer par valeur de température

**⚠️ ATTENTION : Ce filtre est LENT car il scanne toutes les colonnes !**

```hbase
import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.ValueFilter
import org.apache.hadoop.hbase.filter.BinaryComparator
import org.apache.hadoop.hbase.util.Bytes

scan 'iot_logs', {
  FILTER => ValueFilter.new(
    CompareFilter::CompareOp.valueOf('GREATER'),
    BinaryComparator.new(Bytes.toBytes('23'))
  )
}
```

**Explication :**
- `ValueFilter` = filtre sur les valeurs (toutes colonnes confondues)
- `GREATER` = supérieur à
- `BinaryComparator.new(Bytes.toBytes('23'))` = comparer avec la valeur "23"

**Résultat attendu :** Toutes les lignes où au moins une colonne a une valeur > "23".

#### Étape 3.3 : SingleColumnValueFilter - Filtrer sur une colonne spécifique

**✅ RECOMMANDÉ : Beaucoup plus efficace que ValueFilter !**

```hbase
import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.SingleColumnValueFilter
import org.apache.hadoop.hbase.filter.BinaryComparator
import org.apache.hadoop.hbase.util.Bytes

scan 'iot_logs', {
  FILTER => SingleColumnValueFilter.new(
    Bytes.toBytes('data'),
    Bytes.toBytes('temperature'),
    CompareFilter::CompareOp.valueOf('GREATER'),
    BinaryComparator.new(Bytes.toBytes('23'))
  )
}
```

**Explication DÉTAILLÉE :**
- `SingleColumnValueFilter` = filtre sur une colonne spécifique
- `Bytes.toBytes('data')` = famille de colonnes
- `Bytes.toBytes('temperature')` = nom de la colonne
- `GREATER` = supérieur à
- `BinaryComparator.new(Bytes.toBytes('23'))` = valeur de comparaison

**Avantage :** HBase lit seulement la colonne `data:temperature`, pas toutes les colonnes !

**Résultat attendu :** Toutes les lignes où `data:temperature` > 23.

#### Étape 3.4 : ColumnPrefixFilter - Filtrer par préfixe de colonne

**Récupérez seulement les colonnes commençant par "temp" :**

```hbase
import org.apache.hadoop.hbase.filter.ColumnPrefixFilter
import org.apache.hadoop.hbase.util.Bytes

scan 'iot_logs', {
  FILTER => ColumnPrefixFilter.new(Bytes.toBytes('temp'))
}
```

**Résultat attendu :** Seulement les colonnes `data:temperature` (si elles existent).

#### Étape 3.5 : Combiner plusieurs filtres

**Trouvez les logs de DEV001 où la température > 23 :**

```hbase
import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.RowFilter
import org.apache.hadoop.hbase.filter.SingleColumnValueFilter
import org.apache.hadoop.hbase.filter.FilterList
import org.apache.hadoop.hbase.filter.RegexStringComparator
import org.apache.hadoop.hbase.filter.BinaryComparator
import org.apache.hadoop.hbase.util.Bytes

scan 'iot_logs', {
  FILTER => FilterList.new([
    RowFilter.new(
      CompareFilter::CompareOp.valueOf('EQUAL'),
      RegexStringComparator.new('DEV001_.*')
    ),
    SingleColumnValueFilter.new(
      Bytes.toBytes('data'),
      Bytes.toBytes('temperature'),
      CompareFilter::CompareOp.valueOf('GREATER'),
      BinaryComparator.new(Bytes.toBytes('23'))
    )
  ])
}
```

**Explication :**
- `FilterList` = combine plusieurs filtres
- Les filtres sont appliqués avec un ET logique (les deux conditions doivent être vraies)

**🎉 Exercice 3 terminé !** Vous maîtrisez maintenant les filtres avancés.

---

### Exercice 4 : Requêtes temporelles - GUIDE COMPLET

**Objectif** : Utiliser STARTROW et STOPROW pour des requêtes temporelles efficaces.

#### Étape 4.1 : Comprendre STARTROW et STOPROW

**STARTROW et STOPROW permettent de scanner seulement une plage de row keys !**

**Avantage :** Beaucoup plus rapide qu'un scan complet car HBase sait exactement où commencer et où s'arrêter.

#### Étape 4.2 : Récupérer les logs d'une période spécifique

**Récupérez tous les logs entre 10:00 et 11:00 pour DEV001 :**

```hbase
scan 'iot_logs', {
  STARTROW => 'DEV001_20240101100000',
  STOPROW => 'DEV001_20240101110000'
}
```

**Explication DÉTAILLÉE :**
- `STARTROW` = row key de début (incluse)
- `STOPROW` = row key de fin (exclue)
- HBase scanne toutes les lignes entre ces deux row keys (ordre alphabétique)

**Format des row keys :**
- `DEV001_20240101100000` = DEV001 à 10:00:00
- `DEV001_20240101110000` = DEV001 à 11:00:00

**Résultat attendu :** Tous les logs de DEV001 entre 10:00 et 11:00.

#### Étape 4.3 : Récupérer les logs de plusieurs devices sur une période

**Récupérez tous les logs de tous les devices entre 10:00 et 11:00 :**

```hbase
scan 'iot_logs', {
  STARTROW => 'DEV001_20240101100000',
  STOPROW => 'DEV999_20240101110000'
}
```

**Explication :**
- `DEV001_...` = premier device possible
- `DEV999_...` = dernier device possible (avant DEV1000)
- Cela capture tous les devices DEV001 à DEV999

#### Étape 4.4 : Combiner avec des filtres

**Récupérez les logs de DEV001 entre 10:00 et 11:00 où la température > 23 :**

```hbase
import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.SingleColumnValueFilter
import org.apache.hadoop.hbase.filter.BinaryComparator
import org.apache.hadoop.hbase.util.Bytes

scan 'iot_logs', {
  STARTROW => 'DEV001_20240101100000',
  STOPROW => 'DEV001_20240101110000',
  FILTER => SingleColumnValueFilter.new(
    Bytes.toBytes('data'),
    Bytes.toBytes('temperature'),
    CompareFilter::CompareOp.valueOf('GREATER'),
    BinaryComparator.new(Bytes.toBytes('23'))
  )
}
```

**🎉 Exercice 4 terminé !** Vous savez maintenant faire des requêtes temporelles efficaces.

---

### Exercice 5 : Optimisation et analyse - GUIDE COMPLET

**Objectif** : Analyser vos données et optimiser les performances.

#### Étape 5.1 : Analyser la distribution des données

**Comptez le nombre de lignes par device :**

```hbase
# Device DEV001
scan 'iot_logs', {
  STARTROW => 'DEV001_',
  STOPROW => 'DEV002_'
}
# Notez le nombre de lignes

# Device DEV002
scan 'iot_logs', {
  STARTROW => 'DEV002_',
  STOPROW => 'DEV003_'
}
# Notez le nombre de lignes
```

**Analysez :**
- Les données sont-elles équitablement distribuées ?
- Y a-t-il des devices avec beaucoup plus de données que d'autres ?

#### Étape 5.2 : Identifier les hotspots

**Un hotspot = concentration de données sur un seul RegionServer**

**Signes de hotspot :**
- Beaucoup de row keys séquentielles (ex: 1, 2, 3...)
- Toutes les insertions vont au même endroit
- Un RegionServer est surchargé

**Vérifiez vos row keys :**
```hbase
scan 'iot_logs', {LIMIT => 20}
```

**Analysez :**
- Les row keys sont-elles bien distribuées ?
- Y a-t-il des patterns qui créent des hotspots ?

#### Étape 5.3 : Proposer des optimisations

**Si vous avez identifié des problèmes, proposez des améliorations :**

**Exemple 1 : Ajouter un préfixe de hash**
```
Avant : DEV001_20240101100000
Après : 0_DEV001_20240101100000  (hash de DEV001 = 0)
```

**Exemple 2 : Inverser le timestamp**
```
Avant : DEV001_20240101100000
Après : DEV001_99999999999999_20240101100000  (timestamp inversé)
```

#### Étape 5.4 : Tester les performances

**Comparez les temps d'exécution :**

```hbase
# Test 1 : Scan complet
# Notez le temps
scan 'iot_logs'

# Test 2 : Scan avec STARTROW/STOPROW
# Notez le temps
scan 'iot_logs', {
  STARTROW => 'DEV001_20240101100000',
  STOPROW => 'DEV001_20240101110000'
}

# Test 3 : Scan avec filtre
# Notez le temps
scan 'iot_logs', {
  FILTER => SingleColumnValueFilter.new(...)
}
```

**Analysez :**
- Quelle méthode est la plus rapide ?
- Les filtres ralentissent-ils beaucoup ?

**🎉 Exercice 5 terminé !** Vous comprenez maintenant l'optimisation HBase.

---

## 📝 Fichiers à compléter

Créez les fichiers suivants dans ce dossier (`rooms/room-2_hbase_advanced/`) :

### 1. `room-2_exercices.md`

Documentation complète de tous vos exercices avec :
- Les commandes exécutées
- Les résultats obtenus
- Les difficultés rencontrées
- Les observations

**Structure suggérée :**
```markdown
# Room 2 - Mes exercices HBase avancé

## Exercice 1 : Versions

### Commandes exécutées :
[Vos commandes]

### Résultats :
[Ce que vous avez observé]

### Observations :
- Les versions permettent de garder l'historique
- Par défaut, seulement la version la plus récente est retournée
- On peut récupérer une valeur à un timestamp précis

## Exercice 2 : Chargement de données IoT
[...]
```

### 2. `room-2_commandes.hbase`

Toutes vos commandes HBase dans un fichier réutilisable.

**Format :**
```hbase
# Room 2 - Commandes HBase avancé

# Exercice 1 : Versions
create 'sensor_data', {NAME => 'readings', VERSIONS => 5}
put 'sensor_data', 'SENSOR001_20240101_100000', 'readings:temperature', '22.5'
# [...]
```

### 3. `room-2_observations.md`

Vos réflexions approfondies sur :
- Le choix des row keys pour les données temporelles
- L'utilisation des versions (quand et pourquoi)
- Les performances des différents filtres
- Les optimisations possibles

---

## ✅ Validation

Vous avez terminé cette room quand :

- [ ] Vous avez créé une table avec plusieurs versions et testé la récupération des versions
- [ ] Vous avez chargé au moins 10 lignes de données IoT dans HBase
- [ ] Vous avez utilisé au moins 3 types de filtres différents (RowFilter, ValueFilter, SingleColumnValueFilter)
- [ ] Vous avez effectué des requêtes temporelles avec STARTROW/STOPROW
- [ ] Vous avez analysé la distribution de vos données
- [ ] Vous avez identifié d'éventuels hotspots
- [ ] Vous avez proposé des optimisations
- [ ] Vous avez créé `room-2_exercices.md` avec toutes vos notes
- [ ] Vous avez créé `room-2_commandes.hbase` avec toutes vos commandes
- [ ] Vous avez créé `room-2_observations.md` avec vos réflexions

**Si toutes les cases sont cochées → Félicitations !** 🎉

---

## 🚀 Prochaine étape

Une fois cette room terminée, vous pouvez passer à **Room 3 : Introduction à Hive**.

Dans la Room 3, vous apprendrez :
- Les bases de Hive et HiveQL
- Comment créer des tables Hive
- Comment charger des données depuis HDFS
- Les requêtes SQL de base

**Bon courage !** 💪

---

## 📖 Aide mémoire rapide

### Commandes de versions
- `get 'table', 'row', {VERSIONS => 5}` = voir plusieurs versions
- `get 'table', 'row', {TIMESTAMP => ts}` = récupérer à un timestamp

### Filtres avancés
- `RowFilter` = filtrer sur les row keys
- `ValueFilter` = filtrer sur les valeurs (lent !)
- `SingleColumnValueFilter` = filtrer sur une colonne (rapide !)
- `ColumnPrefixFilter` = filtrer par préfixe de colonne
- `FilterList` = combiner plusieurs filtres

### Requêtes temporelles
- `STARTROW => '...'` = début de la plage
- `STOPROW => '...'` = fin de la plage (exclue)

**Gardez ce fichier ouvert pendant vos exercices !** 📚
