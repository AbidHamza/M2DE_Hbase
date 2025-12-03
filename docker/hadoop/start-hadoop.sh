#!/bin/bash

# Source Hadoop environment (sets JAVA_HOME)
if [ -f "${HADOOP_HOME}/etc/hadoop/hadoop-env.sh" ]; then
    source ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
fi

# Verify JAVA_HOME is set and valid
if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
    echo "ERROR: JAVA_HOME is not set or invalid: $JAVA_HOME" >&2
    echo "ERROR: Hadoop services cannot start without Java." >&2
    exit 1
fi

# Ensure Java is in PATH
export PATH=${JAVA_HOME}/bin:${PATH}

# Display JAVA_HOME for confirmation
echo "JAVA_HOME is set to: $JAVA_HOME"

# Export JAVA_HOME to environment so SSH sessions inherit it
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo "export PATH=\${JAVA_HOME}/bin:\${PATH}" >> ~/.bashrc

# Start SSH
echo "Starting SSH service..."
service ssh start || echo "WARNING: SSH service may already be running"

# Wait a bit for SSH to be ready
sleep 2

# Start HDFS
echo "Starting HDFS..."
${HADOOP_HOME}/sbin/start-dfs.sh || {
    echo "WARNING: HDFS start command returned error, but continuing..."
    echo "HDFS services may still be starting in the background"
    sleep 5
}

# Wait for HDFS to be ready (up to 2 minutes)
echo "Waiting for HDFS to be ready..."
HDFS_READY=0
for i in {1..60}; do
    if ${HADOOP_HOME}/bin/hdfs dfsadmin -report 2>&1 | grep -q "Live datanodes"; then
        echo "HDFS is ready! (attempt $i/60)"
        HDFS_READY=1
        break
    fi
    if [ $((i % 10)) -eq 0 ]; then
        echo "Waiting for HDFS... (attempt $i/60)"
    fi
    sleep 2
done

if [ $HDFS_READY -eq 0 ]; then
    echo "WARNING: HDFS may not be fully ready, but continuing..."
fi

# Start YARN
echo "Starting YARN..."
${HADOOP_HOME}/sbin/start-yarn.sh || {
    echo "WARNING: YARN start command returned error, but continuing..."
    echo "YARN services may still be starting in the background"
    sleep 5
}

# Wait a bit for YARN to be ready
sleep 5

# Verify services are running
echo "Verifying services..."
if ${HADOOP_HOME}/bin/hdfs dfsadmin -report 2>&1 | grep -q "Live datanodes"; then
    echo "Hadoop services started successfully!"
else
    echo "WARNING: HDFS report check failed, but services may still be running..."
fi

# Keep container running
tail -f /dev/null

