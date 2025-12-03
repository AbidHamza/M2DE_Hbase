#!/bin/bash
# Script unique pour lancer l'environnement HBase & Hive (Linux/Mac)
# Fusionne setup + run : vérifie, installe si possible, nettoie et lance
# Usage: ./scripts/start.sh

set +u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=========================================="
echo "LANCEMENT ENVIRONNEMENT HBASE & HIVE"
echo "=========================================="
echo ""

ERRORS=0
WARNINGS=0
COMPOSE_CMD=""
IS_ROOT=false
[ "$EUID" -eq 0 ] && IS_ROOT=true

# Fonction : Libérer les ports occupés
free_port() {
    local port=$1
    if command -v lsof &> /dev/null; then
        local pid=$(lsof -ti:$port 2>/dev/null)
        [ -n "$pid" ] && kill -9 "$pid" 2>/dev/null && sleep 2 && return 0
    fi
    if command -v fuser &> /dev/null; then
        fuser -k $port/tcp 2>/dev/null && sleep 2 && return 0
    fi
    return 1
}

# Fonction : Démarrer Docker daemon
start_docker_daemon() {
    if command -v systemctl &> /dev/null; then
        if [ "$IS_ROOT" = true ]; then
            systemctl start docker 2>/dev/null && sleep 5 && return 0
        elif command -v sudo &> /dev/null; then
            sudo systemctl start docker 2>/dev/null && sleep 5 && return 0
        fi
    fi
    return 1
}

# Fonction : Récupérer fichiers manquants
restore_missing_files() {
    [ -d ".git" ] && git pull origin main 2>/dev/null && return 0
    return 1
}

# ==========================================
# ÉTAPE 1 : Vérification Docker
# ==========================================
echo "[1/8] Vérification Docker..."
if ! command -v docker &> /dev/null; then
    echo "  [ERREUR] Docker n'est pas installé"
    echo "  -> Installation automatique..."
    
    if [ "$IS_ROOT" = true ] || command -v sudo &> /dev/null; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case $ID in
                ubuntu|debian)
                    if [ "$IS_ROOT" = true ]; then
                        apt-get update && apt-get install -y docker.io docker-compose
                    else
                        sudo apt-get update && sudo apt-get install -y docker.io docker-compose
                    fi
                    ;;
                centos|rhel|fedora)
                    if [ "$IS_ROOT" = true ]; then
                        yum install -y docker docker-compose
                        systemctl start docker && systemctl enable docker
                    else
                        sudo yum install -y docker docker-compose
                        sudo systemctl start docker && sudo systemctl enable docker
                    fi
                    ;;
                *)
                    echo "  -> Distribution non reconnue"
                    echo "  -> Installez Docker manuellement: https://www.docker.com/get-started"
                    exit 1
                    ;;
            esac
        else
            echo "  -> Impossible de détecter la distribution"
            echo "  -> Installez Docker manuellement: https://www.docker.com/get-started"
            exit 1
        fi
    else
        echo "  -> Installation automatique non disponible (besoin de sudo)"
        echo "  -> Installez Docker manuellement: https://www.docker.com/get-started"
        exit 1
    fi
fi

DOCKER_VERSION=$(docker --version 2>&1)
echo "  [OK] Docker installé: $DOCKER_VERSION"
echo ""

# ==========================================
# ÉTAPE 2 : Détection Docker Compose
# ==========================================
echo "[2/8] Détection Docker Compose..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    COMPOSE_VERSION=$(docker-compose --version 2>&1)
    echo "  [OK] Docker Compose V1 détecté"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    COMPOSE_VERSION=$(docker compose version 2>&1)
    echo "  [OK] Docker Compose V2 détecté"
