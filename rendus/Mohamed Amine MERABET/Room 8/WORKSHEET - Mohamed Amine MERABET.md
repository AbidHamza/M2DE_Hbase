# Worksheet : Exercices Architecture HBase + Hive

**Nom de l'étudiant :** **\*\***\*\*\*\***\*\***\_**\*\***\*\*\*\***\*\***

**Date :** **\*\***\*\*\*\***\*\***\_**\*\***\*\*\*\***\*\***

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
HDFS est placé en bas car il constitue la couche de stockage physique sur laquelle reposent tous les autres composants.
Ni HBase ni Hive ne stockent directement les données :
• HBase persiste ses données sous forme de HFiles dans HDFS
• Hive lit les fichiers stockés dans HDFS
HDFS est donc une dépendance fondamentale pour :
• HBase (stockage des tables)
• Hive (lecture des données analytiques)
Sans HDFS, ni HBase ni Hive ne peuvent fonctionner.

**Question 2 :** Comment les clients HBase accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**

1. Client HBase (HBase Shell) envoie une requête (get / put)
2. Le client consulte ZooKeeper
   • pour connaître le RegionServer qui détient la région correspondant à la row key
3. Le client communique directement avec le HBase RegionServer
4. Le RegionServer :
   • écrit d’abord dans le WAL
   • écrit ensuite dans le MemStore
5. Les données sont persistées dans des HFiles stockés dans HDFS
6. Le résultat est renvoyé au client
   Points clés :
   • Le HBase Master n’est pas sur le chemin des requêtes
   • L’accès est direct RegionServer ↔ client
   • HDFS n’est jamais interrogé directement par le client

---

**Question 3 :** Comment les clients Hive accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**

1. Client Hive (Beeline) se connecte à HiveServer2
2. HiveServer2 reçoit la requête HiveQL
3. HiveServer2 interroge le Hive Metastore
   • pour récupérer le schéma
   • l’emplacement des fichiers
4. Hive traduit la requête en tâches de calcul
5. YARN :
   • alloue les ressources
   • exécute les tâches (MapReduce / Tez)
6. Les tâches lisent les fichiers stockés dans HDFS
7. Le résultat est renvoyé à HiveServer2
8. HiveServer2 renvoie le résultat au client Beeline
   Points clés :
   • Hive ne stocke aucune donnée
   • Le Metastore est consulté avant toute lecture
   • YARN orchestre l’exécution

**Question 4 :** Quel est le rôle de ZooKeeper dans cette architecture ?

**Réponse de l'étudiant :**

ZooKeeper est le service de coordination central de l’architecture HBase.
Il permet notamment :
• l’élection du HBase Master actif
• l’enregistrement des RegionServers
• la découverte par les clients du RegionServer responsable d’une région
• la gestion de la configuration distribuée
Sans ZooKeeper :
• HBase ne peut pas démarrer
• les clients ne peuvent pas localiser les données
ZooKeeper ne stocke aucune donnée métier et ne remplace aucun autre composant.

## Exercice 2 : Comprendre un dataflow Hive

### Consigne

Complétez les étapes suivantes en indiquant ce qui se passe à chaque étape lors de l'exécution de la requête :
`SELECT city, COUNT(*) FROM customers WHERE status='active' GROUP BY city;`

### Étapes à compléter

**Étape 1 :** Le client (Beeline) envoie la requête à \***\*\_\_\*\***

**Réponse de l'étudiant :**

Le client (Beeline) envoie la requête à HiveServer2

**Étape 2 :** \***\*\_\_\*\*** consulte \***\*\_\_\*\*** pour connaître le schéma de la table `customers`

**Réponse de l'étudiant :**

HiveServer2 consulte le Hive Metastore pour connaître le schéma de la table customers

**Étape 3 :** \***\*\_\_\*\*** traduit la requête en \***\*\_\_\*\***

**Réponse de l'étudiant :**

Hive traduit la requête en tâches de calcul (MapReduce ou Tez)

**Étape 4 :** Les tâches sont soumises à \***\*\_\_\*\*** pour exécution

**Réponse de l'étudiant :**

Les tâches sont soumises à YARN pour exécution

**Étape 5 :** \***\*\_\_\*\*** alloue les ressources (CPU, mémoire) sur les \***\*\_\_\*\***

**Réponse de l'étudiant :**

Le ResourceManager (YARN) alloue les ressources (CPU, mémoire) sur les NodeManagers

**Étape 6 :** Les tâches lisent les données depuis \***\*\_\_\*\***

**Réponse de l'étudiant :**

Les tâches lisent les données depuis HDFS

**Étape 7 :** Les résultats intermédiaires sont \***\*\_\_\*\***

**Réponse de l'étudiant :**

Les résultats intermédiaires sont agrégés et combinés par les tâches de calcul distribuées

**Étape 8 :** Le résultat final est retourné au \***\*\_\_\*\***

**Réponse de l'étudiant :**

Le résultat final est retourné au client (Beeline)

### Question complémentaire

**Question :** Pourquoi Hive ne peut-il pas exécuter directement la requête sans passer par YARN ?

**Réponse de l'étudiant :**

Hive est un moteur de requêtes, pas un moteur d’exécution distribué.
Il ne gère ni le CPU, ni la mémoire, ni la répartition des tâches sur le cluster.
YARN est indispensable car il :
• alloue les ressources sur les différentes machines
• planifie l’exécution parallèle des tâches
• gère la concurrence entre plusieurs jobs
Sans YARN, Hive ne pourrait pas exécuter une requête sur un cluster distribué.

## Exercice 3 : Raisonnement métier

### Cas 1 : Système IoT

**Contexte :** Un système IoT collecte les données de 10 000 capteurs. Chaque capteur envoie une mesure toutes les 5 minutes. Les applications doivent pouvoir :

