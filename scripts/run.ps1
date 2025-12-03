# Script principal pour lancer l'environnement (Windows PowerShell)
# Intègre la vérification des prérequis et le lancement avec AUTO-RÉPARATION
# Usage: .\scripts\run.ps1

$ErrorActionPreference = "Continue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir

Set-Location $projectRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "DÉMARRAGE DE L'ENVIRONNEMENT HBASE & HIVE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Variables de vérification
$Errors = 0
$Warnings = 0
$composeCmd = ""

# Fonction d'auto-réparation : Libérer les ports occupés
function Free-Port {
    param([int]$Port)
    Write-Host "  🔧 Tentative de libération du port $Port..." -ForegroundColor Yellow
    try {
        $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        foreach ($conn in $connections) {
            if ($conn.OwningProcess) {
                Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
                Write-Host "    → Processus $($conn.OwningProcess) arrêté" -ForegroundColor Green
            }
        }
        Start-Sleep -Seconds 2
        return $true
    } catch {
        return $false
    }
}

# Fonction d'auto-réparation : Lancer Docker Desktop
function Start-DockerDesktop {
    Write-Host "  🔧 Tentative de lancement de Docker Desktop..." -ForegroundColor Yellow
    $dockerDesktopPath = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerDesktopPath) {
        Start-Process $dockerDesktopPath
        Write-Host "    → Docker Desktop lancé, attente 30 secondes..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
        # Vérifier que Docker fonctionne maintenant
        $maxRetries = 10
        $retry = 0
        while ($retry -lt $maxRetries) {
            docker info 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    → Docker Desktop est maintenant opérationnel" -ForegroundColor Green
                return $true
            }
            Start-Sleep -Seconds 5
            $retry++
        }
        return $false
    }
    return $false
}

# Fonction d'auto-réparation : Récupérer les fichiers manquants
function Restore-MissingFiles {
    Write-Host "  🔧 Tentative de récupération des fichiers manquants..." -ForegroundColor Yellow
    if (Test-Path ".git") {
        try {
            git pull origin main 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    → Fichiers récupérés via git pull" -ForegroundColor Green
                return $true
            }
        } catch {
            Write-Host "    → Échec de git pull" -ForegroundColor Red
        }
    }
    return $false
}

# 1. Vérifier Docker
Write-Host "[1/9] Vérification Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Docker installé: $dockerVersion" -ForegroundColor Green
    } else {
        throw "Docker non disponible"
    }
} catch {
    Write-Host "  ❌ ERREUR: Docker n'est pas installé" -ForegroundColor Red
    Write-Host "     → Installez Docker: https://www.docker.com/get-started" -ForegroundColor Yellow
    $Errors++
}
Write-Host ""

# 2. Détecter docker-compose (V1 ou V2)
Write-Host "[2/9] Détection Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $composeCmd = "docker-compose"
        Write-Host "  ✅ Docker Compose V1 détecté: $composeVersion" -ForegroundColor Green
    } else {
        throw "docker-compose V1 non disponible"
    }
} catch {
    try {
        $composeVersion = docker compose version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $composeCmd = "docker compose"
            Write-Host "  ✅ Docker Compose V2 détecté: $composeVersion" -ForegroundColor Green
        } else {
            throw "Docker Compose non disponible"
        }
    } catch {
        Write-Host "  ❌ ERREUR: Docker Compose n'est pas installé" -ForegroundColor Red
        Write-Host "     → Installez Docker Compose ou mettez à jour Docker Desktop" -ForegroundColor Yellow
        $Errors++
    }
}
Write-Host ""

# 3. Vérifier Docker Desktop lancé (avec auto-réparation)
Write-Host "[3/9] Vérification Docker Desktop..." -ForegroundColor Yellow
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Docker Desktop est lancé et fonctionne" -ForegroundColor Green
    } else {
        throw "Docker Desktop non lancé"
    }
} catch {
    Write-Host "  ⚠️  Docker Desktop n'est pas lancé" -ForegroundColor Yellow
    Write-Host "     → AUTO-RÉPARATION: Tentative de lancement..." -ForegroundColor Cyan
    if (Start-DockerDesktop) {
        Write-Host "  ✅ Docker Desktop lancé automatiquement" -ForegroundColor Green
    } else {
        Write-Host "  ❌ ERREUR: Impossible de lancer Docker Desktop automatiquement" -ForegroundColor Red
        Write-Host "     → Lancez Docker Desktop manuellement depuis le menu Démarrer" -ForegroundColor Yellow
        $Errors++
    }
}
Write-Host ""

