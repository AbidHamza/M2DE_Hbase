#!/bin/bash
# Script de configuration et lancement automatique (Linux/Mac)
# Installe les dépendances manquantes et lance l'environnement
# Usage: ./scripts/setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "=========================================="
echo "CONFIGURATION ET LANCEMENT AUTOMATIQUE"
echo "=========================================="
echo ""

# Vérifier si on est root (pour installation)
IS_ROOT=false
if [ "$EUID" -eq 0 ]; then
    IS_ROOT=true
fi

# 1. Vérifier Docker
echo "[1/4] Vérification Docker..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo "  ✅ Docker installé: $DOCKER_VERSION"
else
    echo "  ❌ Docker n'est pas installé"
    echo "     → Tentative d'installation automatique..."
    
    if [ "$IS_ROOT" = true ] || command -v sudo &> /dev/null; then
        # Détecter la distribution
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case $ID in
                ubuntu|debian)
                    echo "     → Installation Docker pour Ubuntu/Debian..."
                    if [ "$IS_ROOT" = true ]; then
                        apt-get update
                        apt-get install -y docker.io docker-compose
                    else
                        sudo apt-get update
                        sudo apt-get install -y docker.io docker-compose
                    fi
                    ;;
                centos|rhel|fedora)
                    echo "     → Installation Docker pour CentOS/RHEL/Fedora..."
                    if [ "$IS_ROOT" = true ]; then
                        yum install -y docker docker-compose
                        systemctl start docker
                        systemctl enable docker
                    else
                        sudo yum install -y docker docker-compose
                        sudo systemctl start docker
                        sudo systemctl enable docker
                    fi
                    ;;
                *)
                    echo "     → Distribution non reconnue, installation manuelle requise"
                    echo "     → Voir: https://www.docker.com/get-started"
                    exit 1
                    ;;
            esac
        else
            echo "     → Impossible de détecter la distribution"
            echo "     → Installation manuelle requise: https://www.docker.com/get-started"
            exit 1
        fi
    else
        echo "     → Installation automatique non disponible (besoin de sudo)"
        echo "     → Installez Docker manuellement: https://www.docker.com/get-started"
        exit 1
    fi
fi

# 2. Vérifier Docker daemon
echo "[2/4] Vérification Docker daemon..."
if docker info &> /dev/null; then
    echo "  ✅ Docker daemon fonctionne"
else
    echo "  ❌ Docker daemon n'est pas en cours d'exécution"
    echo "     → Démarrage automatique..."
    
    if [ "$IS_ROOT" = true ]; then
        systemctl start docker
    elif command -v sudo &> /dev/null; then
        sudo systemctl start docker
    else
        echo "     → Démarrez Docker manuellement: sudo systemctl start docker"
        exit 1
    fi
    
    # Attendre que Docker démarre
    sleep 3
    if docker info &> /dev/null; then
        echo "  ✅ Docker daemon démarré"
    else
        echo "  ❌ Impossible de démarrer Docker daemon"
        exit 1
    fi
fi

# 3. Vérifier Docker Compose
echo "[3/4] Vérification Docker Compose..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    COMPOSE_VERSION=$(docker-compose --version)
    echo "  ✅ Docker Compose V1 détecté: $COMPOSE_VERSION"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    COMPOSE_VERSION=$(docker compose version)
    echo "  ✅ Docker Compose V2 détecté: $COMPOSE_VERSION"
else
    echo "  ❌ Docker Compose n'est pas installé"
    echo "     → Installation automatique..."
    
    if [ "$IS_ROOT" = true ] || command -v sudo &> /dev/null; then
        if command -v curl &> /dev/null; then
            echo "     → Installation docker-compose..."
            DOCKER_COMPOSE_VERSION="2.24.0"
            if [ "$IS_ROOT" = true ]; then
                curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
            else
                sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose
            fi
            COMPOSE_CMD="docker-compose"
            echo "  ✅ Docker Compose installé"
        else
            echo "     → curl n'est pas installé, installation manuelle requise"
            exit 1
        fi
    else
        echo "     → Installation automatique non disponible (besoin de sudo)"
        echo "     → Installez Docker Compose manuellement"
        exit 1
    fi
fi

# 4. Vérifier Git (optionnel)
echo "[4/4] Vérification Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo "  ✅ Git installé: $GIT_VERSION"
else
    echo "  ⚠️  Git n'est pas installé (optionnel)"
    echo "     → Recommandé pour mettre à jour le dépôt"
    if [ "$IS_ROOT" = true ] || command -v sudo &> /dev/null; then
        echo "     → Installation automatique..."
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case $ID in
                ubuntu|debian)
                    if [ "$IS_ROOT" = true ]; then
                        apt-get install -y git
                    else
                        sudo apt-get install -y git
                    fi
                    ;;
                centos|rhel|fedora)
                    if [ "$IS_ROOT" = true ]; then
                        yum install -y git
                    else
                        sudo yum install -y git
                    fi
                    ;;
            esac
            echo "  ✅ Git installé"
        fi
    else
        echo "     → Installation manuelle: https://git-scm.com/downloads"
    fi
fi

echo ""
echo "=========================================="
echo "TOUS LES PRÉREQUIS SONT OK"
echo "=========================================="
echo ""

# Nettoyage complet et reconstruction automatique
echo "Nettoyage complet des conteneurs et volumes..."
eval "$COMPOSE_CMD down -v" >/dev/null 2>&1
echo "  ✅ Nettoyage terminé"

echo ""
echo "Reconstruction des images Docker..."
echo "  (Cela peut prendre 5-10 minutes la première fois)"
if eval "$COMPOSE_CMD build --no-cache"; then
    echo ""
    echo "  ✅ Images reconstruites avec succès"
else
    echo ""
    echo "  ❌ ERREUR lors de la reconstruction des images"
    echo "     → Vérifiez les logs ci-dessus"
    exit 1
fi

echo ""
echo "Lancement automatique de l'environnement..."
echo ""

RUN_SCRIPT="$SCRIPT_DIR/run.sh"
if [ -f "$RUN_SCRIPT" ]; then
    bash "$RUN_SCRIPT"
else
    echo "❌ ERREUR: Script run.sh introuvable"
    exit 1
fi

