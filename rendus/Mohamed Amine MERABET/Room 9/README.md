# Room Expert : Maîtrise Avancée HBase & Hive

## Introduction

### Contexte

Cette room est **complètement indépendante** et ne nécessite **aucun environnement Docker**. Elle est conçue pour les étudiants qui veulent devenir experts en architecture, design et optimisation de systèmes HBase et Hive sans avoir besoin d'un environnement fonctionnel.

**Pourquoi cette room existe :**

- Permet d'apprendre les concepts avancés sans contraintes techniques
- Focus sur la réflexion architecturale plutôt que l'exécution
- Accessible même sans accès à un environnement Docker
- Préparation aux entretiens techniques et projets professionnels

Cette room se concentre sur :

- La **conception architecturale** avancée
- Les **patterns de design** professionnels
- L'**optimisation** à grande échelle
- La **résolution de problèmes** complexes
- Les **meilleures pratiques** de l'industrie

### Objectifs mesurables

À la fin de cette room, vous serez capable de :

1. **Concevoir** des architectures HBase et Hive pour des systèmes à grande échelle
2. **Optimiser** des systèmes existants avec des techniques avancées
3. **Résoudre** des problèmes de performance complexes
4. **Choisir** les bonnes technologies selon les cas d'usage
5. **Expliquer** vos choix architecturaux de manière professionnelle

---

## Section 1 : Architecture Avancée HBase

### Concept 1 : Design de Row Keys pour Production

**Problème réel :** Vous devez stocker des milliards d'événements IoT avec des accès par capteur et par période.

**Contraintes :**

- 10 millions de capteurs
- 1 événement par seconde par capteur
- Accès fréquents : "Donnez-moi tous les événements du capteur X entre 10h et 11h"
- Accès occasionnels : "Donnez-moi tous les événements de tous les capteurs à 10h"

**Solutions possibles :**

**Solution 1 : Row Key simple avec timestamp**

```
Row Key: SENSOR_001_1640995200
```

**Problème :** Hotspot massif. Tous les capteurs écrivent dans la même région au même moment.

**Solution 2 : Préfixe hash pour distribution**

```
Row Key: MD5(sensor_id)[0:4]_SENSOR_001_1640995200
```

**Avantage :** Distribution uniforme des écritures.
**Inconvénient :** Scans par capteur nécessitent de scanner toutes les régions.

**Solution 3 : Row Key inversée avec préfixe capteur**

```
Row Key: SENSOR_001_(Long.MAX_VALUE - timestamp)
```

**Avantage :** Accès rapide par capteur, événements récents en premier.
**Inconvénient :** Hotspot si tous les capteurs écrivent simultanément.

**Solution 4 : Salting avec préfixe aléatoire**

```
Row Key: [0-9]_SENSOR_001_1640995200
```

**Avantage :** Distribution uniforme, scans possibles avec préfixe wildcard.
**Inconvénient :** Complexité de requête accrue.

**Solution recommandée pour ce cas :**

```
Row Key: SENSOR_001_20240101_100000
Format: SENSOR_{id}_{date}_{time}
```

**Justification :**

- Distribution acceptable (par date)
- Scans efficaces par capteur et période
- Préfixe prévisible pour les requêtes
- Pas de hotspot majeur

**Exercice de réflexion :**

Vous devez stocker des logs applicatifs avec :

- 1000 applications différentes
- 1 million de logs par jour par application
- Accès principal : "Logs de l'application X du jour Y"
- Accès secondaire : "Tous les logs d'erreur du jour Y"

**Réponse de l'étudiant :**

1. Quelle structure de row key proposez-vous ?

   Row Key: APP*{app_id}*{date}_{log_level}_{timestamp}
   Exemple: APP_ORDER_20240106_ERROR_1704535200123

2. Justifiez votre choix :

Ce design est basé sur les patterns d’accès réels, ce qui est un principe fondamental en HBase.

L’accès principal consiste à récupérer les logs de l’application X pour le jour Y.
Le préfixe APP*{app_id}*{date} permet un scan séquentiel efficace et une lecture localisée sur un nombre limité de régions, ce qui optimise les performances. Le timestamp placé en suffixe garantit à la fois l’unicité des lignes et un ordre temporel naturel des logs.

L’accès secondaire concerne la récupération de tous les logs d’erreur d’un jour donné. Le champ log_level, positionné avant le timestamp, permet de définir une plage de scan ciblée. Ce type de requête reste plus coûteux, mais il est acceptable car non critique, conformément au principe HBase qui consiste à optimiser prioritairement l’accès principal.

3.  Quels sont les avantages et inconvénients ?

Avantages :
Optimisation de l’accès principal (cas le plus fréquent)
Scans efficaces par application et par jour
Row key lisible et explicable en entretien ou revue d’architecture
Compatible avec TTL par jour et Pré-splitting par date
Pas de hotspot majeur si le volume est réparti sur plusieurs applications

Inconvénients :
Scan transversal nécessaire pour : “Tous les logs ERROR du jour”
Déséquilibre possible si : Une application génère beaucoup plus de logs que les autres
Impossible d’optimiser parfaitement deux axes d’accès orthogonaux sans duplication (limite structurelle d’HBase)

