#!/bin/bash
# Detect JAVA_HOME dynamically if not set
if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ]; then
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
fi
export PATH=${JAVA_HOME}/bin:${PATH}

export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/hive
export HIVE_CONF_DIR=${HIVE_HOME}/conf
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

