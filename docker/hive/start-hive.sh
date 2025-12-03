#!/bin/bash
# Script to start Hive CLI/Server with proper environment setup

# Source hive-env.sh to set JAVA_HOME and HADOOP_HOME
if [ -f "${HIVE_HOME}/conf/hive-env.sh" ]; then
    source ${HIVE_HOME}/conf/hive-env.sh
fi

# Verify JAVA_HOME is set
if [ -z "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
    echo "ERROR: JAVA_HOME is not set or invalid: $JAVA_HOME" >&2
    exit 1
fi

# Verify HADOOP_CONF_DIR exists
if [ ! -d "$HADOOP_CONF_DIR" ]; then
    echo "ERROR: HADOOP_CONF_DIR does not exist: $HADOOP_CONF_DIR" >&2
    echo "ERROR: Hive cannot connect to Hadoop without configuration files" >&2
    exit 1
fi

# Keep container running (for interactive use)
tail -f /dev/null

