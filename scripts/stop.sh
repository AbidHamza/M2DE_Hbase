#!/bin/bash
# Script Bash pour arrêter l'environnement (Linux/Mac)
# Usage: ./scripts/stop.sh

echo "Arrêt de l'environnement HBase & Hive..."
docker-compose down
echo "Environnement arrêté."