### Concept 2 : Stratégies de Familles de Colonnes Avancées

**Cas réel :** Système de e-commerce avec données clients.

**Données à stocker :**

- Informations personnelles (nom, email, téléphone) - accès fréquent
- Adresses (adresse, ville, code postal) - accès modéré
- Historique d'achats (produits, dates, montants) - accès fréquent pour affichage, rare pour analyse
- Préférences (catégories préférées, taille) - accès occasionnel
- Métadonnées (date création, dernière connexion) - accès rare

**Question :** Combien de familles de colonnes et comment les organiser ?

**Analyse :**

**Option 1 : Une seule famille**

```
CF: info (toutes les colonnes)
```

**Problème :** Charge toutes les données même pour un accès simple.

**Option 2 : Familles par fréquence d'accès**

```
CF1: frequent (nom, email, téléphone, produits récents)
CF2: moderate (adresse, ville)
CF3: rare (métadonnées, historique complet)
```

**Avantage :** Charge seulement ce qui est nécessaire.
**Inconvénient :** Gestion complexe, plusieurs accès si besoin de tout.

**Option 3 : Familles par pattern d'accès**

```
CF1: profile (nom, email, téléphone, préférences)
CF2: location (adresse, ville, code postal)
CF3: activity (produits récents, dernière connexion)
CF4: history (historique complet des achats)
```

**Avantage :** Groupement logique, accès optimisés.
**Recommandé pour ce cas.**

**Règle d'or :** Grouper par pattern d'accès, pas par type de données.

**Exercice de réflexion :**

Système de monitoring avec :

- Métriques système (CPU, RAM, disque) - mise à jour toutes les 5 secondes
- Logs d'application - ajout toutes les minutes
- Alertes - création rare mais lecture fréquente
- Configuration - modification rare, lecture fréquente

**Réponse de l'étudiant :**

1. Combien de familles de colonnes proposez-vous ?

   4 familles de colonnes

2. Comment les organisez-vous ?

   CF1: metrics

- cpu
- ram
- disk

CF2: logs

- application_logs

CF3: alerts

- alert_type
- alert_status
- alert_timestamp

CF4: config

- thresholds
- rules
- parameters

3. Justifiez votre choix :

Cette organisation respecte la règle fondamentale d’HBase : une famille de colonnes correspond à un pattern d’accès et un comportement I/O homogènes.

La famille metrics regroupe des données à écritures très fréquentes et à lectures agrégées sur de courtes périodes. Elle nécessite des flushs et compactions adaptés aux écritures continues, et son isolation évite d’impacter les autres familles.

La famille logs contient des données volumineuses avec des écritures régulières et des lectures ponctuelles (debug, audit). La séparer permet d’éviter des compactions coûteuses sur les métriques.

La famille alerts a des écritures rares mais des lectures fréquentes. Elle est optimisée pour la lecture grâce à l’usage de Bloom filters et d’un block cache élevé.

La famille config regroupe des données peu modifiées mais très souvent lues. Elle bénéficie d’un block cache prioritaire, de peu de versions et d’un TTL faible.

### Concept 3 : Gestion des Hotspots et Distribution

**Problème :** Hotspot dans une région HBase.

**Symptômes :**

- Une seule région reçoit 80% des écritures
- Les autres régions sont sous-utilisées
- Performance dégradée

**Causes courantes :**

1. **Row keys séquentielles**

   ```
   Row Key: 1, 2, 3, 4, ...
   ```

   Solution : Préfixe hash ou salting

2. **Row keys basées sur timestamp seul**

   ```
   Row Key: 1640995200
   ```

   Solution : Inverser le timestamp ou ajouter un préfixe

3. **Préfixes communs**
   ```
   Row Key: USER_001_...
   Row Key: USER_002_...
   ```
   Solution : Hash du préfixe ou distribution différente

**Techniques de résolution :**

**Technique 1 : Salting**

```
Row Key original: USER_001_DATA
Row Key avec salting: [0-9]_USER_001_DATA
```

**Avantage :** Distribution uniforme
**Inconvénient :** Scans nécessitent plusieurs requêtes

**Technique 2 : Hashing du préfixe**

```
Row Key original: USER_001_DATA
Row Key avec hash: MD5(USER_001)[0:4]_USER_001_DATA
```

**Avantage :** Distribution uniforme, préfixe prévisible
**Inconvénient :** Complexité de requête

**Technique 3 : Inversion de timestamp**

```
Timestamp: 1640995200
Inversé: Long.MAX_VALUE - 1640995200
```

**Avantage :** Distribution uniforme, événements récents en premier
**Inconvénient :** Calcul nécessaire

**Exercice de réflexion :**

Vous avez un système avec hotspot. Les row keys sont :

```
SESS_20240101_001
SESS_20240101_002
SESS_20240101_003
...
```

**Réponse de l'étudiant :**

1. Quel est le problème avec ces row keys ?

Les row keys sont séquentielles et partagent le même préfixe temporel (SESS_20240101).
Cela provoque un hotspot, car toutes les nouvelles écritures sont dirigées vers la même région HBase, entraînant une surcharge et une sous-utilisation des autres régions

2. Quelle solution proposez-vous ?

Ajouter un mécanisme de distribution, comme du salting ou un hash du préfixe

