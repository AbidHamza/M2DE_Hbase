#!/bin/bash
# Hadoop Environment Variables
# This file is sourced by Hadoop scripts to set environment variables

# Set JAVA_HOME dynamically - find where Java is actually installed
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

# Verify JAVA_HOME exists
if [ ! -d "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
    echo "ERROR: JAVA_HOME is incorrect: $JAVA_HOME" >&2
    echo "ERROR: Java not found at $JAVA_HOME/bin/java" >&2
    exit 1
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

