FROM eclipse-temurin:8-jdk

ENV HIVE_VERSION=3.1.3
ENV HIVE_HOME=/opt/hive
# JAVA_HOME is set by eclipse-temurin base image
# It will be detected dynamically in hive-env.sh if needed
ENV JAVA_HOME=/opt/java/openjdk
# PATH will be set after Hadoop installation to include all components

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    postgresql-client \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Download and install Hive
RUN wget -q https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && tar -xzf apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && mv apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} \
    && rm apache-hive-${HIVE_VERSION}-bin.tar.gz

# Download PostgreSQL JDBC driver
RUN wget -q https://jdbc.postgresql.org/download/postgresql-42.2.24.jar -O ${HIVE_HOME}/lib/postgresql-jdbc.jar || \
    wget -q https://repo1.maven.org/maven2/org/postgresql/postgresql/42.2.24/postgresql-42.2.24.jar -O ${HIVE_HOME}/lib/postgresql-jdbc.jar

# Copy configuration files
COPY hive-site.xml ${HIVE_HOME}/conf/
COPY hive-env.sh ${HIVE_HOME}/conf/
RUN chmod +x ${HIVE_HOME}/conf/hive-env.sh && \
    sed -i 's/\r$//' ${HIVE_HOME}/conf/hive-env.sh

# Install Hadoop binaries (Hive needs hadoop/hdfs commands)
ENV HADOOP_VERSION=3.3.4
ENV HADOOP_HOME=/opt/hadoop

# Download and install Hadoop (only binaries, not full installation)
RUN wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm hadoop-${HADOOP_VERSION}.tar.gz

# Create Hadoop configuration directory
RUN mkdir -p ${HADOOP_HOME}/etc/hadoop

# Copy minimal Hadoop config files needed by Hive
# These point to the Hadoop container hostname 'hadoop'
COPY core-site.xml ${HADOOP_HOME}/etc/hadoop/
COPY hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/

# Add Hadoop and Hive to PATH (order matters: Hadoop first, then Hive, then Java)
# This ensures hadoop/hdfs commands are found before hive commands
ENV PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${HIVE_HOME}/bin:${JAVA_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Copy startup scripts and healthcheck
COPY start-hive-metastore.sh /start-hive-metastore.sh
COPY start-hive.sh /start-hive.sh
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /start-hive-metastore.sh /start-hive.sh /healthcheck.sh && \
    sed -i 's/\r$//' /start-hive-metastore.sh /start-hive.sh /healthcheck.sh

# Initialize Hive schema (Derby) - set JAVA_HOME first
# Create metastore_db directory first
RUN mkdir -p ${HIVE_HOME}/metastore_db ${HIVE_HOME}/logs && \
    JAVA_HOME=/opt/java/openjdk && \
    export JAVA_HOME && \
    export HIVE_HOME=${HIVE_HOME} && \
    ${HIVE_HOME}/bin/schematool -initSchema -dbType derby || \
    (echo "WARNING: Schema initialization failed, will retry at runtime" && true)

# Expose ports (9083 for Metastore, 10000/10002 for HiveServer2)
EXPOSE 9083 10000 10002

# Default command
CMD ["/bin/bash"]

