#!/bin/bash

# Set JAVA_HOME dynamically
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=${JAVA_HOME}/bin:${PATH}

# Wait for Hadoop HDFS to be ready (check via network connection)
echo "Waiting for Hadoop HDFS to be ready..."
HDFS_READY=0
for i in {1..60}; do
    if nc -z hadoop 9000 2>/dev/null; then
        echo "HDFS is ready!"
        HDFS_READY=1
        break
    fi
    if [ $((i % 5)) -eq 0 ]; then
        echo "Attempt $i/60: Waiting for HDFS..."
    fi
    sleep 2
done

if [ $HDFS_READY -eq 0 ]; then
    echo "WARNING: HDFS may not be ready, but continuing anyway..."
fi

# Wait for ZooKeeper to be ready
echo "Waiting for ZooKeeper to be ready..."
ZK_READY=0
for i in {1..60}; do
    if nc -z zookeeper 2181 2>/dev/null; then
        echo "ZooKeeper is ready!"
        ZK_READY=1
        break
    fi
    if [ $((i % 5)) -eq 0 ]; then
        echo "Attempt $i/60: Waiting for ZooKeeper..."
    fi
    sleep 2
done

if [ $ZK_READY -eq 0 ]; then
    echo "WARNING: ZooKeeper may not be ready, but continuing anyway..."
fi

# Create HBase directory in HDFS (will be created by HBase if it doesn't exist)
echo "HBase will create /hbase directory in HDFS if needed..."

# Start HBase
echo "Starting HBase..."
${HBASE_HOME}/bin/start-hbase.sh

# Keep container running
tail -f /dev/null

