# Script de vérification COMPLÈTE avant le lancement (Windows PowerShell)
# Usage: .\scripts\check-before-start.ps1

$ErrorActionPreference = "Stop"
$Errors = 0
$Warnings = 0

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "VÉRIFICATION COMPLÈTE AVANT DÉMARRAGE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier Docker installé
Write-Host "[1/15] Vérification Docker..." -ForegroundColor Yellow
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

# 2. Vérifier docker-compose installé
Write-Host "[2/15] Vérification docker-compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ docker-compose installé: $composeVersion" -ForegroundColor Green
    } else {
        throw "docker-compose non disponible"
    }
} catch {
    Write-Host "  ❌ ERREUR: docker-compose n'est pas installé" -ForegroundColor Red
    $Errors++
}
Write-Host ""

# 3. Vérifier Docker Desktop lancé
Write-Host "[3/15] Vérification Docker Desktop..." -ForegroundColor Yellow
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Docker Desktop est lancé et fonctionne" -ForegroundColor Green
    } else {
        throw "Docker Desktop non lancé"
    }
} catch {
    Write-Host "  ❌ ERREUR: Docker Desktop n'est pas lancé" -ForegroundColor Red
    Write-Host "     → Lancez Docker Desktop depuis le menu Démarrer" -ForegroundColor Yellow
    Write-Host "     → Attendez que l'icône Docker apparaisse dans la barre des tâches" -ForegroundColor Yellow
    $Errors++
}
Write-Host ""

# 4. Vérifier Git installé
Write-Host "[4/15] Vérification Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Git installé: $gitVersion" -ForegroundColor Green
    } else {
        throw "Git non disponible"
    }
} catch {
    Write-Host "  ⚠️  AVERTISSEMENT: Git n'est pas installé" -ForegroundColor Yellow
    $Warnings++
}
Write-Host ""

# 5. Vérifier que nous sommes dans le bon répertoire
Write-Host "[5/15] Vérification répertoire..." -ForegroundColor Yellow
if (Test-Path "docker-compose.yml") {
    Write-Host "  ✅ Répertoire correct" -ForegroundColor Green
} else {
    Write-Host "  ❌ ERREUR: docker-compose.yml introuvable" -ForegroundColor Red
    Write-Host "     → Assurez-vous d'être dans le répertoire M2DE_Hbase" -ForegroundColor Yellow
    $Errors++
}
Write-Host ""

# 6. Vérifier fichiers Docker essentiels
Write-Host "[6/15] Vérification fichiers Docker..." -ForegroundColor Yellow
$requiredFiles = @(
    "docker/hadoop/Dockerfile",
    "docker/hbase/Dockerfile",
    "docker/hive/Dockerfile",
    "docker/hadoop/start-hadoop.sh",
    "docker/hbase/start-hbase.sh",
    "docker/hbase/hbase-site.xml",
    "docker/hbase/hbase-env.sh",
    "docker/hive/hive-env.sh"
)
$missingFiles = 0
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "  ❌ Fichier manquant: $file" -ForegroundColor Red
        $missingFiles++
    }
}
if ($missingFiles -eq 0) {
    Write-Host "  ✅ Tous les fichiers Docker sont présents" -ForegroundColor Green
} else {
    Write-Host "  ❌ ERREUR: $missingFiles fichier(s) manquant(s)" -ForegroundColor Red
    Write-Host "     → Faites: git pull origin main" -ForegroundColor Yellow
    $Errors++
}
Write-Host ""

# 7. Vérifier syntaxe docker-compose.yml
Write-Host "[7/15] Vérification syntaxe docker-compose.yml..." -ForegroundColor Yellow
try {
    docker-compose config 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Syntaxe docker-compose.yml valide" -ForegroundColor Green
    } else {
        throw "Syntaxe invalide"
    }
} catch {
    Write-Host "  ❌ ERREUR: Syntaxe docker-compose.yml invalide" -ForegroundColor Red
    Write-Host "     → Faites: git pull origin main" -ForegroundColor Yellow
    $Errors++
}
Write-Host ""

# 8. Vérifier JAVA_HOME dans les fichiers Docker
Write-Host "[8/15] Vérification JAVA_HOME dans Dockerfiles..." -ForegroundColor Yellow
$javaFiles = @(
    "docker/hadoop/Dockerfile",
    "docker/hbase/Dockerfile",
    "docker/hive/Dockerfile",
    "docker/hbase/hbase-env.sh",
    "docker/hive/hive-env.sh"
)
foreach ($file in $javaFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($content -match "JAVA_HOME") {
            if ($content -match "JAVA_HOME.*openjdk|JAVA_HOME.*temurin|JAVA_HOME.*dirname") {
                Write-Host "  ✅ JAVA_HOME configuré dans $(Split-Path $file -Leaf)" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  JAVA_HOME présent mais peut-être incorrect dans $(Split-Path $file -Leaf)" -ForegroundColor Yellow
                $Warnings++
            }
        } else {
            Write-Host "  ⚠️  JAVA_HOME non trouvé dans $(Split-Path $file -Leaf)" -ForegroundColor Yellow
            $Warnings++
        }
    }
}
Write-Host ""

# 9. Vérifier ports disponibles
Write-Host "[9/15] Vérification ports disponibles..." -ForegroundColor Yellow
$ports = @(9000, 9870, 16011, 16020, 16030, 2181, 9083, 10000)
$portConflicts = 0
foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "  ⚠️  Port $port est déjà utilisé" -ForegroundColor Yellow
        $portConflicts++
        $Warnings++
    }
}
if ($portConflicts -eq 0) {
    Write-Host "  ✅ Tous les ports sont disponibles" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  $portConflicts port(s) déjà utilisé(s) - peut causer des problèmes" -ForegroundColor Yellow
}
Write-Host ""

