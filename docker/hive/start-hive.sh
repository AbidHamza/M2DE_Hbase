#!/bin/bash
# Script to start Hive CLI/Server with proper environment setup

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

# Wait for Hive Metastore to be ready before allowing Hive CLI to be used
echo "Waiting for Hive Metastore to be ready..."
METASTORE_HOST="hive-metastore"
METASTORE_PORT=9083
MAX_WAIT=180
WAIT_COUNT=0
METASTORE_READY=0

while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    # Try to connect to Metastore
    if command -v nc >/dev/null 2>&1; then
        if nc -z "$METASTORE_HOST" "$METASTORE_PORT" 2>/dev/null; then
            echo "Hive Metastore is ready on $METASTORE_HOST:$METASTORE_PORT"
            METASTORE_READY=1
            break
        fi
    elif command -v timeout >/dev/null 2>&1 && command -v bash >/dev/null 2>&1; then
        if timeout 2 bash -c "echo > /dev/tcp/$METASTORE_HOST/$METASTORE_PORT" 2>/dev/null; then
            echo "Hive Metastore is ready on $METASTORE_HOST:$METASTORE_PORT"
            METASTORE_READY=1
            break
        fi
    else
        # Fallback: try to check if hostname resolves (DNS check)
        if command -v getent >/dev/null 2>&1; then
            if getent hosts "$METASTORE_HOST" >/dev/null 2>&1; then
                echo "Hive Metastore hostname resolves (assuming ready, but connection may fail)"
                METASTORE_READY=1
                break
            fi
        elif command -v nslookup >/dev/null 2>&1; then
            if nslookup "$METASTORE_HOST" >/dev/null 2>&1; then
                echo "Hive Metastore hostname resolves (assuming ready, but connection may fail)"
                METASTORE_READY=1
                break
            fi
        fi
    fi
    
    sleep 3
    WAIT_COUNT=$((WAIT_COUNT + 3))
    
    # Show progress every 15 seconds
    if [ $((WAIT_COUNT % 15)) -eq 0 ]; then
        echo "Still waiting for Hive Metastore... ($WAIT_COUNT/$MAX_WAIT seconds)"
    fi
done

if [ $METASTORE_READY -eq 0 ]; then
    echo "WARNING: Hive Metastore did not become ready within $MAX_WAIT seconds" >&2
    echo "Hive CLI may not work correctly until Metastore is ready" >&2
    echo "Check Metastore logs: docker compose logs hive-metastore" >&2
fi

echo "Hive CLI container is ready"
echo "You can now use: docker exec -it <container_name> hive"

# Keep container running (for interactive use)
tail -f /dev/null

