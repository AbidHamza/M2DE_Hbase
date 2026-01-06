# Room Architecture : Comprendre HBase et Hive

## Introduction

### Contexte

Cette room a été conçue pour être **indépendante de Docker**. Vous pouvez la valider complètement sans avoir besoin d'un environnement fonctionnel. L'objectif est de comprendre l'architecture avant de manipuler les outils.

Pourquoi commencer par l'architecture ? Beaucoup d'étudiants rencontrent des problèmes avec Docker, mais ces problèmes masquent souvent une incompréhension fondamentale : **comment les composants s'articulent entre eux**. En comprenant d'abord l'architecture, vous serez capable de diagnostiquer les problèmes d'environnement et de construire vous-même une architecture fonctionnelle.

### Objectifs mesurables

À la fin de cette room, vous serez capable de :

1. **Expliquer** le rôle de chaque composant dans une architecture HBase + Hive
2. **Dessiner** un schéma d'architecture complet avec les flux de données
3. **Justifier** le choix entre HBase et Hive pour un cas d'usage donné
4. **Identifier** les erreurs architecturales courantes
5. **Comprendre** ce qui se passe lors d'une requête Hive de bout en bout

---

## Rappel fondamental : Big Data

### Pourquoi HDFS existe

Imaginez que vous devez stocker les données de millions de capteurs IoT qui envoient des mesures toutes les 5 minutes. Sur un seul ordinateur, cela devient rapidement impossible : le disque dur se remplit, les accès deviennent lents, et si la machine tombe en panne, toutes les données sont perdues.

**HDFS (Hadoop Distributed File System)** résout ce problème en répartissant les données sur plusieurs machines. C'est comme avoir plusieurs disques durs qui travaillent ensemble pour former un seul système de fichiers géant.

**Rappel : rôle précis**
- HDFS stocke les fichiers de données de manière distribuée
- Chaque fichier est découpé en blocs (par défaut 128 Mo)
- Chaque bloc est répliqué sur plusieurs machines (par défaut 3 copies)
- Si une machine tombe en panne, les données restent accessibles grâce aux copies

**Rappel : ce que HDFS n'est PAS**
- HDFS n'est pas une base de données (pas de requêtes SQL)
- HDFS ne fait pas de calcul (il stocke seulement)
- HDFS n'optimise pas les accès aléatoires (optimisé pour lecture séquentielle)

**Erreur fréquente d'étudiant**
"Je peux utiliser HDFS comme une base de données MySQL" → Non, HDFS est un système de fichiers, pas une base de données. Vous ne pouvez pas faire de requêtes SQL directement sur HDFS.

**Exemple concret**
Un système IoT collecte les données de 1000 capteurs. Chaque capteur envoie une mesure toutes les 5 minutes. En une journée, cela représente 288 000 mesures. Ces mesures sont stockées dans des fichiers CSV sur HDFS. HDFS répartit ces fichiers sur plusieurs machines et crée des copies pour éviter la perte de données.

### Différence : stockage / calcul / accès / métadonnées

Dans un système Big Data, il faut distinguer quatre concepts :

**1. Stockage**
- Où sont physiquement stockées les données ?
- Exemple : HDFS stocke les fichiers sur plusieurs machines

**2. Calcul**
- Qui traite les données ?
- Exemple : YARN orchestre les tâches de calcul sur plusieurs machines

**3. Accès**
- Comment les applications accèdent-elles aux données ?
- Exemple : HBase permet un accès rapide ligne par ligne, Hive permet des requêtes SQL

**4. Métadonnées**
- Où sont stockées les informations sur les données (schémas, emplacements) ?
- Exemple : Hive Metastore stocke les schémas des tables

**Rappel : placement architectural**
- Stockage = couche la plus basse (HDFS)
- Calcul = couche au-dessus du stockage (YARN)
- Accès = couche d'abstraction pour les applications (HBase, Hive)
- Métadonnées = service séparé qui connaît la structure des données (Metastore)

**Erreur fréquente d'étudiant**
Confondre le stockage (HDFS) avec l'accès (HBase/Hive). HDFS stocke les fichiers, mais HBase et Hive sont des façons différentes d'accéder à ces données.

---

