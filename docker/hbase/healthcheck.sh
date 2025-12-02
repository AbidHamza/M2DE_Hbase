#!/bin/bash
# Healthcheck script for HBase
# This script checks if HBase Master is running

# Set JAVA_HOME dynamically
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=${JAVA_HOME}/bin:${PATH}
export HBASE_HOME=/opt/hbase
export PATH=${HBASE_HOME}/bin:${PATH}

# Check if HBase Master process is running
if pgrep -f "hbase.*master" > /dev/null || pgrep -f "HMaster" > /dev/null; then
    # Also try to connect to HBase shell as a secondary check
    if command -v hbase >/dev/null 2>&1; then
        # Try a simple command (non-interactive)
        echo "version" | hbase shell -n 2>&1 | grep -q "HBase" && exit 0 || exit 1
    else
        # If hbase command not available, just check process
        exit 0
    fi
else
    exit 1
fi

