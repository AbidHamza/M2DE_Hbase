# Worksheet : Exercices Architecture HBase + Hive

**Nom de l'étudiant :** Jean-Andre N'DIAYE

**Date :** 

---

## Exercice 1 : Construire l'architecture

### Instructions

Complétez le diagramme `diagrams/architecture-blank.mmd` en plaçant tous les composants et en traçant les flux de données.

### Composants à placer

- [ ] HDFS (NameNode + DataNodes)
- [ ] YARN (ResourceManager + NodeManagers)
- [ ] HBase Master
- [ ] HBase RegionServers (au moins 2)
- [ ] HFiles
- [ ] WAL
- [ ] ZooKeeper
- [ ] Hive Metastore
- [ ] HiveServer2
- [ ] Client HBase (HBase Shell)
- [ ] Client Hive (Beeline)

### Justification de vos choix

**Question 1 :** Pourquoi avez-vous placé HDFS en bas de l'architecture ?

**Réponse de l'étudiant :**
HDFS est placé en bas de l’architecture car il constitue la couche de stockage physique du système Big Data.
Tous les autres composants (HBase, Hive) s’appuient sur HDFS pour stocker leurs données.
HDFS ne fait ni calcul ni requêtes : il stocke uniquement des fichiers distribués, ce qui en fait la fondation de toute l’architecture.

**Question 2 :** Comment les clients HBase accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**
Le client HBase (HBase Shell ou API) contacte ZooKeeper pour localiser les RegionServers
Le client communique directement avec le RegionServer qui détient la région correspondant à la row key
Le RegionServer lit les données depuis :
le MemStore (si en mémoire)
ou les HFiles stockés dans HDFS
Le résultat est retourné directement au client
👉 Le HBase Master n’intervient pas dans les lectures/écritures normales.
**Question 3 :** Comment les clients Hive accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**
Le client Hive (Beeline) se connecte à HiveServer2
HiveServer2 consulte le Hive Metastore pour obtenir :
le schéma
l’emplacement HDFS des données
HiveServer2 traduit la requête HiveQL en jobs (MapReduce / Tez)
Les jobs sont exécutés via YARN
Les données sont lues depuis HDFS
Le résultat final est renvoyé au client Beeline
**Question 4 :** Quel est le rôle de ZooKeeper dans cette architecture ?

**Réponse de l'étudiant :**
_________________________________
ZooKeeper est un service de coordination distribué indispensable à HBase.
Il permet :
l’élection du HBase Master actif
l’enregistrement des RegionServers
la découverte des services par les clients
la gestion de la configuration distribuée
Sans ZooKeeper, HBase ne peut pas démarrer.

## Exercice 2 : Comprendre un dataflow Hive

### Consigne

Complétez les étapes suivantes en indiquant ce qui se passe à chaque étape lors de l'exécution de la requête :
`SELECT city, COUNT(*) FROM customers WHERE status='active' GROUP BY city;`

### Étapes à compléter

**Étape 1 :** Le client (Beeline) envoie la requête à HiveServer2

**Réponse de l'étudiant :**
_________________________________

**Étape 2 :** HiveServer2 consulte Hive Metastore pour connaître le schéma de la table `customers`

**Réponse de l'étudiant :**
_________________________________

**Étape 3 :** HiveServer2 traduit la requête en jobs MapReduce ou Tez

**Réponse de l'étudiant :**
_________________________________

**Étape 4 :** Les tâches sont soumises à YARN pour exécution

**Réponse de l'étudiant :**
_________________________________

**Étape 5 :** YARN (ResourceManager) alloue les ressources (CPU, mémoire) sur les NodeManagers

**Réponse de l'étudiant :**
_________________________________

**Étape 6 :** Les tâches lisent les données depuis HDFS

**Réponse de l'étudiant :**
_________________________________

**Étape 7 :** Les résultats intermédiaires sont traités et agrégés

**Réponse de l'étudiant :**
_________________________________

**Étape 8 :** Le résultat final est retourné au client Beeline

**Réponse de l'étudiant :**
_________________________________

### Question complémentaire

**Question :** Pourquoi Hive ne peut-il pas exécuter directement la requête sans passer par YARN ?



