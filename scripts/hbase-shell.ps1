# Script PowerShell pour ouvrir le shell HBase
# Usage: .\scripts\hbase-shell.ps1

Write-Host "Ouverture du shell HBase..." -ForegroundColor Cyan
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell

