# Worksheet : Exercices Architecture HBase + Hive

**Nom de l'étudiant :** ZIMMERMANN Théo

**Date :** 6 Janvier 2026

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
HDFS est placé en bas car il constitue la couche de stockage sur laquelle reposent tous les autres composants.
Hive et HBase n’y stockent pas directement les données mais les lisent et les écrivent via HDFS.
Sans HDFS, les couches de calcul et d’accès ne peuvent pas fonctionner.

**Question 2 :** Comment les clients HBase accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**
Le client HBase (HBase Shell) contacte d’abord ZooKeeper pour localiser le RegionServer qui contient la donnée.
Il communique ensuite directement avec le RegionServer pour lire ou écrire les données.
Le RegionServer accède aux données via le MemStore, le WAL et les HFiles stockés dans HDFS.

**Question 3 :** Comment les clients Hive accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**
Le client Hive (Beeline) envoie la requête à HiveServer2, qui consulte le Hive Metastore pour obtenir le schéma.
La requête est ensuite exécutée via YARN, qui lit les données dans HDFS.
Le résultat final est renvoyé à HiveServer2, puis au client Hive.
Flux :
Client Hive (Beeline) → HiveServer2 → Hive Metastore → YARN → HDFS → YARN → HiveServer2 → Client Hive

**Question 4 :** Quel est le rôle de ZooKeeper dans cette architecture ?

**Réponse de l'étudiant :**
ZooKeeper assure la coordination des composants HBase et stocke les informations de configuration du cluster.
Il gère l’élection du HBase Master et permet aux clients de localiser les RegionServers.

---

## Exercice 2 : Comprendre un dataflow Hive

### Consigne

Complétez les étapes suivantes en indiquant ce qui se passe à chaque étape lors de l'exécution de la requête :
`SELECT city, COUNT(*) FROM customers WHERE status='active' GROUP BY city;`

### Étapes à compléter

**Étape 1 :** Le client (Beeline) envoie la requête à __________

**Réponse de l'étudiant :**
HiveServer2

**Étape 2 :** __________ consulte __________ pour connaître le schéma de la table `customers`

**Réponse de l'étudiant :**
HiveServer2 consulte le Hive Metastore

**Étape 3 :** __________ traduit la requête en __________

**Réponse de l'étudiant :**
HiveServer2 traduit la requête en tâches de calcul

**Étape 4 :** Les tâches sont soumises à __________ pour exécution

**Réponse de l'étudiant :**
YARN

**Étape 5 :** __________ alloue les ressources (CPU, mémoire) sur les __________

**Réponse de l'étudiant :**
YARN alloue les ressources sur les NodeManagers

**Étape 6 :** Les tâches lisent les données depuis __________

**Réponse de l'étudiant :**
HDFS

**Étape 7 :** Les résultats intermédiaires sont __________

**Réponse de l'étudiant :**
traités et agrégés (GROUP BY)

**Étape 8 :** Le résultat final est retourné au __________

**Réponse de l'étudiant :**
Client Hive (Beeline)

### Question complémentaire

**Question :** Pourquoi Hive ne peut-il pas exécuter directement la requête sans passer par YARN ?

**Réponse de l'étudiant :**
Hive ne fait pas le calcul lui-même.
YARN est nécessaire pour répartir et exécuter les tâches sur le cluster.
Sans YARN, Hive ne peut pas utiliser les ressources distribuées.

---

## Exercice 3 : Raisonnement métier

### Cas 1 : Système IoT

**Contexte :** Un système IoT collecte les données de 10 000 capteurs. Chaque capteur envoie une mesure toutes les 5 minutes. Les applications doivent pouvoir :
- Récupérer rapidement les dernières mesures d'un capteur spécifique
- Analyser les tendances sur les 30 derniers jours

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
HBase est utilisé pour accéder rapidement aux dernières mesures d’un capteur grâce à la clé de ligne.
Hive est utilisé pour analyser les tendances sur les 30 derniers jours avec des requêtes analytiques.
Les deux outils sont donc complémentaires dans ce cas d’usage.

### Cas 2 : Logs applicatifs

