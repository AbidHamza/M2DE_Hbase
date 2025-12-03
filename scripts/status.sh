#!/bin/bash
# Script Bash pour vérifier l'état des services (Linux/Mac)
# Usage: ./scripts/status.sh

# Détecter docker-compose V1 ou V2
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo "État des services Docker:"
$COMPOSE_CMD ps

echo ""
echo "Interfaces Web disponibles:"
echo "  - HDFS NameNode: http://localhost:9870"
echo "  - YARN ResourceManager: http://localhost:8088"
echo "  - HBase Master: http://localhost:16011"

