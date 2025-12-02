#!/bin/bash
# Script de vérification COMPLÈTE avant le lancement (Linux/Mac)
# Usage: ./scripts/check-before-start.sh

set -e  # Arrêter en cas d'erreur

ERRORS=0
WARNINGS=0

echo "=========================================="
echo "VÉRIFICATION COMPLÈTE AVANT DÉMARRAGE"
echo "=========================================="
echo ""

# 1. Vérifier Docker installé
echo "[1/15] Vérification Docker..."
if ! command -v docker &> /dev/null; then
    echo "  ❌ ERREUR: Docker n'est pas installé"
    echo "     → Installez Docker: https://www.docker.com/get-started"
    ERRORS=$((ERRORS + 1))
else
    DOCKER_VERSION=$(docker --version)
    echo "  ✅ Docker installé: $DOCKER_VERSION"
fi
echo ""

# 2. Vérifier docker-compose installé
echo "[2/15] Vérification docker-compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "  ❌ ERREUR: docker-compose n'est pas installé"
    ERRORS=$((ERRORS + 1))
else
    COMPOSE_VERSION=$(docker-compose --version)
    echo "  ✅ docker-compose installé: $COMPOSE_VERSION"
fi
echo ""

# 3. Vérifier Docker daemon en cours d'exécution
echo "[3/15] Vérification Docker daemon..."
if ! docker info &> /dev/null; then
    echo "  ❌ ERREUR: Docker daemon n'est pas en cours d'exécution"
    echo "     → Sur Mac/Windows: Lancez Docker Desktop"
    echo "     → Sur Linux: sudo systemctl start docker"
    ERRORS=$((ERRORS + 1))
else
    echo "  ✅ Docker daemon fonctionne"
fi
echo ""

# 4. Vérifier Git installé
echo "[4/15] Vérification Git..."
if ! command -v git &> /dev/null; then
    echo "  ⚠️  AVERTISSEMENT: Git n'est pas installé"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✅ Git installé"
fi
echo ""

# 5. Vérifier que nous sommes dans le bon répertoire
echo "[5/15] Vérification répertoire..."
if [ ! -f "docker-compose.yml" ]; then
    echo "  ❌ ERREUR: docker-compose.yml introuvable"
    echo "     → Assurez-vous d'être dans le répertoire M2DE_Hbase"
    ERRORS=$((ERRORS + 1))
else
    echo "  ✅ Répertoire correct"
fi
echo ""

# 6. Vérifier fichiers Docker essentiels
echo "[6/15] Vérification fichiers Docker..."
MISSING_FILES=0
for file in "docker/hadoop/Dockerfile" "docker/hbase/Dockerfile" "docker/hive/Dockerfile" \
            "docker/hadoop/start-hadoop.sh" "docker/hbase/start-hbase.sh" \
            "docker/hbase/hbase-site.xml" "docker/hbase/hbase-env.sh" \
            "docker/hive/hive-env.sh"; do
    if [ ! -f "$file" ]; then
        echo "  ❌ Fichier manquant: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done
if [ $MISSING_FILES -eq 0 ]; then
    echo "  ✅ Tous les fichiers Docker sont présents"
else
    echo "  ❌ ERREUR: $MISSING_FILES fichier(s) manquant(s)"
    echo "     → Faites: git pull origin main"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 7. Vérifier syntaxe docker-compose.yml
echo "[7/15] Vérification syntaxe docker-compose.yml..."
if docker-compose config &> /dev/null; then
    echo "  ✅ Syntaxe docker-compose.yml valide"
else
    echo "  ❌ ERREUR: Syntaxe docker-compose.yml invalide"
    echo "     → Faites: git pull origin main"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 8. Vérifier JAVA_HOME dans les fichiers Docker
echo "[8/15] Vérification JAVA_HOME dans Dockerfiles..."
JAVA_HOME_OK=1
for file in "docker/hadoop/Dockerfile" "docker/hbase/Dockerfile" "docker/hive/Dockerfile" \
            "docker/hbase/hbase-env.sh" "docker/hive/hive-env.sh"; do
    if [ -f "$file" ]; then
        if grep -q "JAVA_HOME" "$file"; then
            if grep -q "JAVA_HOME.*openjdk\|JAVA_HOME.*temurin\|JAVA_HOME.*\$(dirname" "$file"; then
                echo "  ✅ JAVA_HOME configuré dans $(basename $file)"
            else
                echo "  ⚠️  JAVA_HOME présent mais peut-être incorrect dans $(basename $file)"
                WARNINGS=$((WARNINGS + 1))
            fi
        else
            echo "  ⚠️  JAVA_HOME non trouvé dans $(basename $file)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done
echo ""

