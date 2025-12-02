#!/bin/bash

# Start SSH
service ssh start

# Start HDFS
${HADOOP_HOME}/sbin/start-dfs.sh

# Start YARN
${HADOOP_HOME}/sbin/start-yarn.sh

# Keep container running
tail -f /dev/null

