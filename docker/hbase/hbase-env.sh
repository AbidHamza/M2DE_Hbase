#!/bin/bash
# Detect JAVA_HOME dynamically if not set
if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ]; then
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
fi
export PATH=${JAVA_HOME}/bin:${PATH}

export HBASE_HEAPSIZE=512
export HBASE_OPTS="$HBASE_OPTS -XX:+UseConcMarkSweepGC"
export HBASE_MANAGES_ZK=false
