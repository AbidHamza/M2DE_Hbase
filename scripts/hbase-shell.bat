@echo off
REM Script Batch pour ouvrir le shell HBase (Windows)
REM Usage: scripts\hbase-shell.bat

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
!COMPOSE_CMD! ps -q hbase >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Le conteneur HBase n'est pas démarré.
    echo Vérifiez l'état avec: !COMPOSE_CMD! ps
    echo Démarrez avec: !COMPOSE_CMD! up -d
    exit /b 1
)

echo Ouverture du shell HBase...
for /f "tokens=*" %%i in ('!COMPOSE_CMD! ps -q hbase') do set CONTAINER_ID=%%i
docker exec -it %CONTAINER_ID% hbase shell

