@echo off
REM Script de configuration et lancement automatique (Windows Batch)
REM Usage: scripts\setup.bat

setlocal enabledelayedexpansion

echo ==========================================
echo CONFIGURATION ET LANCEMENT AUTOMATIQUE
echo ==========================================
echo.

REM 1. Vérifier Docker
echo [1/4] Vérification Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo   ❌ Docker n'est pas installé
    echo      → Installation automatique non disponible
    echo      → Téléchargez Docker Desktop: https://www.docker.com/get-started
    echo      → Après installation, relancez ce script
    exit /b 1
) else (
    echo   ✅ Docker installé
)

REM 2. Vérifier Docker Desktop lancé
echo [2/4] Vérification Docker Desktop...
docker info >nul 2>&1
if errorlevel 1 (
    echo   ❌ Docker Desktop n'est pas lancé
    echo      → Lancement automatique...
    
    REM Essayer de lancer Docker Desktop
    if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" (
        start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
        echo      → Docker Desktop est en cours de lancement...
        echo      → Attendez 30-60 secondes puis relancez ce script
        exit /b 0
    ) else (
        echo      → Lancez Docker Desktop manuellement depuis le menu Démarrer
        exit /b 1
    )
) else (
    echo   ✅ Docker Desktop est lancé
)

REM 3. Vérifier Docker Compose
echo [3/4] Vérification Docker Compose...
docker-compose --version >nul 2>&1
if not errorlevel 1 (
    set COMPOSE_CMD=docker-compose
    echo   ✅ Docker Compose V1 détecté
) else (
    docker compose version >nul 2>&1
    if not errorlevel 1 (
        set COMPOSE_CMD=docker compose
        echo   ✅ Docker Compose V2 détecté
    ) else (
        echo   ❌ Docker Compose n'est pas installé
        echo      → Docker Compose est généralement inclus avec Docker Desktop
        echo      → Mettez à jour Docker Desktop
        exit /b 1
    )
)

REM 4. Vérifier Git (optionnel)
echo [4/4] Vérification Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo   ⚠️  Git n'est pas installé (optionnel)
    echo      → Recommandé pour mettre à jour le dépôt
    echo      → Téléchargez Git: https://git-scm.com/downloads
) else (
    echo   ✅ Git installé
)

echo.
echo ==========================================
echo TOUS LES PRÉREQUIS SONT OK
echo ==========================================
echo.

REM Vérifier si l'environnement est déjà lancé
echo Vérification de l'état actuel...
set RUNNING_COUNT=0
for /f "tokens=*" %%i in ('docker ps --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2^>nul') do (
    set /a RUNNING_COUNT+=1
    echo   - %%i
)

if !RUNNING_COUNT! gtr 0 (
    echo   ⚠️  Des conteneurs sont déjà en cours d'exécution
    echo   → Arrêt et nettoyage automatique...
) else (
    echo   ✅ Aucun conteneur en cours d'exécution
)
echo.

REM Nettoyage complet et reconstruction automatique
echo Nettoyage complet des conteneurs et volumes...
!COMPOSE_CMD! down -v >nul 2>&1
echo   ✅ Nettoyage terminé

echo.
echo Reconstruction des images Docker...
echo   (Cela peut prendre 5-10 minutes la première fois)
!COMPOSE_CMD! build --no-cache
if errorlevel 1 (
    echo.
    echo   ❌ ERREUR lors de la reconstruction des images
    echo      → Vérifiez les logs ci-dessus
    exit /b 1
)
echo.
echo   ✅ Images reconstruites avec succès

echo.
echo Lancement automatique de l'environnement...
echo.

if exist "scripts\run.bat" (
    call scripts\run.bat
) else (
    echo ❌ ERREUR: Script run.bat introuvable
    exit /b 1
)

