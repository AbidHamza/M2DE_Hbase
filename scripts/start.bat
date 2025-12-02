@echo off
REM Script Batch pour démarrer l'environnement (Windows - Alternative à PowerShell)
REM Usage: scripts\start.bat

echo Démarrage de l'environnement HBase ^& Hive...

REM Vérifier que Docker est disponible
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Docker n'est pas installé ou pas dans le PATH
    echo Téléchargez Docker depuis: https://www.docker.com/get-started
    exit /b 1
)

REM Démarrer les services
echo Lancement des conteneurs Docker...
docker-compose up -d

REM Attendre un peu
echo Attente du démarrage des services (30 secondes)...
timeout /t 30 /nobreak >nul

REM Vérifier l'état
echo.
echo Vérification de l'état des services...
docker-compose ps

echo.
echo Environnement démarré !
echo Pour accéder aux services:
echo   - HBase Shell: scripts\hbase-shell.bat
echo   - Hive CLI: scripts\hive-cli.bat
echo   - Vérifier l'état: scripts\status.bat

