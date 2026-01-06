# Room Expert : Mes Réponses et Réflexions

## Section 1 : Architecture Avancée HBase

### Exercice : Design de Row Keys pour Logs Applicatifs

**Réponse de l'étudiant :**

1. Quelle structure de row key proposez-vous ?
   - APP_ID#YYYYMMDD#REVERSE_TIMESTAMP#LOG_ID

2. Justifiez votre choix :
   - APP_ID permet des scans rapides par application
YYYYMMDD facilite l’accès par jour (cas principal)
REVERSE_TIMESTAMP évite les hotspots et permet d’accéder aux logs récents en premier
LOG_ID garantit l’unicité

3. Quels sont les avantages et inconvénients ?
✅ Scans efficaces par application et par jour
✅ Réduction des hotspots
❌ Complexité de génération de clé
❌ Scan global (toutes apps) plus coûteux
---

### Exercice : Stratégies de Familles de Colonnes pour Monitoring

**Réponse de l'étudiant :**

1. Combien de familles de colonnes proposez-vous ?
   - 4 famille

2. Comment les organisez-vous ?
   - 
metrics_cf : CPU, RAM, disque
logs_cf : logs applicatifs
alerts_cf : alertes actives
config_cf : configuration serveur
3. Justifiez votre choix :
   - Groupement par pattern d’accès
Lecture ciblée sans charger inutilement les autres données
Optimisation I/O et mémoire

---

### Exercice : Résolution de Hotspot

**Réponse de l'étudiant :**

1. Quel est le problème avec ces row keys ?
   - Clés séquentielles → toutes les écritures arrivent dans la même région
Hotspot massif sur une région

2. Quelle solution proposez-vous ?
   - Salting ou hash du préfixe

3. Comment modifiez-vous les row keys ?
   - [0-9]#SESS#20240101#001

---

## Section 2 : Architecture Avancée Hive

### Exercice : Stratégies de Partitionnement pour Logs

**Réponse de l'étudiant :**

1. Quelle stratégie de partitionnement proposez-vous ?
   - PARTITIONED BY (date STRING, env STRING)


2. Utilisez-vous des buckets ? Pourquoi ?
   - Oui, par application_id

3. Justifiez votre choix :
   - Filtrage rapide par date et environnement
Buckets utiles pour agrégations et jointures par application
Nombre de partitions maîtrisé

---

### Exercice : Migration de Format de Fichier

**Réponse de l'étudiant :**

1. Quel format proposez-vous pour améliorer les performances ?
   - ORC


2. Comment migrez-vous les données ?
   - CREATE TABLE logs_orc STORED AS ORC AS
SELECT * FROM logs_text;

3. Quels gains attendez-vous (espace, performance) ?
   - 📉 Espace : -70 à -90 %
⚡ Performance : requêtes 3 à 5 fois plus rapides

---

### Exercice : Optimisation de Requête

**Réponse de l'étudiant :**

1. Quelles optimisations proposez-vous ?
   - Partitionnement par login_date
Filtrage le plus tôt possible
Table agrégée

2. Comment réécrivez-vous la requête ?
SELECT user_id, COUNT(*) AS login_count
FROM user_logins
WHERE login_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND status = 'success'
GROUP BY user_id
HAVING COUNT(*) > 100;


3. Quels gains attendez-vous ?
   - Scan réduit
Moins de shuffle
Temps divisé par 3 à 10

---

## Section 3 : Patterns de Design Professionnels

### Exercice : Lambda Architecture pour Recommandations

**Réponse de l'étudiant :**

1. Comment organisez-vous l'architecture ?
   HBase = Speed Layer (temps réel)
Hive = Batch Layer (historique)
API unifiée = Serving Layer

2. Quelles données dans HBase ? Quelles données dans Hive ?
   HBase : préférences actuelles, derniers clics
Hive : historique complet (2 ans)

3. Comment synchronisez-vous les deux systèmes ?
   - Streaming (Kafka) + batch quotidien Hive

---

### Exercice : Data Lake avec Sources Multiples

**Réponse de l'étudiant :**

1. Comment organisez-vous le Data Lake ?
   - Landing → Curated → Analytics

2. Comment intégrez-vous chaque source ?
CRM MySQL → Sqoop
Logs → ingestion HDFS
IoT JSON → ingestion streaming

