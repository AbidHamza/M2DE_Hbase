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

# Wait for HBase processes to start
echo "Waiting for HBase processes to start..."
MASTER_STARTED=0
for i in {1..60}; do
    if pgrep -f "hbase.*master" > /dev/null 2>&1 || pgrep -f "HMaster" > /dev/null 2>&1; then
        echo "HBase Master process is running!"
        MASTER_STARTED=1
        break
    fi
    if [ $((i % 10)) -eq 0 ]; then
        echo "Attempt $i/60: Waiting for HBase Master process..."
    fi
    sleep 2
done

if [ $MASTER_STARTED -eq 0 ]; then
    echo "WARNING: HBase Master process not found after 120 seconds"
fi

# Also check RegionServer
REGIONSERVER_STARTED=0
for i in {1..30}; do
    if pgrep -f "hbase.*regionserver" > /dev/null 2>&1 || pgrep -f "HRegionServer" > /dev/null 2>&1; then
        echo "HBase RegionServer process is running!"
        REGIONSERVER_STARTED=1
        break
    fi
    sleep 2
done

if [ $REGIONSERVER_STARTED -eq 0 ]; then
    echo "WARNING: HBase RegionServer process not found"
fi

# Wait for HBase Master to be fully ready (accepting RPC calls)
echo "Waiting for HBase Master to be ready (this may take 1-2 minutes)..."
MASTER_READY=0
for i in {1..120}; do
    # Try to connect to HBase Master via hbase shell command
    if ${HBASE_HOME}/bin/hbase shell -n <<< "status" 2>&1 | grep -q "active master\|1 active master" || \
       ${HBASE_HOME}/bin/hbase shell -n <<< "version" 2>&1 | grep -q "HBase\|version"; then
        echo "HBase Master is ready and accepting commands! (attempt $i/120)"
        MASTER_READY=1
        break
    fi
    
    # Alternative: check if Master Web UI is responding
    if curl -s http://localhost:16010/master-status 2>/dev/null | grep -q "HBase\|Master" || \
       curl -s http://localhost:16010/ 2>/dev/null | grep -q "HBase\|Master"; then
        echo "HBase Master Web UI is responding! (attempt $i/120)"
        MASTER_READY=1
        break
    fi
    
    if [ $((i % 15)) -eq 0 ]; then
        echo "Attempt $i/120: Waiting for HBase Master to be ready..."
        echo "  (Master process is running, but initialization may take time)"
    fi
    sleep 2
done

if [ $MASTER_READY -eq 1 ]; then
    echo "✅ HBase Master is fully operational!"
else
    echo "⚠️  WARNING: HBase Master may not be fully ready yet"
    echo "   The Master process is running, but it may need more time to initialize"
    echo "   You can try connecting in a few moments"
fi

# Keep container running
tail -f /dev/null

