# HBase & Hive Learning Lab

Environnement d'apprentissage complet pour HBase et Hive avec Docker. **Tout est automatisé** - vous n'avez qu'à lancer un script.

---

## Guide d'Installation Complet

Ce guide vous explique **étape par étape** comment créer l'environnement depuis zéro, ce qu'il faut télécharger, installer et configurer.

**Pour les détails techniques sur la création de l'environnement** (comment il a été fait, architecture, Dockerfiles, etc.), consultez [README_ENVIRONMENT.md](README_ENVIRONMENT.md).

### Prérequis Système

Avant de commencer, vérifiez que vous avez :

- **Espace disque** : Minimum **10 GB** d'espace libre (recommandé : 20 GB)
- **RAM** : Minimum **4 GB** (recommandé : 8 GB)
- **Connexion Internet** : Pour télécharger Docker et les images
- **Système d'exploitation** :
  - Windows 10/11 (64-bit) avec WSL2
  - macOS 10.15+ (Intel ou Apple Silicon)
  - Linux (Ubuntu 20.04+, Debian 11+, CentOS 8+)

---

## Alternative : Installation Sans Docker

> **Note importante** : Cette section est destinée aux étudiants qui **ne peuvent pas** ou **ne souhaitent pas** utiliser Docker. Si vous avez Docker disponible, nous vous recommandons fortement de l'utiliser car c'est la méthode la plus simple et la plus fiable.

### Pourquoi Utiliser Docker est Recommandé

- **Installation automatique** : Tout est pré-configuré et fonctionne immédiatement
- **Pas de conflits** : L'environnement est isolé, pas d'impact sur votre système
- **Compatible** : Fonctionne de la même manière sur Windows, Mac et Linux
- **Facile à réinitialiser** : Un simple `docker compose down` et vous repartez de zéro
- **Support complet** : Tous les scripts et guides sont optimisés pour Docker

### Si Vous Ne Pouvez Pas Utiliser Docker

Si vous n'avez pas Docker ou ne pouvez pas l'installer, voici les alternatives possibles :

#### Option 1 : Installation Manuelle (Avancé)

Vous devrez installer manuellement :

1. **Java 8 JDK** (requis pour Hadoop, HBase et Hive)
2. **Hadoop 3.3.4** (HDFS + YARN)
3. **Zookeeper 3.7**
4. **HBase 2.5.0**
5. **Hive 3.1.3**
6. **PostgreSQL** (pour le metastore Hive)

**Difficulté** : **Très élevée** - Nécessite une bonne compréhension de la configuration système et des fichiers de configuration XML.

**Temps estimé** : 4-6 heures de configuration minimum

**Ressources nécessaires** :
- Système Linux ou macOS (Windows sans WSL est très compliqué)
- Minimum 8 GB RAM (recommandé 16 GB)
- 20+ GB d'espace disque
- Connaissance avancée de la ligne de commande et de la configuration système

**Documentation** :
- Guide Hadoop : https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html
- Guide HBase : https://hbase.apache.org/book.html#quickstart
- Guide Hive : https://cwiki.apache.org/confluence/display/Hive/GettingStarted

#### Option 2 : Machines Virtuelles Pré-configurées

Vous pouvez utiliser des machines virtuelles pré-configurées disponibles en ligne :

- **Cloudera QuickStart VM** : https://www.cloudera.com/downloads/quickstart_vms.html
  - Contient Hadoop, HBase, Hive pré-installés
  - Disponible pour VirtualBox ou VMware
  - Taille : ~10-15 GB
  
- **Hortonworks Sandbox** : Disponible via archives (maintenant Cloudera)
  - Alternative à Cloudera

**Difficulté** : **Moyenne** - Nécessite VirtualBox ou VMware

**Avantages** :
- Tout est pré-configuré
- Peut fonctionner sur Windows, Mac ou Linux
- Ne nécessite pas Docker

**Inconvénients** :
- Configuration différente de cet environnement de cours
- Les scripts et exemples du projet peuvent ne pas fonctionner directement
- Nécessite beaucoup de RAM (8-16 GB)

#### Option 3 : Environnements Cloud (Payants)

Services cloud qui offrent Hadoop/HBase/Hive :

- **Amazon EMR** (AWS)
- **Azure HDInsight**
- **Google Cloud Dataproc**

**Difficulté** : **Faible** (mais nécessite un compte cloud)

**Coût** : Payant (généralement quelques dollars/heure)