3. Quel rôle joue Hive dans cette architecture ?
   Catalogue de métadonnées
Interface SQL unifiée
Accès BI

---

### Exercice : CQRS pour E-commerce

**Réponse de l'étudiant :**

1. Comment séparez-vous écriture et lecture ?
   - Écritures → HBase
Lectures analytiques → Hive

2. Quelles données dans HBase ? Quelles données dans Hive ?
   - HBase : commandes, stock, utilisateurs
Hive : ventes agrégées, tendances

3. Comment synchronisez-vous les deux modèles ?
   - CDC / Kafka / batch quotidien

---

## Section 4 : Résolution de Problèmes Complexes

### Exercice : Performance Dégradée sur Grande Table

**Réponse de l'étudiant :**

1. Quelles sont les causes probables ?
   - Région trop grande
Mauvais row key
Hotspot

2. Quelles solutions proposez-vous (par ordre de priorité) ?
   - Redesign row key
Split régions
Archivage vers Hive
Compaction

3. Comment mesurez-vous l'amélioration ?
   - Temps de réponse
Latence région
Throughput

---

### Exercice : Requêtes Hive Très Lentes

**Réponse de l'étudiant :**

1. Quelles optimisations proposez-vous ?
Partitions
Buckets
Tables agrégées

2. Comment réécrivez-vous la requête ?
   - Réduction du volume traité
Jointures optimisées

3. Quels paramètres ajustez-vous ?
   - SET hive.exec.parallel=true;
SET mapreduce.job.reduces=10;

---

## Section 5 : Exercices de Conception

### Exercice 1 : Système de Monitoring

**Réponse de l'étudiant :**

1. Quelle architecture proposez-vous (HBase, Hive, ou les deux) ?
   - HBase + Hive (Lambda)

2. Comment structurez-vous les données dans HBase ?
   - Row keys : SERVER_ID#REVERSE_TIMESTAMP

   - Familles de colonnes : metrics_cf, alerts_cf
   - Justification : accès temps réel rapide

3. Comment structurez-vous les données dans Hive ?
   - Partitions : date
   - Format de fichier : ORC
   - Justification : analyses historiques

4. Comment synchronisez-vous les deux systèmes ?
   - Batch quotidien + streaming

---

### Exercice 2 : Système E-commerce

**Réponse de l'étudiant :**

1. Quelle architecture proposez-vous ?
   - CQRS + Lambda

2. Quelles données dans HBase ? Pourquoi ?
   - Profil utilisateur, panier, commandes récentes

3. Quelles données dans Hive ? Pourquoi ?
   - Historique achats, analytics


4. Comment optimisez-vous pour les performances ?
   - Pré-agrégations
ORC + partitions

---

### Exercice 3 : Migration d'un Système Existant

**Réponse de l'étudiant :**

1. Quelle stratégie de migration proposez-vous ?
   - Migration progressive

2. Comment migrez-vous les données ?
   - Export batch vers Hive/HBase


3. Comment gérez-vous la transition (double écriture) ?
   - Double écriture temporaire

4. Comment validez-vous la migration ?
   - Comptage
Requêtes comparatives

---

## Réflexions Personnelles

### Ce que j'ai appris :

- Importance du design des clés et partitions

### Concepts les plus importants :

- Row key design
Partitionnement Hive
Lambda & CQRS

### Patterns de design que je retiens :
Lambda Architecture
Data Lake
CQRS
- 

### Questions restantes :

- Coût réel en production

### Comment j'appliquerai ces connaissances :

- Projets data engineering
Préparation entretien


### Prochaines étapes :

- Implémentation Spark / Kafka

---

## Auto-évaluation

### Ma compréhension des concepts (1-5) :

- Architecture HBase avancée : ___/5
- Architecture Hive avancée : ___/5
- Patterns de design : ___/5
- Optimisation : ___/5
- Résolution de problèmes : ___/5

### Points forts identifiés :

- 

### Points à améliorer :

- 

### Prêt pour des projets professionnels ?

 Partiellement

**Justification :**
mise en place de la solution et de architecture faire plus de projet. voir comment on peut authomatise plus la solution faire en sorte que sa soit comprehensible par tout 
- 

