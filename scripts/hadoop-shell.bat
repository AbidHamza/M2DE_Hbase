@echo off
REM Script Batch pour accéder au shell Hadoop (Windows)
REM Usage: scripts\hadoop-shell.bat

setlocal enabledelayedexpansion

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

echo Vérification du conteneur Hadoop...

REM Méthode robuste : essayer plusieurs façons de trouver le conteneur
set CONTAINER_ID=

REM Méthode 1 : docker compose ps -q
for /f "tokens=*" %%i in ('!COMPOSE_CMD! ps -q hadoop 2^>nul') do set CONTAINER_ID=%%i

REM Méthode 2 : docker ps directement
if "!CONTAINER_ID!"=="" (
    for /f "tokens=*" %%i in ('docker ps --filter "name=hbase-hive-learning-lab-hadoop" --format "{{.ID}}" 2^>nul') do set CONTAINER_ID=%%i
)

if "!CONTAINER_ID!"=="" (
    echo ERREUR: Le conteneur Hadoop n'est pas démarré.
    echo.
    echo Solutions:
    echo   1. Vérifiez l'état: !COMPOSE_CMD! ps
    echo   2. Démarrez l'environnement: !COMPOSE_CMD! up -d
    echo   3. OU utilisez le script start: scripts\start.bat
    echo.
    exit /b 1
)

echo Ouverture du shell Hadoop...
echo.
docker exec -it !CONTAINER_ID! bash

