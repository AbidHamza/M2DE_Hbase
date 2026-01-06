# Room 8 : Troubleshooting et Dépannage

## Introduction

### Contexte

Cette room vous apprend à diagnostiquer et résoudre les problèmes courants rencontrés lors de l'utilisation de HBase et Hive. Même avec un environnement bien configuré, des problèmes peuvent survenir. Cette room vous donne les outils pour les identifier et les résoudre rapidement.

### Objectifs mesurables

À la fin de cette room, vous serez capable de :

1. **Diagnostiquer** les problèmes d'environnement Docker
2. **Identifier** les erreurs courantes de HBase et Hive
3. **Résoudre** les problèmes de connexion et d'accès
4. **Comprendre** les messages d'erreur et leurs solutions
5. **Vérifier** l'état de santé de votre environnement

---

## Prérequis

Avant de commencer cette room, assurez-vous d'avoir :

- Complété la Room Architecture (compréhension des composants)
- Complété au moins la Room 0 (Introduction)
- Accès à un terminal/console
- Docker installé et fonctionnel

### Vérification rapide de l'environnement

Avant de commencer, vérifiez que votre environnement est prêt :

```bash
# Vérifier Docker
docker --version

# Vérifier Docker Compose
docker compose version

# Vérifier que les conteneurs sont démarrés
docker compose ps
```

Si ces commandes fonctionnent, vous pouvez continuer. Sinon, consultez la section "Problèmes d'environnement" ci-dessous.

---

## Section 1 : Problèmes d'environnement Docker

### Problème 1 : Docker n'est pas installé ou non accessible

**Symptômes :**
- Message d'erreur : `docker: command not found` ou `docker: command not recognized`
- Le script `start` échoue immédiatement

**Diagnostic :**

```bash
# Vérifier si Docker est installé
docker --version

# Sur Windows, vérifier si Docker Desktop est lancé
# L'icône Docker doit être visible dans la barre des tâches
```

**Solutions :**

