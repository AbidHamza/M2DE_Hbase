ZIMMERMANN Théo - M2 - DE

# Room Expert : Mes Réponses et Réflexions

## Section 1 : Architecture Avancée HBase

### Exercice : Design de Row Keys pour Logs Applicatifs

**Réponse de l'étudiant :**

1. Quelle structure de row key proposez-vous ?

   * APP_ID_DATE_TIMESTAMP

2. Justifiez votre choix :

   * Le préfixe par application permet un accès rapide aux logs d’une application donnée pour une date précise.

3. Quels sont les avantages et inconvénients ?

   * Avantages : scans efficaces par application et par date, structure simple
   * Inconvénients : risque de hotspot si une application génère beaucoup de logs

---

### Exercice : Stratégies de Familles de Colonnes pour Monitoring

**Réponse de l'étudiant :**

1. Combien de familles de colonnes proposez-vous ?

   * 4 familles de colonnes

2. Comment les organisez-vous ?

   * metrics (CPU, RAM, disque)
   * logs (messages applicatifs)
   * alerts (alertes système)
   * config (paramètres de configuration)

3. Justifiez votre choix :

   * Les familles sont regroupées par pattern d’accès et fréquence d’utilisation.

---

### Exercice : Résolution de Hotspot

**Réponse de l'étudiant :**

1. Quel est le problème avec ces row keys ?

   * Les row keys sont séquentielles et concentrent les écritures sur une seule région.

2. Quelle solution proposez-vous ?

   * Ajouter un préfixe de salting ou un hash pour répartir les écritures.

3. Comment modifiez-vous les row keys ?

   * [0-9]_SESS_20240101_001

---

## Section 2 : Architecture Avancée Hive

### Exercice : Stratégies de Partitionnement pour Logs

**Réponse de l'étudiant :**

1. Quelle stratégie de partitionnement proposez-vous ?

   * Partitionnement par date et environnement (dev/prod)

2. Utilisez-vous des buckets ? Pourquoi ?

   * Oui, buckets par application pour faciliter les jointures et répartir les données.

3. Justifiez votre choix :

   * Les requêtes filtrent principalement par date et environnement.

---

### Exercice : Migration de Format de Fichier

**Réponse de l'étudiant :**

1. Quel format proposez-vous pour améliorer les performances ?

   * ORC

2. Comment migrez-vous les données ?

   * Création d’une nouvelle table ORC et insertion depuis la table TextFile existante.

3. Quels gains attendez-vous (espace, performance) ?

   * Réduction importante de l’espace disque et requêtes 3 à 5 fois plus rapides.

---

### Exercice : Optimisation de Requête

**Réponse de l'étudiant :**

1. Quelles optimisations proposez-vous ?

   * Utiliser les partitions, éviter les scans complets, créer des tables agrégées.

2. Comment réécrivez-vous la requête ?

   * En filtrant sur les partitions et en utilisant des données pré-agrégées.

3. Quels gains attendez-vous ?

   * Réduction du temps d’exécution et meilleure utilisation des ressources.

---

## Section 3 : Patterns de Design Professionnels

### Exercice : Lambda Architecture pour Recommandations

**Réponse de l'étudiant :**

1. Comment organisez-vous l'architecture ?

   * HBase pour le temps réel et Hive pour l’historique.

2. Quelles données dans HBase ? Quelles données dans Hive ?

   * HBase : préférences utilisateurs récentes
   * Hive : historique complet des comportements

3. Comment synchronisez-vous les deux systèmes ?

   * Par des traitements batch réguliers depuis HBase vers Hive.

---

### Exercice : Data Lake avec Sources Multiples

**Réponse de l'étudiant :**

1. Comment organisez-vous le Data Lake ?

   * Zones landing, curated et analytics dans HDFS.

2. Comment intégrez-vous chaque source ?

   * Ingestion via des pipelines batch vers la landing zone.

3. Quel rôle joue Hive dans cette architecture ?

   * Interface SQL unique pour interroger toutes les zones.

---

### Exercice : CQRS pour E-commerce

**Réponse de l'étudiant :**

