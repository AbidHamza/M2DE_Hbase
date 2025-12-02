@echo off
REM Script de vérification COMPLÈTE avant le lancement (Windows Batch)
REM Usage: scripts\check-before-start.bat

setlocal enabledelayedexpansion
set ERRORS=0
set WARNINGS=0

echo ==========================================
echo VÉRIFICATION COMPLÈTE AVANT DÉMARRAGE
echo ==========================================
echo.

REM 1. Vérifier Docker installé
echo [1/15] Vérification Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo   ❌ ERREUR: Docker n'est pas installé
    echo      → Installez Docker: https://www.docker.com/get-started
    set /a ERRORS+=1
) else (
    echo   ✅ Docker installé
)
echo.

REM 2. Vérifier docker-compose installé
echo [2/15] Vérification docker-compose...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo   ❌ ERREUR: docker-compose n'est pas installé
    set /a ERRORS+=1
) else (
    echo   ✅ docker-compose installé
)
echo.

REM 3. Vérifier Docker Desktop lancé
echo [3/15] Vérification Docker Desktop...
docker info >nul 2>&1
if errorlevel 1 (
    echo   ❌ ERREUR: Docker Desktop n'est pas lancé
    echo      → Lancez Docker Desktop depuis le menu Démarrer
    echo      → Attendez que l'icône Docker apparaisse dans la barre des tâches
    set /a ERRORS+=1
) else (
    echo   ✅ Docker Desktop est lancé et fonctionne
)
echo.

REM 4. Vérifier Git installé
echo [4/15] Vérification Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo   ⚠️  AVERTISSEMENT: Git n'est pas installé
    set /a WARNINGS+=1
) else (
    echo   ✅ Git installé
)
echo.

REM 5. Vérifier que nous sommes dans le bon répertoire
echo [5/15] Vérification répertoire...
if not exist "docker-compose.yml" (
    echo   ❌ ERREUR: docker-compose.yml introuvable
    echo      → Assurez-vous d'être dans le répertoire M2DE_Hbase
    set /a ERRORS+=1
) else (
    echo   ✅ Répertoire correct
)
echo.

REM 6. Vérifier fichiers Docker essentiels
echo [6/15] Vérification fichiers Docker...
set MISSING=0
if not exist "docker\hadoop\Dockerfile" set /a MISSING+=1
if not exist "docker\hbase\Dockerfile" set /a MISSING+=1
if not exist "docker\hive\Dockerfile" set /a MISSING+=1
if not exist "docker\hadoop\start-hadoop.sh" set /a MISSING+=1
if not exist "docker\hbase\start-hbase.sh" set /a MISSING+=1
if not exist "docker\hbase\hbase-site.xml" set /a MISSING+=1
if not exist "docker\hbase\hbase-env.sh" set /a MISSING+=1
if not exist "docker\hive\hive-env.sh" set /a MISSING+=1

if !MISSING! equ 0 (
    echo   ✅ Tous les fichiers Docker sont présents
) else (
    echo   ❌ ERREUR: !MISSING! fichier(s) manquant(s)
    echo      → Faites: git pull origin main
    set /a ERRORS+=1
)
echo.

REM 7. Vérifier syntaxe docker-compose.yml
echo [7/15] Vérification syntaxe docker-compose.yml...
docker-compose config >nul 2>&1
if errorlevel 1 (
    echo   ❌ ERREUR: Syntaxe docker-compose.yml invalide
    echo      → Faites: git pull origin main
    set /a ERRORS+=1
) else (
    echo   ✅ Syntaxe docker-compose.yml valide
)
echo.

REM 8-14. Vérifications simplifiées (trop complexes pour Batch)
echo [8-14/15] Vérifications avancées...
echo   ⚠️  Utilisez check-before-start.ps1 pour des vérifications complètes
set /a WARNINGS+=1
echo.

REM 15. Vérifier réseau Docker
echo [15/15] Vérification réseau Docker...
docker network ls | findstr "hbase-hive-network" >nul 2>&1
if not errorlevel 1 (
    echo   ⚠️  Réseau Docker existant détecté
    echo      → Pour nettoyer: docker network prune -f
    set /a WARNINGS+=1
) else (
    echo   ✅ Réseau Docker prêt à être créé
)
echo.

REM Résumé
echo ==========================================
echo RÉSUMÉ DE LA VÉRIFICATION
echo ==========================================
echo Erreurs bloquantes: !ERRORS!
echo Avertissements: !WARNINGS!
echo.

if !ERRORS! gtr 0 (
    echo ❌ ERREURS BLOQUANTES DÉTECTÉES
    echo    Corrigez les erreurs ci-dessus avant de continuer.
    echo.
    exit /b 1
) else if !WARNINGS! gtr 0 (
    echo ⚠️  AVERTISSEMENTS DÉTECTÉS
    echo    Vous pouvez continuer, mais certains problèmes peuvent survenir.
    echo.
    set /p CONTINUE="Continuer quand même ? (O/N): "
    if /i not "!CONTINUE!"=="O" (
        echo Arrêté par l'utilisateur.
        exit /b 1
    )
) else (
    echo ✅ TOUTES LES VÉRIFICATIONS SONT PASSÉES
    echo    Vous pouvez lancer docker-compose up -d
    echo.
)

exit /b 0

