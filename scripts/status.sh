#!/bin/bash
# Script Bash pour vérifier l'état des services (Linux/Mac)
# Usage: ./scripts/status.sh

echo "État des services Docker:"
docker-compose ps

echo ""
echo "Interfaces Web disponibles:"
echo "  - HDFS NameNode: http://localhost:9870"
echo "  - YARN ResourceManager: http://localhost:8088"
echo "  - HBase Master: http://localhost:16011"

