#!/bin/bash
# Script Bash pour ouvrir le shell HBase (Linux/Mac)
# Usage: ./scripts/hbase-shell.sh

echo "Ouverture du shell HBase..."
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell

