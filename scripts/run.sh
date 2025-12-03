#!/bin/bash
# Script principal pour lancer l'environnement (Linux/Mac)
# Intègre la vérification des prérequis et le lancement avec AUTO-RÉPARATION
# Usage: ./scripts/run.sh

set +u  # Ne pas arrêter si variable non définie (pour auto-réparation)
set -o pipefail  # Arrêter si une commande dans un pipe échoue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "=========================================="
echo "DÉMARRAGE DE L'ENVIRONNEMENT HBASE & HIVE"
echo "=========================================="
echo ""

ERRORS=0
WARNINGS=0
COMPOSE_CMD=""

# Fonction d'auto-réparation : Libérer les ports occupés
free_port() {
    local port=$1
    echo "  🔧 Tentative de libération du port $port..."
    
    # Linux/Mac: Trouver et arrêter le processus
    if command -v lsof &> /dev/null; then
        local pid=$(lsof -ti:$port 2>/dev/null)
        if [ -n "$pid" ]; then
            kill -9 "$pid" 2>/dev/null && echo "    → Processus $pid arrêté" || echo "    → Impossible d'arrêter le processus"
            sleep 2
            return 0
        fi
    fi
    
    # Alternative avec fuser (Linux)
    if command -v fuser &> /dev/null; then
        fuser -k $port/tcp 2>/dev/null && sleep 2 && return 0
    fi
    
    return 1
}

# Fonction d'auto-réparation : Démarrer Docker daemon
start_docker_daemon() {
    echo "  🔧 Tentative de démarrage du Docker daemon..."
    
    if command -v systemctl &> /dev/null; then
        if [ "$EUID" -eq 0 ]; then
            systemctl start docker 2>/dev/null && sleep 5 && return 0
        elif command -v sudo &> /dev/null; then
            sudo systemctl start docker 2>/dev/null && sleep 5 && return 0
        fi
    fi
    
    return 1
}

# Fonction d'auto-réparation : Récupérer les fichiers manquants
restore_missing_files() {
    echo "  🔧 Tentative de récupération des fichiers manquants..."
    if [ -d ".git" ]; then
        git pull origin main 2>/dev/null && return 0
    fi
    return 1
}

# 1. Vérifier Docker
echo "[1/9] Vérification Docker..."
if ! command -v docker &> /dev/null; then
    echo "  ❌ ERREUR: Docker n'est pas installé"
    echo "     → Installez Docker: https://www.docker.com/get-started"
    ERRORS=$((ERRORS + 1))
else
    DOCKER_VERSION=$(docker --version 2>&1)
    echo "  ✅ Docker installé: $DOCKER_VERSION"
fi
echo ""

# 2. Détecter docker-compose (V1 ou V2)
echo "[2/9] Détection Docker Compose..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    COMPOSE_VERSION=$(docker-compose --version 2>&1)
    echo "  ✅ Docker Compose V1 détecté: $COMPOSE_VERSION"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    COMPOSE_VERSION=$(docker compose version 2>&1)
    echo "  ✅ Docker Compose V2 détecté: $COMPOSE_VERSION"
else
    echo "  ❌ ERREUR: Docker Compose n'est pas installé"
    echo "     → Installez Docker Compose ou mettez à jour Docker Desktop"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 3. Vérifier Docker daemon (avec auto-réparation)
echo "[3/9] Vérification Docker daemon..."
if ! docker info &> /dev/null; then
    echo "  ⚠️  Docker daemon n'est pas en cours d'exécution"
    echo "     → AUTO-RÉPARATION: Tentative de démarrage..."
    if start_docker_daemon; then
        if docker info &> /dev/null; then
            echo "  ✅ Docker daemon démarré automatiquement"
        else
            echo "  ❌ ERREUR: Impossible de démarrer Docker daemon"
            echo "     → Sur Mac/Windows: Lancez Docker Desktop"
            echo "     → Sur Linux: sudo systemctl start docker"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "  ❌ ERREUR: Docker daemon n'est pas en cours d'exécution"
        echo "     → Sur Mac/Windows: Lancez Docker Desktop"
        echo "     → Sur Linux: sudo systemctl start docker"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "  ✅ Docker daemon fonctionne"
