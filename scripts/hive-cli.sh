#!/bin/bash
# Script Bash pour ouvrir le CLI Hive (Linux/Mac)
# Usage: ./scripts/hive-cli.sh

# Détecter docker-compose V1 ou V2
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo "Vérification du conteneur Hive..."
CONTAINER_NAME=$($COMPOSE_CMD ps -q hive)

if [ -z "$CONTAINER_NAME" ]; then
    echo "ERREUR: Le conteneur Hive n'est pas démarré."
    echo "Vérifiez l'état avec: $COMPOSE_CMD ps"
    echo "Démarrez avec: $COMPOSE_CMD up -d"
    exit 1
fi

echo "Ouverture du CLI Hive..."
docker exec -it $CONTAINER_NAME hive

