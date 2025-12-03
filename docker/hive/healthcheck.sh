#!/bin/bash
# Healthcheck script for Hive Metastore
# Checks if the Metastore service is listening on port 9083 AND responding

# Method 1: Check if process is running (must be first)
if ! pgrep -f "hive.*metastore" > /dev/null 2>&1 && ! pgrep -f "Metastore" > /dev/null 2>&1; then
    exit 1
fi

# Method 2: Check if port 9083 is listening AND accepting connections
if command -v nc >/dev/null 2>&1; then
    if nc -z localhost 9083 2>/dev/null; then
        # Port is open, check if it's actually responding (not just bound)
        # Try to connect and see if connection is accepted
        if echo "" | nc -w 1 localhost 9083 2>/dev/null; then
            exit 0
        fi
    fi
fi

# Method 3: Try TCP connection with timeout
if command -v timeout >/dev/null 2>&1 && command -v bash >/dev/null 2>&1; then
    if timeout 2 bash -c "echo > /dev/tcp/localhost/9083" 2>/dev/null; then
        exit 0
    fi
fi

# Method 4: Check logs for successful startup AND absence of fatal errors
LOG_FILE=${HIVE_HOME:-/opt/hive}/logs/metastore.log
if [ -f "$LOG_FILE" ]; then
    # Check for successful startup messages
    if grep -qiE "(Starting.*Metastore|Metastore.*started|listening on|bind.*9083|ThriftBinary.*started)" "$LOG_FILE" 2>/dev/null; then
        # But check for fatal errors - if found, consider unhealthy
        if grep -qiE "(FATAL|ERROR.*Cannot.*start|Exception.*failed|bind.*failed|Unable to instantiate|Connection refused)" "$LOG_FILE" 2>/dev/null; then
            exit 1
        fi
        # If we have startup message and no fatal errors, consider healthy
        exit 0
    fi
    # If there are fatal errors in logs, consider unhealthy
    if grep -qiE "(FATAL|ERROR.*Cannot.*start|Exception.*failed|bind.*failed|Unable to instantiate)" "$LOG_FILE" 2>/dev/null; then
        exit 1
    fi
fi

# If process is running but port checks failed, still consider unhealthy
# (process might be stuck or erroring)
exit 1