# 4. Vérifier répertoire et fichiers (avec auto-réparation)
Write-Host "[4/9] Vérification fichiers Docker..." -ForegroundColor Yellow
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "  ⚠️  docker-compose.yml introuvable" -ForegroundColor Yellow
    Write-Host "     → AUTO-RÉPARATION: Tentative de récupération..." -ForegroundColor Cyan
    if (Restore-MissingFiles) {
        if (Test-Path "docker-compose.yml") {
            Write-Host "  ✅ Fichiers récupérés avec succès" -ForegroundColor Green
        } else {
            Write-Host "  ❌ ERREUR: docker-compose.yml toujours introuvable" -ForegroundColor Red
            $Errors++
        }
    } else {
        Write-Host "  ❌ ERREUR: docker-compose.yml introuvable" -ForegroundColor Red
        $Errors++
    }
} else {
    Write-Host "  ✅ Fichiers Docker présents" -ForegroundColor Green
}
Write-Host ""

# 5. Vérifier et libérer les ports occupés (avec auto-réparation)
Write-Host "[5/9] Vérification et libération des ports..." -ForegroundColor Yellow
$ports = @(9000, 9870, 16011, 2181)
$portConflicts = 0
foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        $portConflicts++
        Write-Host "  ⚠️  Port $port est occupé" -ForegroundColor Yellow
        Write-Host "     → AUTO-RÉPARATION: Libération du port $port..." -ForegroundColor Cyan
        if (Free-Port -Port $port) {
            Write-Host "  ✅ Port $port libéré" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Port $port toujours occupé (sera nettoyé par docker-compose down)" -ForegroundColor Yellow
            $Warnings++
        }
    }
}
if ($portConflicts -eq 0) {
    Write-Host "  ✅ Tous les ports sont disponibles" -ForegroundColor Green
}
Write-Host ""

# 6. Vérifier espace disque
Write-Host "[6/9] Vérification espace disque..." -ForegroundColor Yellow
try {
    $disk = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq (Get-Location).Drive.Root }
    $freeGB = [math]::Round($disk.Free / 1GB, 2)
    if ($freeGB -lt 5) {
        Write-Host "  ⚠️  AVERTISSEMENT: Moins de 5GB d'espace libre ($freeGB GB)" -ForegroundColor Yellow
        Write-Host "     → AUTO-RÉPARATION: Nettoyage des images Docker inutilisées..." -ForegroundColor Cyan
        docker system prune -f 2>&1 | Out-Null
        $Warnings++
    } else {
        Write-Host "  ✅ Espace disque suffisant: $freeGB GB" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Impossible de vérifier l'espace disque" -ForegroundColor Yellow
    $Warnings++
}
Write-Host ""

# 7. Vérifier si l'environnement est déjà lancé
Write-Host "[7/9] Vérification de l'état actuel..." -ForegroundColor Yellow
$runningContainers = @()
try {
    if (-not [string]::IsNullOrWhiteSpace($composeCmd)) {
        # Vérifier avec docker-compose ps
        $psOutput = Invoke-Expression "$composeCmd ps --format json" 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($psOutput) {
            $runningContainers = $psOutput | Where-Object { $_.State -eq "running" -or $_.State -eq "restarting" } | Select-Object -ExpandProperty Name
        }
    }
    
    # Alternative: vérifier directement avec docker ps
    if ($runningContainers.Count -eq 0) {
        $runningContainers = docker ps --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2>&1 | Where-Object { $_ -ne "" }
    }
    
    if ($runningContainers.Count -gt 0) {
        Write-Host "  ⚠️  Des conteneurs sont déjà en cours d'exécution:" -ForegroundColor Yellow
        $runningContainers | ForEach-Object {
            Write-Host "     - $_" -ForegroundColor White
        }
        Write-Host ""
        Write-Host "  → AUTO-RÉPARATION: Arrêt et nettoyage des conteneurs existants..." -ForegroundColor Cyan
        Write-Host "     (Pour garder les conteneurs existants, utilisez: $composeCmd ps)" -ForegroundColor Gray
    } else {
        Write-Host "  ✅ Aucun conteneur en cours d'exécution" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Impossible de vérifier l'état (continuation)" -ForegroundColor Yellow
}
Write-Host ""

# Nettoyer les conteneurs existants (FORCÉ)
Write-Host "[8/9] Nettoyage FORCÉ des conteneurs existants..." -ForegroundColor Yellow
try {
    # Arrêter TOUS les conteneurs du projet
    docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.ID}}" | ForEach-Object {
        docker stop $_ 2>&1 | Out-Null
        docker rm -f $_ 2>&1 | Out-Null
    }
    
    # Nettoyer avec docker-compose si disponible
    if (-not [string]::IsNullOrWhiteSpace($composeCmd)) {
        Invoke-Expression "$composeCmd down -v --remove-orphans" 2>&1 | Out-Null
    }
    
    # Nettoyer les volumes orphelins
    docker volume prune -f 2>&1 | Out-Null
    
    Start-Sleep -Seconds 3
    Write-Host "  ✅ Nettoyage complet terminé" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Erreur lors du nettoyage (continuation)" -ForegroundColor Yellow
}
Write-Host ""

