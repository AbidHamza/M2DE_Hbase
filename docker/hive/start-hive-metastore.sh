#!/bin/bash
# Script to start Hive Metastore with proper environment setup

# Set HIVE_HOME first (before sourcing hive-env.sh)
export HIVE_HOME=${HIVE_HOME:-/opt/hive}

# Source hive-env.sh to set JAVA_HOME and HADOOP_HOME
if [ -f "${HIVE_HOME}/conf/hive-env.sh" ]; then
    source ${HIVE_HOME}/conf/hive-env.sh
fi

# Gérer le répertoire metastore_db (peut exister mais être corrompu)
METASTORE_DB_DIR="/opt/hive/metastore_db"
if [ -d "$METASTORE_DB_DIR" ]; then
    # Vérifier si c'est une base Derby valide (doit contenir service.properties)
    if [ ! -f "$METASTORE_DB_DIR/service.properties" ]; then
        echo "WARNING: Répertoire metastore_db existe mais n'est pas une base Derby valide"
        echo "Nettoyage du répertoire corrompu..."
        rm -rf "$METASTORE_DB_DIR"/*
        rm -rf "$METASTORE_DB_DIR"/.??* 2>/dev/null || true
    fi
fi

# Créer le répertoire s'il n'existe pas
mkdir -p "$METASTORE_DB_DIR"

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

# Create log directory if it doesn't exist
mkdir -p ${HIVE_HOME}/logs

# Start Hive Metastore in background and capture output
echo "Launching Hive Metastore service..."
LOG_FILE=${HIVE_HOME}/logs/metastore.log
${HIVE_HOME}/bin/hive --service metastore > "$LOG_FILE" 2>&1 &
METASTORE_PID=$!

# Function to check if Metastore is truly ready (not just port open, but responding)
check_metastore_ready() {
    # Method 1: Check port is listening
    if ! nc -z localhost 9083 2>/dev/null && \
       ! (command -v timeout >/dev/null 2>&1 && timeout 1 bash -c "echo > /dev/tcp/localhost/9083" 2>/dev/null); then
        return 1
    fi
    
    # Method 2: Check process is running
    if ! kill -0 $METASTORE_PID 2>/dev/null; then
        return 1
    fi
    
    # Method 3: Check logs for successful startup (look for "Starting Hive Metastore Server" or similar)
    if [ -f "$LOG_FILE" ]; then
        if grep -qiE "(Starting.*Metastore|Metastore.*started|listening on|bind.*9083)" "$LOG_FILE" 2>/dev/null; then
            # Check for errors in logs
            if grep -qiE "(ERROR|FATAL|Exception.*failed|Cannot.*start)" "$LOG_FILE" 2>/dev/null; then
                return 1
            fi
            return 0
        fi
    fi
    
    return 1
}

# Wait for Metastore to be truly ready
echo "Waiting for Hive Metastore to be ready..."
MAX_WAIT=180
WAIT_COUNT=0
READY=0

while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    # Check if process died
    if ! kill -0 $METASTORE_PID 2>/dev/null; then
        echo "ERROR: Hive Metastore process died unexpectedly" >&2
        if [ -f "$LOG_FILE" ]; then
            echo "Last 50 lines of log:" >&2
            tail -50 "$LOG_FILE" >&2
        fi
        wait $METASTORE_PID 2>/dev/null
        exit 1
    fi
    
    # Check if ready
    if check_metastore_ready; then
        echo "Hive Metastore is ready and listening on port 9083"
        READY=1
        break
    fi
    
    sleep 3
    WAIT_COUNT=$((WAIT_COUNT + 3))
    
    # Show progress every 15 seconds
    if [ $((WAIT_COUNT % 15)) -eq 0 ]; then
        echo "Still waiting for Hive Metastore... ($WAIT_COUNT/$MAX_WAIT seconds)"
    fi
done

if [ $READY -eq 0 ]; then
    echo "ERROR: Hive Metastore did not become ready within $MAX_WAIT seconds" >&2
    if [ -f "$LOG_FILE" ]; then
        echo "Last 100 lines of log:" >&2
        tail -100 "$LOG_FILE" >&2
    fi
    kill $METASTORE_PID 2>/dev/null
    exit 1
fi

echo "Hive Metastore started successfully. PID: $METASTORE_PID"
echo "Logs available at: $LOG_FILE"

# Keep the process running and monitor it
while kill -0 $METASTORE_PID 2>/dev/null; do
    sleep 5
done

# Process exited, check exit code
wait $METASTORE_PID
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Hive Metastore exited with code $EXIT_CODE" >&2
    if [ -f "$LOG_FILE" ]; then
        echo "Last 100 lines of log:" >&2
        tail -100 "$LOG_FILE" >&2
    fi
    exit $EXIT_CODE
fi

