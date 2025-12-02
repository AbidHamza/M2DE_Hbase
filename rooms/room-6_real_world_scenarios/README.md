# Room 6 : Cas d'usage réels

## Objectifs de cette room

- Appliquer vos connaissances à des scénarios réels
- Concevoir des solutions complètes pour des problèmes business
- Optimiser les structures de données pour des cas d'usage spécifiques
- Créer des workflows analytiques end-to-end

## Scénarios proposés

Vous allez travailler sur **deux cas d'usage réels** qui combinent HBase et Hive.

## Scénario 1 : Système de recommandation e-commerce

### Contexte

Une plateforme e-commerce souhaite analyser le comportement des clients pour améliorer ses recommandations. Les données incluent :
- Historique des achats (stocké dans HBase pour accès rapide)
- Profils clients (dans HBase)
- Analyses agrégées (dans Hive pour reporting)

### Objectifs

1. **HBase** : Créez une table `customer_purchases` pour stocker l'historique des achats
   - Row key : `CUSTOMERID_PRODUCTID_TIMESTAMP`
   - Colonnes : quantité, prix, catégorie, rating

2. **HBase** : Créez une table `customer_profiles` pour les profils clients
   - Row key : `CUSTOMERID`
   - Colonnes : préférences, historique, segments

3. **Hive** : Créez des tables externes pour analyser ces données

4. **Hive** : Générez des analyses :
   - Top produits par catégorie
   - Clients les plus actifs
   - Corrélations entre produits achetés ensemble
   - Recommandations basées sur l'historique

### Données à créer

Créez au moins 20 achats pour 5 clients différents avec des produits variés.

### Livrables

- Structure des tables HBase
- Tables Hive externes
- Requêtes d'analyse
- Recommandations de produits pour 2 clients

## Scénario 2 : Monitoring IoT en temps réel

### Contexte

Un système IoT collecte des données de capteurs en temps réel. Les besoins sont :
- Stockage rapide des données de capteurs (HBase)
- Analyse historique et alertes (Hive)
- Détection d'anomalies

### Objectifs

1. **HBase** : Créez une table `sensor_readings_realtime` pour les lectures en temps réel
   - Row key : `SENSORID_TIMESTAMP`
   - Colonnes : température, humidité, pression, localisation, statut

2. **HBase** : Créez une table `sensor_alerts` pour les alertes
   - Row key : `ALERTID_TIMESTAMP`
   - Colonnes : sensor_id, type_alerte, valeur, seuil

3. **Hive** : Créez des tables pour l'analyse historique
   - Table partitionnée par date pour les lectures
   - Table d'agrégation par capteur et heure

4. **Hive** : Générez des analyses :
   - Moyennes horaires par capteur
   - Détection des capteurs avec valeurs anormales
   - Tendances temporelles
   - Rapport d'alertes par type

### Données à créer

Créez des données pour 5 capteurs sur une période de 24 heures (une lecture toutes les 5 minutes).

### Livrables

- Structure des tables HBase et Hive
- Requêtes d'analyse et de détection d'anomalies
- Rapport d'alertes généré
- Visualisation des tendances

## Exercices pratiques

### Exercice 1 : Choix de l'architecture

Pour chaque scénario, justifiez vos choix :
- Pourquoi utiliser HBase pour certaines données ?
- Pourquoi utiliser Hive pour d'autres ?
- Comment les deux s'intègrent-ils ?

Documentez vos réflexions dans `room-6_architecture.md`.

### Exercice 2 : Implémentation Scénario 1

1. Créez toutes les tables nécessaires (HBase et Hive)
2. Chargez les données
3. Implémentez les analyses demandées
4. Générez les recommandations

### Exercice 3 : Implémentation Scénario 2

1. Créez toutes les tables nécessaires
2. Simulez les données de capteurs
3. Implémentez la détection d'alertes
4. Générez les rapports d'analyse

### Exercice 4 : Optimisation

Pour chaque scénario :
1. Identifiez les goulots d'étranglement potentiels
2. Proposez des optimisations (partitions, formats, index)
3. Testez les améliorations si possible
4. Documentez les gains de performance

### Exercice 5 : Documentation complète

Créez une documentation complète pour chaque scénario incluant :
- Architecture de la solution
- Schémas de données
- Requêtes principales
- Résultats et analyses
- Recommandations d'optimisation

## Fichiers à compléter

Créez les fichiers suivants dans ce dossier :

1. **room-6_scenario1_implementation.md** : implémentation complète du scénario 1
2. **room-6_scenario2_implementation.md** : implémentation complète du scénario 2
3. **room-6_architecture.md** : justification des choix architecturaux
4. **room-6_requetes.hql** : toutes les requêtes HiveQL
5. **room-6_hbase_commandes.hbase** : toutes les commandes HBase
6. **room-6_optimisations.md** : analyse des optimisations
7. **room-6_conclusions.md** : réflexions finales et apprentissages

## Validation

Vous avez terminé cette room quand :

-  Vous avez implémenté les deux scénarios complets
-  Vous avez créé toutes les tables nécessaires (HBase et Hive)
-  Vous avez généré les analyses et rapports demandés
-  Vous avez documenté vos choix et optimisations
-  Vous avez complété tous les fichiers demandés

## Prochaine étape

Une fois cette room terminée, vous pouvez passer à **Room 7 : Projet final**.

