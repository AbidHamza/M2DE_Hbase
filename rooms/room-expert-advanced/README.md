# Room Expert : Maîtrise Avancée HBase & Hive

## Introduction

### Contexte

Cette room est **complètement indépendante** et ne nécessite **aucun environnement Docker**. Elle est conçue pour les étudiants qui veulent devenir experts en architecture, design et optimisation de systèmes HBase et Hive sans avoir besoin d'un environnement fonctionnel.

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
   - 

2. Justifiez votre choix :
   - 

3. Quels sont les avantages et inconvénients ?
   - 

---

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
   - 

2. Comment les organisez-vous ?
   - 

3. Justifiez votre choix :
   - 

---

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
   - 

2. Quelle solution proposez-vous ?
   - 

3. Comment modifiez-vous les row keys ?
   - 

---

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
   - 

2. Utilisez-vous des buckets ? Pourquoi ?
   - 

3. Justifiez votre choix :
   - 

---

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
   - 

2. Comment migrez-vous les données ?
   - 

3. Quels gains attendez-vous (espace, performance) ?
   - 

---

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

**2. Éviter SELECT * et filtrer tôt**
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
   - 

2. Comment réécrivez-vous la requête ?
   - 

3. Quels gains attendez-vous ?
   - 

---

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
   - 

2. Quelles données dans HBase ? Quelles données dans Hive ?
   - 

3. Comment synchronisez-vous les deux systèmes ?
   - 

---

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
   - 

2. Comment intégrez-vous chaque source ?
   - 

3. Quel rôle joue Hive dans cette architecture ?
   - 

---

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
   - 

2. Quelles données dans HBase ? Quelles données dans Hive ?
   - 

3. Comment synchronisez-vous les deux modèles ?
   - 

---

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
   - 

2. Quelles solutions proposez-vous (par ordre de priorité) ?
   - 

3. Comment mesurez-vous l'amélioration ?
   - 

---

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
   - 

2. Comment réécrivez-vous la requête ?
   - 

3. Quels paramètres ajustez-vous ?
   - 

---

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
   - 

2. Comment structurez-vous les données dans HBase ?
   - Row keys : 
   - Familles de colonnes : 
   - Justification : 

3. Comment structurez-vous les données dans Hive ?
   - Partitions : 
   - Format de fichier : 
   - Justification : 

4. Comment synchronisez-vous les deux systèmes ?
   - 

---

### Exercice 2 : Conception d'un Système E-commerce

**Contexte :**
- Catalogue de 1 million de produits
- 10 millions d'utilisateurs
- Historique d'achats complet
- Besoin de recommandations temps réel
- Analyses de tendances

**Réponse de l'étudiant :**

1. Quelle architecture proposez-vous ?
   - 

2. Quelles données dans HBase ? Pourquoi ?
   - 

3. Quelles données dans Hive ? Pourquoi ?
   - 

4. Comment optimisez-vous pour les performances ?
   - 

---

### Exercice 3 : Migration d'un Système Existant

**Contexte :**
- Système MySQL avec 500 millions de lignes
- Requêtes de plus en plus lentes
- Besoin de scalabilité horizontale
- Budget limité

**Réponse de l'étudiant :**

1. Quelle stratégie de migration proposez-vous ?
   - 

2. Comment migrez-vous les données ?
   - 

3. Comment gérez-vous la transition (double écriture) ?
   - 

4. Comment validez-vous la migration ?
   - 

---

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
- [ ] Éviter SELECT *
- [ ] LIMIT pour tests
- [ ] EXPLAIN pour comprendre le plan

---

## Validation

Pour valider cette room, vous devez :

1. Avoir complété tous les exercices de réflexion
2. Avoir conçu au moins 2 architectures complètes (exercices de conception)
3. Comprendre les patterns de design professionnels
4. Être capable d'expliquer vos choix architecturaux

**Critères d'évaluation :**
- Justification des choix architecturaux (40%)
- Compréhension des concepts avancés (30%)
- Qualité des solutions proposées (20%)
- Clarté et précision (10%)

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

Vous êtes maintenant prêt à travailler sur des projets professionnels avec HBase et Hive.

