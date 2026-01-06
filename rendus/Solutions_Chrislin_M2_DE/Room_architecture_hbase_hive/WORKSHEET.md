# Worksheet : Exercices Architecture HBase + Hive

**Nom de l'étudiant :** _________________________________

**Date :** _________________________________

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

Parce que HDFS est la couche de stockage de base. Tous les autres composants (HBase, Hive) stockent leurs données dans HDFS. C'est la fondation de tout le système.

**Question 2 :** Comment les clients HBase accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**

Client HBase → ZooKeeper (pour trouver le bon RegionServer) → RegionServer → lit/écrit dans HFiles et WAL → données stockées dans HDFS.


**Question 3 :** Comment les clients Hive accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**

Beeline → HiveServer2 → consulte Metastore (pour le schéma) → soumet des tâches à YARN → YARN lit les données depuis HDFS → retourne les résultats

**Question 4 :** Quel est le rôle de ZooKeeper dans cette architecture ?

**Réponse de l'étudiant :**

ZooKeeper coordonne le cluster HBase : il élit le Master actif, enregistre les RegionServers disponibles, et permet aux clients de trouver où sont les données. 

---

## Exercice 2 : Comprendre un dataflow Hive

### Consigne

Complétez les étapes suivantes en indiquant ce qui se passe à chaque étape lors de l'exécution de la requête :
`SELECT city, COUNT(*) FROM customers WHERE status='active' GROUP BY city;`

### Étapes à compléter

**Étape 1 :** Le client (Beeline) envoie la requête à __________

**Réponse de l'étudiant :**
HiverServer2

**Étape 2 :** __________ consulte __________ pour connaître le schéma de la table `customers`

**Réponse de l'étudiant :**

HiveServer2 & Hive Metastore

**Étape 3 :** __________ traduit la requête en __________

**Réponse de l'étudiant :**

HiveServer2 & tâches MapReduce

**Étape 4 :** Les tâches sont soumises à __________ pour exécution

**Réponse de l'étudiant :**

YARN

**Étape 5 :** __________ alloue les ressources (CPU, mémoire) sur les __________

**Réponse de l'étudiant :**

YARN & NodeManagers

**Étape 6 :** Les tâches lisent les données depuis __________

**Réponse de l'étudiant :**

HDFS

**Étape 7 :** Les résultats intermédiaires sont __________

**Réponse de l'étudiant :**

agrégés et regroupés par ville

**Étape 8 :** Le résultat final est retourné au __________

**Réponse de l'étudiant :**

client

### Question complémentaire

**Question :** Pourquoi Hive ne peut-il pas exécuter directement la requête sans passer par YARN ?

**Réponse de l'étudiant :**
Parce que Hive ne fait pas de calculs. YARN sert à distribuer le travail sur plusieurs machines du cluster. Et YARN gère les ressources et exécute les tâches en parallèles sur les données stockées dans HDFS. Donc Hive à besoin de YARN pour fonctionner. 

---

## Exercice 3 : Raisonnement métier

### Cas 1 : Système IoT

**Contexte :** Un système IoT collecte les données de 10 000 capteurs. Chaque capteur envoie une mesure toutes les 5 minutes. Les applications doivent pouvoir :
- Récupérer rapidement les dernières mesures d'un capteur spécifique
- Analyser les tendances sur les 30 derniers jours

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**

HBase car il faut récupérer rapidement les dernières mesures d'un capteur spécifique . Pour les analyses de tendances sur 30 jours, on peut faire des scans HBase même si c'est moins optimal que Hive.


### Cas 2 : Logs applicatifs

**Contexte :** Une application génère des millions de logs par jour. Les besoins sont :
- Stocker tous les logs de manière fiable
- Rechercher rapidement les logs d'un utilisateur spécifique sur les dernières 24 heures
- Analyser les patterns d'erreurs sur le dernier mois

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**

HBase car il faut rechercher rapidement les logs d'un utilisateur sur les 24 dernières heures. HBase permet aussi d'analyser les patterns avec des scans, même si c'est moins pratique que Hive.

