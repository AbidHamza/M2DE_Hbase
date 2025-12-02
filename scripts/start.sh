#!/bin/bash
# Script Bash pour démarrer l'environnement (Linux/Mac)
# Usage: ./scripts/start.sh

echo "Démarrage de l'environnement HBase & Hive..."

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "ERREUR: Docker n'est pas installé ou pas dans le PATH"
    echo "Téléchargez Docker depuis: https://www.docker.com/get-started"
    exit 1
fi

# Vérifier que docker-compose est disponible
if ! command -v docker-compose &> /dev/null; then
    echo "ERREUR: docker-compose n'est pas disponible"
    exit 1
fi

# Démarrer les services
echo "Lancement des conteneurs Docker..."
docker-compose up -d

# Attendre un peu que les services démarrent
echo "Attente du démarrage des services (30 secondes)..."
sleep 30

# Vérifier l'état
echo ""
echo "Vérification de l'état des services..."
docker-compose ps

echo ""
echo "Environnement démarré !"
echo "Pour accéder aux services:"
echo "  - HBase Shell: ./scripts/hbase-shell.sh"
echo "  - Hive CLI: ./scripts/hive-cli.sh"
echo "  - Vérifier l'état: ./scripts/status.sh"