else
    echo "  [ERREUR] Docker Compose n'est pas installé"
    echo "  -> Installation automatique..."
    
    if [ "$IS_ROOT" = true ] || command -v sudo &> /dev/null; then
        if command -v curl &> /dev/null; then
            DOCKER_COMPOSE_VERSION="2.24.0"
            if [ "$IS_ROOT" = true ]; then
                curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
            else
                sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose
            fi
            COMPOSE_CMD="docker-compose"
            echo "  [OK] Docker Compose installé"
        else
            echo "  -> curl n'est pas installé"
            exit 1
        fi
    else
        echo "  -> Installation automatique non disponible"
        exit 1
    fi
fi
echo ""

# ==========================================
# ÉTAPE 3 : Vérification Docker daemon
# ==========================================
echo "[3/8] Vérification Docker daemon..."
if ! docker info &> /dev/null; then
    echo "  [INFO] Docker daemon n'est pas en cours d'exécution"
    echo "  [INFO] Tentative de démarrage..."
    if start_docker_daemon; then
        if docker info &> /dev/null; then
            echo "  [OK] Docker daemon démarré"
        else
            echo "  [ERREUR] Impossible de démarrer Docker daemon"
            echo "  -> Sur Mac/Windows: Lancez Docker Desktop"
            echo "  -> Sur Linux: sudo systemctl start docker"
            exit 1
        fi
    else
        echo "  [ERREUR] Docker daemon non accessible"
        echo "  -> Sur Mac/Windows: Lancez Docker Desktop"
        echo "  -> Sur Linux: sudo systemctl start docker"
        exit 1
    fi
else
    echo "  [OK] Docker daemon fonctionne"
fi
echo ""

# ==========================================
# ÉTAPE 4 : Vérification fichiers
# ==========================================
echo "[4/8] Vérification fichiers..."
if [ ! -f "docker-compose.yml" ]; then
    echo "  [INFO] docker-compose.yml introuvable"
    echo "  [INFO] Tentative de récupération..."
    if restore_missing_files; then
        if [ -f "docker-compose.yml" ]; then
            echo "  [OK] Fichiers récupérés"
        else
            echo "  [ERREUR] docker-compose.yml toujours introuvable"
            exit 1
        fi
    else
        echo "  [ERREUR] docker-compose.yml introuvable"
        exit 1
    fi
else
    echo "  [OK] Fichiers présents"
fi
echo ""

# ==========================================
# ÉTAPE 5 : Nettoyage conteneurs existants
# ==========================================
echo "[5/8] Nettoyage conteneurs existants..."
RUNNING_COUNT=$(docker ps --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2>/dev/null | wc -l || echo "0")
if [ "$RUNNING_COUNT" -gt 0 ]; then
    echo "  [INFO] Arrêt des conteneurs existants..."
    docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.ID}}" 2>/dev/null | while read -r container_id; do
        [ -n "$container_id" ] && docker stop "$container_id" 2>/dev/null && docker rm -f "$container_id" 2>/dev/null
    done
fi

if [ -n "$COMPOSE_CMD" ]; then
    eval "$COMPOSE_CMD down -v --remove-orphans" >/dev/null 2>&1 || true
fi

docker volume prune -f 2>/dev/null || true
echo "  [OK] Nettoyage terminé"
echo ""

# ==========================================
# ÉTAPE 6 : Libération ports occupés
# ==========================================
echo "[6/8] Vérification ports..."
PORT_CONFLICTS=0
for port in 9000 9870 16011 2181; do
    if lsof -Pi :$port -sTCP:LISTEN -t &> /dev/null 2>&1 || \
       netstat -an 2>/dev/null | grep -q ":$port.*LISTEN" 2>/dev/null; then
        PORT_CONFLICTS=$((PORT_CONFLICTS + 1))
        echo "  [INFO] Port $port occupé, libération..."
        free_port $port || true
    fi
done
if [ $PORT_CONFLICTS -eq 0 ]; then
    echo "  [OK] Tous les ports sont disponibles"
else
    echo "  [OK] Ports libérés"
fi
echo ""