fi
echo ""

# 4. Vérifier répertoire et fichiers (avec auto-réparation)
echo "[4/9] Vérification fichiers Docker..."
if [ ! -f "docker-compose.yml" ]; then
    echo "  ⚠️  docker-compose.yml introuvable"
    echo "     → AUTO-RÉPARATION: Tentative de récupération..."
    if restore_missing_files; then
        if [ -f "docker-compose.yml" ]; then
            echo "  ✅ Fichiers récupérés avec succès"
        else
            echo "  ❌ ERREUR: docker-compose.yml toujours introuvable"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "  ❌ ERREUR: docker-compose.yml introuvable"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "  ✅ Fichiers Docker présents"
fi
echo ""

# 5. Vérifier et libérer les ports occupés (avec auto-réparation)
echo "[5/9] Vérification et libération des ports..."
PORT_CONFLICTS=0
for port in 9000 9870 16011 2181; do
    if lsof -Pi :$port -sTCP:LISTEN -t &> /dev/null 2>&1 || \
       netstat -an 2>/dev/null | grep -q ":$port.*LISTEN" 2>/dev/null; then
        PORT_CONFLICTS=$((PORT_CONFLICTS + 1))
        echo "  ⚠️  Port $port est occupé"
        echo "     → AUTO-RÉPARATION: Libération du port $port..."
        if free_port $port; then
            echo "  ✅ Port $port libéré"
        else
            echo "  ⚠️  Port $port toujours occupé (sera nettoyé par docker-compose down)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done
if [ $PORT_CONFLICTS -eq 0 ]; then
    echo "  ✅ Tous les ports sont disponibles"
fi
echo ""

# 6. Vérifier espace disque
echo "[6/9] Vérification espace disque..."
if command -v df &> /dev/null; then
    DISK_SPACE_RAW=$(df -BG . 2>/dev/null | tail -1 | awk '{print $4}' | sed 's/G//' || echo "0")
    # Validation: vérifier que c'est un nombre
    if [[ "$DISK_SPACE_RAW" =~ ^[0-9]+$ ]]; then
        DISK_SPACE=$DISK_SPACE_RAW
        if [ "$DISK_SPACE" -lt 5 ] 2>/dev/null; then
            echo "  ⚠️  AVERTISSEMENT: Moins de 5GB d'espace libre ($DISK_SPACE GB)"
            echo "     → AUTO-RÉPARATION: Nettoyage des images Docker inutilisées..."
            docker system prune -f 2>/dev/null
            WARNINGS=$((WARNINGS + 1))
        else
            echo "  ✅ Espace disque suffisant: $DISK_SPACE GB"
        fi
    else
        echo "  ⚠️  Impossible de vérifier l'espace disque (valeur invalide)"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "  ⚠️  Impossible de vérifier l'espace disque"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 7. Vérifier si l'environnement est déjà lancé
echo "[7/9] Vérification de l'état actuel..."
RUNNING_CONTAINERS=""
if [ -n "$COMPOSE_CMD" ]; then
    # Vérifier avec docker-compose ps
    RUNNING_CONTAINERS=$(eval "$COMPOSE_CMD ps --format json" 2>/dev/null | grep -o '"State":"running"' | wc -l || echo "0")
    if [ "$RUNNING_CONTAINERS" = "0" ]; then
        # Alternative: vérifier directement avec docker ps
        RUNNING_CONTAINERS=$(docker ps --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2>/dev/null | wc -l || echo "0")
    fi
else
    RUNNING_CONTAINERS=$(docker ps --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2>/dev/null | wc -l || echo "0")
fi

if [ "$RUNNING_CONTAINERS" -gt 0 ]; then
    echo "  ⚠️  Des conteneurs sont déjà en cours d'exécution:"
    docker ps --filter "name=hbase-hive-learning-lab" --format "  - {{.Names}} ({{.Status}})" 2>/dev/null || true
    echo ""
    echo "  → AUTO-RÉPARATION: Arrêt et nettoyage des conteneurs existants..."
    echo "     (Pour garder les conteneurs existants, utilisez: $COMPOSE_CMD ps)"
