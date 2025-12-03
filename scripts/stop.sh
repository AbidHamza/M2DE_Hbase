#!/bin/bash
# Script pour arrêter l'environnement HBase & Hive (Linux/Mac)
# Usage: ./scripts/stop.sh

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

echo "Arrêt de l'environnement HBase & Hive..."

# Arrêter tous les conteneurs du projet
CONTAINERS=$(docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2>/dev/null)
if [ -n "$CONTAINERS" ]; then
    CONTAINER_COUNT=$(echo "$CONTAINERS" | wc -l)
    echo "Conteneurs trouvés: $CONTAINER_COUNT"
    echo "$CONTAINERS" | while read -r container; do
        [ -n "$container" ] && echo "  - Arrêt de $container..." && docker stop "$container" 2>/dev/null && docker rm -f "$container" 2>/dev/null
    done
fi

# Arrêter avec docker-compose si disponible
if [ -n "$COMPOSE_CMD" ]; then
    echo "Arrêt avec docker-compose..."
    eval "$COMPOSE_CMD down" 2>/dev/null || true
fi

echo ""
echo "Environnement arrêté."
echo ""
echo "Pour supprimer aussi les volumes (données):"
echo "  $COMPOSE_CMD down -v"
echo ""