**Contexte :** Une application génère des millions de logs par jour. Les besoins sont :
- Stocker tous les logs de manière fiable
- Rechercher rapidement les logs d'un utilisateur spécifique sur les dernières 24 heures
- Analyser les patterns d'erreurs sur le dernier mois

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
HBase est utilisé pour rechercher rapidement les logs d’un utilisateur sur une courte période.
Hive est utilisé pour analyser les patterns d’erreurs sur un grand volume de logs.
Les logs sont stockés de manière fiable dans HDFS et exploités par les deux outils.

### Cas 3 : Base de données clients

**Contexte :** Une entreprise veut analyser son portefeuille clients. Les besoins sont :
- Stocker les informations clients (nom, email, ville, etc.)
- Générer des rapports par ville, par segment, etc.
- Mettre à jour les informations clients occasionnellement

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
Hive est le plus adapté car les besoins sont principalement analytiques (rapports par ville ou segment).
Les mises à jour sont peu fréquentes et peuvent être gérées par des traitements batch.
HBase n’est pas nécessaire car l’accès temps réel par clé n’est pas prioritaire.

---

## Exercice 4 : Vrai / Faux justifié

### Consigne

Pour chaque affirmation, indiquez si elle est vraie ou fausse et **justifiez votre réponse**.

### Affirmation 1

**Énoncé :** HBase stocke les données directement dans HDFS sous forme de fichiers CSV.

**Réponse (Vrai/Faux) :** Faux

**Justification :**
HBase stocke les données dans HDFS sous forme de HFiles, pas en fichiers CSV.
Les HFiles sont des fichiers binaires optimisés pour HBase.

### Affirmation 2

**Énoncé :** HiveServer2 et Metastore sont deux noms pour le même composant.

**Réponse (Vrai/Faux) :** Faux

**Justification :**
HiveServer2 exécute les requêtes Hive et gère les connexions clients.
Le Metastore stocke uniquement les métadonnées des tables Hive.

### Affirmation 3

**Énoncé :** Les clients HBase communiquent toujours avec HBase Master pour lire des données.

**Réponse (Vrai/Faux) :** Faux

**Justification :**
Les clients HBase communiquent directement avec les RegionServers pour lire les données.
Le HBase Master sert uniquement à la coordination et aux opérations administratives.

### Affirmation 4

**Énoncé :** YARN orchestre les tâches de calcul mais ne stocke pas les données.

**Réponse (Vrai/Faux) :** Vrai

**Justification :**
YARN gère et orchestre l’exécution des tâches de calcul sur le cluster.
Le stockage des données est assuré par HDFS, pas par YARN.

### Affirmation 5

**Énoncé :** Hive peut interroger des tables HBase en créant une table externe.

**Réponse (Vrai/Faux) :** Vrai

**Justification :**
Hive peut accéder aux données HBase via des tables externes.
Cela permet d’interroger HBase avec HiveQL.

### Affirmation 6

**Énoncé :** ZooKeeper est optionnel pour HBase.

**Réponse (Vrai/Faux) :** Faux

**Justification :**
ZooKeeper est indispensable au fonctionnement de HBase.
Il assure la coordination et l’élection du HBase Master.

---

## Auto-évaluation

### Questions de réflexion

**Question 1 :** Quelle est la différence principale entre HBase et Hive selon vous ?

**Réponse de l'étudiant :**
HBase permet un accès rapide aux données ligne par ligne en temps réel.
Hive est destiné à l’analyse de grandes quantités de données avec des requêtes de type SQL.

**Question 2 :** Pourquoi HBase utilise-t-il HDFS pour le stockage au lieu de stocker directement sur le disque local ?

**Réponse de l'étudiant :**
HDFS permet le stockage distribué et la réplication des données.
Cela assure la tolérance aux pannes et la scalabilité, ce qu’un disque local ne permet pas.

**Question 3 :** Dans quels cas utiliseriez-vous HBase et Hive ensemble ?

**Réponse de l'étudiant :**
HBase est utilisé pour l’accès rapide et en temps réel aux données.
Hive est utilisé pour l’analyse globale et les requêtes analytiques sur ces mêmes données.

---

## Notes personnelles

Utilisez cet espace pour noter vos questions, vos difficultés, ou vos observations :

Comprendre le rôle précis de chaque composant aide à mieux lire les schémas d’architecture.
La distinction entre stockage, calcul et accès est essentielle pour éviter les confusions.
Les flux de données entre Hive, HBase, HDFS et YARN sont plus clairs une fois l’architecture comprise.