- Récupérer rapidement les dernières mesures d'un capteur spécifique
- Analyser les tendances sur les 30 derniers jours

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**

HBase ET Hive (usage complémentaire)
Justification
HBase est adapté pour :
• récupérer rapidement les dernières mesures d’un capteur spécifique
• accès direct par row key (ex. CAPTEUR_ID + timestamp)
• faible latence (lecture ligne par ligne)
Hive est adapté pour :
• analyser les tendances sur 30 jours
• agrégations, scans complets, requêtes analytiques
• traitement par lots sur de grands volumes
Conclusion :
• HBase pour l’accès temps quasi réel
• Hive pour l’analyse historique et les tendances

### Cas 2 : Logs applicatifs

**Contexte :** Une application génère des millions de logs par jour. Les besoins sont :

- Stocker tous les logs de manière fiable
- Rechercher rapidement les logs d'un utilisateur spécifique sur les dernières 24 heures
- Analyser les patterns d'erreurs sur le dernier mois

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**

Réponse : HBase ET Hive (usage complémentaire)
Justification
• Stockage fiable assuré par HDFS (sous-jacent aux deux)
• Recherche rapide des logs d’un utilisateur sur 24h
HBase est adapté :
• accès ciblé via une clé (ex. USER_ID + timestamp)
• lecture rapide sans scan global
• Analyse des patterns d’erreurs sur un mois
Hive est adapté :
• agrégations
• regroupements
• analyse statistique sur gros volumes
Conclusion :
• HBase pour les recherches ciblées et rapides
• Hive pour l’analyse globale des logs

### Cas 3 : Base de données clients

**Contexte :** Une entreprise veut analyser son portefeuille clients. Les besoins sont :

- Stocker les informations clients (nom, email, ville, etc.)
- Générer des rapports par ville, par segment, etc.
- Mettre à jour les informations clients occasionnellement

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**

Il faut chosir Hive
Justification
Les besoins sont principalement :
• analyse par ville, segment, catégorie
• génération de rapports
• peu de mises à jour
Hive est adapté car :
• optimisé pour les requêtes analytiques
• supporte SQL (GROUP BY, agrégations)
• lecture par scans complets acceptable
HBase n’est pas optimal ici :
• peu d’accès par clé unique
• pas de besoin de latence très faible
• jointures et analyses complexes non adaptées
Conclusion :
Hive est le meilleur choix pour une analyse décisionnelle clients.

## Exercice 4 : Vrai / Faux justifié

### Consigne

Pour chaque affirmation, indiquez si elle est vraie ou fausse et **justifiez votre réponse**.

### Affirmation 1

**Énoncé :** HBase stocke les données directement dans HDFS sous forme de fichiers CSV.

**Réponse (Vrai/Faux) :** \***\*\_\_\*\***

**Justification :**

Réponse : Faux
Justification :
HBase stocke les données dans HDFS sous forme de fichiers binaires appelés HFiles, et non en CSV.
Les HFiles sont optimisés pour l’accès rapide par clé et ne sont pas lisibles directement.

### Affirmation 2

**Énoncé :** HiveServer2 et Metastore sont deux noms pour le même composant.

**Réponse (Vrai/Faux) :** \***\*\_\_\*\***

**Justification :**

Réponse : Faux
Justification :
HiveServer2 exécute les requêtes HiveQL et gère les connexions clients, tandis que le Metastore stocke uniquement les métadonnées (schémas, emplacements, partitions).
Ce sont deux services distincts.

### Affirmation 3

**Énoncé :** Les clients HBase communiquent toujours avec HBase Master pour lire des données.

**Réponse (Vrai/Faux) :** \***\*\_\_\*\***

**Justification :**

Réponse : Faux
Justification :
Les clients HBase communiquent directement avec les RegionServers pour lire et écrire les données.
Le HBase Master intervient uniquement pour les opérations administratives.

### Affirmation 4

**Énoncé :** YARN orchestre les tâches de calcul mais ne stocke pas les données.

**Réponse (Vrai/Faux) :** \***\*\_\_\*\***

**Justification :**

Réponse : Vrai
Justification :
YARN gère les ressources (CPU, mémoire) et l’exécution des tâches, mais ne stocke aucune donnée.
Le stockage est assuré par HDFS.

### Affirmation 5

**Énoncé :** Hive peut interroger des tables HBase en créant une table externe.

**Réponse (Vrai/Faux) :** \***\*\_\_\*\***

**Justification :**

Réponse : Vrai
Justification :
Hive peut créer une table externe mappée sur une table HBase, ce qui permet d’interroger HBase via HiveQL, même si les performances restent analytiques et non temps réel.

### Affirmation 6

**Énoncé :** ZooKeeper est optionnel pour HBase.

**Réponse (Vrai/Faux) :** \***\*\_\_\*\***

**Justification :**

Énoncé : ZooKeeper est optionnel pour HBase.
Réponse : Faux
Justification :
ZooKeeper est indispensable au fonctionnement de HBase :
élection du Master, coordination des RegionServers et découverte des services par les clients.

## Auto-évaluation

### Questions de réflexion

**Question 1 :** Quelle est la différence principale entre HBase et Hive selon vous ?

**Réponse de l'étudiant :**

---

---

---

**Question 2 :** Pourquoi HBase utilise-t-il HDFS pour le stockage au lieu de stocker directement sur le disque local ?

**Réponse de l'étudiant :**

---

---

---

**Question 3 :** Dans quels cas utiliseriez-vous HBase et Hive ensemble ?

**Réponse de l'étudiant :**

---

---

---

---

## Notes personnelles

Utilisez cet espace pour noter vos questions, vos difficultés, ou vos observations :

---

---

---

---

---