## Les briques une par une

### HDFS

**Définition simple**
HDFS est le système de fichiers distribué de Hadoop. Il permet de stocker de très gros fichiers en les répartissant sur plusieurs machines.

**Rappel : rôle précis**
- Stocke les fichiers de données de manière distribuée
- Découpe les fichiers en blocs (par défaut 128 Mo)
- Réplique chaque bloc sur plusieurs machines (par défaut 3 copies)
- Gère la tolérance aux pannes (si une machine tombe, les données restent accessibles)

**Rappel : ce que HDFS n'est PAS**
- HDFS n'est pas une base de données (pas de requêtes SQL, pas d'index)
- HDFS n'optimise pas les accès aléatoires (optimisé pour lecture séquentielle)
- HDFS ne fait pas de calcul (il stocke seulement)

**Erreur fréquente d'étudiant**
Essayer d'accéder directement à un fichier HDFS comme on accède à un fichier local. HDFS nécessite des commandes spéciales (`hdfs dfs -ls`, `hdfs dfs -cat`, etc.) et les fichiers ne sont pas directement accessibles depuis le système de fichiers local.

**Exemple concret**
Un fichier de logs applicatifs de 500 Mo est stocké dans HDFS. HDFS le découpe en 4 blocs de 128 Mo chacun. Chaque bloc est répliqué sur 3 machines différentes. Si une machine tombe en panne, les données restent accessibles grâce aux copies sur les autres machines.

### YARN

**Définition simple**
YARN (Yet Another Resource Negotiator) est le gestionnaire de ressources de Hadoop. Il orchestre les tâches de calcul sur le cluster.

**Rappel : rôle précis**
- Gère les ressources du cluster (CPU, mémoire)
- Planifie et exécute les tâches de calcul
- Répartit le travail sur plusieurs machines
- Gère la file d'attente des tâches

**Rappel : ce que YARN n'est PAS**
- YARN ne stocke pas les données (c'est le rôle de HDFS)
- YARN n'est pas une base de données (c'est un gestionnaire de ressources)
- YARN ne fait pas les calculs lui-même (il orchestre les calculs)

**Erreur fréquente d'étudiant**
Confondre YARN avec HDFS. YARN gère le calcul, HDFS gère le stockage. Ce sont deux composants complémentaires mais distincts.

**Exemple concret**
Une requête Hive doit analyser un fichier de 1 Go stocké dans HDFS. YARN alloue les ressources nécessaires (mémoire, CPU) sur plusieurs machines, lance les tâches MapReduce ou Tez pour traiter les données, et coordonne l'exécution jusqu'à ce que la requête soit terminée.

### HBase

**Définition simple**
HBase est une base de données NoSQL distribuée qui fonctionne sur HDFS. Elle permet un accès rapide aux données ligne par ligne.

**Rappel : rôle précis**
- Stocke les données dans des tables avec des row keys (clés de ligne)
- Permet un accès très rapide à une ligne spécifique grâce à la row key
- Stocke les données physiquement dans HDFS (sous forme de HFiles)
- Gère la réplication et la distribution des données

**Rappel : ce que HBase n'est PAS**
- HBase n'est pas une base de données relationnelle (pas de jointures SQL complexes)
- HBase n'est pas optimisé pour les requêtes analytiques sur de grandes plages de données
- HBase ne remplace pas HDFS (elle utilise HDFS pour le stockage)

**Erreur fréquente d'étudiant**
Essayer d'utiliser HBase pour faire des requêtes analytiques complexes avec des jointures. HBase est optimisé pour l'accès rapide à des lignes spécifiques, pas pour l'analyse de grandes plages de données.

**Exemple concret**
Un système IoT stocke les dernières mesures de chaque capteur dans HBase. La row key est `CAPTEUR_ID_TIMESTAMP`. Pour récupérer les dernières mesures d'un capteur spécifique, HBase accède directement à la ligne correspondante sans scanner toute la table. C'est beaucoup plus rapide qu'une requête SQL qui devrait parcourir toutes les lignes.

### HBase Master

**Définition simple**
HBase Master est le coordinateur central de HBase. Il gère les métadonnées des tables et coordonne les RegionServers.

