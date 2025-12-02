# Room 2 : HBase avancé

## Objectifs de cette room

- Comprendre les versions et l'historique des données
- Maîtriser les filtres avancés
- Apprendre à optimiser les performances
- Travailler avec des données temporelles (logs IoT)

## Rappels théoriques

### Versions et historique

HBase stocke plusieurs **versions** de chaque cellule. Par défaut, 3 versions sont conservées. Chaque modification crée une nouvelle version avec un timestamp.

**Utilité** :
- Auditer les changements
- Récupérer des données à un moment précis
- Analyser l'évolution des données

**Commandes** :
- `get 'table', 'row', {VERSIONS => 5}` : voir plusieurs versions
- `get 'table', 'row', {TIMESTAMP => timestamp}` : récupérer à un moment précis

### Filtres avancés

HBase propose de nombreux filtres pour interroger efficacement les données :

- **RowFilter** : filtrer sur les row keys
- **ValueFilter** : filtrer sur les valeurs
- **ColumnPrefixFilter** : filtrer sur le préfixe des colonnes
- **QualifierFilter** : filtrer sur les qualifiers
- **SingleColumnValueFilter** : filtrer sur la valeur d'une colonne spécifique
- **PageFilter** : limiter le nombre de résultats

### Optimisation

**Row Key Design** :
- Évitez les row keys séquentielles (ex: 1, 2, 3...) qui créent des hotspots
- Utilisez des préfixes pour distribuer les données
- Incluez des informations temporelles si nécessaire (mais attention à l'ordre)

**Familles de colonnes** :
- Ne créez pas trop de familles (1-3 recommandé)
- Regroupez les colonnes fréquemment accédées ensemble

## Exercices pratiques

### Exercice 1 : Travailler avec les versions

1. Créez une table `sensor_data` avec la famille `readings`
2. Insérez une valeur de température pour un capteur à différents moments
3. Modifiez cette valeur plusieurs fois
4. Récupérez toutes les versions de cette valeur
5. Récupérez la valeur à un timestamp spécifique

**Données à utiliser** :
- Row key : `SENSOR001_20240101_100000`
- Colonne : `readings:temperature`
- Valeurs : 22.5, puis 22.8, puis 23.1, puis 22.9

**Commandes utiles** :
```hbase
create 'sensor_data', {NAME => 'readings', VERSIONS => 5}
put 'sensor_data', 'SENSOR001_20240101_100000', 'readings:temperature', '22.5'
get 'sensor_data', 'SENSOR001_20240101_100000', {VERSIONS => 5}
```

### Exercice 2 : Charger des données IoT

Utilisez le fichier `/data/resources/iot-logs/sample-logs.csv` pour charger des données dans HBase.

1. Créez une table `iot_logs` avec la famille `data`
2. Structurez les row keys de manière à permettre des requêtes efficaces
3. Chargez au moins 10 lignes du fichier CSV dans HBase

**Stratégie de row key** :
- Format suggéré : `DEVICEID_TIMESTAMP` (ex: `DEV001_20240101100000`)
- Cela permet de filtrer par device et par période

**Indications** :
- Vous pouvez charger les données manuellement avec `put`
- Ou créer un script simple pour automatiser

### Exercice 3 : Filtres avancés

Sur la table `iot_logs`, testez les filtres suivants :

1. **RowFilter** : trouver tous les logs d'un device spécifique (ex: DEV001)
2. **ValueFilter** : trouver tous les logs où la température dépasse 23°C
3. **ColumnPrefixFilter** : récupérer uniquement les colonnes commençant par `temp`
4. **SingleColumnValueFilter** : trouver les devices avec un statut spécifique

**Exemples de syntaxe** :
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

### Exercice 4 : Requêtes temporelles

1. Créez des row keys qui incluent le timestamp pour faciliter les requêtes temporelles
2. Utilisez `scan` avec `STARTROW` et `STOPROW` pour récupérer les logs d'une période donnée
3. Testez une requête pour récupérer tous les logs entre 10:00 et 11:00

**Format de row key suggéré** :
- `DEVICEID_YYYYMMDDHHMMSS` (ex: `DEV001_20240101100000`)

**Commandes utiles** :
```hbase
scan 'iot_logs', {
  STARTROW => 'DEV001_20240101100000',
  STOPROW => 'DEV001_20240101110000'
}
```

### Exercice 5 : Optimisation et analyse

1. Analysez la distribution de vos données avec `scan` et `count`
2. Identifiez d'éventuels hotspots (concentrations de données)
3. Proposez une amélioration de la structure des row keys si nécessaire
4. Testez les performances avec des scans sur différentes plages

## Fichiers à compléter

Créez les fichiers suivants dans ce dossier :

1. **room-2_exercices.md** : documentation complète de vos exercices
2. **room-2_commandes.hbase** : toutes vos commandes HBase
3. **room-2_observations.md** : vos réflexions sur :
   - Le choix des row keys pour les données temporelles
   - L'utilisation des versions
   - Les performances des différents filtres
   - Les optimisations possibles

## Validation

Vous avez terminé cette room quand :

-  Vous avez créé et manipulé des tables avec versions
-  Vous avez chargé des données IoT dans HBase
-  Vous avez utilisé au moins 3 types de filtres différents
-  Vous avez effectué des requêtes temporelles avec STARTROW/STOPROW
-  Vous avez analysé et documenté vos choix d'optimisation
-  Vous avez complété tous les fichiers demandés

## Prochaine étape

Une fois cette room terminée, vous pouvez passer à **Room 3 : Introduction à Hive**.

