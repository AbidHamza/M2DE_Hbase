#!/bin/bash

# Set JAVA_HOME dynamically
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=${JAVA_HOME}/bin:${PATH}

# Wait for Hadoop HDFS to be ready (check via network connection)
echo "Waiting for Hadoop HDFS to be ready..."
for i in {1..30}; do
    if nc -z hadoop 9000 2>/dev/null; then
        echo "HDFS is ready!"
        break
    fi
    echo "Attempt $i/30: Waiting for HDFS..."
    sleep 2
done

# Wait for ZooKeeper to be ready
echo "Waiting for ZooKeeper to be ready..."
for i in {1..30}; do
    if nc -z zookeeper 2181 2>/dev/null; then
        echo "ZooKeeper is ready!"
        break
    fi
    echo "Attempt $i/30: Waiting for ZooKeeper..."
    sleep 2
done

# Create HBase directory in HDFS using Hadoop container
echo "Creating HBase directory in HDFS..."
docker exec hbase-hive-learning-lab-hadoop-1 hdfs dfs -mkdir -p /hbase 2>/dev/null || \
    echo "Note: HBase directory creation will be handled by HBase startup"

# Start HBase
echo "Starting HBase..."
${HBASE_HOME}/bin/start-hbase.sh

# Keep container running
tail -f /dev/null