**Rappel : rôle précis**
- Gère les métadonnées des tables (quelles tables existent, comment elles sont structurées)
- Coordonne les RegionServers (attribution des régions, équilibrage de charge)
- Gère les opérations administratives (création/suppression de tables)
- Surveille l'état des RegionServers

**Rappel : ce que HBase Master n'est PAS**
- HBase Master ne stocke pas les données (c'est le rôle des RegionServers)
- HBase Master ne répond pas directement aux requêtes des clients (il coordonne seulement)
- HBase Master n'est pas un point de défaillance unique (il peut y avoir des backups)

**Erreur fréquente d'étudiant**
Penser que toutes les requêtes passent par HBase Master. En réalité, les clients communiquent directement avec les RegionServers pour lire/écrire les données. Le Master intervient seulement pour les opérations administratives.

**Exemple concret**
Un client veut créer une nouvelle table `sensor_data` dans HBase. Le client envoie la requête de création au HBase Master. Le Master vérifie que la table n'existe pas déjà, crée les métadonnées, et assigne les régions aux RegionServers disponibles. Une fois la table créée, les clients communiquent directement avec les RegionServers pour insérer ou lire des données.

### HBase RegionServer

**Définition simple**
HBase RegionServer est le composant qui stocke et sert les données HBase. Chaque RegionServer gère plusieurs régions (parties de tables).

**Rappel : rôle précis**
- Stocke les données HBase dans des HFiles sur HDFS
- Gère le Write-Ahead Log (WAL) pour la durabilité
- Répond aux requêtes de lecture et d'écriture des clients
- Gère le cache en mémoire (MemStore) pour améliorer les performances

**Rappel : ce que RegionServer n'est PAS**
- RegionServer n'est pas le coordinateur (c'est le rôle du Master)
- RegionServer ne gère pas les métadonnées des tables (c'est le rôle du Master)
- RegionServer ne stocke pas directement dans HDFS (il utilise HFiles qui sont ensuite écrits dans HDFS)

**Erreur fréquente d'étudiant**
Penser qu'un RegionServer stocke une table entière. En réalité, une table est divisée en régions, et chaque région est gérée par un RegionServer. Une grande table peut avoir des centaines de régions réparties sur plusieurs RegionServers.

**Exemple concret**
Une table HBase `iot_logs` contient des millions de lignes. La table est divisée en 10 régions. Chaque région est gérée par un RegionServer différent. Quand un client veut lire une ligne avec la row key `DEV001_20240101100000`, HBase détermine dans quelle région se trouve cette ligne, puis le client communique directement avec le RegionServer qui gère cette région.

### HFiles / WAL

**Définition simple**
HFiles sont les fichiers physiques où HBase stocke les données sur HDFS. Le WAL (Write-Ahead Log) est un journal qui enregistre toutes les modifications avant qu'elles ne soient écrites dans les HFiles.

**Rappel : rôle précis**
- HFiles : format de stockage optimisé pour HBase, stocké dans HDFS
- WAL : journal des modifications pour garantir la durabilité en cas de panne
- Les données sont d'abord écrites dans le WAL, puis dans le MemStore, puis dans les HFiles

**Rappel : ce que HFiles/WAL n'est PAS**
- HFiles ne sont pas des fichiers CSV ou JSON lisibles directement
- Le WAL n'est pas une base de données (c'est un journal de transactions)
- Les HFiles ne sont pas modifiables directement (HBase les régénère lors des compactions)

**Erreur fréquente d'étudiant**
Essayer de lire directement un HFile avec une commande système standard. Les HFiles sont dans un format binaire optimisé pour HBase et ne sont pas lisibles directement.

**Exemple concret**
Un client insère une nouvelle ligne dans une table HBase. La modification est d'abord écrite dans le WAL (pour garantir la durabilité), puis dans le MemStore (cache en mémoire). Quand le MemStore est plein, son contenu est écrit dans un nouveau HFile sur HDFS. Si le RegionServer tombe en panne avant que le MemStore ne soit vidé, les données peuvent être récupérées depuis le WAL.

### ZooKeeper

**Définition simple**
ZooKeeper est un service de coordination distribué utilisé par HBase pour la gestion de la configuration et la coordination entre les composants.

