# Guide de Création Technique de l'Environnement

Ce document explique **comment créer cet environnement depuis zéro** : quels fichiers télécharger, quelles commandes utiliser, comment construire les images Docker, etc.

---

## Vue d'Ensemble

Cet environnement est créé avec :
- **Docker** et **Docker Compose** pour orchestrer les services
- **Images Docker personnalisées** construites à partir d'images de base
- **5 services** : Hadoop, Zookeeper, HBase, Hive Metastore, Hive Server

---

## Prérequis pour Créer l'Environnement

- Docker installé et fonctionnel
- Docker Compose installé (V1 ou V2)
- Connexion Internet (pour télécharger les binaires Apache)
- Environ 10 GB d'espace disque

---

## Composants et Versions Utilisées

### Images de Base Docker

- **eclipse-temurin:8-jdk** : Image de base pour Hadoop, HBase et Hive
  - Contient Java 8 JDK
  - Téléchargée automatiquement lors du build Docker

- **zookeeper:3.7** : Image officielle Zookeeper
  - Téléchargée automatiquement lors du build Docker

### Binaires Apache à Télécharger

Les Dockerfiles téléchargent automatiquement ces binaires depuis les archives Apache :

1. **Hadoop 3.3.4**
   - URL : `https://archive.apache.org/dist/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz`
   - Taille : ~350 MB
   - Téléchargé dans : `docker/hadoop/Dockerfile`

2. **HBase 2.5.0**
   - URL : `https://archive.apache.org/dist/hbase/2.5.0/hbase-2.5.0-bin.tar.gz`
   - Taille : ~200 MB
   - Téléchargé dans : `docker/hbase/Dockerfile`

3. **Hive 3.1.3**
   - URL : `https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz`
   - Taille : ~250 MB
   - Téléchargé dans : `docker/hive/Dockerfile`

4. **Driver JDBC PostgreSQL** (pour Hive)
   - URL : `https://jdbc.postgresql.org/download/postgresql-42.2.24.jar`
   - Taille : ~1 MB
   - Téléchargé dans : `docker/hive/Dockerfile`

---

## Structure des Fichiers à Créer

Pour créer cet environnement, vous devez créer la structure suivante :

```
M2DE_Hbase/
├── docker-compose.yml
├── docker/
│   ├── hadoop/
│   │   ├── Dockerfile
│   │   ├── core-site.xml
│   │   ├── hdfs-site.xml
│   │   ├── mapred-site.xml
│   │   ├── yarn-site.xml
│   │   ├── hadoop-env.sh
│   │   └── start-hadoop.sh
│   ├── hbase/
│   │   ├── Dockerfile
│   │   ├── hbase-site.xml
│   │   ├── hbase-env.sh
│   │   ├── start-hbase.sh
│   │   └── healthcheck.sh
│   └── hive/
│       ├── Dockerfile
│       ├── hive-site.xml
│       ├── hive-env.sh
│       ├── core-site.xml
│       ├── hdfs-site.xml
│       ├── start-hive.sh
│       ├── start-hive-metastore.sh
│       └── healthcheck.sh
└── scripts/
    ├── start.ps1
    ├── start.bat
    ├── start.sh
    ├── stop.ps1
    ├── stop.bat
    └── stop.sh
```

---

## Commandes pour Créer l'Environnement

### Étape 1 : Créer la Structure de Dossiers

```bash
mkdir -p M2DE_Hbase/docker/hadoop
mkdir -p M2DE_Hbase/docker/hbase
mkdir -p M2DE_Hbase/docker/hive
mkdir -p M2DE_Hbase/scripts
mkdir -p M2DE_Hbase/resources
mkdir -p M2DE_Hbase/rooms
```

### Étape 2 : Créer le Dockerfile Hadoop

Créer `docker/hadoop/Dockerfile` :

