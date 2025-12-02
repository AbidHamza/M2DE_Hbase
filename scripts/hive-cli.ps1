# Script PowerShell pour ouvrir le CLI Hive
# Usage: .\scripts\hive-cli.ps1

Write-Host "Vérification du conteneur Hive..." -ForegroundColor Cyan
$containerName = docker-compose ps -q hive

if ([string]::IsNullOrEmpty($containerName)) {
    Write-Host "ERREUR: Le conteneur Hive n'est pas démarré." -ForegroundColor Red
    Write-Host "Vérifiez l'état avec: docker-compose ps" -ForegroundColor Yellow
    Write-Host "Démarrez avec: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "Ouverture du CLI Hive..." -ForegroundColor Cyan
docker exec -it $containerName hive

