@echo off
REM Script Batch pour vérifier l'état des services (Windows)
REM Usage: scripts\status.bat

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

echo État des services Docker:
!COMPOSE_CMD! ps

echo.
echo Interfaces Web disponibles:
echo   - HDFS NameNode: http://localhost:9870
echo   - YARN ResourceManager: http://localhost:8088
echo   - HBase Master: http://localhost:16011

