FROM eclipse-temurin:8-jdk

ENV HBASE_VERSION=2.5.0
ENV HBASE_HOME=/opt/hbase
# JAVA_HOME will be detected dynamically in hbase-env.sh and start-hbase.sh

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    netcat-openbsd \
    dos2unix \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Download and install HBase
RUN wget -q https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
    && tar -xzf hbase-${HBASE_VERSION}-bin.tar.gz \
    && mv hbase-${HBASE_VERSION} ${HBASE_HOME} \
    && rm hbase-${HBASE_VERSION}-bin.tar.gz

# Copy configuration files
COPY hbase-site.xml ${HBASE_HOME}/conf/
COPY hbase-env.sh ${HBASE_HOME}/conf/

# Fix line endings and ensure hbase-env.sh is executable
RUN sed -i 's/\r$//' ${HBASE_HOME}/conf/hbase-env.sh && \
    dos2unix ${HBASE_HOME}/conf/hbase-env.sh 2>/dev/null || true && \
    chmod +x ${HBASE_HOME}/conf/hbase-env.sh

# Add HBase to PATH
ENV PATH=${HBASE_HOME}/bin:${PATH}

# Expose ports
EXPOSE 16010 16020 16030

# Start HBase
COPY start-hbase.sh /start-hbase.sh
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /start-hbase.sh /healthcheck.sh && \
    sed -i 's/\r$//' /start-hbase.sh /healthcheck.sh && \
    dos2unix /start-hbase.sh /healthcheck.sh 2>/dev/null || true && \
    chmod +x /start-hbase.sh /healthcheck.sh

ENTRYPOINT []
CMD ["/bin/bash", "-c", "/start-hbase.sh"]

