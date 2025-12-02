#!/bin/bash
# Script Bash pour ouvrir le CLI Hive (Linux/Mac)
# Usage: ./scripts/hive-cli.sh

echo "Vérification du conteneur Hive..."
CONTAINER_NAME=$(docker-compose ps -q hive)

if [ -z "$CONTAINER_NAME" ]; then
    echo "ERREUR: Le conteneur Hive n'est pas démarré."
    echo "Vérifiez l'état avec: docker-compose ps"
    echo "Démarrez avec: docker-compose up -d"
    exit 1
fi

echo "Ouverture du CLI Hive..."
docker exec -it $CONTAINER_NAME hive