# ==========================================
# ÉTAPE 7 : Vérification espace disque
# ==========================================
echo "[7/8] Vérification espace disque..."
if command -v df &> /dev/null; then
    DISK_SPACE_RAW=$(df -BG . 2>/dev/null | tail -1 | awk '{print $4}' | sed 's/G//' || echo "0")
    if [[ "$DISK_SPACE_RAW" =~ ^[0-9]+$ ]]; then
        DISK_SPACE=$DISK_SPACE_RAW
        if [ "$DISK_SPACE" -lt 5 ] 2>/dev/null; then
            echo "  [ATTENTION] Moins de 5GB libres ($DISK_SPACE GB)"
            echo "  [INFO] Nettoyage Docker..."
            docker system prune -f 2>/dev/null || true
            WARNINGS=$((WARNINGS + 1))
        else
            echo "  [OK] Espace suffisant: $DISK_SPACE GB"
        fi
    else
        echo "  [INFO] Vérification espace impossible"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "  [INFO] Vérification espace impossible"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# ==========================================
# ÉTAPE 8 : Vérification finale Docker
# ==========================================
echo "[8/8] Vérification finale Docker..."
DOCKER_READY=0
for i in {1..10}; do
    if docker info &> /dev/null 2>&1; then
        DOCKER_READY=1
        echo "  [OK] Docker daemon accessible"
        break
    fi
    [ $i -lt 10 ] && sleep 2
done

if [ $DOCKER_READY -eq 0 ]; then
    echo "  [ERREUR] Docker daemon non accessible"
    echo "  -> Attendez que Docker Desktop soit complètement démarré"
    exit 1
fi
echo ""

# ==========================================
# LANCEMENT DES CONTENEURS
# ==========================================
echo "=========================================="
echo "LANCEMENT DES CONTENEURS"
echo "=========================================="
echo ""
echo "Cela peut prendre 3-5 minutes..."
echo ""

MAX_RETRIES=3
RETRY=0
SUCCESS=0

while [ $RETRY -lt $MAX_RETRIES ] && [ $SUCCESS -eq 0 ]; do
    if [ $RETRY -gt 0 ]; then
        echo "[RETRY $RETRY/$MAX_RETRIES] Nouvelle tentative..."
        eval "$COMPOSE_CMD down -v" >/dev/null 2>&1 || true
        sleep 5
    fi
    
    if eval "$COMPOSE_CMD up -d --build"; then
        SUCCESS=1
    else
        RETRY=$((RETRY + 1))
        if [ $RETRY -lt $MAX_RETRIES ]; then
            echo "[INFO] Échec, nouvelle tentative dans 10 secondes..."
            sleep 10
        fi
    fi
done

if [ $SUCCESS -eq 0 ]; then
    echo ""
    echo "[ERREUR] Échec après $MAX_RETRIES tentatives"
    echo ""
    echo "Pour diagnostiquer:"
    echo "  $COMPOSE_CMD logs"
    echo "  $COMPOSE_CMD ps"
    echo ""
    exit 1
fi

echo ""
echo "[OK] Conteneurs démarrés"
echo ""
echo "Attente du démarrage complet (60 secondes)..."
sleep 60

echo ""
echo "Vérification de l'état..."
$COMPOSE_CMD ps

echo ""
echo "=========================================="
echo "ENVIRONNEMENT DÉMARRÉ"
echo "=========================================="
echo ""
echo "Accès aux services:"
echo "  - HBase Shell: ./scripts/hbase-shell.sh"
echo "  - Hive CLI: ./scripts/hive-cli.sh"
echo "  - État: ./scripts/status.sh"
echo ""
echo "Interfaces Web:"
echo "  - HDFS: http://localhost:9870"
echo "  - YARN: http://localhost:8088"
echo "  - HBase: http://localhost:16011"
echo ""
echo "Note: Les services peuvent prendre 2-3 minutes pour être opérationnels."
echo "      Si un conteneur est 'unhealthy', attendez encore 1-2 minutes."
echo ""