Ces techniques permettent de répartir les écritures sur plusieurs régions tout en conservant des scans possibles.

3. Comment modifiez-vous les row keys ?

Exemple avec salting :
Row Key: [0-9]\_SESS_20240101_001

Exemple avec hash du préfixe :
Row Key: MD5(SESS)[0:4]\_SESS_20240101_001

## Section 2 : Architecture Avancée Hive

### Concept 1 : Stratégies de Partitionnement Avancées

**Cas réel :** Système d'analyse de ventes avec données multi-dimensionnelles.

**Données :**

- Ventes par produit, région, date, canal de vente
- 100 millions de lignes par jour
- Requêtes fréquentes :
  - "Ventes par région pour le mois de janvier"
  - "Ventes par produit pour la dernière semaine"
  - "Ventes par canal pour l'année 2024"

**Question :** Comment partitionner efficacement ?

**Analyse :**

**Option 1 : Partition simple par date**

```sql
PARTITIONED BY (date STRING)
```

**Avantage :** Simple, efficace pour requêtes temporelles
**Inconvénient :** Scans complets pour requêtes par région/produit

**Option 2 : Partition multi-niveaux**

```sql
PARTITIONED BY (year INT, month INT, region STRING)
```

**Avantage :** Filtrage efficace sur plusieurs dimensions
**Inconvénient :** Nombre de partitions peut exploser (12 mois × 10 régions = 120 partitions par an)

**Option 3 : Partition par date + Buckets par région**

```sql
PARTITIONED BY (date STRING)
CLUSTERED BY (region) INTO 10 BUCKETS
```

**Avantage :** Équilibre entre filtrage temporel et distribution
**Recommandé pour ce cas.**

**Règle d'or :** Partitionner sur les colonnes les plus filtrées, bucketer sur les colonnes de jointure.

**Exercice de réflexion :**

Système de logs avec :

- Logs par application, environnement (dev/prod), date
- 50 applications, 2 environnements
- Requêtes : "Logs de l'app X en prod hier" (fréquent), "Tous les logs d'erreur d'aujourd'hui" (occasionnel)

**Réponse de l'étudiant :**

1. Quelle stratégie de partitionnement proposez-vous ?

Je propose un partitionnement par date et par environnement :
PARTITIONED BY (date STRING, environment STRING)

Le partitionnement par date est prioritaire car toutes les requêtes incluent un filtre temporel. Il permet un partition pruning efficace, indispensable avec des volumes élevés de logs quotidiens.

L’ajout de la colonne environment (dev / prod) comme second niveau de partition est justifié car ce filtre est très fréquent, notamment pour les analyses en production. Le nombre de partitions reste maîtrisé :
1 jour × 2 environnements = 2 partitions par jour, ce qui est parfaitement acceptable à grande échelle.

2. Utilisez-vous des buckets ? Pourquoi ?

Oui, j’utilise des buckets, avec un bucketing par application :
CLUSTERED BY (application) INTO 50 BUCKETS

Le bucketing permet de distribuer uniformément les données à l’intérieur de chaque partition et d’optimiser les requêtes filtrant sur une application donnée.

Ce choix est pertinent car :
Le nombre d’applications est connu et stable (50)
Les requêtes ciblent souvent une application précise
Il améliore les performances de scans, d’agrégations et de jointures par application

Le bucketing évite également la création de partitions trop fines, ce qui limiterait la scalabilité du système.

3. Justifiez votre choix :

Cette stratégie est basée sur les patterns de requêtes réels, principe clé en Hive.

La requête la plus fréquente est :
“Logs de l’application X en prod hier”.

Le partitionnement par date et environment permet un partition pruning efficace, limitant la lecture aux seules partitions pertinentes (ex. date = hier et environment = prod).

Le bucketing par application permet :
Une distribution uniforme des données
Des lectures plus efficaces lorsqu’une application est filtrée
Une meilleure performance pour d’éventuelles jointures ou agrégations par application

La requête secondaire “Tous les logs d’erreur d’aujourd’hui” nécessite un scan de la partition du jour, ce qui est acceptable car occasionnel. Elle reste limitée grâce au partitionnement temporel.

### Concept 2 : Formats de Fichiers et Compression

**Comparaison des formats :**

**TextFile (par défaut)**

- Compression : Aucune par défaut
- Performance lecture : Lente
- Performance écriture : Rapide
- Taille : Grande
- **Utilisation :** Développement, petits datasets

**SequenceFile**

- Compression : Oui (gzip, snappy)
- Performance lecture : Moyenne
- Performance écriture : Moyenne
- Taille : Moyenne
- **Utilisation :** Format intermédiaire

**ORC (Optimized Row Columnar)**

- Compression : Excellente (70-90%)
- Performance lecture : Très rapide (3-5x TextFile)
- Performance écriture : Rapide
- Taille : Petite
- Index intégré : Oui
- **Utilisation :** Production, tables analytiques (recommandé)

**Parquet**

- Compression : Excellente (70-90%)
- Performance lecture : Très rapide
- Performance écriture : Rapide
- Taille : Petite
- Compatibilité : Spark, Impala, autres outils
- **Utilisation :** Écosystème multi-outils

**Recommandations :**

