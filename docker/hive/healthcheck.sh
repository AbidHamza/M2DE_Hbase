#!/bin/bash
# Healthcheck script for Hive Metastore
# Checks if the Metastore service is listening on port 9083

# Method 1: Check if port 9083 is listening
if command -v nc >/dev/null 2>&1; then
    if nc -z localhost 9083 2>/dev/null; then
        exit 0
    fi
fi

# Method 2: Check if process is running
if pgrep -f "hive.*metastore" > /dev/null 2>&1 || pgrep -f "Metastore" > /dev/null 2>&1; then
    exit 0
fi

# Method 3: Try to connect with timeout
if command -v timeout >/dev/null 2>&1 && command -v bash >/dev/null 2>&1; then
    if timeout 2 bash -c "echo > /dev/tcp/localhost/9083" 2>/dev/null; then
        exit 0
    fi
fi

# If none of the checks pass, service is not healthy
exit 1

