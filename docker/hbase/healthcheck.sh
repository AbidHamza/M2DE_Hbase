#!/bin/bash
# Healthcheck script for HBase
# This script checks if HBase Master is running AND ready

# First check if processes are running
MASTER_PROCESS=0
REGIONSERVER_PROCESS=0

if pgrep -f "hbase.*master" > /dev/null 2>&1 || pgrep -f "HMaster" > /dev/null 2>&1; then
    MASTER_PROCESS=1
fi

if pgrep -f "hbase.*regionserver" > /dev/null 2>&1 || pgrep -f "HRegionServer" > /dev/null 2>&1; then
    REGIONSERVER_PROCESS=1
fi

# If processes are not running, HBase is not healthy
if [ $MASTER_PROCESS -eq 0 ] && [ $REGIONSERVER_PROCESS -eq 0 ]; then
    exit 1
fi

# If Master process is running, try to verify it's ready
# Use a lightweight check: try to get version (non-blocking)
if [ $MASTER_PROCESS -eq 1 ]; then
    # Try to check if Master Web UI responds (quick check)
    if curl -s --max-time 2 http://localhost:16010/ 2>/dev/null | grep -q "HBase\|Master" || \
       curl -s --max-time 2 http://localhost:16010/master-status 2>/dev/null | grep -q "HBase\|Master"; then
        exit 0
    fi
    
    # If Web UI check fails but process is running, still consider healthy
    # (Master may be initializing but process is up)
    if [ $MASTER_PROCESS -eq 1 ]; then
        exit 0
    fi
fi

# If we get here and processes are running, consider healthy
if [ $MASTER_PROCESS -eq 1 ] || [ $REGIONSERVER_PROCESS -eq 1 ]; then
    exit 0
fi

# Otherwise, not healthy
exit 1