else
    echo "  ✅ Aucun conteneur en cours d'exécution"
fi
echo ""

# 8. Nettoyer les conteneurs existants (FORCÉ)
echo "[8/9] Nettoyage FORCÉ des conteneurs existants..."
# Arrêter TOUS les conteneurs du projet
docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.ID}}" 2>/dev/null | while read -r container_id; do
    [ -n "$container_id" ] && docker stop "$container_id" 2>/dev/null && docker rm -f "$container_id" 2>/dev/null
done

# Nettoyer avec docker-compose si disponible
if [ -n "$COMPOSE_CMD" ]; then
    eval "$COMPOSE_CMD down -v --remove-orphans" >/dev/null 2>&1 || true
fi

# Nettoyer les volumes orphelins
docker volume prune -f 2>/dev/null || true

sleep 3
echo "  ✅ Nettoyage complet terminé"
echo ""

# 9. Résumé des vérifications
echo "[9/11] Résumé des vérifications..."
if [ $ERRORS -gt 0 ]; then
    echo "  ❌ $ERRORS erreur(s) bloquante(s) détectée(s)"
    echo "     → Corrigez les erreurs ci-dessus avant de continuer"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "  ⚠️  $WARNINGS avertissement(s) - continuation automatique"
else
    echo "  ✅ Toutes les vérifications sont passées"
fi
echo ""

# Vérifier que COMPOSE_CMD est défini avant de continuer
if [ -z "$COMPOSE_CMD" ]; then
    echo "  ❌ ERREUR CRITIQUE: Docker Compose non détecté"
    echo "     → Le script ne peut pas continuer sans Docker Compose"
    exit 1
fi

# 10. Lancer docker compose avec retry automatique
echo "[10/10] Lancement des conteneurs Docker..."
echo "  (Cela peut prendre 3-5 minutes pour démarrer tous les services)"
echo ""

MAX_RETRIES=3
RETRY=0
SUCCESS=0

while [ $RETRY -lt $MAX_RETRIES ] && [ $SUCCESS -eq 0 ]; do
    if [ $RETRY -gt 0 ]; then
        echo "  🔄 Tentative $((RETRY + 1))/$MAX_RETRIES..."
        echo "     → Nettoyage avant retry..."
        eval "$COMPOSE_CMD down -v" >/dev/null 2>&1 || true
        sleep 5
    fi
    
    
    if eval "$COMPOSE_CMD up -d --build"; then
        SUCCESS=1
        echo ""
        echo "✅ Conteneurs démarrés avec succès"
        echo ""
        echo "Attente du démarrage complet des services (60 secondes)..."
        sleep 60
        
        echo ""
        echo "Vérification de l'état des services..."
        $COMPOSE_CMD ps
        
        echo ""
        echo "=========================================="
        echo "ENVIRONNEMENT DÉMARRÉ"
        echo "=========================================="
        echo ""
        echo "Pour accéder aux services:"
        echo "  - HBase Shell: ./scripts/hbase-shell.sh"
        echo "  - Hive CLI: ./scripts/hive-cli.sh"
        echo "  - Vérifier l'état: ./scripts/status.sh"
        echo ""
        echo "Interfaces Web:"
        echo "  - HDFS NameNode: http://localhost:9870"
        echo "  - YARN ResourceManager: http://localhost:8088"
        echo "  - HBase Master: http://localhost:16011"
        echo ""
        echo "Note: Les services peuvent prendre 2-3 minutes pour être complètement opérationnels."
        echo "      Si un conteneur est 'unhealthy', attendez encore 1-2 minutes."
        echo ""
    else
        RETRY=$((RETRY + 1))
        if [ $RETRY -lt $MAX_RETRIES ]; then
            echo "  ⚠️  Échec, nouvelle tentative dans 10 secondes..."
            sleep 10
        else
            echo ""
            echo "❌ ERREUR: Échec du démarrage après $MAX_RETRIES tentatives"
            echo ""
            echo "Pour diagnostiquer le problème:"
            echo "  $COMPOSE_CMD logs"
            echo "  $COMPOSE_CMD ps"
            echo ""
            exit 1
        fi
    fi
done