```dockerfile
FROM eclipse-temurin:8-jdk

ENV HADOOP_VERSION=3.3.4
ENV HADOOP_HOME=/opt/hadoop

ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    wget \
    ssh \
    pdsh \
    && rm -rf /var/lib/apt/lists/*

# Télécharger et installer Hadoop
RUN wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm hadoop-${HADOOP_VERSION}.tar.gz

# Configurer SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

# Copier les fichiers de configuration
COPY core-site.xml ${HADOOP_HOME}/etc/hadoop/
COPY hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/
COPY mapred-site.xml ${HADOOP_HOME}/etc/hadoop/
COPY yarn-site.xml ${HADOOP_HOME}/etc/hadoop/
COPY hadoop-env.sh ${HADOOP_HOME}/etc/hadoop/
RUN chmod +x ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    sed -i 's/\r$//' ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

# Formater HDFS
RUN JAVA_HOME="" && \
    if [ -d "/opt/java/openjdk" ] && [ -f "/opt/java/openjdk/bin/java" ]; then \
        JAVA_HOME="/opt/java/openjdk"; \
    elif [ -n "$JAVA_HOME" ] && [ -d "$JAVA_HOME" ] && [ -f "$JAVA_HOME/bin/java" ]; then \
        JAVA_HOME="$JAVA_HOME"; \
    else \
        JAVA_BIN=$(which java 2>/dev/null || echo ""); \
        if [ -n "$JAVA_BIN" ] && [ -f "$JAVA_BIN" ]; then \
            JAVA_DIR=$(dirname "$JAVA_BIN"); \
            JAVA_HOME=$(dirname "$JAVA_DIR"); \
        else \
            echo "ERROR: Cannot find Java installation" >&2; \
            exit 1; \
        fi; \
    fi && \
    export JAVA_HOME && \
    echo "Formatting HDFS with JAVA_HOME=$JAVA_HOME" && \
    ${HADOOP_HOME}/bin/hdfs namenode -format -force

# Ajouter Hadoop au PATH
ENV PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}

# Exposer les ports
EXPOSE 9870 8088 9000 9864

# Script de démarrage
COPY start-hadoop.sh /start-hadoop.sh
RUN chmod +x /start-hadoop.sh && \
    sed -i 's/\r$//' /start-hadoop.sh

ENTRYPOINT []
CMD ["/bin/bash", "/start-hadoop.sh"]
```

**Commandes pour créer ce fichier** :
```bash
cd M2DE_Hbase
# Créer le fichier avec votre éditeur préféré
nano docker/hadoop/Dockerfile
# ou
vim docker/hadoop/Dockerfile
# ou sur Windows : notepad docker\hadoop\Dockerfile
```

### Étape 3 : Créer le Dockerfile HBase

Créer `docker/hbase/Dockerfile` :

```dockerfile
FROM eclipse-temurin:8-jdk

ENV HBASE_VERSION=2.5.0
ENV HBASE_HOME=/opt/hbase

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    netcat-openbsd \
    dos2unix \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Télécharger et installer HBase
RUN wget -q https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
    && tar -xzf hbase-${HBASE_VERSION}-bin.tar.gz \
    && mv hbase-${HBASE_VERSION} ${HBASE_HOME} \
    && rm hbase-${HBASE_VERSION}-bin.tar.gz

# Copier les fichiers de configuration
COPY hbase-site.xml ${HBASE_HOME}/conf/
COPY hbase-env.sh ${HBASE_HOME}/conf/

# Corriger les fins de ligne et rendre exécutable
RUN sed -i 's/\r$//' ${HBASE_HOME}/conf/hbase-env.sh && \
    dos2unix ${HBASE_HOME}/conf/hbase-env.sh 2>/dev/null || true && \
    chmod +x ${HBASE_HOME}/conf/hbase-env.sh

# Ajouter HBase au PATH
ENV PATH=${HBASE_HOME}/bin:${PATH}

# Exposer les ports
EXPOSE 16010 16020 16030

# Scripts de démarrage
COPY start-hbase.sh /start-hbase.sh
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /start-hbase.sh /healthcheck.sh && \
    sed -i 's/\r$//' /start-hbase.sh /healthcheck.sh && \
    dos2unix /start-hbase.sh /healthcheck.sh 2>/dev/null || true && \
    chmod +x /start-hbase.sh /healthcheck.sh

ENTRYPOINT []
CMD ["/bin/bash", "-c", "/start-hbase.sh"]
```

