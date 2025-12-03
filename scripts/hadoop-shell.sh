#!/bin/bash
# Script Bash pour accéder au shell Hadoop (Linux/Mac)
# Usage: ./scripts/hadoop-shell.sh

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

echo "Vérification du conteneur Hadoop..."

# Méthode robuste : essayer plusieurs façons de trouver le conteneur
CONTAINER_NAME=""

# Méthode 1 : docker compose ps -q
CONTAINER_NAME=$($COMPOSE_CMD ps -q hadoop 2>/dev/null | head -n 1)

# Méthode 2 : docker ps directement
if [ -z "$CONTAINER_NAME" ]; then
    CONTAINER_NAME=$(docker ps --filter "name=hbase-hive-learning-lab-hadoop" --format "{{.ID}}" 2>/dev/null | head -n 1)
fi

if [ -z "$CONTAINER_NAME" ]; then
    echo "ERREUR: Le conteneur Hadoop n'est pas démarré."
    echo ""
    echo "Solutions:"
    echo "  1. Vérifiez l'état: $COMPOSE_CMD ps"
    echo "  2. Démarrez l'environnement: $COMPOSE_CMD up -d"
    echo "  3. OU utilisez le script start: ./scripts/start.sh"
    echo ""
    exit 1
fi

echo "Ouverture du shell Hadoop..."
echo ""
docker exec -it $CONTAINER_NAME bash

