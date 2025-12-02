FROM openjdk:8-jdk

ENV HIVE_VERSION=3.1.3
ENV HIVE_HOME=/opt/hive
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
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

# Initialize Hive schema (Derby)
RUN ${HIVE_HOME}/bin/schematool -initSchema -dbType derby || true

# Expose ports
EXPOSE 10000 10002

# Default command
CMD ["/bin/bash"]

