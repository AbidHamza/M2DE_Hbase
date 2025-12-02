#!/bin/bash

# Set JAVA_HOME - Try multiple possible locations
if [ -z "$JAVA_HOME" ]; then
    if [ -d "/usr/lib/jvm/temurin-8-jdk-amd64" ]; then
        export JAVA_HOME=/usr/lib/jvm/temurin-8-jdk-amd64
    elif [ -d "/opt/java/openjdk" ]; then
        export JAVA_HOME=/opt/java/openjdk
    else
        export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    fi
fi

export PATH=${JAVA_HOME}/bin:${PATH}

# Verify JAVA_HOME
echo "JAVA_HOME is set to: $JAVA_HOME"
if [ ! -f "$JAVA_HOME/bin/java" ]; then
    echo "ERROR: JAVA_HOME is incorrect: $JAVA_HOME"
    exit 1
fi

# Start SSH
service ssh start

# Start HDFS
${HADOOP_HOME}/sbin/start-dfs.sh

# Start YARN
${HADOOP_HOME}/sbin/start-yarn.sh

# Keep container running
tail -f /dev/null