1. Comment séparez-vous écriture et lecture ?

   * Écritures dans HBase, lectures analytiques dans Hive.

2. Quelles données dans HBase ? Quelles données dans Hive ?

   * HBase : commandes, stock
   * Hive : ventes agrégées, statistiques

3. Comment synchronisez-vous les deux modèles ?

   * Réplication des données depuis HBase vers Hive.

---

## Section 4 : Résolution de Problèmes Complexes

### Exercice : Performance Dégradée sur Grande Table

**Réponse de l'étudiant :**

1. Quelles sont les causes probables ?

   * Régions trop grandes, hotspots, mauvaise conception des row keys.

2. Quelles solutions proposez-vous (par ordre de priorité) ?

   * Split des régions, redesign des row keys, archivage des données anciennes.

3. Comment mesurez-vous l'amélioration ?

   * Temps de réponse, charge des RegionServers, métriques HBase.

---

### Exercice : Requêtes Hive Très Lentes

**Réponse de l'étudiant :**

1. Quelles optimisations proposez-vous ?

   * Optimisation des partitions, des jointures et création de tables agrégées.

2. Comment réécrivez-vous la requête ?

   * En filtrant sur les partitions et en réduisant le volume de données traitées.

3. Quels paramètres ajustez-vous ?

   * Parallélisme Hive et nombre de reducers.

---

## Section 5 : Exercices de Conception

### Exercice 1 : Système de Monitoring

**Réponse de l'étudiant :**

1. Quelle architecture proposez-vous (HBase, Hive, ou les deux) ?

   * Les deux

2. Comment structurez-vous les données dans HBase ?

   * Row keys : SERVER_ID_TIMESTAMP
   * Familles de colonnes : metrics, alerts
   * Justification : accès rapide aux données récentes

3. Comment structurez-vous les données dans Hive ?

   * Partitions : date
   * Format de fichier : ORC
   * Justification : analyses historiques efficaces

4. Comment synchronisez-vous les deux systèmes ?

   * Export batch régulier de HBase vers Hive.

---

### Exercice 2 : Système E-commerce

**Réponse de l'étudiant :**

1. Quelle architecture proposez-vous ?

   * Architecture hybride HBase + Hive

2. Quelles données dans HBase ? Pourquoi ?

   * Données transactionnelles et temps réel pour accès rapide.

3. Quelles données dans Hive ? Pourquoi ?

   * Historique des ventes pour analyses globales.

4. Comment optimisez-vous pour les performances ?

   * Bon design des row keys, partitions Hive, formats ORC.

---

### Exercice 3 : Migration d'un Système Existant

**Réponse de l'étudiant :**

1. Quelle stratégie de migration proposez-vous ?

   * Migration progressive vers HDFS et Hive.

2. Comment migrez-vous les données ?

   * Export MySQL vers HDFS puis création de tables Hive.

3. Comment gérez-vous la transition (double écriture) ?

   * Double écriture temporaire MySQL et HBase/Hive.

4. Comment validez-vous la migration ?

   * Comparaison des volumes, contrôles de cohérence et tests de performance.

---

## Réflexions Personnelles

### Ce que j'ai appris :

* La différence claire entre accès temps réel et analyse batch.

### Concepts les plus importants :

* Design des row keys et partitionnement Hive.

### Patterns de design que je retiens :

* Lambda Architecture et CQRS.

### Questions restantes :

* Comment automatiser au mieux la synchronisation entre HBase et Hive.

### Comment j'appliquerai ces connaissances :

* Dans des projets Big Data et d’architecture distribuée.

### Prochaines étapes :

* Mise en pratique sur un projet réel.

---

## Auto-évaluation

### Ma compréhension des concepts (1-5) :

* Architecture HBase avancée : 4/5
* Architecture Hive avancée : 4/5
* Patterns de design : 4/5
* Optimisation : 4/5
* Résolution de problèmes : 4/5

### Points forts identifiés :

* Compréhension globale de l’architecture et des flux.

### Points à améliorer :

* Approfondir l’optimisation fine des performances.

### Prêt pour des projets professionnels ?

* Oui

**Justification :**

* Capacité à concevoir, justifier et expliquer des architectures réalistes.
