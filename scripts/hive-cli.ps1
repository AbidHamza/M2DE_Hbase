# Script PowerShell pour ouvrir le CLI Hive
# Usage: .\scripts\hive-cli.ps1

Write-Host "Ouverture du CLI Hive..." -ForegroundColor Cyan
docker exec -it hbase-hive-learning-lab-hive-1 hive