1. **ORC** pour la plupart des cas Hive
2. **Parquet** si utilisation avec Spark ou autres outils
3. **Éviter TextFile** pour les grandes tables en production

**Exemple concret :**

Table de 100 millions de lignes :

- TextFile : ~500 GB
- ORC : ~50-100 GB (compression 80-90%)
- Gain d'espace : 400-450 GB
- Gain de performance : 3-5x plus rapide

**Exercice de réflexion :**

Vous avez une table TextFile de 1 TB qui prend trop de temps à interroger.

**Réponse de l'étudiant :**

1. Quel format proposez-vous pour améliorer les performances ?

Le format ORC (Optimized Row Columnar) est retenu, car il est nativement optimisé pour Hive et les charges analytiques. Son stockage en colonnes, combiné à une forte compression et à des statistiques intégrées, permet de réduire significativement les volumes de données lus et d’améliorer les performances des requêtes.

2. Comment migrez-vous les données ?

La migration consiste à créer une nouvelle table au format ORC, puis à y insérer les données de la table existante via une opération de type CREATE TABLE AS SELECT. Cette méthode permet une transition simple et sécurisée, sans modification du schéma logique ni des requêtes existantes.

3. Quels gains attendez-vous (espace, performance) ?

En migrant vers ORC, on peut s’attendre à une réduction de l’espace disque de l’ordre de 70 à 90 %, grâce à la compression colonne par colonne, ainsi qu’à une amélioration des performances de lecture typiquement comprise entre 3 et 5 fois, car Hive lit uniquement les colonnes nécessaires et s’appuie sur les index et statistiques intégrées pour limiter les scans inutiles.

### Concept 3 : Optimisation des Requêtes Complexes

**Problème :** Requête très lente sur grande table.

**Requête initiale :**

```sql
SELECT product, SUM(amount)
FROM sales
WHERE date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY product
ORDER BY SUM(amount) DESC
LIMIT 10;
```

**Optimisations possibles :**

**1. Utiliser les partitions**

```sql
-- Si table partitionnée par date
SELECT product, SUM(amount)
FROM sales
WHERE date >= '2024-01-01' AND date <= '2024-12-31'
GROUP BY product
ORDER BY SUM(amount) DESC
LIMIT 10;
```

**Gain :** Scan seulement des partitions pertinentes

**2. Éviter SELECT \* et filtrer tôt**

```sql
-- Déjà optimisé dans l'exemple (pas de SELECT *)
```

**3. Utiliser EXPLAIN pour comprendre le plan**

```sql
EXPLAIN SELECT product, SUM(amount) ...
```

**Gain :** Identifier les goulots d'étranglement

**4. Créer une table agrégée pour les requêtes fréquentes**

```sql
CREATE TABLE sales_daily_aggregate AS
SELECT date, product, SUM(amount) as total_amount
FROM sales
GROUP BY date, product;

-- Requête optimisée
SELECT product, SUM(total_amount)
FROM sales_daily_aggregate
WHERE date >= '2024-01-01' AND date <= '2024-12-31'
GROUP BY product
ORDER BY SUM(total_amount) DESC
LIMIT 10;
```

**Gain :** Beaucoup plus rapide (données pré-agrégées)

**5. Utiliser des index si disponibles (selon version Hive)**

**Exercice de réflexion :**

Requête lente :

```sql
SELECT user_id, COUNT(*) as login_count
FROM user_logins
WHERE login_date >= '2024-01-01'
  AND login_date <= '2024-12-31'
  AND status = 'success'
GROUP BY user_id
HAVING COUNT(*) > 100;
```

**Réponse de l'étudiant :**

1. Quelles optimisations proposez-vous ?

Les optimisations consistent à exploiter le partitionnement par date pour réduire le volume de données scannées, à filtrer le plus tôt possible sur la colonne status, et à pré-agréger les données dans une table intermédiaire lorsque ce type de requête est fréquent.

2. Comment réécrivez-vous la requête ?

SELECT user*id, COUNT(*) AS login*count
FROM user_logins
WHERE login_date >= '2024-01-01'
AND login_date <= '2024-12-31'
AND status = 'success'
GROUP BY user_id
HAVING COUNT(*) > 100;

3. Quels gains attendez-vous ?

Ces optimisations permettent de réduire drastiquement le volume de données traité en limitant le scan aux partitions temporelles pertinentes et en appliquant les filtres dès la phase de lecture. La pré-agrégation transforme une requête coûteuse en calcul distribué sur une grande table en une opération beaucoup plus légère sur un jeu de données déjà résumé, ce qui diminue les échanges réseau, les phases de shuffle et le temps de calcul global, avec des gains de performance significatifs à grande échelle.

## Section 3 : Patterns de Design Professionnels

### Pattern 1 : Lambda Architecture avec HBase et Hive

**Contexte :** Système nécessitant traitement temps réel et batch.

**Architecture :**

```
Données brutes
    ↓
    ├─→ HBase (Speed Layer) ─→ Vues temps réel
    │
    └─→ HDFS ─→ Hive (Batch Layer) ─→ Vues batch
                ↓
            Vues unifiées (Serving Layer)
```

**Speed Layer (HBase) :**

- Données récentes (< 24h)
- Accès temps réel
- Mises à jour fréquentes

