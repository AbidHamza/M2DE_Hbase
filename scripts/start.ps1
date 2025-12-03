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
Write-Host "Ce script va automatiquement :" -ForegroundColor Gray
Write-Host "  - Verifier Docker et Docker Compose" -ForegroundColor Gray
Write-Host "  - Nettoyer les conteneurs existants" -ForegroundColor Gray
Write-Host "  - Lancer tous les services (Hadoop, HBase, Hive)" -ForegroundColor Gray
Write-Host "  - Corriger automatiquement les erreurs detectees" -ForegroundColor Gray
Write-Host ""
Write-Host "Temps estime : 3-5 minutes pour le premier lancement" -ForegroundColor Yellow
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
    Write-Host "  [ERREUR] Docker n'est pas installe" -ForegroundColor Red
    Write-Host ""
    Write-Host "SOLUTION :" -ForegroundColor Yellow
    Write-Host "  1. Telechargez Docker Desktop : https://www.docker.com/get-started" -ForegroundColor White
    Write-Host "  2. Installez Docker Desktop" -ForegroundColor White
    Write-Host "  3. Lancez Docker Desktop et attendez qu'il soit pret" -ForegroundColor White
    Write-Host "  4. Relancez ce script : .\scripts\start.ps1" -ForegroundColor White
    Write-Host ""
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
        Write-Host "  [ERREUR] Docker Compose n'est pas installe" -ForegroundColor Red
        Write-Host ""
        Write-Host "SOLUTION :" -ForegroundColor Yellow
        Write-Host "  1. Mettez a jour Docker Desktop vers la derniere version" -ForegroundColor White
        Write-Host "  2. Redemarrez Docker Desktop" -ForegroundColor White
        Write-Host "  3. Relancez ce script : .\scripts\start.ps1" -ForegroundColor White
        Write-Host ""
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
        Write-Host "  [ERREUR] Impossible de lancer Docker Desktop automatiquement" -ForegroundColor Red
        Write-Host ""
        Write-Host "SOLUTION :" -ForegroundColor Yellow
        Write-Host "  1. Lancez Docker Desktop manuellement depuis le menu Demarrer" -ForegroundColor White
        Write-Host "  2. Attendez que l'icone Docker apparaisse dans la barre des taches" -ForegroundColor White
        Write-Host "  3. Verifiez que Docker fonctionne : docker info" -ForegroundColor White
        Write-Host "  4. Relancez ce script : .\scripts\start.ps1" -ForegroundColor White
        Write-Host ""
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
    Write-Host "[ERREUR] Echec apres $maxRetries tentatives" -ForegroundColor Red
    Write-Host ""
    Write-Host "DIAGNOSTIC :" -ForegroundColor Yellow
    Write-Host "  Pour voir les logs : $composeCmd logs" -ForegroundColor White
    Write-Host "  Pour voir l'etat : $composeCmd ps" -ForegroundColor White
    Write-Host ""
    Write-Host "SOLUTIONS POSSIBLES :" -ForegroundColor Yellow
    Write-Host "  1. Verifiez que Docker Desktop est bien lance" -ForegroundColor White
    Write-Host "  2. Verifiez votre connexion Internet (telechargement des images)" -ForegroundColor White
    Write-Host "  3. Verifiez l'espace disque disponible (minimum 5GB)" -ForegroundColor White
    Write-Host "  4. Essayez de nettoyer Docker : docker system prune -a" -ForegroundColor White
    Write-Host "  5. Relancez le script : .\scripts\start.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Si le probleme persiste, consultez le README.md section 'Depannage'" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "[OK] Conteneurs démarrés" -ForegroundColor Green
Write-Host ""

# ==========================================
# ÉTAPE 9 : Vérification JAVA_HOME dans les logs
# ==========================================
Write-Host "[9/9] Vérification JAVA_HOME..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

$javaHomeErrors = $false
$maxChecks = 6
$checkCount = 0

while ($checkCount -lt $maxChecks) {
    $hadoopLogs = Invoke-Expression "$composeCmd logs hadoop 2>&1" | Out-String
    
    # Détecter les erreurs JAVA_HOME (tous les patterns possibles)
    if ($hadoopLogs -match "ERROR.*JAVA_HOME.*not.*set" -or 
        $hadoopLogs -match "ERROR.*JAVA_HOME.*could not be found" -or
        $hadoopLogs -match "ERROR.*JAVA_HOME.*not set" -or
        $hadoopLogs -match "ERROR.*JAVA_HOME.*could not be found" -or
        $hadoopLogs -match "JAVA_HOME.*not.*set" -or
        $hadoopLogs -match "JAVA_HOME.*could not be found" -or
        $hadoopLogs -match "readlink.*missing operand" -or
        $hadoopLogs -match "dirname.*missing operand" -or
        $hadoopLogs -match "Cannot find Java installation" -or
        $hadoopLogs -match "Java not found") {
        
        $javaHomeErrors = $true
        Write-Host "  [ATTENTION] Erreurs JAVA_HOME détectées dans les logs" -ForegroundColor Yellow
        Write-Host "  [REPARATION] Reconstruction de l'image Hadoop..." -ForegroundColor Cyan
        
        # Arrêter les conteneurs
        Invoke-Expression "$composeCmd down -v" 2>&1 | Out-Null
        Start-Sleep -Seconds 5
        
        # Reconstruire l'image hadoop sans cache (afficher la sortie pour debug)
        Write-Host "  [INFO] Reconstruction en cours (cela peut prendre 2-3 minutes)..." -ForegroundColor Gray
        Invoke-Expression "$composeCmd build --no-cache hadoop" 2>&1 | Tee-Object -Variable buildOutput | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Image Hadoop reconstruite" -ForegroundColor Green
            Write-Host "  [INFO] Relancement des conteneurs..." -ForegroundColor Cyan
            
            # Relancer les conteneurs avec build pour être sûr
            Invoke-Expression "$composeCmd up -d --build" 2>&1 | Out-Null
            Write-Host "  [INFO] Attente du démarrage initial (45 secondes)..." -ForegroundColor Gray
            Start-Sleep -Seconds 45
            
            # Réinitialiser le compteur pour vérifier à nouveau
            $checkCount = 0
            $javaHomeErrors = $false
            continue
        } else {
            Write-Host "  [ERREUR] Échec de la reconstruction" -ForegroundColor Red
            break
        }
    } else {
        # Vérifier si Hadoop est healthy
        $hadoopStatus = Invoke-Expression "$composeCmd ps hadoop --format json" 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($hadoopStatus -and $hadoopStatus.Health -eq "healthy") {
            Write-Host "  [OK] Hadoop est opérationnel (JAVA_HOME correct)" -ForegroundColor Green
            break
        }
    }
    
    $checkCount++
    if ($checkCount -lt $maxChecks) {
        Write-Host "  [INFO] Attente du démarrage... ($checkCount/$maxChecks)" -ForegroundColor Gray
        Start-Sleep -Seconds 15
    }
}

