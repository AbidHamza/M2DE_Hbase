@echo off
REM Script Batch pour ouvrir le CLI Hive (Windows)
REM Usage: scripts\hive-cli.bat

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

echo Vérification du conteneur Hive...
!COMPOSE_CMD! ps -q hive >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Le conteneur Hive n'est pas démarré.
    echo Vérifiez l'état avec: !COMPOSE_CMD! ps
    echo Démarrez avec: !COMPOSE_CMD! up -d
    exit /b 1
)

echo Ouverture du CLI Hive...
for /f "tokens=*" %%i in ('!COMPOSE_CMD! ps -q hive') do set CONTAINER_ID=%%i
docker exec -it %CONTAINER_ID% hive

