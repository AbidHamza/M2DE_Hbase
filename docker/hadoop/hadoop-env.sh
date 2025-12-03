#!/bin/bash
# Hadoop Environment Variables
# This file is sourced by Hadoop scripts to set environment variables

# Set JAVA_HOME dynamically - find where Java is actually installed
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

# Verify JAVA_HOME exists
if [ ! -d "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
    echo "WARNING: JAVA_HOME is incorrect: $JAVA_HOME" >&2
    echo "WARNING: Java not found at $JAVA_HOME/bin/java" >&2
    echo "Attempting to detect Java automatically..." >&2
    # Try to find Java again
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    if [ ! -f "$JAVA_HOME/bin/java" ]; then
        echo "ERROR: Cannot find Java installation" >&2
        echo "Hadoop services may fail to start" >&2
    else
        echo "Java found at: $JAVA_HOME" >&2
    fi
fi

# Add Java to PATH
export PATH=${JAVA_HOME}/bin:${PATH}

# Hadoop Configuration Directory
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

# Hadoop Log Directory
export HADOOP_LOG_DIR=${HADOOP_HOME}/logs

# Hadoop PID Directory
export HADOOP_PID_DIR=${HADOOP_HOME}/pids

# Ensure directories exist
mkdir -p ${HADOOP_LOG_DIR} ${HADOOP_PID_DIR}

# Display JAVA_HOME for debugging
echo "JAVA_HOME is set to: $JAVA_HOME" >&2

