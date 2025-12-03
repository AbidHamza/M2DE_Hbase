# Script PowerShell pour ouvrir le shell HBase
# Usage: .\scripts\hbase-shell.ps1

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

Write-Host "Vérification du conteneur HBase..." -ForegroundColor Cyan
$containerName = Invoke-Expression "$composeCmd ps -q hbase"

if ([string]::IsNullOrEmpty($containerName)) {
    Write-Host "ERREUR: Le conteneur HBase n'est pas démarré." -ForegroundColor Red
    Write-Host "Vérifiez l'état avec: $composeCmd ps" -ForegroundColor Yellow
    Write-Host "Démarrez avec: $composeCmd up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "Ouverture du shell HBase..." -ForegroundColor Cyan
docker exec -it $containerName hbase shell