**Rappel : rôle précis**
- Stocke la configuration du cluster HBase
- Gère l'élection du HBase Master actif
- Coordonne les RegionServers
- Fournit un service de verrous distribués

**Rappel : ce que ZooKeeper n'est PAS**
- ZooKeeper ne stocke pas les données HBase (c'est le rôle des RegionServers)
- ZooKeeper n'est pas une base de données pour les applications (c'est un service de coordination)
- ZooKeeper n'est pas optionnel pour HBase (HBase nécessite ZooKeeper pour fonctionner)

**Erreur fréquente d'étudiant**
Ignorer ZooKeeper ou penser qu'il n'est pas important. En réalité, HBase ne peut pas fonctionner sans ZooKeeper. Si ZooKeeper est indisponible, HBase ne peut pas démarrer.

**Exemple concret**
Quand HBase démarre, le HBase Master doit s'enregistrer dans ZooKeeper pour indiquer qu'il est actif. Si plusieurs Masters tentent de démarrer en même temps, ZooKeeper garantit qu'un seul Master soit actif. Les RegionServers s'enregistrent aussi dans ZooKeeper pour que le Master sache quels RegionServers sont disponibles.

### Hive

**Définition simple**
Hive est un entrepôt de données qui permet d'interroger des données stockées dans HDFS en utilisant HiveQL, un langage similaire à SQL.

**Rappel : rôle précis**
- Fournit une interface SQL pour interroger les données dans HDFS
- Traduit les requêtes HiveQL en tâches MapReduce ou Tez
- Gère les schémas de données (définition des tables)
- Optimise les requêtes automatiquement

**Rappel : ce que Hive n'est PAS**
- Hive n'est pas une base de données (c'est un moteur de requêtes)
- Hive ne stocke pas les données (il interroge les données stockées dans HDFS)
- Hive n'est pas optimisé pour les accès en temps réel (c'est pour l'analyse par lots)

**Erreur fréquente d'étudiant**
Penser que Hive stocke les données comme MySQL. En réalité, Hive lit les données depuis HDFS. Les tables Hive sont des abstractions logiques qui pointent vers des fichiers dans HDFS.

**Exemple concret**
Un analyste veut connaître le nombre de clients actifs par ville. Il écrit une requête HiveQL : `SELECT city, COUNT(*) FROM customers WHERE status='active' GROUP BY city;`. Hive traduit cette requête en tâches MapReduce, exécute ces tâches sur le cluster via YARN, lit les données depuis HDFS, et retourne les résultats.

### Hive Metastore

**Définition simple**
Hive Metastore est une base de données qui stocke les métadonnées des tables Hive (schémas, emplacements des fichiers, partitions).

**Rappel : rôle précis**
- Stocke les définitions des tables Hive (noms de colonnes, types, formats)
- Stocke l'emplacement des fichiers de données dans HDFS
- Gère les partitions et les buckets
- Permet à plusieurs clients Hive de partager les mêmes métadonnées

**Rappel : ce que Metastore n'est PAS**
- Metastore ne stocke pas les données des tables (il stocke seulement les métadonnées)
- Metastore n'est pas Hive lui-même (c'est un service séparé utilisé par Hive)
- Metastore n'est pas optionnel (Hive nécessite Metastore pour fonctionner)

**Erreur fréquente d'étudiant**
Confondre Metastore avec HDFS. Metastore stocke les métadonnées (schémas), HDFS stocke les données réelles. Ce sont deux choses complètement différentes.

**Exemple concret**
Quand vous créez une table Hive avec `CREATE TABLE customers (...)`, Hive enregistre la définition de la table dans Metastore. Quand vous exécutez `SELECT * FROM customers`, Hive consulte d'abord Metastore pour connaître le schéma et l'emplacement des fichiers, puis lit les données depuis HDFS.

### HiveServer2

**Définition simple**
HiveServer2 est le serveur qui accepte les connexions des clients Hive et exécute les requêtes HiveQL.

**Rappel : rôle précis**
- Accepte les connexions des clients (Beeline, JDBC, ODBC)
- Exécute les requêtes HiveQL
- Gère les sessions utilisateur
- Traduit les requêtes en tâches MapReduce ou Tez

