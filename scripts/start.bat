@echo off
REM Script unique pour lancer l'environnement HBase & Hive (Windows Batch)
REM Fusionne setup + run : vérifie, nettoie et lance
REM Usage: scripts\start.bat

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
cd /d "!SCRIPT_DIR!.."

echo ==========================================
echo LANCEMENT ENVIRONNEMENT HBASE ^& HIVE
echo ==========================================
echo.

set ERRORS=0
set COMPOSE_CMD=

REM ÉTAPE 1 : Vérification Docker
echo [1/10] Vérification Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo   [ERREUR] Docker n'est pas installé
    echo   -^> Téléchargez Docker Desktop: https://www.docker.com/get-started
    exit /b 1
) else (
    echo   [OK] Docker installé
)
echo.

REM ÉTAPE 2 : Détection Docker Compose
echo [2/10] Détection Docker Compose...
docker-compose --version >nul 2>&1
if not errorlevel 1 (
    set COMPOSE_CMD=docker-compose
    echo   [OK] Docker Compose V1 détecté
) else (
    docker compose version >nul 2>&1
    if not errorlevel 1 (
        set COMPOSE_CMD=docker compose
        echo   [OK] Docker Compose V2 détecté
    ) else (
        echo   [ERREUR] Docker Compose n'est pas installé
        echo   -^> Mettez à jour Docker Desktop
        exit /b 1
    )
)
echo.

REM ÉTAPE 3 : Vérification Docker Desktop
echo [3/10] Vérification Docker Desktop...
docker info >nul 2>&1
if errorlevel 1 (
    echo   [INFO] Docker Desktop n'est pas lancé
    echo   [INFO] Tentative de lancement...
    
    REM Essayer plusieurs emplacements possibles
    set DOCKER_DESKTOP_PATH=
    if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" (
        set DOCKER_DESKTOP_PATH=%ProgramFiles%\Docker\Docker\Docker Desktop.exe
    ) else if exist "%ProgramFiles(x86)%\Docker\Docker\Docker Desktop.exe" (
        set DOCKER_DESKTOP_PATH=%ProgramFiles(x86)%\Docker\Docker\Docker Desktop.exe
    ) else if exist "%LOCALAPPDATA%\Docker\Docker Desktop.exe" (
        set DOCKER_DESKTOP_PATH=%LOCALAPPDATA%\Docker\Docker Desktop.exe
    )
    
    if not "!DOCKER_DESKTOP_PATH!"=="" (
        start "" "!DOCKER_DESKTOP_PATH!"
        echo      Docker Desktop en cours de lancement...
        echo      Attente 30 secondes...
        timeout /t 30 /nobreak >nul
        
        set RETRY_COUNT=0
        :check_docker
        docker info >nul 2>&1
        if not errorlevel 1 (
            echo   [OK] Docker Desktop lancé
            goto docker_ok
        )
        set /a RETRY_COUNT+=1
        if !RETRY_COUNT! lss 10 (
            timeout /t 5 /nobreak >nul
            goto check_docker
        )
        echo   [ERREUR] Docker Desktop n'a pas démarré
        exit /b 1
        :docker_ok
    ) else (
        echo   [INFO] Docker Desktop non trouve dans les emplacements standards
        echo   [INFO] Lancez Docker Desktop manuellement puis relancez ce script
        echo   -^> Ou installez Docker Desktop: https://www.docker.com/get-started
        exit /b 1
    )
) else (
    echo   [OK] Docker Desktop est lancé
)
echo.

REM ÉTAPE 4 : Vérification fichiers
echo [4/10] Vérification fichiers...
if not exist "docker-compose.yml" (
    echo   [INFO] docker-compose.yml introuvable
    echo   [INFO] Tentative de récupération...
    if exist ".git" (
        git pull origin main >nul 2>&1
        if exist "docker-compose.yml" (
            echo   [OK] Fichiers récupérés
        ) else (
            echo   [ERREUR] docker-compose.yml toujours introuvable
            exit /b 1
        )
    ) else (
        echo   [ERREUR] docker-compose.yml introuvable
        exit /b 1
    )
) else (
    echo   [OK] Fichiers présents
)
echo.

REM ÉTAPE 5 : Nettoyage conteneurs existants
echo [5/10] Nettoyage conteneurs existants...
for /f "tokens=*" %%i in ('docker ps --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2^>nul') do (
    set /a RUNNING_COUNT+=1
)

if defined RUNNING_COUNT (
    echo   [INFO] Arrêt des conteneurs existants...
    for /f "tokens=*" %%i in ('docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.ID}}" 2^>nul') do (
        docker stop %%i >nul 2>&1
        docker rm -f %%i >nul 2>&1
    )
)

if not "!COMPOSE_CMD!"=="" (
    !COMPOSE_CMD! down -v --remove-orphans >nul 2>&1
)