**Réponse de l'étudiant :**
Hive n’exécute pas lui-même les calculs.
Il s’appuie sur YARN pour :
répartir le travail sur le cluster
allouer CPU et mémoire
paralléliser les traitements
Sans YARN, Hive ne pourrait pas exploiter un cluster distribué.
---

## Exercice 3 : Raisonnement métier

### Cas 1 : Système IoT

**Contexte :** Un système IoT collecte les données de 10 000 capteurs. Chaque capteur envoie une mesure toutes les 5 minutes. Les applications doivent pouvoir :
- Récupérer rapidement les dernières mesures d'un capteur spécifique
- Analyser les tendances sur les 30 derniers jours

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
Réponse attendue :
Accès rapide aux dernières mesures → HBase
Analyse sur 30 jours → Hive
Solution optimale : HBase + Hive
HBase pour le temps réel, Hive pour l’analytique historique.

### Cas 2 : Logs applicatifs

**Contexte :** Une application génère des millions de logs par jour. Les besoins sont :
- Stocker tous les logs de manière fiable
- Rechercher rapidement les logs d'un utilisateur spécifique sur les dernières 24 heures
- Analyser les patterns d'erreurs sur le dernier mois

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
Stockage massif et fiable → HDFS
Recherche rapide par utilisateur récent → HBase
Analyse mensuelle des erreurs → Hive
👉 Architecture combinée : ingestion vers HBase + analyse Hive.

### Cas 3 : Base de données clients

**Contexte :** Une entreprise veut analyser son portefeuille clients. Les besoins sont :
- Stocker les informations clients (nom, email, ville, etc.)
- Générer des rapports par ville, par segment, etc.
- Mettre à jour les informations clients occasionnellement

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
Données structurées
Peu de mises à jour
Requêtes analytiques fréquentes
👉 Hive est le meilleur choix
HBase serait inutilement complexe ici.

---

## Exercice 4 : Vrai / Faux justifié

### Consigne

Pour chaque affirmation, indiquez si elle est vraie ou fausse et **justifiez votre réponse**.

### Affirmation 1

**Énoncé :** HBase stocke les données directement dans HDFS sous forme de fichiers CSV.

**Réponse (Vrai/Faux) :** FAUX

**Justification :**
HBase stocke les données sous forme de HFiles binaires, pas en CSV.

### Affirmation 2

**Énoncé :** HiveServer2 et Metastore sont deux noms pour le même composant.

**Réponse (Vrai/Faux) :** FAUX

**Justification :**
HiveServer2 exécute les requêtes, le Metastore stocke les métadonnées.
Ce sont deux services distincts.
### Affirmation 3

**Énoncé :** Les clients HBase communiquent toujours avec HBase Master pour lire des données.

**Réponse (Vrai/Faux) :** FAUX

**Justification :**
Les clients HBase communiquent directement avec les RegionServers, pas avec le Master.

### Affirmation 4

**Énoncé :** YARN orchestre les tâches de calcul mais ne stocke pas les données.

**Réponse (Vrai/Faux) :** VRAI

**Justification :**
YARN orchestre le calcul mais ne stocke aucune donnée.
### Affirmation 5

**Énoncé :** Hive peut interroger des tables HBase en créant une table externe.

**Réponse (Vrai/Faux) :** VRAI

**Justification :**
Hive peut interroger HBase via des tables externes utilisant un storage handler.

### Affirmation 6

**Énoncé :** ZooKeeper est optionnel pour HBase.

**Réponse (Vrai/Faux) :** FAUX

**Justification :**
ZooKeeper est obligatoire pour HBase.

---

## Auto-évaluation

### Questions de réflexion

**Question 1 :** Quelle est la différence principale entre HBase et Hive selon vous ?

**Réponse de l'étudiant :**
_________________________________
_________________________________
_________________________________

**Question 2 :** Pourquoi HBase utilise-t-il HDFS pour le stockage au lieu de stocker directement sur le disque local ?

**Réponse de l'étudiant :**
_________________________________
_________________________________
_________________________________

**Question 3 :** Dans quels cas utiliseriez-vous HBase et Hive ensemble ?

**Réponse de l'étudiant :**
_________________________________
_________________________________
_________________________________

---

## Notes personnelles

Utilisez cet espace pour noter vos questions, vos difficultés, ou vos observations :

_________________________________
_________________________________
_________________________________
_________________________________
_________________________________