**Batch Layer (Hive) :**

- Données historiques complètes
- Traitement par lots quotidien
- Requêtes analytiques complexes

**Serving Layer :**

- Combine les vues temps réel et batch
- API unifiée pour les applications

**Avantages :**

- Temps réel ET historique
- Tolérance aux pannes (données dans les deux systèmes)
- Flexibilité (choix du système selon besoin)

**Exercice de réflexion :**

Système de recommandations nécessitant :

- Données utilisateur temps réel (préférences actuelles)
- Historique complet pour analyse (comportement sur 2 ans)

**Réponse de l'étudiant :**

1. Comment organisez-vous l'architecture ?

L’architecture repose sur un pattern Lambda, combinant une Speed Layer basée sur HBase pour le temps réel et une Batch Layer basée sur Hive pour l’historique. Les deux couches alimentent une Serving Layer qui expose une vue unifiée aux systèmes de recommandation, permettant de répondre à la fois aux besoins immédiats et aux analyses de fond.

2. Quelles données dans HBase ? Quelles données dans Hive ?

HBase stocke les données utilisateur récentes, telles que les préférences actuelles, les interactions en cours et les signaux temps réel nécessaires aux recommandations instantanées.

Hive conserve l’historique complet des comportements utilisateurs sur plusieurs années, utilisé pour l’analyse batch, l’entraînement des modèles et le recalcul périodique des profils globaux.

3. Comment synchronisez-vous les deux systèmes ?

La synchronisation s’effectue via un flux d’ingestion commun où les données sont écrites simultanément ou quasi simultanément vers HBase et HDFS. Les données temps réel sont progressivement consolidées dans Hive lors des traitements batch quotidiens, garantissant la cohérence entre vues temps réel et historiques tout en maintenant des performances élevées et une séparation claire des usages.

### Pattern 2 : Data Lake avec Hive comme Interface

**Contexte :** Centralisation de toutes les données de l'entreprise.

**Architecture :**

```
Sources multiples
    ↓
HDFS (Data Lake)
    ├─→ Données brutes (zone landing)
    ├─→ Données nettoyées (zone curated)
    └─→ Données agrégées (zone analytics)
        ↓
    Hive (Interface SQL)
        ↓
    Outils BI / Analytics
```

**Zones du Data Lake :**

1. **Landing Zone** : Données brutes, format source
2. **Curated Zone** : Données nettoyées, format standardisé (ORC/Parquet)
3. **Analytics Zone** : Données agrégées, optimisées pour requêtes

**Rôle de Hive :**

- Interface SQL unique sur toutes les zones
- Schémas et métadonnées centralisés
- Requêtes cross-zones possibles

**Avantages :**

- Source unique de vérité
- Flexibilité (tous formats supportés)
- Évolutivité (ajout facile de nouvelles sources)

**Exercice de réflexion :**

Entreprise avec :

- Données CRM (MySQL)
- Données logs (fichiers texte)
- Données IoT (JSON)
- Besoin d'analyses croisées

**Réponse de l'étudiant :**

1. Comment organisez-vous le Data Lake ?

Le Data Lake est structuré en trois zones distinctes sur HDFS afin de séparer clairement les usages et les niveaux de transformation. La Landing Zone reçoit l’ensemble des données brutes dans leur format d’origine, sans modification. La Curated Zone contient les données nettoyées, normalisées et converties dans des formats optimisés comme ORC ou Parquet. La Analytics Zone regroupe enfin les données agrégées et préparées pour les usages analytiques et décisionnels, avec des schémas stables et des performances de requêtes optimisées.

2. Comment intégrez-vous chaque source ?

Les données CRM issues de MySQL sont ingérées de manière batch ou incrémentale vers la Landing Zone, puis transformées et standardisées dans la Curated Zone. Les logs applicatifs, initialement sous forme de fichiers texte, sont déposés tels quels dans la Landing Zone avant d’être nettoyés et structurés. Les données IoT au format JSON suivent le même principe, avec un schéma appliqué lors de la phase de curation afin de rendre les champs exploitables pour l’analyse. Cette approche garantit une traçabilité complète entre données sources et données analysées.

3. Quel rôle joue Hive dans cette architecture ?

Hive joue le rôle d’interface SQL centrale sur l’ensemble du Data Lake en fournissant des schémas, des métadonnées et un accès unifié aux données des trois zones. Il permet de réaliser des requêtes analytiques et des analyses croisées entre données CRM, logs et IoT sans duplication, tout en masquant la complexité des formats et du stockage sous-jacent, ce qui en fait le point d’entrée principal pour les outils BI et les utilisateurs métiers.

### Pattern 3 : CQRS avec HBase et Hive

**Contexte :** Séparation entre écriture (Command) et lecture (Query).

**Architecture :**

```
Écritures (Command)
    ↓
HBase (Write Model)
    ├─→ Données normalisées
    ├─→ Optimisé pour écriture
    └─→ Source de vérité
        ↓
    Réplication/Sync
        ↓
Hive (Read Model)
    ├─→ Données dénormalisées
    ├─→ Optimisé pour lecture
    └─→ Vues pré-calculées
```

**Write Model (HBase) :**

- Écritures rapides
- Données normalisées
- Transactions atomiques

