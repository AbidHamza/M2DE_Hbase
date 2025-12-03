FROM eclipse-temurin:8-jdk

ENV HIVE_VERSION=3.1.3
ENV HIVE_HOME=/opt/hive
# JAVA_HOME is set by eclipse-temurin base image
# It will be detected dynamically in hive-env.sh if needed
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=${HIVE_HOME}/bin:${PATH}

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    postgresql-client \
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

# Create Hadoop configuration directory for Hive (Hive needs Hadoop config but not Hadoop binaries)
# Hive will use these configs to connect to Hadoop container via network
RUN mkdir -p /opt/hadoop/etc/hadoop

# Copy minimal Hadoop config files needed by Hive
# These point to the Hadoop container hostname 'hadoop'
COPY core-site.xml /opt/hadoop/etc/hadoop/
COPY hdfs-site.xml /opt/hadoop/etc/hadoop/

# Copy startup scripts
COPY start-hive-metastore.sh /start-hive-metastore.sh
COPY start-hive.sh /start-hive.sh
RUN chmod +x /start-hive-metastore.sh /start-hive.sh && \
    sed -i 's/\r$//' /start-hive-metastore.sh /start-hive.sh

# Initialize Hive schema (Derby) - set JAVA_HOME first
RUN JAVA_HOME=/opt/java/openjdk && \
    export JAVA_HOME && \
    ${HIVE_HOME}/bin/schematool -initSchema -dbType derby || true

# Expose ports
EXPOSE 10000 10002

# Default command
CMD ["/bin/bash"]

