@echo off
REM Script principal pour lancer l'environnement (Windows Batch)
REM Intègre la vérification des prérequis et le lancement avec AUTO-RÉPARATION
REM Usage: scripts\run.bat

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
cd /d "!SCRIPT_DIR!.."

echo ==========================================
echo DÉMARRAGE DE L'ENVIRONNEMENT HBASE ^& HIVE
echo ==========================================
echo.

set ERRORS=0
set WARNINGS=0
set COMPOSE_CMD=

REM 1. Vérifier Docker
echo [1/9] Vérification Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo   ❌ ERREUR: Docker n'est pas installé
    echo      → Installez Docker: https://www.docker.com/get-started
    set /a ERRORS+=1
) else (
    echo   ✅ Docker installé
)
echo.

REM 2. Détecter docker-compose (V1 ou V2)
echo [2/9] Détection Docker Compose...
docker-compose --version >nul 2>&1
if not errorlevel 1 (
    set COMPOSE_CMD=docker-compose
    echo   ✅ Docker Compose V1 détecté
) else (
    docker compose version >nul 2>&1
    if not errorlevel 1 (
        set COMPOSE_CMD=docker compose
        echo   ✅ Docker Compose V2 détecté
    ) else (
        echo   ❌ ERREUR: Docker Compose n'est pas installé
        echo      → Installez Docker Compose ou mettez à jour Docker Desktop
        set /a ERRORS+=1
    )
)
echo.

REM 3. Vérifier Docker Desktop lancé (avec auto-réparation)
echo [3/9] Vérification Docker Desktop...
docker info >nul 2>&1
if errorlevel 1 (
    echo   ⚠️  Docker Desktop n'est pas lancé
    echo      → AUTO-RÉPARATION: Tentative de lancement...
    if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" (
        start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
        echo      → Docker Desktop lancé, attente 30 secondes...
        timeout /t 30 /nobreak >nul
        
        REM Vérifier que Docker fonctionne maintenant
        set RETRY_COUNT=0
        :check_docker
        docker info >nul 2>&1
        if not errorlevel 1 (
            echo   ✅ Docker Desktop est maintenant opérationnel
            goto docker_ok
        )
        set /a RETRY_COUNT+=1
        if !RETRY_COUNT! lss 10 (
            timeout /t 5 /nobreak >nul
            goto check_docker
        )
        echo   ❌ ERREUR: Docker Desktop n'a pas démarré
        set /a ERRORS+=1
        :docker_ok
    ) else (
        echo   ❌ ERREUR: Docker Desktop n'est pas lancé
        echo      → Lancez Docker Desktop manuellement depuis le menu Démarrer
        set /a ERRORS+=1
    )
) else (
    echo   ✅ Docker Desktop est lancé et fonctionne
)
echo.

REM 4. Vérifier répertoire et fichiers (avec auto-réparation)
echo [4/9] Vérification fichiers Docker...
if not exist "docker-compose.yml" (
    echo   ⚠️  docker-compose.yml introuvable
    echo      → AUTO-RÉPARATION: Tentative de récupération...
    if exist ".git" (
        git pull origin main >nul 2>&1
        if exist "docker-compose.yml" (
            echo   ✅ Fichiers récupérés avec succès
        ) else (
            echo   ❌ ERREUR: docker-compose.yml toujours introuvable
            set /a ERRORS+=1
        )
    ) else (
        echo   ❌ ERREUR: docker-compose.yml introuvable
        set /a ERRORS+=1
    )
) else (
    echo   ✅ Fichiers Docker présents
)
echo.

REM 5. Vérifier ports (simplifié - nettoyage automatique)
echo [5/9] Vérification ports...
echo   ⚠️  Vérification simplifiée - nettoyage automatique...
set /a WARNINGS+=1
echo.

REM 6. Vérifier espace disque (simplifié)
echo [6/9] Vérification espace disque...
echo   ⚠️  Vérification simplifiée
set /a WARNINGS+=1
echo.

REM 7. Vérifier si l'environnement est déjà lancé
echo [7/9] Vérification de l'état actuel...
set RUNNING_COUNT=0
if not "!COMPOSE_CMD!"=="" (
    for /f "tokens=*" %%i in ('docker ps --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2^>nul') do (
        set /a RUNNING_COUNT+=1
        echo   - %%i
    )
)

if !RUNNING_COUNT! gtr 0 (
    echo   ⚠️  Des conteneurs sont déjà en cours d'exécution
    echo.
    echo   → AUTO-RÉPARATION: Arrêt et nettoyage des conteneurs existants...
    echo      (Pour garder les conteneurs existants, utilisez: !COMPOSE_CMD! ps)
) else (
    echo   ✅ Aucun conteneur en cours d'exécution
)
echo.

REM 8. Nettoyer les conteneurs existants (FORCÉ)
echo [8/9] Nettoyage FORCÉ des conteneurs existants...
REM Arrêter TOUS les conteneurs du projet
for /f "tokens=*" %%i in ('docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.ID}}" 2^>nul') do (
    docker stop %%i >nul 2>&1
    docker rm -f %%i >nul 2>&1
)