# 9. Vérifier ports disponibles
echo "[9/15] Vérification ports disponibles..."
PORTS=(9000 9870 16011 16020 16030 2181 9083 10000)
PORT_CONFLICTS=0
for port in "${PORTS[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t &> /dev/null || netstat -an 2>/dev/null | grep -q ":$port.*LISTEN"; then
        echo "  ⚠️  Port $port est déjà utilisé"
        PORT_CONFLICTS=$((PORT_CONFLICTS + 1))
        WARNINGS=$((WARNINGS + 1))
    fi
done
if [ $PORT_CONFLICTS -eq 0 ]; then
    echo "  ✅ Tous les ports sont disponibles"
else
    echo "  ⚠️  $PORT_CONFLICTS port(s) déjà utilisé(s) - peut causer des problèmes"
fi
echo ""

# 10. Vérifier conteneurs déjà en cours
echo "[10/15] Vérification conteneurs existants..."
EXISTING_CONTAINERS=$(docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2>/dev/null | wc -l | tr -d ' ')
if [ "$EXISTING_CONTAINERS" -gt 0 ]; then
    echo "  ⚠️  $EXISTING_CONTAINERS conteneur(s) existant(s)"
    echo "     → Pour nettoyer: docker-compose down"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✅ Aucun conteneur existant"
fi
echo ""

# 11. Vérifier espace disque
echo "[11/15] Vérification espace disque..."
DISK_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$DISK_SPACE" -lt 5 ]; then
    echo "  ⚠️  AVERTISSEMENT: Moins de 5GB d'espace libre"
    echo "     → Recommandé: au moins 10GB"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✅ Espace disque suffisant: ${DISK_SPACE}GB"
fi
echo ""

# 12. Vérifier Git à jour
echo "[12/15] Vérification Git à jour..."
if command -v git &> /dev/null && [ -d ".git" ]; then
    git fetch origin main &> /dev/null || true
    LOCAL=$(git rev-parse HEAD 2>/dev/null || echo "")
    REMOTE=$(git rev-parse origin/main 2>/dev/null || echo "")
    if [ -n "$LOCAL" ] && [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
        echo "  ⚠️  AVERTISSEMENT: Le dépôt n'est pas à jour"
        echo "     → Faites: git pull origin main"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "  ✅ Dépôt à jour"
    fi
else
    echo "  ⚠️  Impossible de vérifier (pas un dépôt Git ou Git non installé)"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 13. Vérifier permissions scripts
echo "[13/15] Vérification permissions scripts..."
if [ ! -x "scripts/start.sh" ]; then
    echo "  ⚠️  Scripts non exécutables, correction..."
    chmod +x scripts/*.sh 2>/dev/null || true
    echo "  ✅ Permissions corrigées"
else
    echo "  ✅ Permissions correctes"
fi
echo ""

# 14. Vérifier ressources système (mémoire)
echo "[14/15] Vérification mémoire..."
TOTAL_MEM=$(free -g 2>/dev/null | awk '/^Mem:/{print $2}' || echo "0")
if [ "$TOTAL_MEM" -lt 4 ] && [ "$TOTAL_MEM" -gt 0 ]; then
    echo "  ⚠️  AVERTISSEMENT: Moins de 4GB RAM disponible"
    echo "     → Recommandé: au moins 8GB"
    WARNINGS=$((WARNINGS + 1))
elif [ "$TOTAL_MEM" -eq 0 ]; then
    echo "  ⚠️  Impossible de vérifier la mémoire (commande non disponible)"
else
    echo "  ✅ Mémoire suffisante: ${TOTAL_MEM}GB"
fi
echo ""

# 15. Vérifier réseau Docker
echo "[15/15] Vérification réseau Docker..."
if docker network ls | grep -q "hbase-hive-network"; then
    echo "  ⚠️  Réseau Docker existant détecté"
    echo "     → Pour nettoyer: docker network prune -f"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✅ Réseau Docker prêt à être créé"
fi
echo ""

# Résumé
echo "=========================================="
echo "RÉSUMÉ DE LA VÉRIFICATION"
echo "=========================================="
echo "Erreurs bloquantes: $ERRORS"
echo "Avertissements: $WARNINGS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "❌ ERREURS BLOQUANTES DÉTECTÉES"
    echo "   Corrigez les erreurs ci-dessus avant de continuer."
    echo ""
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  AVERTISSEMENTS DÉTECTÉS"
    echo "   Vous pouvez continuer, mais certains problèmes peuvent survenir."
    echo ""
    read -p "Continuer quand même ? (o/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        echo "Arrêté par l'utilisateur."
        exit 1
    fi
else
    echo "✅ TOUTES LES VÉRIFICATIONS SONT PASSÉES"
    echo "   Vous pouvez lancer docker-compose up -d"
    echo ""
fi

exit 0

