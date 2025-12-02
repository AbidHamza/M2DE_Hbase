#!/bin/bash

# Set JAVA_HOME dynamically
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=${JAVA_HOME}/bin:${PATH}

# Wait for Hadoop and ZooKeeper to be ready
echo "Waiting for Hadoop HDFS to be ready..."
until hdfs dfsadmin -report 2>/dev/null; do
    sleep 5
done

echo "Waiting for ZooKeeper to be ready..."
until nc -z zookeeper 2181; do
    sleep 5
done

# Create HBase directory in HDFS
hdfs dfs -mkdir -p /hbase

# Start HBase
${HBASE_HOME}/bin/start-hbase.sh

# Keep container running
tail -f /dev/null

