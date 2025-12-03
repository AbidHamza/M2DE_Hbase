# Script pour arrêter l'environnement HBase & Hive (Windows PowerShell)
# Usage: .\scripts\stop.ps1

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
Set-Location $projectRoot

# Détecter docker-compose V1 ou V2
$composeCmd = $null
try {
    $null = docker-compose --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $composeCmd = "docker-compose"
    }
} catch {
    try {
        $null = docker compose version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $composeCmd = "docker compose"
        }
    } catch {
        $composeCmd = "docker-compose"
    }
}

Write-Host "Arrêt de l'environnement HBase & Hive..." -ForegroundColor Yellow

# Arrêter tous les conteneurs du projet
$containers = docker ps -a --filter "name=hbase-hive-learning-lab" --format "{{.Names}}" 2>&1 | Where-Object { $_ -ne "" }
if ($containers.Count -gt 0) {
    Write-Host "Conteneurs trouvés: $($containers.Count)" -ForegroundColor Cyan
    foreach ($container in $containers) {
        Write-Host "  - Arrêt de $container..." -ForegroundColor Gray
        docker stop $container 2>&1 | Out-Null
        docker rm -f $container 2>&1 | Out-Null
    }
}

# Arrêter avec docker-compose si disponible
if (-not [string]::IsNullOrWhiteSpace($composeCmd)) {
    Write-Host "Arrêt avec docker-compose..." -ForegroundColor Cyan
    Invoke-Expression "$composeCmd down" 2>&1 | Out-Null
}

Write-Host ""
Write-Host "Environnement arrêté." -ForegroundColor Green
Write-Host ""
Write-Host "Pour supprimer aussi les volumes (données):" -ForegroundColor Yellow
Write-Host "  $composeCmd down -v" -ForegroundColor White
Write-Host ""