**Avantages** :
- Pas d'installation locale
- Scalable
- Professionnel

#### Option 4 : Utiliser un Ordinateur avec Docker

Si vous avez accès à un autre ordinateur ou à un laboratoire informatique :

- Utiliser les ordinateurs du laboratoire de l'école
- Demander de l'aide pour installer Docker sur votre machine
- Utiliser Docker via un service cloud (Docker Hub + machine distante)

### Limitations Sans Docker

Si vous choisissez de ne pas utiliser Docker :

1. **Les scripts fournis ne fonctionneront pas** - Vous devrez adapter ou créer vos propres scripts
2. **Configuration manuelle requise** - Tous les fichiers de configuration doivent être créés/modifiés manuellement
3. **Problèmes de compatibilité** - Les exemples du cours peuvent ne pas fonctionner directement
4. **Support limité** - L'équipe pédagogique peut avoir plus de difficultés à vous aider
5. **Temps de configuration important** - Plusieurs heures nécessaires au lieu de quelques minutes

### Ressources pour Installation Manuelle

Si vous choisissez l'installation manuelle, voici les guides officiels :

- **Hadoop** : https://hadoop.apache.org/docs/stable/
- **HBase** : https://hbase.apache.org/book.html
- **Hive** : https://cwiki.apache.org/confluence/display/Hive/Home

### Recommandation

**Nous recommandons fortement d'utiliser Docker** car :
- C'est gratuit et fonctionne sur tous les systèmes
- L'installation prend 10-15 minutes au lieu de plusieurs heures
- Tout est testé et fonctionne ensemble
- Le support est complet

Si vous rencontrez des problèmes avec Docker, consultez la section "Résolution de Problèmes" de ce README.

---

### Étape 1 : Installer Docker

Docker est **recommandé** pour faire fonctionner cet environnement facilement. Voici comment l'installer selon votre système :

#### Windows

1. **Télécharger Docker Desktop** :
   - Allez sur : https://www.docker.com/products/docker-desktop/
   - Cliquez sur "Download for Windows"
   - Le fichier téléchargé s'appelle `Docker Desktop Installer.exe` (environ 500 MB)

2. **Installer Docker Desktop** :
   - Double-cliquez sur `Docker Desktop Installer.exe`
   - Suivez l'assistant d'installation
   - **Cochez** "Use WSL 2 instead of Hyper-V" (recommandé)
   - Cliquez sur "Install" et attendez la fin de l'installation

3. **Lancer Docker Desktop** :
   - Recherchez "Docker Desktop" dans le menu Démarrer
   - Lancez l'application
   - **Attendez** que l'icône Docker apparaisse dans la barre des tâches (en bas à droite)
   - Cela peut prendre **2-3 minutes** au premier lancement

4. **Vérifier l'installation** :
   - Ouvrez PowerShell ou l'Invite de commande
   - Tapez : `docker --version`
   - Vous devriez voir quelque chose comme : `Docker version 24.0.0, build ...`

#### macOS

1. **Télécharger Docker Desktop** :
   - Allez sur : https://www.docker.com/products/docker-desktop/
   - Cliquez sur "Download for Mac"
   - Choisissez la version selon votre processeur :
     - **Apple Silicon (M1/M2/M3)** : Téléchargez la version "Mac with Apple Silicon"
     - **Intel** : Téléchargez la version "Mac with Intel chip"
   - Le fichier téléchargé s'appelle `Docker.dmg` (environ 500 MB)

2. **Installer Docker Desktop** :
   - Double-cliquez sur `Docker.dmg`
   - Glissez l'icône Docker dans le dossier Applications
   - Ouvrez Applications et lancez Docker Desktop
   - **Autorisez** Docker à s'exécuter (système peut demander votre mot de passe)

3. **Lancer Docker Desktop** :
   - Cliquez sur l'icône Docker dans la barre de menu (en haut)
   - Attendez que l'icône devienne verte (cela peut prendre 1-2 minutes)

4. **Vérifier l'installation** :
   - Ouvrez Terminal
   - Tapez : `docker --version`
   - Vous devriez voir la version de Docker

#### Linux (Ubuntu/Debian)

1. **Mettre à jour le système** :
   ```bash
   sudo apt-get update
   sudo apt-get upgrade -y
   ```

2. **Installer les dépendances** :
   ```bash
   sudo apt-get install -y \
       ca-certificates \
       curl \
       gnupg \
       lsb-release
   ```

