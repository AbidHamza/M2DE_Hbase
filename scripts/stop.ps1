# Script PowerShell pour arrêter l'environnement
# Usage: .\scripts\stop.ps1

Write-Host "Arrêt de l'environnement HBase & Hive..." -ForegroundColor Yellow

docker-compose down

Write-Host "Environnement arrêté." -ForegroundColor Green