### Étape 4 : Créer le Dockerfile Hive

Créer `docker/hive/Dockerfile` :

```dockerfile
FROM eclipse-temurin:8-jdk

ENV HIVE_VERSION=3.1.3
ENV HIVE_HOME=/opt/hive
ENV JAVA_HOME=/opt/java/openjdk
ENV HADOOP_VERSION=3.3.4
ENV HADOOP_HOME=/opt/hadoop

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    postgresql-client \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Télécharger et installer Hive
RUN wget -q https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && tar -xzf apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && mv apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} \
    && rm apache-hive-${HIVE_VERSION}-bin.tar.gz

# Télécharger le driver JDBC PostgreSQL
RUN wget -q https://jdbc.postgresql.org/download/postgresql-42.2.24.jar -O ${HIVE_HOME}/lib/postgresql-jdbc.jar || \
    wget -q https://repo1.maven.org/maven2/org/postgresql/postgresql/42.2.24/postgresql-42.2.24.jar -O ${HIVE_HOME}/lib/postgresql-jdbc.jar

# Copier les fichiers de configuration
COPY hive-site.xml ${HIVE_HOME}/conf/
COPY hive-env.sh ${HIVE_HOME}/conf/
RUN chmod +x ${HIVE_HOME}/conf/hive-env.sh && \
    sed -i 's/\r$//' ${HIVE_HOME}/conf/hive-env.sh

# Installer Hadoop (nécessaire pour les commandes hadoop/hdfs)
RUN wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm hadoop-${HADOOP_VERSION}.tar.gz

# Créer le répertoire de configuration Hadoop
RUN mkdir -p ${HADOOP_HOME}/etc/hadoop

# Copier les fichiers de configuration Hadoop pour Hive
COPY core-site.xml ${HADOOP_HOME}/etc/hadoop/
COPY hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/

# Ajouter au PATH
ENV PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${HIVE_HOME}/bin:${JAVA_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Copier les scripts de démarrage
COPY start-hive-metastore.sh /start-hive-metastore.sh
COPY start-hive.sh /start-hive.sh
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /start-hive-metastore.sh /start-hive.sh /healthcheck.sh && \
    sed -i 's/\r$//' /start-hive-metastore.sh /start-hive.sh /healthcheck.sh

# Créer le répertoire de logs
RUN mkdir -p ${HIVE_HOME}/logs

# Exposer les ports
EXPOSE 9083 10000 10002

CMD ["/bin/bash"]
```

### Étape 5 : Créer les Fichiers de Configuration

Vous devez créer les fichiers de configuration XML et les scripts shell. Consultez le dépôt GitHub pour voir le contenu exact de ces fichiers :

- `docker/hadoop/core-site.xml`
- `docker/hadoop/hdfs-site.xml`
- `docker/hadoop/mapred-site.xml`
- `docker/hadoop/yarn-site.xml`
- `docker/hadoop/hadoop-env.sh`
- `docker/hadoop/start-hadoop.sh`
- `docker/hbase/hbase-site.xml`
- `docker/hbase/hbase-env.sh`
- `docker/hbase/start-hbase.sh`
- `docker/hbase/healthcheck.sh`
- `docker/hive/hive-site.xml`
- `docker/hive/hive-env.sh`
- `docker/hive/core-site.xml`
- `docker/hive/hdfs-site.xml`
- `docker/hive/start-hive.sh`
- `docker/hive/start-hive-metastore.sh`
- `docker/hive/healthcheck.sh`

