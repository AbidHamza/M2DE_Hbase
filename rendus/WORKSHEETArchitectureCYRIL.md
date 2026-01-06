# Worksheet : Exercices Architecture HBase + Hive

**Nom de l'étudiant :** SOUPRAMANIANE CYRIL

**Date :** 06/01/2026

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
J'ai placé HDFS en bas de l'architecture car il appartient à la couche stockage et cette dernière est la couche la plus basse sur l'architecture sur laquelle repose les autres briques

**Question 2 :** Comment les clients HBase accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**

Client HBase → ZooKeeper → RegionServer → lit/écrit dans HFiles et WAL → données stockées dans HDFS.

**Question 3 :** Comment les clients Hive accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**

Beeline → HiveServer2 → consulte Metastore (pour le schéma) → soumet des tâches à YARN → YARN lit les données depuis HDFS → retourne les résultats

**Question 4 :** Quel est le rôle de ZooKeeper dans cette architecture ?

**Réponse de l'étudiant :**
Zookeeper permet de stocker la configuration du cluster Hbase, gérer l'élection du Hbase Master actif, coordonner les RegionServer et fournir un service de verrous distribués


---

## Exercice 2 : Comprendre un dataflow Hive

### Consigne

Complétez les étapes suivantes en indiquant ce qui se passe à chaque étape lors de l'exécution de la requête :
`SELECT city, COUNT(*) FROM customers WHERE status='active' GROUP BY city;`

### Étapes à compléter

**Étape 1 :** Le client (Beeline) envoie la requête à HiveServer2

**Réponse de l'étudiant :**

**Étape 2 :** HiveServer2 consulte Metastore pour connaître le schéma de la table `customers`

**Réponse de l'étudiant :**


**Étape 3 :** HiveServer2 traduit la requête en MapReduce

**Réponse de l'étudiant :**

**Étape 4 :** Les tâches sont soumises à YARN pour exécution

**Réponse de l'étudiant :**


**Étape 5 :** YARN alloue les ressources (CPU, mémoire) sur les NodeManagers

**Réponse de l'étudiant :**


**Étape 6 :** Les tâches lisent les données depuis HDFS

**Réponse de l'étudiant :**


**Étape 7 :** Les résultats intermédiaires sont traités et stockés temporairement dans HDFS lors des phases de calcul distribuées

**Réponse de l'étudiant :**


**Étape 8 :** Le résultat final est retourné au client Beeline

**Réponse de l'étudiant :**


### Question complémentaire

**Question :** Pourquoi Hive ne peut-il pas exécuter directement la requête sans passer par YARN ?

**Réponse de l'étudiant :**

Hive ne peut pas exécuter directement une requête car il n’est pas un moteur de calcul distribué. Il traduit les requêtes en tâches, mais délègue leur exécution et l’allocation des ressources à YARN

---

## Exercice 3 : Raisonnement métier

### Cas 1 : Système IoT

**Contexte :** Un système IoT collecte les données de 10 000 capteurs. Chaque capteur envoie une mesure toutes les 5 minutes. Les applications doivent pouvoir :
- Récupérer rapidement les dernières mesures d'un capteur spécifique
- Analyser les tendances sur les 30 derniers jours

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
HBase est utilisé pour stocker et accéder rapidement aux dernières mesures d’un capteur spécifique, car il permet un accès rapide par clé de ligne (row key).

### Cas 2 : Logs applicatifs

**Contexte :** Une application génère des millions de logs par jour. Les besoins sont :
- Stocker tous les logs de manière fiable
- Rechercher rapidement les logs d'un utilisateur spécifique sur les dernières 24 heures
- Analyser les patterns d'erreurs sur le dernier mois

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
Pour rechercher rapidement les logs d’un utilisateur sur les dernières 24 heures, on utilise HBase car il permet un accès rapide ligne par ligne via une row key (ex. userId_timestamp) et évite de scanner de gros fichiers.

### Cas 3 : Base de données clients

**Contexte :** Une entreprise veut analyser son portefeuille clients. Les besoins sont :
- Stocker les informations clients (nom, email, ville, etc.)
- Générer des rapports par ville, par segment, etc.
- Mettre à jour les informations clients occasionnellement

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**

Hive est le meilleur choix car le besoin principal est de faire des analyses et du reporting (rapports par ville, par segment), ce pour quoi Hive est optimisé avec des requêtes de type SQL sur de gros volumes stockés dans HDFS.

---

## Exercice 4 : Vrai / Faux justifié

### Consigne

Pour chaque affirmation, indiquez si elle est vraie ou fausse et **justifiez votre réponse**.

### Affirmation 1

**Énoncé :** HBase stocke les données directement dans HDFS sous forme de fichiers CSV.

**Réponse (Vrai/Faux) :** Faux

**Justification :**

Hbase stocke les données dans HDFS sous forme de HFiles

### Affirmation 2

**Énoncé :** HiveServer2 et Metastore sont deux noms pour le même composant.

**Réponse (Vrai/Faux) :** Faux

**Justification :**

HiveServer2 est le serveur qui accepte les connexions des clients Hive tandis que Metastore permet de stocker les métadonnées des tables Hive

### Affirmation 3

**Énoncé :** Les clients HBase communiquent toujours avec HBase Master pour lire des données.

**Réponse (Vrai/Faux) :** Faux

**Justification :**

Les clients HBase communiquent avec les RegionServer pour lire des données

### Affirmation 4

**Énoncé :** YARN orchestre les tâches de calcul mais ne stocke pas les données.

**Réponse (Vrai/Faux) :** Vrai

**Justification :**

YARN concerne la couche calcul tandis que la couche stockage est géré par HDFS

### Affirmation 5

**Énoncé :** Hive peut interroger des tables HBase en créant une table externe.

**Réponse (Vrai/Faux) :** Vrai

**Justification :**

Hive peut accéder à des tables HBase par le biais d'un storage handler HBase. Ainsi une table Hive externe peut être définie pour pointer vers une table HBase existante.

### Affirmation 6

**Énoncé :** ZooKeeper est optionnel pour HBase.

**Réponse (Vrai/Faux) :** Faux

**Justification :**

Hbase nécessite ZooKeeper pour fonctionner car quand Hbase démarre, le HBase Master doit s'enregistrer dans ZooKeeper pour indiquer qu'ile est actif

## Auto-évaluation

### Questions de réflexion

**Question 1 :** Quelle est la différence principale entre HBase et Hive selon vous ?

**Réponse de l'étudiant :**

HBase est une base de données NoSQL distribuée qui fonctionne sur HDFS tandis que Hive est un moteur de requêtes qui permet d'interroger des données stockées dans HDFS. 

**Question 2 :** Pourquoi HBase utilise-t-il HDFS pour le stockage au lieu de stocker directement sur le disque local ?

**Réponse de l'étudiant :**

HBase utilise HDFS car HDFS fournit un stockage distribué, répliqué et tolérant aux pannes. Cela permet à HBase de se concentrer sur l’accès rapide aux données sans gérer lui-même la réplication, la durabilité et la récupération après panne, ce que le stockage local ne garantit pas.

**Question 3 :** Dans quels cas utiliseriez-vous HBase et Hive ensemble ?

**Réponse de l'étudiant :**

On utilise HBase et Hive ensemble lorsque l’on a besoin à la fois d’un accès rapide et temps réel aux données (HBase) et d’analyses SQL sur de grands volumes de données historiques (Hive). 

---

## Notes personnelles

Utilisez cet espace pour noter vos questions, vos difficultés, ou vos observations :

_________________________________
_________________________________
_________________________________
_________________________________
_________________________________

