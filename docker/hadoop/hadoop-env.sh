#!/bin/bash
# Hadoop Environment Variables
# This file is sourced by Hadoop scripts to set environment variables

# Robust JAVA_HOME detection
# First, check if JAVA_HOME is already set and valid (from eclipse-temurin base image)
if [ -n "$JAVA_HOME" ] && [ -d "$JAVA_HOME" ] && [ -f "$JAVA_HOME/bin/java" ]; then
    # JAVA_HOME is already set and valid - use it
    export JAVA_HOME="$JAVA_HOME"
else
    # JAVA_HOME not set or invalid - try to detect Java automatically
    JAVA_DETECTED=0
    
    # Method 1: Check common eclipse-temurin paths (most common first)
    for JAVA_PATH in "/opt/java/openjdk" "/usr/lib/jvm/temurin-8-jdk-amd64" "/usr/lib/jvm/java-8-openjdk-amd64" "/usr/lib/jvm/default-java"; do
        if [ -d "$JAVA_PATH" ] && [ -f "$JAVA_PATH/bin/java" ]; then
            export JAVA_HOME="$JAVA_PATH"
            JAVA_DETECTED=1
            break
        fi
    done
    
    # Method 2: Use which/java if available (with proper error handling)
    if [ $JAVA_DETECTED -eq 0 ]; then
        JAVA_BIN=$(which java 2>/dev/null || echo "")
        if [ -n "$JAVA_BIN" ] && [ -f "$JAVA_BIN" ]; then
            # Extract JAVA_HOME from java binary path
            JAVA_DIR=$(dirname "$JAVA_BIN")
            JAVA_HOME_DIR=$(dirname "$JAVA_DIR")
            if [ -d "$JAVA_HOME_DIR" ] && [ -f "$JAVA_HOME_DIR/bin/java" ]; then
                export JAVA_HOME="$JAVA_HOME_DIR"
                JAVA_DETECTED=1
            else
                # Try readlink if available (but handle errors gracefully)
                if command -v readlink >/dev/null 2>&1; then
                    JAVA_REAL=$(readlink -f "$JAVA_BIN" 2>/dev/null || echo "$JAVA_BIN")
                    if [ -n "$JAVA_REAL" ] && [ "$JAVA_REAL" != "$JAVA_BIN" ] && [ -f "$JAVA_REAL" ]; then
                        JAVA_DIR=$(dirname "$JAVA_REAL")
                        JAVA_HOME_DIR=$(dirname "$JAVA_DIR")
                        if [ -d "$JAVA_HOME_DIR" ] && [ -f "$JAVA_HOME_DIR/bin/java" ]; then
                            export JAVA_HOME="$JAVA_HOME_DIR"
                            JAVA_DETECTED=1
                        fi
                    fi
                fi
            fi
        fi
    fi
    
    # Method 3: Search in /usr/lib/jvm
    if [ $JAVA_DETECTED -eq 0 ] && [ -d "/usr/lib/jvm" ]; then
        for JAVA_PATH in /usr/lib/jvm/*; do
            if [ -d "$JAVA_PATH" ] && [ -f "$JAVA_PATH/bin/java" ]; then
                export JAVA_HOME="$JAVA_PATH"
                JAVA_DETECTED=1
                break
            fi
        done
    fi
    
    # Verify JAVA_HOME was found
    if [ $JAVA_DETECTED -eq 0 ] || [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
        echo "ERROR: Cannot find Java installation" >&2
        echo "ERROR: JAVA_HOME is not set and could not be found." >&2
        echo "ERROR: Please ensure Java is installed in the container." >&2
        exit 1
    fi
fi

# Ensure JAVA_HOME is exported and absolute path
export JAVA_HOME

# Add Java to PATH
export PATH=${JAVA_HOME}/bin:${PATH}

# Hadoop Configuration Directory
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

# Hadoop Log Directory
export HADOOP_LOG_DIR=${HADOOP_HOME}/logs

# Hadoop PID Directory
export HADOOP_PID_DIR=${HADOOP_HOME}/pids

# Ensure directories exist
mkdir -p ${HADOOP_LOG_DIR} ${HADOOP_PID_DIR}

# Display JAVA_HOME for debugging
echo "JAVA_HOME is set to: $JAVA_HOME" >&2