### Étape 6 : Créer docker-compose.yml

Créer `docker-compose.yml` à la racine :

```yaml
services:
  hadoop:
    build:
      context: ./docker/hadoop
      dockerfile: Dockerfile
    container_name: hbase-hive-learning-lab-hadoop
    hostname: hadoop
    ports:
      - "9870:9870"
      - "8088:8088"
      - "9000:9000"
    environment:
      - HADOOP_HEAPSIZE=512
    volumes:
      - hadoop-data:/hadoop/dfs/name
      - hadoop-tmp:/tmp/hadoop
      - ./resources:/data/resources:ro
      - ./scripts:/opt/scripts:ro
    networks:
      - hbase-hive-network
    healthcheck:
      test: ["CMD-SHELL", "pgrep -f NameNode > /dev/null && pgrep -f DataNode > /dev/null && hdfs dfsadmin -report 2>&1 | grep -q 'Live datanodes' || exit 1"]
      interval: 30s
      timeout: 20s
      retries: 8
      start_period: 180s

  zookeeper:
    image: zookeeper:3.7
    container_name: hbase-hive-learning-lab-zookeeper
    hostname: zookeeper
    ports:
      - "2181:2181"
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=0.0.0.0:2888:3888;2181
    volumes:
      - zookeeper-data:/data
      - zookeeper-logs:/datalog
    networks:
      - hbase-hive-network
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "2181"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s

  hbase:
    build:
      context: ./docker/hbase
      dockerfile: Dockerfile
    container_name: hbase-hive-learning-lab-hbase
    hostname: hbase
    depends_on:
      hadoop:
        condition: service_healthy
      zookeeper:
        condition: service_healthy
    restart: unless-stopped
    ports:
      - "16011:16010"
      - "16020:16020"
      - "16030:16030"
    environment:
      - HBASE_HEAPSIZE=512
      - HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
      - HBASE_CONF_DIR=/opt/hbase/conf
    volumes:
      - hbase-data:/opt/hbase/data
      - ./resources:/data/resources:ro
    networks:
      - hbase-hive-network
    healthcheck:
      test: ["CMD", "/bin/bash", "/healthcheck.sh"]
      interval: 30s
      timeout: 20s
      retries: 12
      start_period: 180s

  hive-metastore:
    build:
      context: ./docker/hive
      dockerfile: Dockerfile
    container_name: hbase-hive-learning-lab-hive-metastore
    hostname: hive-metastore
    command: ["/bin/bash", "/start-hive-metastore.sh"]
    depends_on:
      hadoop:
        condition: service_healthy
    environment:
      - HIVE_HOME=/opt/hive
      - HADOOP_HOME=/opt/hadoop
      - SERVICE_NAME=metastore
      - DB_DRIVER=derby
      - JAVA_HOME=/opt/java/openjdk
    volumes:
      - hive-metastore-data:/opt/hive/metastore_db
      - hive-metastore-logs:/opt/hive/logs
    networks:
      - hbase-hive-network
    healthcheck:
      test: ["CMD", "/bin/bash", "/healthcheck.sh"]
      interval: 30s
      timeout: 15s
      retries: 8
      start_period: 120s

  hive:
    build:
      context: ./docker/hive
      dockerfile: Dockerfile
    container_name: hbase-hive-learning-lab-hive
    hostname: hive
    command: ["/bin/bash", "/start-hive.sh"]
    depends_on:
      hadoop:
        condition: service_healthy
      hbase:
        condition: service_healthy
      hive-metastore:
        condition: service_healthy
    ports:
      - "10000:10000"
      - "10002:10002"
    environment:
      - HIVE_HOME=/opt/hive
      - HADOOP_HOME=/opt/hadoop
      - HIVE_SITE_CONF_hive_metastore_uris=thrift://hive-metastore:9083
      - HIVE_SITE_CONF_hive_metastore_warehouse_dir=/user/hive/warehouse
      - HIVE_SITE_CONF_hive_exec_scratchdir=/tmp/hive
      - JAVA_HOME=/opt/java/openjdk
    volumes:
      - hive-data:/opt/hive/warehouse
      - ./resources:/data/resources:ro
      - ./scripts:/opt/scripts:ro
    networks:
      - hbase-hive-network
    healthcheck:
      test: ["CMD", "hive", "--version"]
      interval: 30s
      timeout: 15s
      retries: 5
      start_period: 90s

volumes:
  hadoop-data:
  hadoop-tmp:
  zookeeper-data:
  zookeeper-logs:
  hbase-data:
  hive-data:
  hive-metastore-data:
  hive-metastore-logs:

networks:
  hbase-hive-network:
    driver: bridge
```

