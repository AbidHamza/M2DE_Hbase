# Script PowerShell pour arrêter l'environnement
# Usage: .\scripts\stop.ps1

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

Write-Host "Arrêt de l'environnement HBase & Hive..." -ForegroundColor Yellow

Invoke-Expression "$composeCmd down"

Write-Host "Environnement arrêté." -ForegroundColor Green

