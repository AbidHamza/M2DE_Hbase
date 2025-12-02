#!/bin/bash
# Healthcheck script for HBase
# This script checks if HBase Master is running

# Check if HBase Master process is running (most reliable method)
if pgrep -f "hbase.*master" > /dev/null 2>&1 || pgrep -f "HMaster" > /dev/null 2>&1; then
    exit 0
fi

# Also check if RegionServer is running
if pgrep -f "hbase.*regionserver" > /dev/null 2>&1 || pgrep -f "HRegionServer" > /dev/null 2>&1; then
    exit 0
fi

# If no processes found, HBase is not running
exit 1