### Étape 7 : Construire les Images Docker

Une fois tous les fichiers créés, construisez les images :

```bash
# Construire toutes les images
docker compose build

# Ou construire une image spécifique
docker compose build hadoop
docker compose build hbase
docker compose build hive
```

**Temps estimé** : 10-15 minutes pour la première construction (téléchargement des binaires Apache)

### Étape 8 : Lancer l'Environnement

```bash
# Lancer tous les services
docker compose up -d

# Voir les logs
docker compose logs -f

# Vérifier l'état
docker compose ps
```

---

## Commandes Utiles pour le Développement

### Reconstruire une Image Spécifique

```bash
# Reconstruire sans cache
docker compose build --no-cache hadoop

# Reconstruire et relancer
docker compose up -d --build hadoop
```

### Voir les Logs d'un Service

```bash
docker compose logs hadoop
docker compose logs hbase
docker compose logs hive
docker compose logs hive-metastore
```

### Accéder à un Conteneur

```bash
# Shell Hadoop
docker exec -it hbase-hive-learning-lab-hadoop bash

# Shell HBase
docker exec -it hbase-hive-learning-lab-hbase bash

# Shell Hive
docker exec -it hbase-hive-learning-lab-hive bash
```

### Arrêter et Nettoyer

```bash
# Arrêter les conteneurs
docker compose down

# Arrêter et supprimer les volumes (ATTENTION : perte de données)
docker compose down -v

# Nettoyer les images
docker system prune -a
```

---

## URLs de Téléchargement Direct

Si vous voulez télécharger manuellement les binaires (pour vérification ou usage hors Docker) :

- **Hadoop 3.3.4** : https://archive.apache.org/dist/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz
- **HBase 2.5.0** : https://archive.apache.org/dist/hbase/2.5.0/hbase-2.5.0-bin.tar.gz
- **Hive 3.1.3** : https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
- **PostgreSQL JDBC Driver** : https://jdbc.postgresql.org/download/postgresql-42.2.24.jar

---

## Notes Importantes

1. **Les téléchargements se font automatiquement** lors du build Docker - vous n'avez pas besoin de télécharger manuellement les binaires
2. **Les images de base** (`eclipse-temurin:8-jdk` et `zookeeper:3.7`) sont téléchargées automatiquement par Docker lors du premier build
3. **Le temps de build** dépend de votre connexion Internet (les binaires Apache font plusieurs centaines de MB)
4. **Les volumes Docker** sont créés automatiquement lors du premier `docker compose up`

---

## Vérification de la Création

Pour vérifier que tout a été créé correctement :

```bash
# Vérifier que les images sont construites
docker images | grep hbase-hive-learning-lab

# Vérifier que les conteneurs sont créés
docker compose ps

# Vérifier que les volumes sont créés
docker volume ls | grep hbase-hive-learning-lab
```

---

## Références

- **Archives Apache Hadoop** : https://archive.apache.org/dist/hadoop/common/
- **Archives Apache HBase** : https://archive.apache.org/dist/hbase/
- **Archives Apache Hive** : https://archive.apache.org/dist/hive/
- **Docker Documentation** : https://docs.docker.com/
- **Docker Compose Documentation** : https://docs.docker.com/compose/
