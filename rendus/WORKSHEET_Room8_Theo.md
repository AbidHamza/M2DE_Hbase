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
_________________________________
_________________________________
_________________________________

**Question 2 :** Comment les clients HBase accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**
_________________________________
_________________________________
_________________________________

**Question 3 :** Comment les clients Hive accèdent-ils aux données ? Tracez le flux complet.

**Réponse de l'étudiant :**
_________________________________
_________________________________
_________________________________

**Question 4 :** Quel est le rôle de ZooKeeper dans cette architecture ?

**Réponse de l'étudiant :**
_________________________________
_________________________________
_________________________________

---

## Exercice 2 : Comprendre un dataflow Hive

### Consigne

Complétez les étapes suivantes en indiquant ce qui se passe à chaque étape lors de l'exécution de la requête :
`SELECT city, COUNT(*) FROM customers WHERE status='active' GROUP BY city;`

### Étapes à compléter

**Étape 1 :** Le client (Beeline) envoie la requête à __________

**Réponse de l'étudiant :**
_________________________________

**Étape 2 :** __________ consulte __________ pour connaître le schéma de la table `customers`

**Réponse de l'étudiant :**
_________________________________

**Étape 3 :** __________ traduit la requête en __________

**Réponse de l'étudiant :**
_________________________________

**Étape 4 :** Les tâches sont soumises à __________ pour exécution

**Réponse de l'étudiant :**
_________________________________

**Étape 5 :** __________ alloue les ressources (CPU, mémoire) sur les __________

**Réponse de l'étudiant :**
_________________________________

**Étape 6 :** Les tâches lisent les données depuis __________

**Réponse de l'étudiant :**
_________________________________

**Étape 7 :** Les résultats intermédiaires sont __________

**Réponse de l'étudiant :**
_________________________________

**Étape 8 :** Le résultat final est retourné au __________

**Réponse de l'étudiant :**
_________________________________

### Question complémentaire

**Question :** Pourquoi Hive ne peut-il pas exécuter directement la requête sans passer par YARN ?

**Réponse de l'étudiant :**
_________________________________
_________________________________
_________________________________

---

## Exercice 3 : Raisonnement métier

### Cas 1 : Système IoT

**Contexte :** Un système IoT collecte les données de 10 000 capteurs. Chaque capteur envoie une mesure toutes les 5 minutes. Les applications doivent pouvoir :
- Récupérer rapidement les dernières mesures d'un capteur spécifique
- Analyser les tendances sur les 30 derniers jours

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
_________________________________
_________________________________
_________________________________
_________________________________
_________________________________

### Cas 2 : Logs applicatifs

**Contexte :** Une application génère des millions de logs par jour. Les besoins sont :
- Stocker tous les logs de manière fiable
- Rechercher rapidement les logs d'un utilisateur spécifique sur les dernières 24 heures
- Analyser les patterns d'erreurs sur le dernier mois

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
_________________________________
_________________________________
_________________________________
_________________________________
_________________________________

### Cas 3 : Base de données clients

**Contexte :** Une entreprise veut analyser son portefeuille clients. Les besoins sont :
- Stocker les informations clients (nom, email, ville, etc.)
- Générer des rapports par ville, par segment, etc.
- Mettre à jour les informations clients occasionnellement

**Question :** HBase ou Hive ? Justifiez votre choix.

**Réponse de l'étudiant :**
_________________________________
_________________________________
_________________________________
_________________________________
_________________________________

---

## Exercice 4 : Vrai / Faux justifié

### Consigne

Pour chaque affirmation, indiquez si elle est vraie ou fausse et **justifiez votre réponse**.

### Affirmation 1

**Énoncé :** HBase stocke les données directement dans HDFS sous forme de fichiers CSV.

**Réponse (Vrai/Faux) :** __________

**Justification :**
_________________________________
_________________________________
_________________________________

### Affirmation 2

**Énoncé :** HiveServer2 et Metastore sont deux noms pour le même composant.

**Réponse (Vrai/Faux) :** __________

**Justification :**
_________________________________
_________________________________
_________________________________

### Affirmation 3

**Énoncé :** Les clients HBase communiquent toujours avec HBase Master pour lire des données.

**Réponse (Vrai/Faux) :** __________

**Justification :**
_________________________________
_________________________________
_________________________________

### Affirmation 4

**Énoncé :** YARN orchestre les tâches de calcul mais ne stocke pas les données.

**Réponse (Vrai/Faux) :** __________

**Justification :**
_________________________________
_________________________________
_________________________________

### Affirmation 5

**Énoncé :** Hive peut interroger des tables HBase en créant une table externe.

**Réponse (Vrai/Faux) :** __________

**Justification :**
_________________________________
_________________________________
_________________________________

### Affirmation 6

**Énoncé :** ZooKeeper est optionnel pour HBase.

**Réponse (Vrai/Faux) :** __________

**Justification :**
_________________________________
_________________________________
_________________________________

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

