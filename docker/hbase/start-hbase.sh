#!/bin/bash

# Set JAVA_HOME dynamically
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=${JAVA_HOME}/bin:${PATH}

# Wait for Hadoop HDFS to be ready
echo "Waiting for Hadoop HDFS to be ready..."
HDFS_READY=0
for i in {1..60}; do
    # Try multiple methods to check if HDFS is ready
    if nc -z hadoop 9000 2>/dev/null && nc -z hadoop 9870 2>/dev/null; then
        # Additional check: try to connect via hdfs command if available
        if command -v hdfs >/dev/null 2>&1; then
            if hdfs dfsadmin -report 2>/dev/null | grep -q "Live datanodes"; then
                echo "HDFS is ready and operational!"
                HDFS_READY=1
                break
            fi
        else
            # If hdfs command not available, just check ports
            echo "HDFS ports are open, assuming ready..."
            HDFS_READY=1
            break
        fi
    fi
    if [ $((i % 10)) -eq 0 ]; then
        echo "Attempt $i/60: Waiting for HDFS (ports 9000 and 9870)..."
    fi
    sleep 2
done

if [ $HDFS_READY -eq 0 ]; then
    echo "WARNING: HDFS may not be fully ready, but continuing anyway..."
    echo "HBase will retry connection during startup..."
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

# Wait for HBase to fully start (give it more time)
echo "Waiting for HBase processes to start..."
for i in {1..30}; do
    if pgrep -f "hbase.*master" > /dev/null 2>&1 || pgrep -f "HMaster" > /dev/null 2>&1; then
        echo "HBase Master is running!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "WARNING: HBase Master process not found after 60 seconds, but continuing..."
    else
        sleep 2
    fi
done

# Also check RegionServer
if pgrep -f "hbase.*regionserver" > /dev/null 2>&1 || pgrep -f "HRegionServer" > /dev/null 2>&1; then
    echo "HBase RegionServer is running!"
else
    echo "WARNING: HBase RegionServer process not found, but continuing..."
fi

# Keep container running
tail -f /dev/null