if ($javaHomeErrors) {
    Write-Host "  [ATTENTION] Problèmes JAVA_HOME persistants" -ForegroundColor Yellow
    Write-Host "  -> Consultez les logs: $composeCmd logs hadoop" -ForegroundColor White
} else {
    Write-Host "  [OK] JAVA_HOME configuré correctement" -ForegroundColor Green
}
Write-Host ""

# ==========================================
# ÉTAPE 10 : Vérification Hive dans les logs
# ==========================================
Write-Host "[10/10] Vérification Hive..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

$hiveErrors = $false
$hiveMaxChecks = 6
$hiveCheckCount = 0

while ($hiveCheckCount -lt $hiveMaxChecks) {
    $hiveMetastoreLogs = Invoke-Expression "$composeCmd logs hive-metastore 2>&1" | Out-String
    $hiveLogs = Invoke-Expression "$composeCmd logs hive 2>&1" | Out-String
    
    # Détecter les erreurs Hive
    if ($hiveMetastoreLogs -match "Cannot find hadoop installation" -or 
        $hiveMetastoreLogs -match "HADOOP_HOME.*not.*set" -or
        $hiveMetastoreLogs -match "HADOOP_CONF_DIR.*not.*exist" -or
        $hiveMetastoreLogs -match "Hadoop binaries not found" -or
        $hiveMetastoreLogs -match "hadoop.*command not found" -or
        $hiveMetastoreLogs -match "ERROR.*JAVA_HOME" -or
        $hiveLogs -match "Cannot find hadoop installation" -or
        $hiveLogs -match "HADOOP_HOME.*not.*set" -or
        $hiveLogs -match "HADOOP_CONF_DIR.*not.*exist" -or
        $hiveLogs -match "Hadoop binaries not found" -or
        $hiveLogs -match "hadoop.*command not found") {
        
        $hiveErrors = $true
        Write-Host "  [ATTENTION] Erreurs Hive détectées dans les logs" -ForegroundColor Yellow
        Write-Host "  [REPARATION] Reconstruction de l'image Hive..." -ForegroundColor Cyan
        
        # Arrêter les conteneurs
        Invoke-Expression "$composeCmd down -v" 2>&1 | Out-Null
        Start-Sleep -Seconds 5
        
        # Reconstruire l'image hive sans cache
        Write-Host "  [INFO] Reconstruction en cours (cela peut prendre 2-3 minutes)..." -ForegroundColor Gray
        Invoke-Expression "$composeCmd build --no-cache hive" 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Image Hive reconstruite" -ForegroundColor Green
            Write-Host "  [INFO] Relancement des conteneurs..." -ForegroundColor Cyan
            
            # Relancer les conteneurs avec build
            Invoke-Expression "$composeCmd up -d --build" 2>&1 | Out-Null
            Write-Host "  [INFO] Attente du démarrage initial (45 secondes)..." -ForegroundColor Gray
            Start-Sleep -Seconds 45
            
            # Réinitialiser le compteur
            $hiveCheckCount = 0
            $hiveErrors = $false
            continue
        } else {
            Write-Host "  [ERREUR] Échec de la reconstruction" -ForegroundColor Red
            break
        }
    } else {
        # Vérifier si Hive est healthy
        $hiveMetastoreStatus = Invoke-Expression "$composeCmd ps hive-metastore --format json" 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue
        $hiveStatus = Invoke-Expression "$composeCmd ps hive --format json" 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue
        
        if (($hiveMetastoreStatus -and $hiveMetastoreStatus.Health -eq "healthy") -and 
            ($hiveStatus -and $hiveStatus.Health -eq "healthy")) {
            Write-Host "  [OK] Hive est opérationnel" -ForegroundColor Green
            break
        }
    }
    
    $hiveCheckCount++
    if ($hiveCheckCount -lt $hiveMaxChecks) {
        Write-Host "  [INFO] Attente du démarrage Hive... ($hiveCheckCount/$hiveMaxChecks)" -ForegroundColor Gray
        Start-Sleep -Seconds 15
    }
}

if ($hiveErrors) {
    Write-Host "  [ATTENTION] Problèmes Hive persistants" -ForegroundColor Yellow
    Write-Host "  -> Consultez les logs: $composeCmd logs hive-metastore hive" -ForegroundColor White
} else {
    Write-Host "  [OK] Hive configuré correctement" -ForegroundColor Green
}
Write-Host ""

Write-Host "Attente du démarrage complet (30 secondes supplémentaires)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

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