**Read Model (Hive) :**

- Requêtes analytiques
- Données dénormalisées
- Vues optimisées par cas d'usage

**Avantages :**

- Optimisation indépendante pour écriture et lecture
- Scalabilité (scale séparément)
- Flexibilité (plusieurs modèles de lecture)

**Exercice de réflexion :**

Système e-commerce avec :

- Écritures fréquentes (commandes, mises à jour stock)
- Lectures analytiques (rapports ventes, tendances)

**Réponse de l'étudiant :**

1. Comment séparez-vous écriture et lecture ?

La séparation est assurée en utilisant HBase comme Write Model pour toutes les opérations d’écriture transactionnelles et Hive comme Read Model pour les requêtes analytiques. HBase est optimisé pour gérer des écritures fréquentes et atomiques, tandis que Hive est utilisé pour exposer des vues de lecture dénormalisées et optimisées pour l’analyse.

2. Quelles données dans HBase ? Quelles données dans Hive ?

HBase contient les données opérationnelles normalisées, telles que les commandes, les mises à jour de stock et les événements transactionnels, afin de garantir des écritures rapides et une cohérence forte à l’échelle de la ligne. Hive stocke des données dénormalisées et agrégées, destinées aux rapports de ventes, aux analyses de tendances et aux usages décisionnels, avec des structures adaptées aux requêtes complexes.

3. Comment synchronisez-vous les deux modèles ?

La synchronisation repose sur un mécanisme d’ingestion asynchrone qui réplique les données depuis HBase vers HDFS, puis vers Hive, de manière incrémentale. Les écritures sont considérées comme la source de vérité dans HBase, tandis que Hive est mis à jour périodiquement pour garantir des vues cohérentes, au prix d’une latence acceptable entre les modèles d’écriture et de lecture, ce qui est conforme aux principes du pattern CQRS.

## Section 4 : Résolution de Problèmes Complexes

### Problème 1 : Performance Dégradée sur Grande Table

**Symptômes :**

- Table HBase de 100 millions de lignes
- Requêtes de plus en plus lentes
- Une région très grande (> 20 GB)

**Diagnostic :**

1. Vérifier la taille des régions
2. Identifier les hotspots
3. Analyser les patterns d'accès

**Solutions :**

**Solution 1 : Split manuel de la région**

```bash
# Dans HBase shell
split 'ma_table', 'row_key_separateur'
```

**Solution 2 : Redesign des row keys**

- Identifier les patterns problématiques
- Réorganiser avec préfixes hash ou salting

**Solution 3 : Compaction majeure**

```bash
major_compact 'ma_table'
```

**Solution 4 : Archiver les anciennes données**

- Déplacer les données anciennes vers Hive
- Garder seulement les données récentes dans HBase

**Exercice de réflexion :**

Table de logs avec 500 millions de lignes, requêtes lentes.

**Réponse de l'étudiant :**

1. Quelles sont les causes probables ?

Les lenteurs proviennent le plus souvent d’une mauvaise distribution des row keys, entraînant une région surdimensionnée et un hotspot d’écritures ou de lectures. L’absence de splits automatiques efficaces, combinée à une croissance continue des données et à des compactions insuffisantes, accentue la concentration des accès sur une seule région et dégrade progressivement les performances.

2. Quelles solutions proposez-vous (par ordre de priorité) ?

La priorité consiste à redimensionner les régions via un split manuel afin de répartir immédiatement la charge. Ensuite, un redesign des row keys est nécessaire pour corriger durablement le problème de distribution et éviter la recréation de hotspots. Une compaction majeure peut être utilisée ponctuellement pour nettoyer les fichiers et améliorer les performances de lecture, tandis que l’archivage des données anciennes vers Hive permet de réduire le volume actif dans HBase et de recentrer le système sur les accès temps réel.

3. Comment mesurez-vous l'amélioration ?

L’amélioration se mesure en observant la répartition des régions, la diminution de la taille de la région dominante et une distribution plus homogène des requêtes entre RegionServers. Les métriques clés incluent la latence moyenne et maximale des requêtes, le throughput global, ainsi que la stabilité des temps de réponse sous charge, confirmant que les accès ne sont plus concentrés sur un seul point.

### Problème 2 : Requêtes Hive Très Lentes

**Symptômes :**

- Requêtes prenant plusieurs minutes
- Utilisation CPU/RAM élevée
- Timeouts fréquents

**Diagnostic :**

1. Utiliser EXPLAIN pour voir le plan d'exécution
2. Vérifier les partitions utilisées
3. Analyser les jointures
4. Vérifier les ressources disponibles

**Solutions :**

**Solution 1 : Optimiser les partitions**

- Vérifier que les filtres WHERE utilisent les colonnes de partition
- Créer des partitions manquantes si nécessaire

**Solution 2 : Optimiser les jointures**

- Utiliser des buckets sur les colonnes de jointure
- Vérifier l'ordre des tables dans les jointures (petite table en premier)

**Solution 3 : Créer des tables agrégées**

- Pré-calculer les agrégations fréquentes
- Utiliser des vues matérialisées si disponibles

**Solution 4 : Ajuster les paramètres Hive**

