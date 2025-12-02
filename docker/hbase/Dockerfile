FROM openjdk:8-jdk

ENV HBASE_VERSION=2.5.0
ENV HBASE_HOME=/opt/hbase
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and install HBase
RUN wget -q https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
    && tar -xzf hbase-${HBASE_VERSION}-bin.tar.gz \
    && mv hbase-${HBASE_VERSION} ${HBASE_HOME} \
    && rm hbase-${HBASE_VERSION}-bin.tar.gz

# Copy configuration files
COPY hbase-site.xml ${HBASE_HOME}/conf/
COPY hbase-env.sh ${HBASE_HOME}/conf/

# Add HBase to PATH
ENV PATH=${HBASE_HOME}/bin:${PATH}

# Expose ports
EXPOSE 16010 16020 16030

# Start HBase
COPY start-hbase.sh /start-hbase.sh
RUN chmod +x /start-hbase.sh

CMD ["/start-hbase.sh"]

