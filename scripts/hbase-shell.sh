#!/bin/bash
# Script Bash pour ouvrir le shell HBase (Linux/Mac)
# Usage: ./scripts/hbase-shell.sh

# Détecter docker-compose V1 ou V2
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo "Vérification du conteneur HBase..."
CONTAINER_NAME=$($COMPOSE_CMD ps -q hbase)

if [ -z "$CONTAINER_NAME" ]; then
    echo "ERREUR: Le conteneur HBase n'est pas démarré."
    echo "Vérifiez l'état avec: $COMPOSE_CMD ps"
    echo "Démarrez avec: $COMPOSE_CMD up -d"
    exit 1
fi

echo "Ouverture du shell HBase..."
docker exec -it $CONTAINER_NAME hbase shell