```sql
SET hive.exec.parallel=true;
SET hive.exec.parallel.thread.number=8;
SET mapreduce.job.reduces=10;
```

**Exercice de réflexion :**

Requête de jointure entre deux grandes tables prenant 30 minutes.

**Réponse de l'étudiant :**

1. Quelles optimisations proposez-vous ?

Les optimisations consistent à s’assurer que les colonnes de partition sont utilisées dans les filtres, à optimiser les jointures via le bucketing sur les clés de jointure et, lorsque les requêtes sont récurrentes, à pré-agréger les données afin de réduire le volume traité lors de l’exécution.

2. Comment réécrivez-vous la requête ?

SELECT a.col1, SUM(b.amount)
FROM table_a a
JOIN table_b b
ON a.key = b.key
WHERE a.date >= '2024-01-01'
AND a.date <= '2024-12-31'
GROUP BY a.col1;

3. Quels paramètres ajustez-vous ?

L’activation de l’exécution parallèle permet d’exploiter davantage les ressources disponibles, tandis que l’ajustement du nombre de reducers aide à équilibrer la charge lors des phases de shuffle. Ces réglages, combinés à un meilleur partition pruning et à des jointures plus efficaces, réduisent significativement le temps d’exécution et les risques de saturation CPU ou mémoire.

## Section 5 : Exercices de Conception

### Exercice 1 : Conception d'un Système de Monitoring

**Contexte :**

- 10 000 serveurs
- Métriques collectées toutes les 30 secondes
- 50 métriques par serveur
- Rétention : 1 an de données
- Requêtes : "Métriques du serveur X sur la dernière heure" (fréquent), "Tendances sur 1 mois" (occasionnel)

**Réponse de l'étudiant :**

1. Quelle architecture proposez-vous (HBase, Hive, ou les deux) ?

Une architecture hybride HBase + Hive est retenue afin de répondre simultanément aux besoins temps réel et analytiques. HBase est utilisé pour les accès rapides aux métriques récentes, tandis que Hive est utilisé pour le stockage historique et l’analyse à long terme.

2. Comment structurez-vous les données dans HBase ?

   - Row keys : SERVER*{server_id}*{reverse_timestamp}
   - Familles de colonnes :
     metrics (CPU, RAM, disque, réseau, etc.)
     meta (timestamp, état, version agent)
   - Justification :
     Ce schéma optimise les requêtes fréquentes sur un serveur donné et une courte période en garantissant des scans séquentiels efficaces et un accès rapide aux données récentes grâce à l’inversion du timestamp. La séparation des familles isole les écritures fréquentes des métadonnées, limitant l’impact des compactions et améliorant la performance globale.

3. Comment structurez-vous les données dans Hive ?

   - Partitions : PARTITIONED BY (year INT, month INT, day INT)
   - Format de fichier : ORC
   - Justification :
     Le partitionnement temporel permet un filtrage efficace pour les analyses mensuelles ou journalières, tout en maintenant un nombre de partitions maîtrisé sur un an. Le format ORC réduit fortement l’espace de stockage et accélère les requêtes analytiques grâce à la compression colonne par colonne et aux statistiques intégrées.

4. Comment synchronisez-vous les deux systèmes ?

La synchronisation repose sur une ingestion asynchrone où les métriques collectées sont écrites en temps réel dans HBase puis transférées périodiquement vers HDFS pour être consolidées dans Hive. Cette approche garantit une cohérence fonctionnelle entre données récentes et historiques tout en acceptant une légère latence, adaptée à des analyses de tendances non temps réel

### Exercice 2 : Conception d'un Système E-commerce

**Contexte :**

- Catalogue de 1 million de produits
- 10 millions d'utilisateurs
- Historique d'achats complet
- Besoin de recommandations temps réel
- Analyses de tendances

**Réponse de l'étudiant :**

1. Quelle architecture proposez-vous ?

   Une architecture hybride combinant HBase et Hive est retenue afin de séparer les besoins temps réel des usages analytiques. HBase sert de couche opérationnelle pour les accès rapides et les mises à jour fréquentes, tandis que Hive est utilisé comme couche analytique pour le traitement de l’historique complet et l’analyse des tendances.

2. Quelles données dans HBase ? Pourquoi ?

   HBase contient les données nécessaires aux recommandations temps réel, telles que le catalogue produit actif, les profils utilisateurs récents, les préférences courantes et les événements d’achat récents. Ce choix permet des lectures et écritures à faible latence, indispensables pour personnaliser l’expérience utilisateur en temps réel tout en supportant un fort volume d’accès concurrents.

3. Quelles données dans Hive ? Pourquoi ?

   Hive stocke l’historique complet des achats, les événements consolidés et les données agrégées utilisées pour l’analyse des tendances et l’entraînement des modèles de recommandation. Ce positionnement est adapté aux requêtes lourdes, aux scans de grands volumes de données et aux calculs périodiques, tout en optimisant les coûts de stockage et de traitement.

4. Comment optimisez-vous pour les performances ?

   Les performances sont optimisées en appliquant un design de row keys distribué et des familles de colonnes adaptées dans HBase, tout en utilisant dans Hive un partitionnement temporel, des formats colonnes comme ORC ou Parquet et des tables agrégées pour les analyses fréquentes. Cette séparation claire des usages permet de scaler indépendamment les charges temps réel et analytiques sans interférences.

