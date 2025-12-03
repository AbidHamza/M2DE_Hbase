#!/bin/bash
# Script Bash pour arrêter l'environnement (Linux/Mac)
# Usage: ./scripts/stop.sh

# Détecter docker-compose V1 ou V2
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo "Arrêt de l'environnement HBase & Hive..."
$COMPOSE_CMD down
echo "Environnement arrêté."

