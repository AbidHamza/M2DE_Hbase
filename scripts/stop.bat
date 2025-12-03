@echo off
REM Script pour arrêter l'environnement HBase & Hive (Windows Batch)
REM Usage: scripts\stop.bat

setlocal enabledelayedexpansion

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

echo Arrêt de l'environnement HBase ^& Hive...

REM Arrêter tous les conteneurs du projet
set CONTAINER_COUNT=0
for /f "tokens=*" %%i in ('docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2^>nul') do (
    set /a CONTAINER_COUNT+=1
    echo   - Arrêt de %%i...
    docker stop %%i >nul 2>&1
    docker rm -f %%i >nul 2>&1
)

if !CONTAINER_COUNT! gtr 0 (
    echo Conteneurs trouvés: !CONTAINER_COUNT!
)

REM Arrêter avec docker-compose si disponible
if not "!COMPOSE_CMD!"=="" (
    echo Arrêt avec docker-compose...
    !COMPOSE_CMD! down >nul 2>&1
)

echo.
echo Environnement arrêté.
echo.
echo Pour supprimer aussi les volumes (données):
echo   !COMPOSE_CMD! down -v
echo.

exit /b 0