### Exercice 3 : Migration d'un Système Existant

**Contexte :**

- Système MySQL avec 500 millions de lignes
- Requêtes de plus en plus lentes
- Besoin de scalabilité horizontale
- Budget limité

**Réponse de l'étudiant :**

1. Quelle stratégie de migration proposez-vous ?

   Une migration progressive vers une architecture HBase pour l’opérationnel et Hive pour l’analytique est retenue afin de répondre aux besoins de scalabilité horizontale tout en maîtrisant les coûts. Cette approche permet de conserver MySQL comme source temporaire pendant la transition, tout en déchargeant progressivement les requêtes lourdes vers des systèmes distribués.

2. Comment migrez-vous les données ?

   Les données sont migrées par lots incrémentaux, en commençant par l’historique le plus ancien vers Hive, puis par les données actives vers HBase. Cette stratégie limite l’impact sur le système existant, réduit les risques opérationnels et permet de valider chaque étape avant de poursuivre la migration complète

3. Comment gérez-vous la transition (double écriture) ?

   La transition est assurée par une double écriture temporaire, où les nouvelles transactions sont enregistrées à la fois dans MySQL et dans le nouveau système cible. Cette phase permet de maintenir la continuité de service tout en comparant les résultats entre les deux systèmes, avec une durée strictement limitée afin de contenir la complexité et les coûts

4. Comment validez-vous la migration ?

   La migration est validée par des contrôles de cohérence entre les systèmes, incluant des comparaisons de volumes, des vérifications d’échantillons de données et des tests de performance sur les requêtes critiques. La bascule finale est effectuée une fois les résultats conformes et les performances stabilisées, garantissant une transition fiable sans interruption majeure

## Section 6 : Meilleures Pratiques de l'Industrie

### Checklist de Design HBase

**Row Keys :**

- [ ] Distribution uniforme (pas de hotspots)
- [ ] Longueur raisonnable (< 100 bytes)
- [ ] Préfixe prévisible pour les scans
- [ ] Inversion de timestamp si nécessaire

**Familles de Colonnes :**

- [ ] Nombre limité (2-3 maximum)
- [ ] Groupement par pattern d'accès
- [ ] Noms courts (économiser l'espace)

**Tables :**

- [ ] Compression activée
- [ ] Versions limitées (selon besoin)
- [ ] TTL configuré pour données temporaires

### Checklist de Design Hive

**Partitions :**

- [ ] Partitionnement sur colonnes fréquemment filtrées
- [ ] Nombre de partitions raisonnable (< 10 000)
- [ ] Format de date cohérent

**Format :**

- [ ] ORC ou Parquet (pas TextFile)
- [ ] Compression activée
- [ ] Buckets pour tables fréquemment jointes

**Requêtes :**

- [ ] Filtres sur partitions dans WHERE
- [ ] Éviter SELECT \*
- [ ] LIMIT pour tests
- [ ] EXPLAIN pour comprendre le plan

---

## Validation

Pour valider cette room, vous devez :

1. Avoir complété tous les exercices de réflexion dans le WORKSHEET.md
2. Avoir conçu au moins 2 architectures complètes (exercices de conception)
3. Comprendre les patterns de design professionnels
4. Être capable d'expliquer vos choix architecturaux de manière claire et justifiée

**Critères d'évaluation :**

- Justification des choix architecturaux (40%)
  - Choix pertinents selon les contraintes
  - Explication claire des avantages/inconvénients
  - Considération des alternatives
- Compréhension des concepts avancés (30%)
  - Maîtrise des techniques d'optimisation
  - Compréhension des patterns de design
  - Application correcte des concepts
- Qualité des solutions proposées (20%)
  - Solutions réalistes et implémentables
  - Prise en compte des contraintes réelles
  - Optimisations pertinentes
- Clarté et précision (10%)
  - Explications structurées
  - Vocabulaire technique approprié
  - Présentation professionnelle

**Note minimale pour validation :** 12/20

---

## Ressources Complémentaires

### Documentation Officielle

- HBase : https://hbase.apache.org/book.html
- Hive : https://cwiki.apache.org/confluence/display/Hive/Home

### Patterns et Best Practices

- Lambda Architecture
- Data Lake Architecture
- CQRS Pattern
- Microservices avec Big Data

### Outils Associés

- Apache Spark (traitement distribué)
- Apache Kafka (streaming)
- Apache Flink (traitement temps réel)
- Presto/Trino (requêtes SQL distribuées)

---

## Conclusion

Cette room vous a donné les connaissances nécessaires pour :

- Concevoir des architectures HBase et Hive à grande échelle
- Optimiser des systèmes existants
- Résoudre des problèmes complexes
- Appliquer les meilleures pratiques de l'industrie
- Prendre des décisions architecturales éclairées

**Prochaines étapes :**

- Appliquer ces concepts dans vos projets pratiques
- Expérimenter avec les patterns présentés
- Continuer à apprendre avec les ressources complémentaires
- Partager vos réflexions et solutions avec la communauté

Vous êtes maintenant prêt à travailler sur des projets professionnels avec HBase et Hive et à prendre des décisions architecturales complexes en toute confiance.
