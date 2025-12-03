@echo off
REM Script Batch pour ouvrir le shell HBase (Windows)
REM Usage: scripts\hbase-shell.bat

setlocal enabledelayedexpansion

REM Changer vers le répertoire du projet (peu importe où le projet est cloné)
set SCRIPT_DIR=%~dp0
cd /d "!SCRIPT_DIR!.."

REM Détecter docker-compose V1 ou V2
docker-compose --version >nul 2>&1
if not errorlevel 1 (
    set COMPOSE_CMD=docker-compose
) else (
    docker compose version >nul 2>&1
    if not errorlevel 1 (
        set COMPOSE_CMD=docker compose
    ) else (
        set COMPOSE_CMD=docker-compose
    )
)

echo Vérification du conteneur HBase...

REM Méthode robuste : essayer plusieurs façons de trouver le conteneur
set CONTAINER_ID=

REM Méthode 1 : docker compose ps -q
for /f "tokens=*" %%i in ('!COMPOSE_CMD! ps -q hbase 2^>nul') do set CONTAINER_ID=%%i

REM Méthode 2 : docker ps directement
if "!CONTAINER_ID!"=="" (
    for /f "tokens=*" %%i in ('docker ps --filter "name=hbase-hive-learning-lab-hbase" --format "{{.ID}}" 2^>nul') do set CONTAINER_ID=%%i
)

if "!CONTAINER_ID!"=="" (
    echo ERREUR: Le conteneur HBase n'est pas démarré.
    echo.
    echo Solutions:
    echo   1. Vérifiez l'état: !COMPOSE_CMD! ps
    echo   2. Démarrez l'environnement: !COMPOSE_CMD! up -d
    echo   3. OU utilisez le script start: scripts\start.bat
    echo.
    echo Attendez 2-3 minutes après le démarrage pour que HBase soit prêt.
    exit /b 1
)

echo Ouverture du shell HBase...
echo (Si vous voyez 'Server is not running yet', attendez 1-2 minutes)
echo.
docker exec -it !CONTAINER_ID! hbase shell