3. **Ajouter la clé GPG Docker** :
   ```bash
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   ```

4. **Ajouter le dépôt Docker** :
   ```bash
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

5. **Installer Docker** :
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
   ```

6. **Démarrer Docker** :
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

7. **Ajouter votre utilisateur au groupe docker** (pour éviter d'utiliser sudo) :
   ```bash
   sudo usermod -aG docker $USER
   ```
   **Important** : Déconnectez-vous et reconnectez-vous pour que ce changement prenne effet.

8. **Vérifier l'installation** :
   ```bash
   docker --version
   docker compose version
   ```

#### Linux (CentOS/RHEL/Fedora)

1. **Installer Docker** :
   ```bash
   sudo yum install -y docker docker-compose
   # ou sur Fedora :
   sudo dnf install -y docker docker-compose
   ```

2. **Démarrer Docker** :
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Ajouter votre utilisateur au groupe docker** :
   ```bash
   sudo usermod -aG docker $USER
   ```
   **Important** : Déconnectez-vous et reconnectez-vous.

4. **Vérifier l'installation** :
   ```bash
   docker --version
   ```

---

### Étape 2 : Installer Git (si pas déjà installé)

Git est nécessaire pour cloner le projet depuis GitHub.

#### Windows

- Git est généralement inclus avec Docker Desktop
- Sinon, téléchargez depuis : https://git-scm.com/download/win
- Installez en suivant l'assistant (options par défaut sont OK)

#### macOS

- Git est généralement déjà installé
- Vérifiez avec : `git --version`
- Si pas installé : `xcode-select --install`

#### Linux

```bash
sudo apt-get install -y git    # Ubuntu/Debian
sudo yum install -y git         # CentOS/RHEL
sudo dnf install -y git         # Fedora
```

---

### Étape 3 : Cloner le Projet

Maintenant, récupérez le code du projet sur votre machine.

1. **Ouvrir un terminal** :
   - **Windows** : PowerShell ou Invite de commande
   - **macOS/Linux** : Terminal

2. **Naviguer vers le dossier où vous voulez mettre le projet** :
   ```bash
   # Exemple : aller sur le Bureau
   cd ~/Desktop          # macOS/Linux
   cd C:\Users\VotreNom\Desktop    # Windows
   ```

3. **Cloner le projet** :
   ```bash
   git clone https://github.com/AbidHamza/M2DE_Hbase.git
   ```

4. **Entrer dans le dossier du projet** :
   ```bash
   cd M2DE_Hbase
   ```

5. **Vérifier la structure** :
   ```bash
   # Windows PowerShell
   dir
   
   # Windows CMD
   dir
   
   # macOS/Linux
   ls -la
   ```

   Vous devriez voir :
   ```
   docker/
   docker-compose.yml
   README.md
   resources/
   rooms/
   scripts/
   ```

---

### Étape 4 : Comprendre la Structure du Projet

Avant de lancer, voici ce que contient chaque dossier :

```
M2DE_Hbase/
├── README.md                 # Ce fichier (guide principal)
├── docker-compose.yml        # Configuration Docker (NE PAS MODIFIER)
│
├── docker/                   # Configurations Docker (NE PAS MODIFIER)
│   ├── hadoop/              # Configuration Hadoop
│   │   ├── Dockerfile      # Image Docker pour Hadoop
│   │   ├── core-site.xml   # Configuration HDFS
│   │   └── ...
│   ├── hbase/               # Configuration HBase
│   │   ├── Dockerfile      # Image Docker pour HBase
│   │   ├── hbase-site.xml  # Configuration HBase
│   │   └── ...
│   └── hive/                # Configuration Hive
│       ├── Dockerfile      # Image Docker pour Hive
│       ├── hive-site.xml    # Configuration Hive
│       └── ...
│
├── scripts/                  # Scripts de démarrage/arrêt
│   ├── start.ps1            # Script Windows PowerShell
│   ├── start.bat            # Script Windows CMD
│   ├── start.sh             # Script Linux/Mac
│   ├── stop.ps1             # Arrêt Windows PowerShell
│   ├── stop.bat             # Arrêt Windows CMD
│   └── stop.sh              # Arrêt Linux/Mac
│
├── resources/                # Datasets pour les exercices
│   ├── customers/           # Données clients
│   ├── iot-logs/            # Logs IoT
│   ├── sales/               # Données de ventes
│   └── sensors/             # Données de capteurs
│
└── rooms/                    # VOS TRAVAUX ICI
    ├── room-architecture-hbase-hive-independent/
    ├── room-0_introduction/
    ├── room-1_hbase_basics/
    ├── room-2_hbase_advanced/
    ├── room-3_hive_introduction/
    ├── room-4_hive_advanced/
    ├── room-5_hbase_hive_integration/
    ├── room-6_real_world_scenarios/
    └── room-7_final_project/
```

**Important** :
- **Modifiez** les fichiers dans `rooms/` (vos exercices)
- **Ajoutez** vos propres datasets dans `resources/`
- **Ne modifiez PAS** les fichiers dans `docker/` sauf si vous savez ce que vous faites
- **Ne modifiez PAS** `docker-compose.yml` sauf si vous savez ce que vous faites

---

### Étape 5 : Vérifier que Docker Fonctionne

Avant de lancer l'environnement, vérifiez que Docker est bien configuré.

1. **Vérifier Docker** :
   ```bash
   docker --version
   docker info
   ```

   Si vous voyez une erreur comme "Cannot connect to Docker daemon" :
   - **Windows/Mac** : Lancez Docker Desktop et attendez qu'il soit prêt
   - **Linux** : Vérifiez que Docker est démarré : `sudo systemctl status docker`

2. **Vérifier Docker Compose** :
   ```bash
   docker compose version
   # ou
   docker-compose --version
   ```

   Si vous voyez une erreur :
   - **Windows/Mac** : Mettez à jour Docker Desktop
   - **Linux** : Installez docker-compose (voir étape 1)

3. **Tester Docker avec un conteneur simple** :
   ```bash
   docker run hello-world
   ```

   Si cela fonctionne, vous verrez "Hello from Docker!" - Docker est prêt !

---

### Étape 6 : Lancer l'Environnement

Maintenant que tout est installé, lancez l'environnement avec le script approprié.

#### Windows PowerShell

```powershell
# Assurez-vous d'être dans le dossier du projet
cd C:\Users\VotreNom\Desktop\M2DE_Hbase

# Lancer le script
.\scripts\start.ps1
```

**Si vous avez une erreur d'exécution de script** :
```powershell
# Autoriser l'exécution de scripts (une seule fois)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Relancer le script
.\scripts\start.ps1
```

#### Windows Invite de commande (CMD)

```batch
# Assurez-vous d'être dans le dossier du projet
cd C:\Users\VotreNom\Desktop\M2DE_Hbase

# Lancer le script
scripts\start.bat
```

#### macOS / Linux

```bash
# Assurez-vous d'être dans le dossier du projet
cd ~/Desktop/M2DE_Hbase

# Rendre le script exécutable (première fois seulement)
chmod +x scripts/start.sh

# Lancer le script
./scripts/start.sh
```

---

### Ce que Fait le Script de Démarrage

Le script `start` fait automatiquement :

1. **Vérifie** que Docker est installé et fonctionne
2. **Vérifie** que Docker Compose est disponible
3. **Lance** Docker Desktop si nécessaire (Windows/Mac)
4. **Nettoie** les anciens conteneurs et volumes
5. **Libère** les ports occupés (9000, 9870, 16011, 2181)
6. **Vérifie** l'espace disque disponible
7. **Télécharge** les images Docker nécessaires (première fois seulement)
8. **Construit** les images personnalisées (Hadoop, HBase, Hive)
9. **Lance** tous les services dans le bon ordre :
    - Hadoop (HDFS + YARN)
    - Zookeeper
    - HBase
    - Hive Metastore
    - Hive Server
10. **Vérifie** que tout fonctionne correctement

**Temps estimé** :
- **Premier lancement** : 5-10 minutes (téléchargement des images)
- **Lancements suivants** : 3-5 minutes

---

### Étape 7 : Vérifier que Tout Fonctionne

Après le lancement, le script affiche l'état des services. Vérifiez que tous les conteneurs sont "healthy" :

```bash
docker compose ps
```

Vous devriez voir quelque chose comme :

```
NAME                                    STATUS
hbase-hive-learning-lab-hadoop         Up X minutes (healthy)
hbase-hive-learning-lab-zookeeper      Up X minutes (healthy)
hbase-hive-learning-lab-hbase         Up X minutes (healthy)
hbase-hive-learning-lab-hive-metastore Up X minutes (healthy)
hbase-hive-learning-lab-hive          Up X minutes (healthy)
```

**Si un conteneur est "unhealthy"** :
- Attendez encore 1-2 minutes (les services peuvent prendre du temps)
- Consultez les logs : `docker compose logs <nom-du-service>`

---

### Étape 8 : Accéder aux Interfaces Web

Une fois tout démarré, vous pouvez accéder aux interfaces web :

1. **HDFS NameNode** : http://localhost:9870
   - Interface web pour gérer HDFS
   - Vérifie que les fichiers sont bien stockés

2. **YARN ResourceManager** : http://localhost:8088
   - Interface web pour gérer les ressources YARN
   - Voir les jobs en cours

3. **HBase Master** : http://localhost:16011
   - Interface web pour gérer HBase
   - Voir les tables et régions

**Important** : Si vous ne pouvez pas accéder à ces URLs :
- Vérifiez que les conteneurs sont bien démarrés : `docker compose ps`
- Vérifiez que les ports ne sont pas bloqués par un firewall
- Attendez encore 1-2 minutes si les conteneurs viennent de démarrer

---

### Étape 9 : Tester HBase et Hive

#### Tester HBase

```bash
# Accéder au shell HBase
docker exec -it $(docker compose ps -q hbase) hbase shell
```

Dans le shell HBase, tapez :
```
version
list
```

Vous devriez voir la version de HBase et une liste vide de tables (normal au début).

Pour quitter : `exit`

#### Tester Hive

```bash
# Accéder au CLI Hive
docker exec -it $(docker compose ps -q hive) hive
```

Dans le CLI Hive, tapez :
```sql
SHOW DATABASES;
```

Vous devriez voir au moins la base `default`.

Pour quitter : `exit;` (notez le point-virgule)

---

### Résumé : Checklist d'Installation

Avant de commencer les exercices, vérifiez que vous avez :

- [ ] Docker installé et fonctionnel (`docker --version`)
- [ ] Docker Compose installé (`docker compose version`)
- [ ] Docker Desktop lancé (Windows/Mac) ou Docker daemon démarré (Linux)
- [ ] Projet cloné depuis GitHub
- [ ] Script de démarrage exécuté avec succès
- [ ] Tous les conteneurs sont "healthy" (`docker compose ps`)
- [ ] Interfaces web accessibles (http://localhost:9870, etc.)
- [ ] HBase shell fonctionne (`hbase shell`)
- [ ] Hive CLI fonctionne (`hive`)

---

## Démarrage Rapide

Si vous avez déjà tout installé et que vous voulez juste relancer l'environnement :

### 1. Installer Docker

**Windows/Mac :**
- Téléchargez Docker Desktop : https://www.docker.com/get-started
- Installez et lancez Docker Desktop
- Attendez que l'icône Docker apparaisse dans la barre des tâches

**Linux :**
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl start docker
```

### 2. Cloner le Projet

```bash
git clone https://github.com/AbidHamza/M2DE_Hbase.git
cd M2DE_Hbase
```

### 3. Lancer l'Environnement

**Windows (PowerShell) :**
```powershell
.\scripts\start.ps1
```

**Windows (Invite de commande) :**
```batch
scripts\start.bat
```

**Linux/Mac :**
```bash
./scripts/start.sh
```

**C'est tout !** Le script fait automatiquement :
- Vérifie Docker et Docker Compose
- Lance Docker Desktop si nécessaire
- Nettoie les conteneurs existants
- Libère les ports occupés
- Lance tous les services

**Temps d'attente :** 3-5 minutes pour le premier lancement.

---

## Vérifier que Tout Fonctionne

### Tester HBase

```bash
# Accéder au shell HBase
docker exec -it $(docker compose ps -q hbase) hbase shell
```

**Note :** Sur Windows PowerShell, utilisez :
```powershell
docker exec -it (docker compose ps -q hbase) hbase shell
```

Dans le shell HBase, tapez :
```
version
```

Vous devriez voir la version de HBase affichée.

### Tester Hive

```bash
# Accéder au CLI Hive
docker exec -it $(docker compose ps -q hive) hive
```

**Note :** Sur Windows PowerShell, utilisez :
```powershell
docker exec -it (docker compose ps -q hive) hive
```

Dans le CLI Hive, tapez :
```sql
SHOW DATABASES;
```

### Interfaces Web

Ouvrez votre navigateur :
- **HDFS NameNode** : http://localhost:9870
- **YARN ResourceManager** : http://localhost:8088
- **HBase Master** : http://localhost:16011

---

## Commencer les Rooms

Les **rooms** sont des parcours d'apprentissage guidés. Suivez-les dans l'ordre :

0. **Room Architecture** : Comprendre l'architecture HBase + Hive (indépendante de Docker, recommandée en premier)
1. **Room 0** : Introduction
2. **Room 1** : HBase Basics
3. **Room 2** : HBase Advanced
4. **Room 3** : Hive Introduction
5. **Room 4** : Hive Advanced
6. **Room 5** : Intégration HBase-Hive
7. **Room 6** : Cas d'usage réels
8. **Room 7** : Projet final
9. **Room 8** : Troubleshooting et Dépannage (optionnel, à consulter en cas de problème)
10. **Room 9** : Optimisation et Performance (optionnel, pour aller plus loin)
11. **Room Expert** : Maîtrise Avancée (indépendante, sans environnement requis, pour devenir expert)

**Comment travailler :**
```bash
# Aller dans une room
cd rooms/room-1_hbase_basics

# Lire le README de la room
cat README.md    # Linux/Mac
notepad README.md    # Windows
```

Chaque room contient :
- Des explications théoriques
- Des exercices pratiques étape par étape
- Des datasets dans `/resources`

---

## Commandes Essentielles

### Accéder aux Conteneurs

**Accéder au shell Hadoop :**
```bash
docker exec -it $(docker compose ps -q hadoop) bash
```

**Accéder au shell HBase :**
```bash
docker exec -it $(docker compose ps -q hbase) hbase shell
```

**Accéder au CLI Hive :**
```bash
docker exec -it $(docker compose ps -q hive) hive
```

**Note :** Si `$(docker compose ps -q ...)` ne fonctionne pas sur votre système, trouvez d'abord l'ID du conteneur :
```bash
docker compose ps
# Utilisez l'ID ou le nom affiché dans la colonne NAME
docker exec -it hbase-hive-learning-lab-hadoop bash
```

### Arrêter l'Environnement

```bash
# Windows PowerShell
.\scripts\stop.ps1

# Windows Batch
scripts\stop.bat

# Linux/Mac
./scripts/stop.sh
```

### Vérifier l'État

```bash
docker compose ps
```

Le script `start` affiche automatiquement l'état à la fin du démarrage.

### Voir les Logs

```bash
docker compose logs
docker compose logs hadoop
docker compose logs hbase
```

### Trouver le Nom Exact d'un Conteneur

Si vous avez besoin d'exécuter `docker exec` manuellement, trouvez d'abord le nom exact :

```bash
# Voir tous les conteneurs avec leurs noms
docker compose ps

# Ou avec docker directement
docker ps --format "{{.Names}}\t{{.Status}}"
```

**Exemple de sortie :**
```
NAME                                STATUS
hbase-hive-learning-lab-hadoop     Up 5 minutes (healthy)
hbase-hive-learning-lab-hbase      Up 5 minutes (healthy)
```

**Utilisez ensuite le nom exact :**
```bash
docker exec -it hbase-hive-learning-lab-hadoop bash
```

**OU utilisez directement l'ID du service :**
```bash
docker exec -it $(docker compose ps -q hadoop) bash
docker exec -it $(docker compose ps -q hbase) hbase shell
docker exec -it $(docker compose ps -q hive) hive
```

---

## Résolution de Problèmes

### Docker Desktop n'est pas lancé

**Symptôme :** `Cannot connect to Docker` ou `docker: command not found`

**Solution :**
1. Lancez Docker Desktop depuis le menu Démarrer
2. Attendez 1-2 minutes que Docker démarre complètement
3. Vérifiez : `docker info` (ne doit pas afficher d'erreur)

### Conteneur "unhealthy"

**Solution :**
1. Attendez encore 1-2 minutes (les services peuvent prendre du temps)
2. Si ça persiste :
   ```bash
   docker compose logs hadoop
   docker compose logs hbase
   ```
3. Pour réinitialiser complètement :
   ```bash
   docker compose down -v
   .\scripts\start.ps1    # Relancer
   ```

### Erreur "No such container"

**Symptôme :** `Error response from daemon: No such container: hbase-hive-learning-lab-hadoop-1`

**Cause :** Le nom exact du conteneur peut varier selon votre version de Docker Compose.

**Solution :**
1. **Vérifiez que les conteneurs sont démarrés :**
   ```bash
   docker compose ps
   ```

2. **Utilisez directement l'ID du service :**
   ```bash
   docker exec -it $(docker compose ps -q hbase) hbase shell
   docker exec -it $(docker compose ps -q hive) hive
   docker exec -it $(docker compose ps -q hadoop) bash
   ```

3. **Ou trouvez le nom exact manuellement :**
   ```bash
   docker compose ps
   # Utilisez le nom exact affiché dans la colonne NAME
   docker exec -it hbase-hive-learning-lab-hbase hbase shell
   ```

### Port déjà utilisé

**Solution :**
Le script `start` libère automatiquement les ports. Si le problème persiste :

**Windows :**
```powershell
netstat -ano | findstr :16011
taskkill /PID <PID> /F
```

**Linux/Mac :**
```bash
lsof -i :16011
kill -9 <PID>
```

### "JAVA_HOME is not set"

**Solution :**
```bash
git pull origin main
.\scripts\start.ps1    # Relancer
```

### Réinitialiser Complètement

Si rien ne fonctionne :
```bash
docker compose down -v
docker system prune -a -f
.\scripts\start.ps1    # Relancer
```

---

## Commandes de Référence

### HBase Shell

**Commandes de base :**
```
create 'table', 'cf'                    # Créer une table
put 'table', 'row', 'cf:col', 'value'  # Insérer
get 'table', 'row'                      # Récupérer
scan 'table'                            # Voir toutes les données
count 'table'                           # Compter
delete 'table', 'row'                   # Supprimer
drop 'table'                            # Supprimer la table
list                                    # Lister les tables
exit                                    # Quitter
```

### Hive CLI

**Commandes de base :**
```sql
SHOW DATABASES;              # Lister les bases
CREATE DATABASE nom_db;      # Créer une base
USE nom_db;                  # Utiliser une base
SHOW TABLES;                 # Lister les tables
CREATE TABLE nom_table (...); # Créer une table
SELECT * FROM table;         # Voir les données
DROP TABLE table;            # Supprimer une table
exit;                        # Quitter (avec ;)
```

**Note :** Hive nécessite un point-virgule `;` à la fin de chaque commande. HBase non.

---

## Structure du Projet

```
M2DE_Hbase/
├── README.md                 # Ce fichier (guide d'utilisation)
├── README_ENVIRONMENT.md      # Guide technique (création de l'environnement)
├── docker-compose.yml        # Configuration Docker
│
├── docker/                   # Configurations Docker
│   ├── hadoop/
│   ├── hbase/
│   └── hive/
│
├── scripts/                  # Scripts utilitaires
│   ├── start.*              # Lancer l'environnement (RECOMMANDÉ)
│   ├── stop.*               # Arrêter l'environnement
│   ├── status.*             # Vérifier l'état
│   └── (scripts supprimés - utilisez docker exec directement)
│
├── resources/                # Datasets pour les exercices
│   ├── customers/
│   ├── iot-logs/
│   ├── sales/
│   └── sensors/
│
└── rooms/                    # VOS TRAVAUX ICI
    ├── room-architecture-hbase-hive-independent/
    ├── room-0_introduction/
    ├── room-1_hbase_basics/
    ├── room-2_hbase_advanced/
    ├── room-3_hive_introduction/
    ├── room-4_hive_advanced/
    ├── room-5_hbase_hive_integration/
    ├── room-6_real_world_scenarios/
    └── room-7_final_project/
```

---

## Objectifs du Module

À la fin de ce parcours, vous serez capable de :
- Comprendre Hadoop, HBase et Hive
- Créer et manipuler des tables HBase (CRUD complet)
- Analyser des données avec Hive (requêtes SQL)
- Intégrer HBase et Hive dans un workflow analytique
- Appliquer ces notions à des datasets réels

**Aucun prérequis avancé nécessaire** - Tout est fourni et expliqué étape par étape.

---

## Support

Si vous rencontrez un problème :

1. Vérifiez que vous avez bien suivi toutes les étapes
2. Consultez les logs : `docker compose logs`
3. Vérifiez que votre dépôt est à jour : `git pull origin main`
4. Utilisez le script `start` pour réinitialiser : `.\scripts\start.ps1`

**Pour les problèmes techniques avancés** (création de l'environnement, modification des Dockerfiles, etc.), consultez [README_ENVIRONMENT.md](README_ENVIRONMENT.md).

**Bon apprentissage !**