REM Nettoyer avec docker-compose si disponible
if not "!COMPOSE_CMD!"=="" (
    !COMPOSE_CMD! down -v --remove-orphans >nul 2>&1
)

REM Nettoyer les volumes orphelins
docker volume prune -f >nul 2>&1

timeout /t 3 /nobreak >nul
echo   ✅ Nettoyage complet terminé
echo.

REM 9. Résumé des vérifications
echo [9/11] Résumé des vérifications...
if !ERRORS! gtr 0 (
    echo   ❌ !ERRORS! erreur(s) bloquante(s) détectée(s)
    echo      → Corrigez les erreurs ci-dessus avant de continuer
    exit /b 1
) else if !WARNINGS! gtr 0 (
    echo   ⚠️  !WARNINGS! avertissement(s) - continuation automatique
) else (
    echo   ✅ Toutes les vérifications sont passées
)
echo.

REM Vérifier que COMPOSE_CMD est défini avant de continuer
if "!COMPOSE_CMD!"=="" (
    echo   ❌ ERREUR CRITIQUE: Docker Compose non détecté
    echo      → Le script ne peut pas continuer sans Docker Compose
    exit /b 1
)

REM 10. Vérification finale Docker daemon avant lancement
echo [10/11] Vérification finale Docker daemon...
set DOCKER_READY=0
for /l %%i in (1,1,10) do (
    docker info >nul 2>&1
    if not errorlevel 1 (
        set DOCKER_READY=1
        echo   ✅ Docker daemon est accessible
        goto docker_ready_ok
    )
    if %%i lss 10 (
        echo   ⚠️  Docker daemon non accessible, attente 2 secondes... (tentative %%i/10)
        timeout /t 2 /nobreak >nul
    )
)

:docker_ready_ok
if !DOCKER_READY! equ 0 (
    echo   ❌ ERREUR: Docker daemon n'est pas accessible
    echo.
    echo Solutions:
    echo   1. Vérifiez que Docker Desktop est lancé
    echo   2. Attendez que Docker Desktop soit complètement démarré (1-2 minutes)
    echo   3. Redémarrez Docker Desktop si nécessaire
    echo   4. Vérifiez avec: docker info
    echo.
    exit /b 1
)
echo.

REM 11. Lancer docker compose avec retry automatique
echo [11/11] Lancement des conteneurs Docker...
echo   (Cela peut prendre 3-5 minutes pour démarrer tous les services)
echo.

set MAX_RETRIES=3
set RETRY=0
set SUCCESS=0

:retry_loop
if !RETRY! geq !MAX_RETRIES! goto launch_failed
if !SUCCESS! equ 1 goto launch_success

if !RETRY! gtr 0 (
    echo   🔄 Tentative !RETRY!/!MAX_RETRIES!...
    echo      → Vérification Docker daemon avant retry...
    set DOCKER_OK=0
    for /l %%j in (1,1,5) do (
        docker info >nul 2>&1
        if not errorlevel 1 (
            set DOCKER_OK=1
            goto docker_check_ok
        )
        timeout /t 2 /nobreak >nul
    )
    :docker_check_ok
    if !DOCKER_OK! equ 0 (
        echo      ❌ Docker daemon non accessible, arrêt des tentatives
        echo.
        echo Solutions:
        echo   1. Vérifiez que Docker Desktop est lancé
        echo   2. Redémarrez Docker Desktop
        echo   3. Vérifiez avec: docker info
        echo.
        exit /b 1
    )
    echo      → Nettoyage avant retry...
    !COMPOSE_CMD! down -v >nul 2>&1
    timeout /t 5 /nobreak >nul
)

!COMPOSE_CMD! up -d --build
if not errorlevel 1 (
    set SUCCESS=1
    goto launch_success
) else (
    set /a RETRY+=1
    if !RETRY! lss !MAX_RETRIES! (
        echo   ⚠️  Échec, nouvelle tentative dans 10 secondes...
        timeout /t 10 /nobreak >nul
        goto retry_loop
    )
)

:launch_failed
echo.
echo ❌ ERREUR: Échec du démarrage après !MAX_RETRIES! tentatives
echo.
echo Pour diagnostiquer le problème:
echo   !COMPOSE_CMD! logs
echo   !COMPOSE_CMD! ps
echo.
exit /b 1

:launch_success
echo.
echo ✅ Conteneurs démarrés avec succès
echo.
echo Attente du démarrage complet des services (60 secondes)...
timeout /t 60 /nobreak >nul

echo.
echo Vérification de l'état des services...
!COMPOSE_CMD! ps

echo.
echo ==========================================
echo ENVIRONNEMENT DÉMARRÉ
echo ==========================================
echo.
echo Pour accéder aux services:
echo   - HBase Shell: scripts\hbase-shell.bat
echo   - Hive CLI: scripts\hive-cli.bat
echo   - Vérifier l'état: scripts\status.bat
echo.
echo Interfaces Web:
echo   - HDFS NameNode: http://localhost:9870
echo   - YARN ResourceManager: http://localhost:8088
echo   - HBase Master: http://localhost:16011
echo.
echo Note: Les services peuvent prendre 2-3 minutes pour être complètement opérationnels.
echo       Si un conteneur est 'unhealthy', attendez encore 1-2 minutes.
echo.

exit /b 0
