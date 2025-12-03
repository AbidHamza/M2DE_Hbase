# Script unique pour lancer l'environnement HBase & Hive (Windows PowerShell)
# Fusionne setup + run : vérifie, installe si possible, nettoie et lance
# Usage: .\scripts\start.ps1

$ErrorActionPreference = "Continue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
Set-Location $projectRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "LANCEMENT ENVIRONNEMENT HBASE & HIVE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Variables
$Errors = 0
$Warnings = 0
$composeCmd = ""
$needRebuild = $false

# Fonction : Libérer les ports occupés
function Free-Port {
    param([int]$Port)
    try {
        $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        if ($null -ne $connections) {
            foreach ($conn in $connections) {
                if ($null -ne $conn.OwningProcess) {
                    Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
                }
            }
            Start-Sleep -Seconds 2
            return $true
        }
    } catch {}
    return $false
}

# Fonction : Lancer Docker Desktop
function Start-DockerDesktop {
    $dockerDesktopPath = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerDesktopPath) {
        Start-Process $dockerDesktopPath
        Write-Host "  [INFO] Docker Desktop en cours de lancement..." -ForegroundColor Yellow
        Write-Host "  [INFO] Attente 30 secondes..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
        for ($i = 1; $i -le 10; $i++) {
            docker info 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                return $true
            }
            Start-Sleep -Seconds 5
        }
    }
    return $false
}

# Fonction : Récupérer fichiers manquants
function Restore-MissingFiles {
    if (Test-Path ".git") {
        try {
            git pull origin main 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                return $true
            }
        } catch {}
    }
    return $false
}

# ==========================================
# ÉTAPE 1 : Vérification Docker
# ==========================================
Write-Host "[1/8] Vérification Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Docker installé: $dockerVersion" -ForegroundColor Green
    } else {
        throw "Docker non disponible"
    }
} catch {
    Write-Host "  [ERREUR] Docker n'est pas installé" -ForegroundColor Red
    Write-Host "  -> Téléchargez Docker Desktop: https://www.docker.com/get-started" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# ==========================================
# ÉTAPE 2 : Détection Docker Compose
# ==========================================
Write-Host "[2/8] Détection Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $composeCmd = "docker-compose"
        Write-Host "  [OK] Docker Compose V1 détecté" -ForegroundColor Green
    } else {
        throw "docker-compose V1 non disponible"
    }
} catch {
    try {
        $composeVersion = docker compose version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $composeCmd = "docker compose"
            Write-Host "  [OK] Docker Compose V2 détecté" -ForegroundColor Green
        } else {
            throw "Docker Compose non disponible"
        }
    } catch {
        Write-Host "  [ERREUR] Docker Compose n'est pas installé" -ForegroundColor Red
        Write-Host "  -> Mettez à jour Docker Desktop" -ForegroundColor Yellow
        exit 1
    }
}
Write-Host ""

# ==========================================
# ÉTAPE 3 : Vérification Docker Desktop
# ==========================================
Write-Host "[3/8] Vérification Docker Desktop..." -ForegroundColor Yellow
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Docker Desktop est lancé" -ForegroundColor Green
    } else {
        throw "Docker Desktop non lancé"
    }
} catch {
    Write-Host "  [INFO] Docker Desktop n'est pas lancé" -ForegroundColor Yellow
    Write-Host "  [INFO] Tentative de lancement automatique..." -ForegroundColor Cyan
    if (Start-DockerDesktop) {
        Write-Host "  [OK] Docker Desktop lancé" -ForegroundColor Green
    } else {
        Write-Host "  [ERREUR] Impossible de lancer Docker Desktop" -ForegroundColor Red
        Write-Host "  -> Lancez Docker Desktop manuellement puis relancez ce script" -ForegroundColor Yellow
        exit 1
    }
}
Write-Host ""

# ==========================================
# ÉTAPE 4 : Vérification fichiers
# ==========================================
Write-Host "[4/8] Vérification fichiers..." -ForegroundColor Yellow
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "  [INFO] docker-compose.yml introuvable" -ForegroundColor Yellow
    Write-Host "  [INFO] Tentative de récupération..." -ForegroundColor Cyan
    if (Restore-MissingFiles) {
        if (Test-Path "docker-compose.yml") {
            Write-Host "  [OK] Fichiers récupérés" -ForegroundColor Green
        } else {
            Write-Host "  [ERREUR] docker-compose.yml toujours introuvable" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "  [ERREUR] docker-compose.yml introuvable" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  [OK] Fichiers présents" -ForegroundColor Green
}
Write-Host ""

# ==========================================
# ÉTAPE 5 : Nettoyage conteneurs existants
# ==========================================
Write-Host "[5/8] Nettoyage conteneurs existants..." -ForegroundColor Yellow
try {
    $runningContainers = docker ps --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2>&1 | Where-Object { $_ -ne "" }
    if ($runningContainers.Count -gt 0) {
        Write-Host "  [INFO] Arrêt des conteneurs existants..." -ForegroundColor Cyan
        docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.ID}}" | ForEach-Object {
            docker stop $_ 2>&1 | Out-Null
            docker rm -f $_ 2>&1 | Out-Null
        }
    }
    
    if (-not [string]::IsNullOrWhiteSpace($composeCmd)) {
        Invoke-Expression "$composeCmd down -v --remove-orphans" 2>&1 | Out-Null
    }
    
    docker volume prune -f 2>&1 | Out-Null
    Write-Host "  [OK] Nettoyage terminé" -ForegroundColor Green
} catch {
    Write-Host "  [INFO] Aucun conteneur à nettoyer" -ForegroundColor Yellow
}
Write-Host ""

