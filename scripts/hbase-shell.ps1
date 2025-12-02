# Script PowerShell pour ouvrir le shell HBase
# Usage: .\scripts\hbase-shell.ps1

Write-Host "Vérification du conteneur HBase..." -ForegroundColor Cyan
$containerName = docker-compose ps -q hbase

if ([string]::IsNullOrEmpty($containerName)) {
    Write-Host "ERREUR: Le conteneur HBase n'est pas démarré." -ForegroundColor Red
    Write-Host "Vérifiez l'état avec: docker-compose ps" -ForegroundColor Yellow
    Write-Host "Démarrez avec: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "Ouverture du shell HBase..." -ForegroundColor Cyan
docker exec -it $containerName hbase shell

