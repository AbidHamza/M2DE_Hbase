# Room 5 : Intégration HBase-Hive

## Objectifs de cette room

- Comprendre comment Hive peut interroger des tables HBase
- Créer des tables Hive externes pointant vers HBase
- Utiliser HiveQL pour analyser des données HBase
- Intégrer HBase et Hive dans un workflow analytique

## Rappels théoriques

### Pourquoi intégrer HBase et Hive ?

**HBase** excelle pour :
- Accès aléatoire en temps réel
- Opérations de lecture/écriture rapides
- Stockage de grandes quantités de données non structurées

**Hive** excelle pour :
- Requêtes analytiques complexes
- Agrégations et jointures
- Intégration avec des outils BI

**L'intégration** permet de :
- Utiliser HBase comme source de données pour Hive
- Analyser des données HBase avec HiveQL
- Combiner les avantages des deux technologies

### Tables Hive externes sur HBase

Hive peut créer des **tables externes** qui pointent vers des tables HBase existantes. Cela permet d'interroger HBase avec HiveQL sans dupliquer les données.

**Avantages** :
- Pas de duplication de données
- Accès SQL aux données HBase
- Compatible avec les outils BI

**Limitations** :
- Performances moins optimales que les tables Hive natives
- Certaines opérations peuvent être plus lentes

## Exercices pratiques

### Exercice 1 : Préparer les données dans HBase

1. Créez une table HBase `iot_sensors` avec la famille `readings`
2. Chargez des données de capteurs IoT dans cette table
3. Utilisez le fichier `/data/resources/sensors/sensor-readings.json` comme référence
4. Insérez au moins 10 enregistrements avec des row keys structurées

**Structure suggérée** :
- Row key : `SENSORID_TIMESTAMP` (ex: `SENSOR001_20240101100000`)
- Colonnes : `readings:temperature`, `readings:pressure`, `readings:location`

**Commandes HBase** :
```hbase
create 'iot_sensors', 'readings'
put 'iot_sensors', 'SENSOR001_20240101100000', 'readings:temperature', '22.5'
put 'iot_sensors', 'SENSOR001_20240101100000', 'readings:pressure', '1013.25'
```

### Exercice 2 : Créer une table Hive externe sur HBase

1. Dans Hive, créez une table externe `hive_iot_sensors` qui pointe vers la table HBase `iot_sensors`
2. Mappez les colonnes HBase aux colonnes Hive
3. Vérifiez que vous pouvez interroger les données HBase depuis Hive

**Syntaxe** :
```sql
CREATE EXTERNAL TABLE hive_iot_sensors (
    row_key STRING,
    temperature DOUBLE,
    pressure DOUBLE,
    location STRING
) STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES (
    "hbase.columns.mapping" = ":key,readings:temperature,readings:pressure,readings:location"
)
TBLPROPERTIES ("hbase.table.name" = "iot_sensors");
```

### Exercice 3 : Requêtes HiveQL sur données HBase

1. Comptez le nombre d'enregistrements dans la table Hive externe
2. Calculez la température moyenne
3. Trouvez les capteurs avec une pression supérieure à 1013
4. Groupez les données par capteur et calculez les statistiques

**Requêtes à écrire** :
```sql
-- Exemple
SELECT 
    SUBSTRING(row_key, 1, 8) as sensor_id,
    AVG(temperature) as avg_temp,
    MAX(pressure) as max_pressure
FROM hive_iot_sensors
GROUP BY SUBSTRING(row_key, 1, 8);
```

### Exercice 4 : Workflow complet

Créez un workflow qui :

1. Stocke des données dans HBase (table `customer_activity`)
2. Crée une table Hive externe pointant vers cette table HBase
3. Effectue des analyses avec HiveQL
4. Stocke les résultats dans une table Hive native pour reporting

**Étapes** :

1. **HBase** : Créez `customer_activity` avec des données d'activité clients
2. **Hive** : Créez la table externe `hive_customer_activity`
3. **Hive** : Analysez les données (activité par client, par jour, etc.)
4. **Hive** : Créez une table de résultats `customer_activity_summary`

### Exercice 5 : Comparaison de performances

1. Créez une table Hive native avec les mêmes données que votre table HBase
2. Comparez les temps d'exécution de requêtes similaires sur :
   - La table Hive externe (HBase)
   - La table Hive native
3. Documentez vos observations

**Commandes pour mesurer** :
```sql
-- Activer le timing
SET hive.querylog.location=/tmp/hive-logs;

-- Exécuter la requête et noter le temps
SELECT ... FROM hive_iot_sensors;
SELECT ... FROM native_iot_sensors;
```

## Fichiers à compléter

Créez les fichiers suivants dans ce dossier :

1. **room-5_exercices.md** : documentation complète
2. **room-5_hbase_commandes.hbase** : toutes vos commandes HBase
3. **room-5_hive_requetes.hql** : toutes vos requêtes HiveQL
4. **room-5_analyse.md** : analyse approfondie sur :
   - Les avantages et inconvénients de l'intégration
   - Les cas d'usage appropriés
   - Les performances comparées
   - Les recommandations d'utilisation

## Validation

Vous avez terminé cette room quand :

-  Vous avez créé des tables HBase et des tables Hive externes correspondantes
-  Vous avez interrogé des données HBase via HiveQL
-  Vous avez créé un workflow complet intégrant les deux technologies
-  Vous avez comparé les performances et documenté vos observations
-  Vous avez complété tous les fichiers demandés

## Prochaine étape

Une fois cette room terminée, vous pouvez passer à **Room 6 : Cas d'usage réels**.

