#!/bin/bash
# Script Bash pour démarrer l'environnement (Linux/Mac)
# Usage: ./scripts/start.sh

echo "Démarrage de l'environnement HBase & Hive..."

# Exécuter la vérification complète AVANT de démarrer
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/check-before-start.sh"

if [ -f "$CHECK_SCRIPT" ]; then
    echo ""
    echo "⚠️  VÉRIFICATION PRÉ-LANCEMENT OBLIGATOIRE"
    echo "=========================================="
    bash "$CHECK_SCRIPT"
    CHECK_EXIT=$?
    
    if [ $CHECK_EXIT -ne 0 ]; then
        echo ""
        echo "❌ La vérification a échoué. Corrigez les erreurs avant de continuer."
        exit 1
    fi
    echo ""
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

