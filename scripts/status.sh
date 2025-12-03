#!/bin/bash
# Script Bash pour vérifier l'état des services (Linux/Mac)
# Usage: ./scripts/status.sh

# Changer vers le répertoire du projet (peu importe où le projet est cloné)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

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