### Cas 3 : Base de données clients

**Contexte :** Une entreprise veut analyser son portefeuille clients. Les besoins sont :
- Stocker les informations clients (nom, email, ville, etc.)
- Générer des rapports par ville, par segment, etc.
- Mettre à jour les informations clients occasionnellement

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**

Hive car les besoins sont principalement analytiques (rapports par ville, par segment). Les mises à jour sont occasionnelles donc pas besoin de la rapidité de HBase. Hive est parfait pour faire des GROUP BY et des agrégations.

---

## Exercice 4 : Vrai / Faux justifié

### Consigne

Pour chaque affirmation, indiquez si elle est vraie ou fausse et **justifiez votre réponse**.

### Affirmation 1

**Énoncé :** HBase stocke les données directement dans HDFS sous forme de fichiers CSV.

**Réponse (Vrai/Faux) :** Faux

**Justification :**

HBase stocke les données dans HDFS sous forme de HFiles, pas en CSV. Les HFiles ne sont pas lisibles directement.

### Affirmation 2

**Énoncé :** HiveServer2 et Metastore sont deux noms pour le même composant.

**Réponse (Vrai/Faux) :** Faux

**Justification :**

Ce sont deux composants différents. HiveServer2 exécute les requêtes SQL, Metastore stocke les métadonnées. Ils travaillent ensemble mais sont distincts.

### Affirmation 3

**Énoncé :** Les clients HBase communiquent toujours avec HBase Master pour lire des données.

**Réponse (Vrai/Faux) :** Faux

**Justification :**

Les clients communiquent directement avec les RegionServers pour lire/écrire. Le Master sert uniquement pour les opérations administratives.

### Affirmation 4

**Énoncé :** YARN orchestre les tâches de calcul mais ne stocke pas les données.

**Réponse (Vrai/Faux) :** Vrai

**Justification :**

YARN gère uniquement les ressources et l'exécution des tâches. Le stockage est géré par HDFS. YARN ne stocke rien.

### Affirmation 5

**Énoncé :** Hive peut interroger des tables HBase en créant une table externe.

**Réponse (Vrai/Faux) :** Vrai

**Justification :**

Hive peut créer une table externe qui pointe vers une table HBase. Cela permet d'interroger les données HBase avec des requêtes SQL via Hive

### Affirmation 6

**Énoncé :** ZooKeeper est optionnel pour HBase.

**Réponse (Vrai/Faux) :** Faux

**Justification :**

ZooKeeper est obligatoire pour HBase. Il coordonne le cluster. Sans ZooKeeper, HBase ne peut pas démarrer.

---

## Auto-évaluation

### Questions de réflexion

**Question 1 :** Quelle est la différence principale entre HBase et Hive selon vous ?

**Réponse de l'étudiant :**

HBase est une base NoSQL pour accéder rapidement à des lignes spécifiques (accès temps réel par clé).
Hive est un moteur SQL pour faire des analyses sur de gros volumes de données (requêtes batch avec GROUP BY, JOIN, etc.).

**Question 2 :** Pourquoi HBase utilise-t-il HDFS pour le stockage au lieu de stocker directement sur le disque local ?

**Réponse de l'étudiant :**

Pour bénéficier de la réplication et de la tolérance aux pannes de HDFS. Si une machine tombe, les données restent accessibles grâce aux copies sur d'autres machines.


**Question 3 :** Dans quels cas utiliseriez-vous HBase et Hive ensemble ?

**Réponse de l'étudiant :**

Quand on a besoin d'accès rapides (temps réel avec HBase) et d'analyses complexes (batch avec Hive). 
Par exemple : stocker les données IoT dans HBase pour les lire rapidement, puis analyser les tendances avec Hive sur les mêmes données.

---

## Notes personnelles

Utilisez cet espace pour noter vos questions, vos difficultés, ou vos observations :

_________________________________
_________________________________
_________________________________
_________________________________
_________________________________

