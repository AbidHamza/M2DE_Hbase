#!/bin/bash

# Set JAVA_HOME if not already set
export JAVA_HOME=${JAVA_HOME:-/opt/java/openjdk}
export PATH=${JAVA_HOME}/bin:${PATH}

# Start SSH
service ssh start

# Start HDFS
${HADOOP_HOME}/sbin/start-dfs.sh

# Start YARN
${HADOOP_HOME}/sbin/start-yarn.sh

# Keep container running
tail -f /dev/null

