#!/bin/bash
# Script Bash pour ouvrir le shell HBase (Linux/Mac)
# Usage: ./scripts/hbase-shell.sh

echo "Vérification du conteneur HBase..."
CONTAINER_NAME=$(docker-compose ps -q hbase)

if [ -z "$CONTAINER_NAME" ]; then
    echo "ERREUR: Le conteneur HBase n'est pas démarré."
    echo "Vérifiez l'état avec: docker-compose ps"
    echo "Démarrez avec: docker-compose up -d"
    exit 1
fi

echo "Ouverture du shell HBase..."
docker exec -it $CONTAINER_NAME hbase shell

