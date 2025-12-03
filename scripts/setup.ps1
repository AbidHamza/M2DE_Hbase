# Script de configuration et lancement automatique (Windows PowerShell)
# Installe les dépendances manquantes et lance l'environnement
# Usage: .\scripts\setup.ps1

$ErrorActionPreference = "Continue"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "CONFIGURATION ET LANCEMENT AUTOMATIQUE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si on est administrateur
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# 1. Vérifier Docker
Write-Host "[1/4] Vérification Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Docker installé: $dockerVersion" -ForegroundColor Green
    } else {
        throw "Docker non disponible"
    }
} catch {
    Write-Host "  ❌ Docker n'est pas installé" -ForegroundColor Red
    Write-Host "     → Installation automatique non disponible" -ForegroundColor Yellow
    Write-Host "     → Téléchargez Docker Desktop: https://www.docker.com/get-started" -ForegroundColor Yellow
    Write-Host "     → Après installation, relancez ce script" -ForegroundColor Yellow
    exit 1
}

# 2. Vérifier Docker Desktop lancé
Write-Host "[2/4] Vérification Docker Desktop..." -ForegroundColor Yellow
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Docker Desktop est lancé" -ForegroundColor Green
    } else {
        throw "Docker Desktop non lancé"
    }
} catch {
    Write-Host "  ❌ Docker Desktop n'est pas lancé" -ForegroundColor Red
    Write-Host "     → Lancement automatique..." -ForegroundColor Yellow
    
    # Essayer de lancer Docker Desktop
    $dockerDesktopPath = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerDesktopPath) {
        Start-Process $dockerDesktopPath
        Write-Host "     → Docker Desktop est en cours de lancement..." -ForegroundColor Yellow
        Write-Host "     → Attendez 30-60 secondes puis relancez ce script" -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "     → Lancez Docker Desktop manuellement depuis le menu Démarrer" -ForegroundColor Yellow
        exit 1
    }
}

# 3. Vérifier Docker Compose
Write-Host "[3/4] Vérification Docker Compose..." -ForegroundColor Yellow
$composeCmd = $null
try {
    $composeVersion = docker-compose --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $composeCmd = "docker-compose"
        Write-Host "  ✅ Docker Compose V1 détecté" -ForegroundColor Green
    } else {
        throw "docker-compose V1 non disponible"
    }
} catch {
    try {
        $composeVersion = docker compose version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $composeCmd = "docker compose"
            Write-Host "  ✅ Docker Compose V2 détecté" -ForegroundColor Green
        } else {
            throw "Docker Compose non disponible"
        }
    } catch {
        Write-Host "  ❌ Docker Compose n'est pas installé" -ForegroundColor Red
        Write-Host "     → Docker Compose est généralement inclus avec Docker Desktop" -ForegroundColor Yellow
        Write-Host "     → Mettez à jour Docker Desktop" -ForegroundColor Yellow
        exit 1
    }
}

# 4. Vérifier Git (optionnel mais recommandé)
Write-Host "[4/4] Vérification Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Git installé: $gitVersion" -ForegroundColor Green
    } else {
        throw "Git non disponible"
    }
} catch {
    Write-Host "  ⚠️  Git n'est pas installé (optionnel)" -ForegroundColor Yellow
    Write-Host "     → Recommandé pour mettre à jour le dépôt" -ForegroundColor Yellow
    Write-Host "     → Téléchargez Git: https://git-scm.com/downloads" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "TOUS LES PRÉREQUIS SONT OK" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Nettoyage complet et reconstruction automatique
Write-Host "Nettoyage complet des conteneurs et volumes..." -ForegroundColor Yellow
try {
    Invoke-Expression "$composeCmd down -v" 2>&1 | Out-Null
    Write-Host "  ✅ Nettoyage terminé" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Aucun conteneur à nettoyer" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Reconstruction des images Docker..." -ForegroundColor Yellow
Write-Host "  (Cela peut prendre 5-10 minutes la première fois)" -ForegroundColor Gray
try {
    Invoke-Expression "$composeCmd build --no-cache" 2>&1 | Out-String | ForEach-Object {
        if ($_ -match "ERROR|error|failed") {
            Write-Host $_ -ForegroundColor Red
        } else {
            Write-Host $_ -NoNewline
        }
    }
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "  ✅ Images reconstruites avec succès" -ForegroundColor Green
    } else {
        throw "Échec de la reconstruction"
    }
} catch {
    Write-Host ""
    Write-Host "  ❌ ERREUR lors de la reconstruction des images" -ForegroundColor Red
    Write-Host "     → Vérifiez les logs ci-dessus" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Lancement automatique de l'environnement..." -ForegroundColor Cyan
Write-Host ""

$runScript = Join-Path $PSScriptRoot "run.ps1"
if (Test-Path $runScript) {
    & $runScript
} else {
    Write-Host "❌ ERREUR: Script run.ps1 introuvable" -ForegroundColor Red
    exit 1
}

