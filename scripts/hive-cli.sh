#!/bin/bash
# Script Bash pour ouvrir le CLI Hive (Linux/Mac)
# Usage: ./scripts/hive-cli.sh

echo "Ouverture du CLI Hive..."
docker exec -it hbase-hive-learning-lab-hive-1 hive