**Rappel : ce que HiveServer2 n'est PAS**
- HiveServer2 n'est pas le seul moyen d'utiliser Hive (on peut aussi utiliser le CLI Hive)
- HiveServer2 ne stocke pas les métadonnées (c'est le rôle de Metastore)
- HiveServer2 n'est pas HDFS (il interroge HDFS mais ne le remplace pas)

**Erreur fréquente d'étudiant**
Penser que HiveServer2 et Metastore sont la même chose. HiveServer2 exécute les requêtes, Metastore stocke les métadonnées. Ce sont deux services distincts qui travaillent ensemble.

**Exemple concret**
Un outil BI (comme Tableau) veut se connecter à Hive pour générer des rapports. Il se connecte à HiveServer2 via JDBC. Quand l'utilisateur exécute une requête depuis Tableau, HiveServer2 reçoit la requête, consulte Metastore pour connaître le schéma, exécute la requête en interrogeant HDFS, et retourne les résultats à Tableau.

### Clients (Beeline, HBase Shell)

**Définition simple**
Les clients sont les outils qui permettent aux utilisateurs d'interagir avec HBase ou Hive.

**Rappel : rôle précis**
- Beeline : client Hive qui se connecte à HiveServer2
- HBase Shell : client HBase en ligne de commande
- Permettent aux utilisateurs d'exécuter des commandes sans connaître les détails techniques

**Rappel : ce que les clients n'sont PAS**
- Les clients ne sont pas les serveurs (ils se connectent aux serveurs)
- Les clients ne stockent pas les données (ils interrogent les serveurs)
- Les clients ne sont pas obligatoires (on peut aussi utiliser des APIs)

**Erreur fréquente d'étudiant**
Penser que Beeline et Hive sont la même chose. Beeline est un client, Hive est le système complet. On peut utiliser Hive sans Beeline (avec le CLI Hive par exemple).

**Exemple concret**
Un développeur veut insérer des données dans HBase. Il ouvre HBase Shell et tape `put 'table', 'row', 'cf:col', 'value'`. HBase Shell envoie cette commande au HBase Master et aux RegionServers, qui exécutent l'opération et retournent le résultat au shell.

---

## Exercice 1 : Construire l'architecture

### Objectif

Construire un schéma d'architecture complet montrant comment tous les composants s'articulent entre eux.

### Consigne

Vous disposez d'un fichier `diagrams/architecture-blank.mmd` qui contient un diagramme vierge avec des zones et des cartes. Votre tâche est de :

1. Placer chaque composant dans la bonne zone
2. Tracer les flux de données entre les composants
3. Justifier vos choix

### Liste des composants à placer

- HDFS (NameNode + DataNodes)
- YARN (ResourceManager + NodeManagers)
- HBase Master
- HBase RegionServers (au moins 2)
- HFiles
- WAL
- ZooKeeper
- Hive Metastore
- HiveServer2
- Client HBase (HBase Shell)
- Client Hive (Beeline)

### Exemple de raisonnement (sans donner le schéma final)

**Question :** Où placer HDFS dans l'architecture ?

**Raisonnement attendu :**
- HDFS est la couche de stockage, donc elle doit être en bas
- HDFS stocke les données physiques, donc les HFiles doivent être dans HDFS
- Les RegionServers écrivent dans HDFS, donc il doit y avoir un flux depuis RegionServers vers HDFS

**Question :** Comment les clients accèdent-ils aux données ?

**Raisonnement attendu :**
- Les clients sont en haut de l'architecture (couche d'accès)
- Les clients HBase communiquent directement avec les RegionServers (pas via le Master pour les lectures)
- Les clients Hive communiquent avec HiveServer2, qui consulte Metastore puis interroge HDFS

### Instructions pour compléter le diagramme

1. Ouvrez le fichier `diagrams/architecture-blank.mmd`
2. Placez chaque composant dans la zone appropriée
3. Tracez les flux avec des flèches (utilisez la syntaxe Mermaid)
4. Ajoutez des légendes si nécessaire
5. Documentez vos choix dans le WORKSHEET.md

---

## Rappel intermédiaire crucial : HBase vs Hive

### Comparaison textuelle

**Type d'accès**

- **HBase** : Accès aléatoire rapide à des lignes spécifiques via row key. Optimisé pour les opérations de lecture/écriture individuelles.
- **Hive** : Accès séquentiel pour analyser de grandes plages de données. Optimisé pour les requêtes analytiques sur de grands volumes.

**Type de données**

- **HBase** : Données non structurées ou semi-structurées. Schéma flexible (colonnes peuvent être ajoutées dynamiquement).
- **Hive** : Données structurées avec schéma défini. Nécessite une définition de schéma avant utilisation.

**Cas d'usage**

- **HBase** : 
  - Systèmes temps réel (IoT, logs applicatifs)
  - Accès rapide à des données spécifiques
  - Données qui changent fréquemment
- **Hive** :
  - Analyse de données historiques
  - Requêtes analytiques complexes (jointures, agrégations)
  - Reporting et Business Intelligence

**Erreur classique**

"Je peux utiliser HBase pour faire des requêtes analytiques complexes avec des jointures" → Non, HBase n'est pas optimisé pour cela. Utilisez Hive pour les requêtes analytiques.

**Quand utiliser les deux ensemble**

Un système IoT peut utiliser HBase pour stocker les dernières mesures de chaque capteur (accès rapide), et Hive pour analyser l'historique complet (requêtes analytiques). Les deux peuvent coexister et interroger les mêmes données dans HDFS.

---

## Exercice 2 : Comprendre un dataflow Hive

### Objectif

Comprendre ce qui se passe étape par étape quand on exécute une requête Hive.

### Consigne

Une requête Hive est exécutée : `SELECT city, COUNT(*) FROM customers WHERE status='active' GROUP BY city;`

Complétez les étapes suivantes en indiquant ce qui se passe à chaque étape. Utilisez le diagramme `diagrams/dataflow.mmd` comme support visuel.

### Étapes à compléter

1. Le client (Beeline) envoie la requête à __________
2. __________ consulte __________ pour connaître le schéma de la table `customers`
3. __________ traduit la requête en __________
4. Les tâches sont soumises à __________ pour exécution
5. __________ alloue les ressources (CPU, mémoire) sur les __________
6. Les tâches lisent les données depuis __________
7. Les résultats intermédiaires sont __________
8. Le résultat final est retourné au __________

### Rappel juste avant l'exercice

- HiveServer2 exécute les requêtes mais ne stocke pas les métadonnées
- Metastore stocke les métadonnées mais n'exécute pas les requêtes
- YARN orchestre l'exécution mais ne stocke pas les données
- HDFS stocke les données mais ne fait pas de calcul

---

## Exercice 3 : Raisonnement métier

### Objectif

Déterminer si HBase ou Hive est le meilleur choix pour un cas d'usage donné.

### Cas 1 : Système IoT

**Contexte :** Un système IoT collecte les données de 10 000 capteurs. Chaque capteur envoie une mesure toutes les 5 minutes. Les applications doivent pouvoir :
- Récupérer rapidement les dernières mesures d'un capteur spécifique
- Analyser les tendances sur les 30 derniers jours

**Question :** HBase ou Hive ? Justifiez votre choix.

**Exemple de raisonnement attendu :**
- Pour récupérer rapidement les dernières mesures : HBase (accès rapide via row key)
- Pour analyser les tendances : Hive (requêtes analytiques)
- Solution : Utiliser les deux. HBase pour l'accès temps réel, Hive pour l'analyse historique.

### Cas 2 : Logs applicatifs

**Contexte :** Une application génère des millions de logs par jour. Les besoins sont :
- Stocker tous les logs de manière fiable
- Rechercher rapidement les logs d'un utilisateur spécifique sur les dernières 24 heures
- Analyser les patterns d'erreurs sur le dernier mois

**Question :** HBase ou Hive ? Justifiez votre choix.

### Cas 3 : Base de données clients

**Contexte :** Une entreprise veut analyser son portefeuille clients. Les besoins sont :
- Stocker les informations clients (nom, email, ville, etc.)
- Générer des rapports par ville, par segment, etc.
- Mettre à jour les informations clients occasionnellement