# 10. Vérifier conteneurs déjà en cours
Write-Host "[10/15] Vérification conteneurs existants..." -ForegroundColor Yellow
try {
    $containers = docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2>&1
    if ($containers) {
        $count = ($containers -split "`n" | Where-Object { $_ -ne "" }).Count
        Write-Host "  ⚠️  $count conteneur(s) existant(s)" -ForegroundColor Yellow
        Write-Host "     → Pour nettoyer: docker-compose down" -ForegroundColor Yellow
        $Warnings++
    } else {
        Write-Host "  ✅ Aucun conteneur existant" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Impossible de vérifier les conteneurs" -ForegroundColor Yellow
    $Warnings++
}
Write-Host ""

# 11. Vérifier espace disque
Write-Host "[11/15] Vérification espace disque..." -ForegroundColor Yellow
try {
    $disk = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq (Get-Location).Drive.Root }
    $freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)
    if ($freeSpaceGB -lt 5) {
        Write-Host "  ⚠️  AVERTISSEMENT: Moins de 5GB d'espace libre ($freeSpaceGB GB)" -ForegroundColor Yellow
        Write-Host "     → Recommandé: au moins 10GB" -ForegroundColor Yellow
        $Warnings++
    } else {
        Write-Host "  ✅ Espace disque suffisant: $freeSpaceGB GB" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Impossible de vérifier l'espace disque" -ForegroundColor Yellow
    $Warnings++
}
Write-Host ""

# 12. Vérifier Git à jour
Write-Host "[12/15] Vérification Git à jour..." -ForegroundColor Yellow
if (Test-Path ".git") {
    try {
        git fetch origin main 2>&1 | Out-Null
        $local = git rev-parse HEAD 2>&1
        $remote = git rev-parse origin/main 2>&1
        if ($local -ne $remote) {
            Write-Host "  ⚠️  AVERTISSEMENT: Le dépôt n'est pas à jour" -ForegroundColor Yellow
            Write-Host "     → Faites: git pull origin main" -ForegroundColor Yellow
            $Warnings++
        } else {
            Write-Host "  ✅ Dépôt à jour" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ⚠️  Impossible de vérifier (problème Git)" -ForegroundColor Yellow
        $Warnings++
    }
} else {
    Write-Host "  ⚠️  Pas un dépôt Git" -ForegroundColor Yellow
    $Warnings++
}
Write-Host ""

# 13. Vérifier permissions scripts (non applicable sur Windows)
Write-Host "[13/15] Vérification scripts..." -ForegroundColor Yellow
if (Test-Path "scripts/start.ps1") {
    Write-Host "  ✅ Scripts présents" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Scripts manquants" -ForegroundColor Yellow
    $Warnings++
}
Write-Host ""

# 14. Vérifier ressources système (mémoire)
Write-Host "[14/15] Vérification mémoire..." -ForegroundColor Yellow
try {
    $totalMem = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 0)
    if ($totalMem -lt 4) {
        Write-Host "  ⚠️  AVERTISSEMENT: Moins de 4GB RAM ($totalMem GB)" -ForegroundColor Yellow
        Write-Host "     → Recommandé: au moins 8GB" -ForegroundColor Yellow
        $Warnings++
    } else {
        Write-Host "  ✅ Mémoire suffisante: $totalMem GB" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Impossible de vérifier la mémoire" -ForegroundColor Yellow
    $Warnings++
}
Write-Host ""

# 15. Vérifier réseau Docker
Write-Host "[15/15] Vérification réseau Docker..." -ForegroundColor Yellow
try {
    $networks = docker network ls --format "{{.Name}}" 2>&1
    if ($networks -match "hbase-hive-network") {
        Write-Host "  ⚠️  Réseau Docker existant détecté" -ForegroundColor Yellow
        Write-Host "     → Pour nettoyer: docker network prune -f" -ForegroundColor Yellow
        $Warnings++
    } else {
        Write-Host "  ✅ Réseau Docker prêt à être créé" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Impossible de vérifier le réseau" -ForegroundColor Yellow
    $Warnings++
}
Write-Host ""

# Résumé
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "RÉSUMÉ DE LA VÉRIFICATION" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Erreurs bloquantes: $Errors" -ForegroundColor $(if ($Errors -gt 0) { "Red" } else { "Green" })
Write-Host "Avertissements: $Warnings" -ForegroundColor $(if ($Warnings -gt 0) { "Yellow" } else { "Green" })
Write-Host ""

if ($Errors -gt 0) {
    Write-Host "❌ ERREURS BLOQUANTES DÉTECTÉES" -ForegroundColor Red
    Write-Host "   Corrigez les erreurs ci-dessus avant de continuer." -ForegroundColor Red
    Write-Host ""
    exit 1
} elseif ($Warnings -gt 0) {
    Write-Host "⚠️  AVERTISSEMENTS DÉTECTÉS" -ForegroundColor Yellow
    Write-Host "   Vous pouvez continuer, mais certains problèmes peuvent survenir." -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Continuer quand même ? (O/N)"
    if ($response -notmatch "^[Oo]$") {
        Write-Host "Arrêté par l'utilisateur." -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✅ TOUTES LES VÉRIFICATIONS SONT PASSÉES" -ForegroundColor Green
    Write-Host "   Vous pouvez lancer docker-compose up -d" -ForegroundColor Green
    Write-Host ""
}

exit 0