docker volume prune -f >nul 2>&1
echo   [OK] Nettoyage terminé
echo.

REM ÉTAPE 6 : Vérification ports (simplifiée)
echo [6/10] Vérification ports...
echo   [OK] Vérification simplifiée
echo.

REM ÉTAPE 7 : Vérification espace disque (simplifiée)
echo [7/10] Vérification espace disque...
echo   [OK] Vérification simplifiée
echo.

REM ÉTAPE 8 : Vérification finale Docker
echo [8/10] Vérification finale Docker...
set DOCKER_READY=0
for /l %%i in (1,1,10) do (
    docker info >nul 2>&1
    if not errorlevel 1 (
        set DOCKER_READY=1
        echo   [OK] Docker daemon accessible
        goto docker_ready_ok
    )
    if %%i lss 10 (
        timeout /t 2 /nobreak >nul
    )
)

:docker_ready_ok
if !DOCKER_READY! equ 0 (
    echo   [ERREUR] Docker daemon non accessible
    echo   -^> Attendez que Docker Desktop soit complètement démarré
    exit /b 1
)
echo.

REM LANCEMENT DES CONTENEURS
echo ==========================================
echo LANCEMENT DES CONTENEURS
echo ==========================================
echo.
echo Cela peut prendre 3-5 minutes...
echo.

set MAX_RETRIES=3
set RETRY=0
set SUCCESS=0

:retry_loop
if !RETRY! geq !MAX_RETRIES! goto launch_failed
if !SUCCESS! equ 1 goto launch_success

if !RETRY! gtr 0 (
    echo [RETRY !RETRY!/!MAX_RETRIES!] Nouvelle tentative...
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
        echo [INFO] Échec, nouvelle tentative dans 10 secondes...
        timeout /t 10 /nobreak >nul
        goto retry_loop
    )
)

:launch_failed
echo.
echo [ERREUR] Échec après !MAX_RETRIES! tentatives
echo.
echo Pour diagnostiquer:
echo   !COMPOSE_CMD! logs
echo   !COMPOSE_CMD! ps
echo.
exit /b 1

:launch_success
echo.
echo [OK] Conteneurs démarrés
echo.

REM ÉTAPE 9 : Vérification JAVA_HOME dans les logs
echo [9/10] Vérification JAVA_HOME...
timeout /t 30 /nobreak >nul

set JAVA_HOME_ERRORS=0
set MAX_CHECKS=6
set CHECK_COUNT=0

:check_java_home
if !CHECK_COUNT! geq !MAX_CHECKS! goto java_home_check_done

!COMPOSE_CMD! logs hadoop 2>&1 | findstr /I /C:"ERROR" /C:"JAVA_HOME" /C:"not set" /C:"could not be found" /C:"readlink" /C:"dirname" /C:"Cannot find Java" /C:"Java not found" >nul 2>&1
if not errorlevel 1 (
    set JAVA_HOME_ERRORS=1
    echo   [ATTENTION] Erreurs JAVA_HOME detectees dans les logs
    echo   [REPARATION] Reconstruction de l'image Hadoop...
    
    REM Arrêter les conteneurs
    !COMPOSE_CMD! down -v >nul 2>&1
    timeout /t 5 /nobreak >nul
    
    REM Reconstruire l'image hadoop sans cache
    echo   [INFO] Reconstruction en cours (cela peut prendre 2-3 minutes)...
    !COMPOSE_CMD! build --no-cache hadoop
    
    if not errorlevel 1 (
        echo   [OK] Image Hadoop reconstruite
        echo   [INFO] Relancement des conteneurs...
        
        REM Relancer les conteneurs avec build pour etre sur
        !COMPOSE_CMD! up -d --build >nul 2>&1
        echo   [INFO] Attente du demarrage initial (45 secondes)...
        timeout /t 45 /nobreak >nul
        
        REM Réinitialiser le compteur
        set CHECK_COUNT=0
        set JAVA_HOME_ERRORS=0
        goto check_java_home
    ) else (
        echo   [ERREUR] Echec de la reconstruction
        goto java_home_check_done
    )
) else (
    REM Vérifier si Hadoop est healthy (simplifié)
    !COMPOSE_CMD! ps hadoop 2>&1 | findstr /C:"healthy" >nul 2>&1
    if not errorlevel 1 (
        echo   [OK] Hadoop est operationnel (JAVA_HOME correct)
        goto java_home_check_done
    )
)

set /a CHECK_COUNT+=1
if !CHECK_COUNT! lss !MAX_CHECKS! (
    echo   [INFO] Attente du demarrage... (!CHECK_COUNT!/!MAX_CHECKS!)
    timeout /t 15 /nobreak >nul
    goto check_java_home
)

