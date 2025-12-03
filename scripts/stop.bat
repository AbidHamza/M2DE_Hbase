@echo off
REM Script Batch pour arrêter l'environnement (Windows)
REM Usage: scripts\stop.bat

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

echo Arrêt de l'environnement HBase ^& Hive...
!COMPOSE_CMD! down
echo Environnement arrêté.

