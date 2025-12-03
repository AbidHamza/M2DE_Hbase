# Script PowerShell pour accéder au shell Hadoop
# Usage: .\scripts\hadoop-shell.ps1

# Changer vers le répertoire du projet (peu importe où le projet est cloné)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
Set-Location $projectRoot

# Détecter docker-compose V1 ou V2
if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
    $composeCmd = "docker-compose"
} else {
    try {
        $null = docker compose version 2>&1
        if ($?) {
            $composeCmd = "docker compose"
        } else {
            $composeCmd = "docker-compose"
        }
    } catch {
        $composeCmd = "docker-compose"
    }
}

Write-Host "Vérification du conteneur Hadoop..." -ForegroundColor Cyan

# Méthode robuste : essayer plusieurs façons de trouver le conteneur
$containerName = $null

# Méthode 1 : docker compose ps -q
try {
    $result = Invoke-Expression "$composeCmd ps -q hadoop" 2>&1
    if ($LASTEXITCODE -eq 0 -and $result -and $result -notmatch "error|Error|ERROR") {
        $containerName = $result.Trim()
    }
} catch {
    # Continuer avec méthode alternative
}

# Méthode 2 : docker ps directement
if ([string]::IsNullOrEmpty($containerName)) {
    try {
        $result = docker ps --filter "name=hbase-hive-learning-lab-hadoop" --format "{{.ID}}" 2>&1
        if ($LASTEXITCODE -eq 0 -and $result -and $result -notmatch "error|Error|ERROR") {
            $containerName = $result.Trim()
        }
    } catch {
        # Continuer
    }
}

if ([string]::IsNullOrEmpty($containerName)) {
    Write-Host "ERREUR: Le conteneur Hadoop n'est pas démarré." -ForegroundColor Red
    Write-Host ""
    Write-Host "Solutions:" -ForegroundColor Yellow
    Write-Host "  1. Vérifiez l'état: $composeCmd ps" -ForegroundColor White
    Write-Host "  2. Démarrez l'environnement: $composeCmd up -d" -ForegroundColor White
    Write-Host "  3. OU utilisez le script start: .\scripts\start.ps1" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "Ouverture du shell Hadoop..." -ForegroundColor Cyan
Write-Host ""
docker exec -it $containerName bash

