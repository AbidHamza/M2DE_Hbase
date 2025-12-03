#!/bin/bash
# Script to start Hive Metastore with proper environment setup

# Set HIVE_HOME first (before sourcing hive-env.sh)
export HIVE_HOME=${HIVE_HOME:-/opt/hive}

# Source hive-env.sh to set JAVA_HOME and HADOOP_HOME
if [ -f "${HIVE_HOME}/conf/hive-env.sh" ]; then
    source ${HIVE_HOME}/conf/hive-env.sh
fi

# Verify JAVA_HOME is set
if [ -z "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
    echo "ERROR: JAVA_HOME is not set or invalid: $JAVA_HOME" >&2
    exit 1
fi

# Verify HADOOP_HOME exists and has binaries
if [ ! -d "$HADOOP_HOME" ] || [ ! -f "$HADOOP_HOME/bin/hadoop" ]; then
    echo "ERROR: HADOOP_HOME does not exist or Hadoop binaries not found: $HADOOP_HOME" >&2
    echo "ERROR: Hive requires Hadoop binaries to function" >&2
    exit 1
fi

# Verify HADOOP_CONF_DIR exists
if [ ! -d "$HADOOP_CONF_DIR" ]; then
    echo "ERROR: HADOOP_CONF_DIR does not exist: $HADOOP_CONF_DIR" >&2
    echo "ERROR: Hive cannot connect to Hadoop without configuration files" >&2
    exit 1
fi

# Verify hadoop command is available
if ! command -v hadoop >/dev/null 2>&1; then
    echo "ERROR: 'hadoop' command not found in PATH" >&2
    echo "ERROR: PATH=$PATH" >&2
    exit 1
fi

echo "Starting Hive Metastore..."
echo "JAVA_HOME: $JAVA_HOME"
echo "HADOOP_HOME: $HADOOP_HOME"
echo "HADOOP_CONF_DIR: $HADOOP_CONF_DIR"
echo "HIVE_HOME: $HIVE_HOME"
echo "HIVE_CONF_DIR: $HIVE_CONF_DIR"
echo "PATH: $PATH"
echo "Hadoop version: $(hadoop version 2>&1 | head -1 || echo 'unknown')"

# Verify hive command exists
if [ ! -f "${HIVE_HOME}/bin/hive" ]; then
    echo "ERROR: Hive binary not found at ${HIVE_HOME}/bin/hive" >&2
    exit 1
fi

# Start Hive Metastore in background and wait for it to be ready
echo "Launching Hive Metastore service..."
${HIVE_HOME}/bin/hive --service metastore &
METASTORE_PID=$!

# Wait for Metastore to start listening on port 9083
echo "Waiting for Hive Metastore to be ready..."
MAX_WAIT=120
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    if nc -z localhost 9083 2>/dev/null || \
       (command -v timeout >/dev/null 2>&1 && timeout 1 bash -c "echo > /dev/tcp/localhost/9083" 2>/dev/null); then
        echo "Hive Metastore is ready and listening on port 9083"
        break
    fi
    
    # Check if process is still running
    if ! kill -0 $METASTORE_PID 2>/dev/null; then
        echo "ERROR: Hive Metastore process died unexpectedly" >&2
        wait $METASTORE_PID
        exit $?
    fi
    
    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 2))
done

if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
    echo "WARNING: Hive Metastore did not become ready within $MAX_WAIT seconds" >&2
    echo "But continuing anyway - healthcheck will verify..." >&2
fi

# Keep the process running
wait $METASTORE_PID
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Hive Metastore exited with code $EXIT_CODE" >&2
    exit $EXIT_CODE
fi