**Question :** HBase ou Hive ? Justifiez votre choix.

---

## Exercice 4 : Vrai / Faux justifié

### Consigne

Pour chaque affirmation, indiquez si elle est vraie ou fausse et **justifiez votre réponse**. Une réponse sans justification ne sera pas acceptée.

### Affirmations

1. **HBase stocke les données directement dans HDFS sous forme de fichiers CSV.**

2. **HiveServer2 et Metastore sont deux noms pour le même composant.**

3. **Les clients HBase communiquent toujours avec HBase Master pour lire des données.**

4. **YARN orchestre les tâches de calcul mais ne stocke pas les données.**

5. **Hive peut interroger des tables HBase en créant une table externe.**

6. **ZooKeeper est optionnel pour HBase.**

### Exemple de bonne justification

**Affirmation :** "HDFS est une base de données comme MySQL."

**Réponse :** Faux.

**Justification :** HDFS est un système de fichiers distribué, pas une base de données. Contrairement à MySQL, HDFS ne permet pas de faire des requêtes SQL, ne gère pas d'index, et n'optimise pas les accès aléatoires. HDFS stocke seulement les fichiers de manière distribuée.

---

## Section OPTIONNELLE : Environnement

### Note importante

**Cette section n'est PAS requise pour valider la Room.** Vous pouvez compléter tous les exercices précédents sans avoir Docker installé ou fonctionnel.

Cette section est fournie uniquement pour les étudiants qui souhaitent tester leurs connaissances avec un environnement réel.

### Checklist minimale (si vous testez)

- [ ] Docker est installé et fonctionnel
- [ ] Au moins 4 GB de RAM disponibles pour Docker
- [ ] Les ports suivants sont libres : 9870, 8088, 16011, 10000
- [ ] Le script de démarrage a été exécuté avec succès

### Commande de démarrage

Si vous souhaitez tester l'environnement, consultez le README principal du dépôt pour les instructions de démarrage.

**Commande de démarrage :**

```bash
# Linux/Mac/Windows (Git Bash/WSL)
./scripts/start

# Windows PowerShell
.\scripts\start.ps1

# Windows CMD
scripts\start.bat
```

Le script universel `./scripts/start` détecte automatiquement votre OS et utilise le bon script.

### Troubleshooting

Si vous rencontrez des problèmes avec Docker, consultez la section "Résolution de Problèmes" du README principal. Les problèmes d'environnement ne doivent pas vous empêcher de valider cette Room.

---

## Validation et évaluation

### Ce qui est évalué

1. **Raisonnement architectural** (8 points)
   - Capacité à placer les composants dans les bonnes zones
   - Compréhension des flux de données
   - Justification des choix

2. **Compréhension des concepts** (6 points)
   - Différenciation HBase vs Hive
   - Compréhension du dataflow Hive
   - Réponses aux cas d'usage métier

3. **Identification des erreurs** (4 points)
   - Réponses Vrai/Faux avec justifications correctes
   - Identification des erreurs fréquentes

4. **Clarté et précision** (2 points)
   - Qualité des explications
   - Précision du vocabulaire technique

### Ce qui n'est PAS évalué

- La capacité à installer Docker
- La capacité à exécuter des commandes HBase ou Hive
- La syntaxe parfaite des diagrammes Mermaid
- La vitesse d'exécution

### Barème sur 20

- Exercice 1 (Architecture) : 8 points
- Exercice 2 (Dataflow) : 3 points
- Exercice 3 (Raisonnement métier) : 6 points
- Exercice 4 (Vrai/Faux) : 3 points

### Critères de validation

Pour valider cette Room, vous devez :

1. Avoir complété tous les exercices dans le WORKSHEET.md
2. Avoir créé un schéma d'architecture cohérent
3. Avoir justifié vos choix pour chaque exercice
4. Avoir obtenu au moins 12/20

---

## Prochaine étape

Une fois cette Room validée, vous pouvez passer aux Rooms pratiques qui utilisent Docker :
- Room 0 : Introduction à l'environnement
- Room 1 : HBase Basics
- Room 3 : Hive Introduction

Ces Rooms pratiques vous permettront d'appliquer vos connaissances architecturales dans un environnement réel.

