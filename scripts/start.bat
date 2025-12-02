@echo off
REM Script Batch pour démarrer l'environnement (Windows - Alternative à PowerShell)
REM Usage: scripts\start.bat

echo Démarrage de l'environnement HBase ^& Hive...

REM Exécuter la vérification complète AVANT de démarrer
if exist "scripts\check-before-start.bat" (
    echo.
    echo ⚠️  VÉRIFICATION PRÉ-LANCEMENT OBLIGATOIRE
    echo ==========================================
    call scripts\check-before-start.bat
    if errorlevel 1 (
        echo.
        echo ❌ La vérification a échoué. Corrigez les erreurs avant de continuer.
        exit /b 1
    )
    echo.
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

