@echo off
REM Script Batch pour ouvrir le shell HBase (Windows)
REM Usage: scripts\hbase-shell.bat

echo Vérification du conteneur HBase...
docker-compose ps -q hbase >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Le conteneur HBase n'est pas démarré.
    echo Vérifiez l'état avec: docker-compose ps
    echo Démarrez avec: docker-compose up -d
    exit /b 1
)

echo Ouverture du shell HBase...
for /f "tokens=*" %%i in ('docker-compose ps -q hbase') do set CONTAINER_ID=%%i
docker exec -it %CONTAINER_ID% hbase shell