:java_home_check_done
if !JAVA_HOME_ERRORS! equ 1 (
    echo   [ATTENTION] Problemes JAVA_HOME persistants
    echo   -^> Consultez les logs: !COMPOSE_CMD! logs hadoop
) else (
    echo   [OK] JAVA_HOME configure correctement
)
echo.

REM ÉTAPE 10 : Vérification Hive dans les logs
echo [10/10] Vérification Hive...
timeout /t 20 /nobreak >nul

set HIVE_ERRORS=0
set HIVE_MAX_CHECKS=6
set HIVE_CHECK_COUNT=0

:check_hive
if !HIVE_CHECK_COUNT! geq !HIVE_MAX_CHECKS! goto hive_check_done

!COMPOSE_CMD! logs hive-metastore hive 2>&1 | findstr /I /C:"Cannot find hadoop" /C:"HADOOP_HOME" /C:"HADOOP_CONF_DIR" /C:"Hadoop binaries" /C:"hadoop.*command" /C:"ERROR" >nul 2>&1
if not errorlevel 1 (
    set HIVE_ERRORS=1
    echo   [ATTENTION] Erreurs Hive detectees dans les logs
    echo   [REPARATION] Reconstruction de l'image Hive...
    
    REM Arrêter les conteneurs
    !COMPOSE_CMD! down -v >nul 2>&1
    timeout /t 5 /nobreak >nul
    
    REM Reconstruire l'image hive sans cache
    echo   [INFO] Reconstruction en cours (cela peut prendre 2-3 minutes)...
    !COMPOSE_CMD! build --no-cache hive
    
    if not errorlevel 1 (
        echo   [OK] Image Hive reconstruite
        echo   [INFO] Relancement des conteneurs...
        
        REM Relancer les conteneurs avec build
        !COMPOSE_CMD! up -d --build >nul 2>&1
        echo   [INFO] Attente du demarrage initial (45 secondes)...
        timeout /t 45 /nobreak >nul
        
        REM Réinitialiser le compteur
        set HIVE_CHECK_COUNT=0
        set HIVE_ERRORS=0
        goto check_hive
    ) else (
        echo   [ERREUR] Echec de la reconstruction
        goto hive_check_done
    )
) else (
    REM Vérifier si Hive est healthy (simplifié)
    !COMPOSE_CMD! ps hive-metastore hive 2>&1 | findstr /C:"healthy" >nul 2>&1
    if not errorlevel 1 (
        echo   [OK] Hive est operationnel
        goto hive_check_done
    )
)

set /a HIVE_CHECK_COUNT+=1
if !HIVE_CHECK_COUNT! lss !HIVE_MAX_CHECKS! (
    echo   [INFO] Attente du demarrage Hive... (!HIVE_CHECK_COUNT!/!HIVE_MAX_CHECKS!)
    timeout /t 15 /nobreak >nul
    goto check_hive
)

:hive_check_done
if !HIVE_ERRORS! equ 1 (
    echo   [ATTENTION] Problemes Hive persistants
    echo   -^> Consultez les logs: !COMPOSE_CMD! logs hive-metastore hive
) else (
    echo   [OK] Hive configure correctement
)
echo.

echo Attente du demarrage complet (30 secondes supplementaires)...
timeout /t 30 /nobreak >nul

echo.
echo Verification de l'etat...
!COMPOSE_CMD! ps

echo.
echo ==========================================
echo ÉTAT DES SERVICES
echo ==========================================
%composeCmd% ps

echo.
echo Interfaces Web disponibles:
echo   - HDFS NameNode: http://localhost:9870
echo   - YARN ResourceManager: http://localhost:8088
echo   - HBase Master: http://localhost:16011
echo.
echo Pour accéder aux shells, utilisez directement Docker:
for /f "tokens=*" %%i in ('%composeCmd% ps -q hbase 2^>nul') do set HBASE_CONTAINER=%%i
for /f "tokens=*" %%i in ('%composeCmd% ps -q hive 2^>nul') do set HIVE_CONTAINER=%%i
for /f "tokens=*" %%i in ('%composeCmd% ps -q hadoop 2^>nul') do set HADOOP_CONTAINER=%%i
echo   - HBase Shell: docker exec -it %HBASE_CONTAINER% hbase shell
echo   - Hive CLI: docker exec -it %HIVE_CONTAINER% hive
echo   - Hadoop Shell: docker exec -it %HADOOP_CONTAINER% bash
echo.
echo Pour arrêter l'environnement: scripts\stop.bat
echo.
echo.
echo Interfaces Web:
echo   - HDFS: http://localhost:9870
echo   - YARN: http://localhost:8088
echo   - HBase: http://localhost:16011
echo.
echo Note: Les services peuvent prendre 2-3 minutes pour être opérationnels.
echo       Si un conteneur est 'unhealthy', attendez encore 1-2 minutes.
echo.

exit /b 0