# 9. Résumé des vérifications
Write-Host "[9/10] Résumé des vérifications..." -ForegroundColor Yellow

if ($Errors -gt 0) {
    Write-Host "  ❌ $Errors erreur(s) bloquante(s) détectée(s)" -ForegroundColor Red
    Write-Host "     → Corrigez les erreurs ci-dessus avant de continuer" -ForegroundColor Red
    exit 1
} elseif ($Warnings -gt 0) {
    Write-Host "  ⚠️  $Warnings avertissement(s) - continuation automatique" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ Toutes les vérifications sont passées" -ForegroundColor Green
}
Write-Host ""

# Vérifier que COMPOSE_CMD est défini avant de continuer
if ([string]::IsNullOrWhiteSpace($composeCmd)) {
    Write-Host "  ❌ ERREUR CRITIQUE: Docker Compose non détecté" -ForegroundColor Red
    Write-Host "     → Le script ne peut pas continuer sans Docker Compose" -ForegroundColor Red
    exit 1
}

# 10. Lancer docker compose avec retry automatique
Write-Host "[10/10] Lancement des conteneurs Docker..." -ForegroundColor Cyan
Write-Host "  (Cela peut prendre 3-5 minutes pour démarrer tous les services)" -ForegroundColor Gray
Write-Host ""

$maxRetries = 3
$retry = 0
$success = $false

while ($retry -lt $maxRetries -and -not $success) {
    if ($retry -gt 0) {
        Write-Host "  🔄 Tentative $($retry + 1)/$maxRetries..." -ForegroundColor Yellow
        Write-Host "     → Nettoyage avant retry..." -ForegroundColor Yellow
        Invoke-Expression "$composeCmd down -v" 2>&1 | Out-Null
        Start-Sleep -Seconds 5
    }
    
    try {
        Invoke-Expression "$composeCmd up -d --build"
        if ($LASTEXITCODE -eq 0) {
            $success = $true
            Write-Host ""
            Write-Host "✅ Conteneurs démarrés avec succès" -ForegroundColor Green
            Write-Host ""
            Write-Host "Attente du démarrage complet des services (60 secondes)..." -ForegroundColor Yellow
            Start-Sleep -Seconds 60
            
            Write-Host ""
            Write-Host "Vérification de l'état des services..." -ForegroundColor Cyan
            Invoke-Expression "$composeCmd ps"
            
            Write-Host ""
            Write-Host "==========================================" -ForegroundColor Cyan
            Write-Host "ENVIRONNEMENT DÉMARRÉ" -ForegroundColor Cyan
            Write-Host "==========================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Pour accéder aux services:" -ForegroundColor Yellow
            Write-Host "  - HBase Shell: .\scripts\hbase-shell.ps1" -ForegroundColor White
            Write-Host "  - Hive CLI: .\scripts\hive-cli.ps1" -ForegroundColor White
            Write-Host "  - Vérifier l'état: .\scripts\status.ps1" -ForegroundColor White
            Write-Host ""
            Write-Host "Interfaces Web:" -ForegroundColor Yellow
            Write-Host "  - HDFS NameNode: http://localhost:9870" -ForegroundColor White
            Write-Host "  - YARN ResourceManager: http://localhost:8088" -ForegroundColor White
            Write-Host "  - HBase Master: http://localhost:16011" -ForegroundColor White
            Write-Host ""
            Write-Host "Note: Les services peuvent prendre 2-3 minutes pour être complètement opérationnels." -ForegroundColor Yellow
            Write-Host "      Si un conteneur est 'unhealthy', attendez encore 1-2 minutes." -ForegroundColor Yellow
            Write-Host ""
        } else {
            throw "Échec du démarrage"
        }
    } catch {
        $retry++
        if ($retry -lt $maxRetries) {
            Write-Host "  ⚠️  Échec, nouvelle tentative dans 10 secondes..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
        } else {
            Write-Host ""
            Write-Host "❌ ERREUR: Échec du démarrage après $maxRetries tentatives" -ForegroundColor Red
            Write-Host ""
            Write-Host "Pour diagnostiquer le problème:" -ForegroundColor Yellow
            Write-Host "  $composeCmd logs" -ForegroundColor White
            Write-Host "  $composeCmd ps" -ForegroundColor White
            Write-Host ""
            exit 1
        }
    }
}