1. **Windows :**
   - Télécharger Docker Desktop depuis https://www.docker.com/get-started
   - Installer Docker Desktop
   - Lancer Docker Desktop et attendre qu'il soit prêt (icône dans la barre des tâches)
   - Vérifier : `docker info` (ne doit pas afficher d'erreur)

2. **Linux :**
   ```bash
   # Installation selon la distribution
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install docker.io docker-compose
   sudo systemctl start docker
   sudo systemctl enable docker
   
   # Vérifier
   docker --version
   ```

3. **macOS :**
   - Installer Docker Desktop depuis https://www.docker.com/get-started
   - Lancer Docker Desktop
   - Vérifier : `docker info`

**Erreur fréquente d'étudiant :** Essayer d'utiliser Docker sans l'avoir lancé. Docker Desktop (Windows/Mac) doit être lancé avant d'utiliser les commandes Docker.

---

### Problème 2 : Docker daemon n'est pas lancé

**Symptômes :**
- Message d'erreur : `Cannot connect to the Docker daemon`
- `docker info` échoue avec une erreur de connexion

**Diagnostic :**

```bash
# Tester la connexion au daemon Docker
docker info
```

**Solutions :**

1. **Windows/Mac :**
   - Lancer Docker Desktop manuellement
   - Attendre 1-2 minutes que Docker démarre complètement
   - Vérifier que l'icône Docker est visible dans la barre des tâches
   - Relancer : `docker info`

2. **Linux :**
   ```bash
   # Démarrer le service Docker
   sudo systemctl start docker
   
   # Vérifier le statut
   sudo systemctl status docker
   
   # Activer au démarrage
   sudo systemctl enable docker
   ```

**Erreur fréquente d'étudiant :** Ne pas attendre que Docker Desktop soit complètement démarré. Il faut attendre 1-2 minutes après le lancement.

---

### Problème 3 : Ports déjà utilisés

**Symptômes :**
- Message d'erreur : `Bind for 0.0.0.0:16011 failed: port is already allocated`
- Les conteneurs ne démarrent pas
- Erreur lors de `docker compose up`

**Diagnostic :**

```bash
# Vérifier les ports occupés
# Windows
netstat -ano | findstr :16011

# Linux/Mac
lsof -i :16011
# ou
netstat -an | grep :16011
```

**Solutions :**

1. **Libérer les ports automatiquement :**
   ```bash
   # Le script start libère automatiquement les ports
   # Relancer le script
   ./scripts/start
   ```

2. **Libérer manuellement :**
   ```bash
   # Windows - Trouver le processus
   netstat -ano | findstr :16011
   # Tuer le processus (remplacer PID par le numéro trouvé)
   taskkill /PID <PID> /F
   
   # Linux/Mac - Trouver et tuer
   lsof -ti:16011 | xargs kill -9
   ```

3. **Arrêter tous les conteneurs existants :**
   ```bash
   docker compose down
   docker ps -a | grep hbase-hive-learning-lab | awk '{print $1}' | xargs docker rm -f
   ```

**Erreur fréquente d'étudiant :** Ne pas vérifier les ports avant de lancer l'environnement. Toujours utiliser le script `start` qui fait cette vérification automatiquement.

---

### Problème 4 : Manque de mémoire RAM

**Symptômes :**
- Les conteneurs démarrent puis s'arrêtent immédiatement
- Message : `Container exited with code 137` (OOM - Out Of Memory)
- Docker Desktop affiche un avertissement de mémoire

**Diagnostic :**

```bash
# Vérifier la mémoire disponible
# Windows PowerShell
(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB

# Linux
free -h

# Mac
vm_stat
```

**Solutions :**

1. **Fermer les applications inutiles** pour libérer de la RAM
2. **Augmenter la mémoire allouée à Docker Desktop** (Windows/Mac) :
   - Ouvrir Docker Desktop
   - Aller dans Settings > Resources > Advanced
   - Augmenter la mémoire à au moins 4 GB
   - Appliquer et redémarrer Docker Desktop

3. **Réduire le nombre de conteneurs simultanés** si nécessaire

**Erreur fréquente d'étudiant :** Essayer de lancer l'environnement avec moins de 4 GB de RAM disponible. HBase et Hive nécessitent au moins 4 GB de RAM pour fonctionner correctement.

---

### Problème 5 : Espace disque insuffisant

**Symptômes :**
- Message d'erreur : `no space left on device`
- Les images Docker ne se téléchargent pas
- Les conteneurs ne peuvent pas écrire sur le disque

**Diagnostic :**

```bash
# Vérifier l'espace disque
# Windows PowerShell
Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}}

# Linux/Mac
df -h
```

**Solutions :**

1. **Nettoyer Docker :**
   ```bash
   # Supprimer les images inutilisées
   docker system prune -a
   
   # Supprimer les volumes inutilisés
   docker volume prune
   
   # Nettoyage complet (attention : supprime tout)
   docker system prune -a --volumes
   ```

2. **Libérer de l'espace disque** en supprimant des fichiers inutiles

3. **Vérifier les volumes Docker** qui peuvent prendre beaucoup d'espace

**Erreur fréquente d'étudiant :** Ne pas nettoyer Docker régulièrement. Les images et volumes Docker peuvent prendre beaucoup d'espace au fil du temps.

---

## Section 2 : Problèmes de connexion aux conteneurs

### Problème 6 : Impossible d'accéder au shell HBase

**Symptômes :**
- Message d'erreur : `Error response from daemon: No such container`
- `docker exec` échoue
- Le conteneur semble ne pas exister

**Diagnostic :**

```bash
# Vérifier que les conteneurs sont démarrés
docker compose ps

# Vérifier tous les conteneurs (même arrêtés)
docker ps -a

# Vérifier le nom exact du conteneur
docker compose ps --format "table {{.Name}}\t{{.Status}}"
```

**Solutions :**

1. **Utiliser le nom du service au lieu du nom du conteneur :**
   ```bash
   # Au lieu de chercher le nom exact, utilisez :
   docker exec -it $(docker compose ps -q hbase) hbase shell
   
   # Ou sur Windows PowerShell :
   docker exec -it (docker compose ps -q hbase) hbase shell
   ```

2. **Vérifier que le conteneur est bien démarré :**
   ```bash
   # Si le conteneur n'est pas démarré, le démarrer
   docker compose up -d hbase
   
   # Attendre quelques secondes
   sleep 10
   
   # Réessayer
   docker exec -it $(docker compose ps -q hbase) hbase shell
   ```

3. **Vérifier l'état du conteneur :**
   ```bash
   # Si le conteneur est "unhealthy", attendre encore 1-2 minutes
   docker compose ps
   
   # Vérifier les logs pour comprendre le problème
   docker compose logs hbase
   ```

**Erreur fréquente d'étudiant :** Utiliser le nom exact du conteneur au lieu d'utiliser `docker compose ps -q`. Le nom peut varier selon la version de Docker Compose.

---

### Problème 7 : Conteneur "unhealthy"

**Symptômes :**
- Le conteneur est démarré mais affiche le statut "unhealthy"
- Les commandes échouent même si le conteneur est démarré
- Les interfaces web ne sont pas accessibles

**Diagnostic :**

```bash
# Vérifier le statut des conteneurs
docker compose ps

# Vérifier les logs du conteneur
docker compose logs hadoop
docker compose logs hbase
docker compose logs hive
```

**Solutions :**

1. **Attendre encore 1-2 minutes** : Les conteneurs peuvent prendre du temps pour devenir "healthy"

2. **Vérifier les logs pour identifier le problème :**
   ```bash
   # Voir les dernières lignes des logs
   docker compose logs --tail=50 hadoop
   ```

3. **Redémarrer le conteneur problématique :**
   ```bash
   # Arrêter et redémarrer
   docker compose restart hadoop
   
   # Ou reconstruire complètement
   docker compose up -d --build hadoop
   ```

4. **Vérifier les ressources système** (RAM, CPU, disque)

**Erreur fréquente d'étudiant :** Ne pas attendre assez longtemps. Les conteneurs HBase et Hive peuvent prendre 2-3 minutes pour être complètement opérationnels.

---

## Section 3 : Problèmes HBase

### Problème 8 : Erreur "Table does not exist"

**Symptômes :**
- Message d'erreur dans HBase shell : `ERROR: Table 'ma_table' does not exist`
- Impossible d'accéder à une table créée précédemment

**Diagnostic :**

```bash
# Accéder au shell HBase
docker exec -it $(docker compose ps -q hbase) hbase shell

# Lister toutes les tables
list

# Vérifier si la table existe avec un nom différent
list 'ma_table*'
```

**Solutions :**

1. **Vérifier le nom exact de la table** (sensible à la casse) :
   ```bash
   # Dans HBase shell
   list
   # Vérifier l'orthographe exacte
   ```

2. **Recréer la table si nécessaire :**
   ```bash
   # Dans HBase shell
   create 'ma_table', 'cf'
   ```

3. **Vérifier que vous êtes dans le bon namespace** (si vous utilisez des namespaces)

**Erreur fréquente d'étudiant :** Confondre majuscules et minuscules. HBase est sensible à la casse : `MaTable` ≠ `matable` ≠ `MATABLE`.

---

### Problème 9 : Erreur "RegionServer not running"

**Symptômes :**
- Message d'erreur : `org.apache.hadoop.hbase.NotServingRegionException`
- Les opérations HBase échouent
- Impossible de lire ou écrire des données

**Diagnostic :**

```bash
# Vérifier l'état du RegionServer
docker compose logs hbase | grep -i "regionserver"

# Vérifier l'interface web HBase Master
# Ouvrir : http://localhost:16011
# Vérifier l'état des RegionServers
```

**Solutions :**

1. **Vérifier que le conteneur HBase est "healthy" :**
   ```bash
   docker compose ps hbase
   ```

2. **Redémarrer le conteneur HBase :**
   ```bash
   docker compose restart hbase
   
   # Attendre 1-2 minutes
   sleep 120
   
   # Vérifier à nouveau
   docker compose ps hbase
   ```

3. **Vérifier les logs pour des erreurs spécifiques :**
   ```bash
   docker compose logs hbase | tail -100
   ```

**Erreur fréquente d'étudiant :** Essayer d'utiliser HBase immédiatement après le démarrage. Attendre que le RegionServer soit complètement démarré (2-3 minutes).

---

### Problème 10 : Erreur lors de la création de table

**Symptômes :**
- Message d'erreur : `ERROR: Table already exists` ou `ERROR: Invalid column family`
- Impossible de créer une table

**Diagnostic :**

```bash
# Dans HBase shell
# Vérifier si la table existe déjà
list

# Vérifier la syntaxe de la commande create
# Syntaxe correcte : create 'table_name', 'column_family'
```

**Solutions :**

1. **Si la table existe déjà :**
   ```bash
   # Supprimer la table existante (attention : supprime les données)
   disable 'ma_table'
   drop 'ma_table'
   
   # Recréer la table
   create 'ma_table', 'cf'
   ```

2. **Vérifier la syntaxe :**
   ```bash
   # Syntaxe correcte
   create 'nom_table', 'famille_colonnes'
   
   # Erreur : oublier les guillemets
   create ma_table, cf  # INCORRECT
   
   # Erreur : oublier la famille de colonnes
   create 'ma_table'  # INCORRECT
   ```

**Erreur fréquente d'étudiant :** Oublier les guillemets autour du nom de table et de la famille de colonnes. HBase shell nécessite des guillemets simples.

---

## Section 4 : Problèmes Hive

### Problème 11 : Erreur "Database does not exist"

**Symptômes :**
- Message d'erreur : `Database 'ma_base' does not exist`
- Impossible d'utiliser une base de données créée précédemment

**Diagnostic :**

```bash
# Accéder au CLI Hive
docker exec -it $(docker compose ps -q hive) hive

# Lister toutes les bases de données
SHOW DATABASES;

# Vérifier le nom exact (sensible à la casse)
```

**Solutions :**

1. **Créer la base de données si elle n'existe pas :**
   ```sql
   CREATE DATABASE IF NOT EXISTS ma_base;
   USE ma_base;
   ```

2. **Vérifier le nom exact** (sensible à la casse) :
   ```sql
   SHOW DATABASES;
   -- Utiliser le nom exact affiché
   ```

3. **Utiliser la base par défaut :**
   ```sql
   USE default;
   ```

**Erreur fréquente d'étudiant :** Confondre majuscules et minuscules. Hive est sensible à la casse pour les noms de bases de données et de tables.

---

### Problème 12 : Erreur "Table does not exist" dans Hive

**Symptômes :**
- Message d'erreur : `Table 'ma_table' does not exist`
- Impossible d'interroger une table créée précédemment

**Diagnostic :**

```sql
-- Dans Hive CLI
SHOW TABLES;

-- Vérifier dans quelle base de données vous êtes
SHOW CURRENT DATABASE;
-- ou
SELECT current_database();
```

**Solutions :**

1. **Vérifier que vous êtes dans la bonne base de données :**
   ```sql
   USE ma_base;
   SHOW TABLES;
   ```

2. **Vérifier le nom exact de la table** (sensible à la casse)

3. **Recréer la table si nécessaire**

**Erreur fréquente d'étudiant :** Oublier de spécifier la base de données avec `USE`. Par défaut, Hive utilise la base `default`.

---

### Problème 13 : Erreur "Metastore not accessible"

**Symptômes :**
- Message d'erreur : `MetaException: Unable to connect to metastore`
- Hive ne peut pas se connecter au Metastore
- Les commandes Hive échouent

**Diagnostic :**

```bash
# Vérifier que le conteneur hive-metastore est démarré
docker compose ps hive-metastore

# Vérifier les logs du Metastore
docker compose logs hive-metastore | tail -50
```

**Solutions :**

1. **Vérifier que hive-metastore est "healthy" :**
   ```bash
   docker compose ps hive-metastore
   ```

2. **Redémarrer le Metastore :**
   ```bash
   docker compose restart hive-metastore
   
   # Attendre 1-2 minutes
   sleep 120
   ```

3. **Vérifier les logs pour des erreurs spécifiques :**
   ```bash
   docker compose logs hive-metastore | grep -i error
   ```

**Erreur fréquente d'étudiant :** Essayer d'utiliser Hive avant que le Metastore soit complètement démarré. Attendre 2-3 minutes après le démarrage.

---

### Problème 14 : Erreur de syntaxe SQL dans Hive

**Symptômes :**
- Message d'erreur : `ParseException: syntax error`
- Les requêtes SQL échouent

**Diagnostic :**

```sql
-- Vérifier la syntaxe de votre requête
-- Erreurs courantes :
-- - Oublier le point-virgule (;) à la fin
-- - Mauvaise casse des mots-clés
-- - Guillemets incorrects
```

**Solutions :**

1. **Toujours terminer par un point-virgule :**
   ```sql
   -- CORRECT
   SHOW TABLES;
   
   -- INCORRECT
   SHOW TABLES
   ```

2. **Vérifier la casse des mots-clés** (Hive est généralement insensible à la casse, mais certains dialectes peuvent être sensibles)

3. **Vérifier les guillemets :**
   ```sql
   -- Utiliser des guillemets simples pour les chaînes
   SELECT * FROM table WHERE name = 'valeur';
   
   -- Utiliser des backticks pour les identifiants si nécessaire
   SELECT * FROM `ma-table`;
   ```

**Erreur fréquente d'étudiant :** Oublier le point-virgule à la fin des commandes Hive. Contrairement à HBase shell, Hive nécessite un point-virgule.

---

## Section 5 : Problèmes de performance

### Problème 15 : Requêtes Hive très lentes

**Symptômes :**
- Les requêtes Hive prennent plusieurs minutes
- Le système semble bloqué pendant l'exécution

**Diagnostic :**

```sql
-- Vérifier l'explication de la requête
EXPLAIN SELECT * FROM ma_table WHERE condition;

-- Vérifier les partitions
SHOW PARTITIONS ma_table;
```

**Solutions :**

1. **Utiliser des partitions** pour réduire la quantité de données scannées

2. **Créer des index** si nécessaire (selon la version de Hive)

3. **Optimiser les requêtes** :
   ```sql
   -- Éviter SELECT *
   -- Utiliser des filtres WHERE
   -- Utiliser LIMIT pour tester
   SELECT colonne1, colonne2 
   FROM ma_table 
   WHERE condition 
   LIMIT 100;
   ```

4. **Vérifier les ressources système** (RAM, CPU)

**Erreur fréquente d'étudiant :** Utiliser `SELECT *` sur de très grandes tables sans filtres. Toujours utiliser des filtres WHERE et LIMIT pour tester.

---

## Section 6 : Checklist de diagnostic rapide

Utilisez cette checklist pour diagnostiquer rapidement un problème :

### Étape 1 : Vérifier l'environnement Docker

- [ ] Docker est installé et accessible (`docker --version`)
- [ ] Docker Desktop est lancé (Windows/Mac) ou Docker daemon est démarré (Linux)
- [ ] Les conteneurs sont démarrés (`docker compose ps`)
- [ ] Les conteneurs sont "healthy" (pas "unhealthy")

### Étape 2 : Vérifier les ressources système

- [ ] Au moins 4 GB de RAM disponible
- [ ] Au moins 5 GB d'espace disque disponible
- [ ] Les ports nécessaires sont libres (9000, 9870, 16011, 2181, 10000, 10002, 16020, 16030)

### Étape 3 : Vérifier les services

- [ ] HDFS NameNode accessible : http://localhost:9870
- [ ] YARN ResourceManager accessible : http://localhost:8088
- [ ] HBase Master accessible : http://localhost:16011
- [ ] HiveServer2 accessible sur le port 10000

### Étape 4 : Vérifier les logs

- [ ] Pas d'erreurs dans `docker compose logs hadoop`
- [ ] Pas d'erreurs dans `docker compose logs hbase`
- [ ] Pas d'erreurs dans `docker compose logs hive`

### Étape 5 : Tester les accès

- [ ] HBase shell fonctionne : `docker exec -it $(docker compose ps -q hbase) hbase shell`
- [ ] Hive CLI fonctionne : `docker exec -it $(docker compose ps -q hive) hive`
- [ ] Les commandes de base fonctionnent (list, show databases, etc.)

---

## Exercices pratiques

### Exercice 1 : Diagnostic d'un problème simulé

Votre environnement ne démarre pas. Utilisez la checklist ci-dessus pour identifier le problème.

**Réponse de l'étudiant :**

1. Quelle est la première chose à vérifier ?
   - 

2. Quelles commandes utilisez-vous pour diagnostiquer ?
   - 

3. Quel est le problème identifié ?
   - 

4. Quelle est la solution appliquée ?
   - 

---

### Exercice 2 : Résolution d'une erreur HBase

Vous essayez d'accéder à une table HBase mais obtenez l'erreur "Table does not exist".

**Réponse de l'étudiant :**

1. Quelles commandes utilisez-vous pour diagnostiquer ?
   - 

2. Quelle est la cause probable du problème ?
   - 

3. Quelle solution appliquez-vous ?
   - 

---

### Exercice 3 : Résolution d'une erreur Hive

Vous essayez d'exécuter une requête Hive mais obtenez une erreur de syntaxe.

**Réponse de l'étudiant :**

1. Quelle est l'erreur exacte affichée ?
   - 

2. Quelle est la cause probable ?
   - 

3. Comment corrigez-vous la requête ?
   - 

---

## Validation

Pour valider cette room, vous devez :

1. Avoir résolu au moins 3 problèmes différents parmi ceux présentés
2. Avoir complété les exercices pratiques
3. Comprendre comment utiliser la checklist de diagnostic
4. Être capable d'identifier rapidement la cause d'un problème courant

---

## Prochaine étape

Une fois cette room validée, vous pouvez :
- Revenir aux rooms précédentes avec confiance
- Passer à la Room 9 : Optimisation et Performance
- Continuer avec le projet final (Room 7)

Cette room vous donne les outils pour résoudre les problèmes de manière autonome.

