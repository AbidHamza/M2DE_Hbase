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

# Méthode robuste : essayer plusieurs façons de trouver le conteneur
CONTAINER_NAME=""

# Méthode 1 : docker compose ps -q
CONTAINER_NAME=$($COMPOSE_CMD ps -q hbase 2>/dev/null | head -n 1)

# Méthode 2 : docker ps directement
if [ -z "$CONTAINER_NAME" ]; then
    CONTAINER_NAME=$(docker ps --filter "name=hbase-hive-learning-lab-hbase" --format "{{.ID}}" 2>/dev/null | head -n 1)
fi

if [ -z "$CONTAINER_NAME" ]; then
    echo "ERREUR: Le conteneur HBase n'est pas démarré."
    echo ""
    echo "Solutions:"
    echo "  1. Vérifiez l'état: $COMPOSE_CMD ps"
    echo "  2. Démarrez l'environnement: $COMPOSE_CMD up -d"
    echo "  3. OU utilisez le script setup: ./scripts/setup.sh"
    echo ""
    echo "Attendez 2-3 minutes après le démarrage pour que HBase soit prêt."
    exit 1
fi

echo "Ouverture du shell HBase..."
echo "(Si vous voyez 'Server is not running yet', attendez 1-2 minutes)"
echo ""
docker exec -it $CONTAINER_NAME hbase shell