# ==========================================
# ÉTAPE 6 : Libération ports occupés
# ==========================================
Write-Host "[6/8] Vérification ports..." -ForegroundColor Yellow
$ports = @(9000, 9870, 16011, 2181)
$portConflicts = 0
foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        $portConflicts++
        Write-Host "  [INFO] Port $port occupé, libération..." -ForegroundColor Cyan
        Free-Port -Port $port | Out-Null
    }
}
if ($portConflicts -eq 0) {
    Write-Host "  [OK] Tous les ports sont disponibles" -ForegroundColor Green
} else {
    Write-Host "  [OK] Ports libérés" -ForegroundColor Green
}
Write-Host ""

# ==========================================
# ÉTAPE 7 : Vérification espace disque
# ==========================================
Write-Host "[7/8] Vérification espace disque..." -ForegroundColor Yellow
try {
    $disk = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq (Get-Location).Drive.Root }
    $freeGB = [math]::Round($disk.Free / 1GB, 2)
    if ($freeGB -lt 5) {
        Write-Host "  [ATTENTION] Moins de 5GB libres ($freeGB GB)" -ForegroundColor Yellow
        Write-Host "  [INFO] Nettoyage Docker..." -ForegroundColor Cyan
        docker system prune -f 2>&1 | Out-Null
        $Warnings++
    } else {
        Write-Host "  [OK] Espace suffisant: $freeGB GB" -ForegroundColor Green
    }
} catch {
    Write-Host "  [INFO] Vérification espace impossible" -ForegroundColor Yellow
    $Warnings++
}
Write-Host ""

# ==========================================
# ÉTAPE 8 : Vérification finale Docker
# ==========================================
Write-Host "[8/8] Vérification finale Docker..." -ForegroundColor Yellow
$dockerReady = $false
for ($i = 1; $i -le 10; $i++) {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $dockerReady = $true
        Write-Host "  [OK] Docker daemon accessible" -ForegroundColor Green
        break
    }
    if ($i -lt 10) {
        Start-Sleep -Seconds 2
    }
}

if (-not $dockerReady) {
    Write-Host "  [ERREUR] Docker daemon non accessible" -ForegroundColor Red
    Write-Host "  -> Attendez que Docker Desktop soit complètement démarré" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# ==========================================
# LANCEMENT DES CONTENEURS
# ==========================================
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "LANCEMENT DES CONTENEURS" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Cela peut prendre 3-5 minutes..." -ForegroundColor Gray
Write-Host ""

$maxRetries = 3
$retry = 0
$success = $false

while ($retry -lt $maxRetries -and -not $success) {
    if ($retry -gt 0) {
        Write-Host "[RETRY $retry/$maxRetries] Nouvelle tentative..." -ForegroundColor Yellow
        Invoke-Expression "$composeCmd down -v" 2>&1 | Out-Null
        Start-Sleep -Seconds 5
    }
    
    try {
        Invoke-Expression "$composeCmd up -d --build"
        if ($LASTEXITCODE -eq 0) {
            $success = $true
        } else {
            throw "Échec du démarrage"
        }
    } catch {
        $retry++
        if ($retry -lt $maxRetries) {
            Write-Host "[INFO] Échec, nouvelle tentative dans 10 secondes..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
        }
    }
}

if (-not $success) {
    Write-Host ""
    Write-Host "[ERREUR] Échec après $maxRetries tentatives" -ForegroundColor Red
    Write-Host ""
    Write-Host "Pour diagnostiquer:" -ForegroundColor Yellow
    Write-Host "  $composeCmd logs" -ForegroundColor White
    Write-Host "  $composeCmd ps" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "[OK] Conteneurs démarrés" -ForegroundColor Green
Write-Host ""
Write-Host "Attente du démarrage complet (60 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

Write-Host ""
Write-Host "Vérification de l'état..." -ForegroundColor Cyan
Invoke-Expression "$composeCmd ps"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "ENVIRONNEMENT DÉMARRÉ" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Accès aux services:" -ForegroundColor Yellow
Write-Host "  - HBase Shell: .\scripts\hbase-shell.ps1" -ForegroundColor White
Write-Host "  - Hive CLI: .\scripts\hive-cli.ps1" -ForegroundColor White
Write-Host "  - État: .\scripts\status.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Interfaces Web:" -ForegroundColor Yellow
Write-Host "  - HDFS: http://localhost:9870" -ForegroundColor White
Write-Host "  - YARN: http://localhost:8088" -ForegroundColor White
Write-Host "  - HBase: http://localhost:16011" -ForegroundColor White
Write-Host ""
Write-Host "Note: Les services peuvent prendre 2-3 minutes pour être opérationnels." -ForegroundColor Gray
Write-Host "      Si un conteneur est 'unhealthy', attendez encore 1-2 minutes." -ForegroundColor Gray
Write-Host ""

