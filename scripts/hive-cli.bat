@echo off
REM Script Batch pour ouvrir le CLI Hive (Windows)
REM Usage: scripts\hive-cli.bat

echo Vérification du conteneur Hive...
docker-compose ps -q hive >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Le conteneur Hive n'est pas démarré.
    echo Vérifiez l'état avec: docker-compose ps
    echo Démarrez avec: docker-compose up -d
    exit /b 1
)

echo Ouverture du CLI Hive...
for /f "tokens=*" %%i in ('docker-compose ps -q hive') do set CONTAINER_ID=%%i
docker exec -it %CONTAINER_ID% hive

