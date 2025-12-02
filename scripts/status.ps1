# Script PowerShell pour vérifier l'état des services
# Usage: .\scripts\status.ps1

Write-Host "État des services Docker:" -ForegroundColor Cyan
docker-compose ps

Write-Host "`nInterfaces Web disponibles:" -ForegroundColor Cyan
Write-Host "  - HDFS NameNode: http://localhost:9870" -ForegroundColor White
Write-Host "  - YARN ResourceManager: http://localhost:8088" -ForegroundColor White
Write-Host "  - HBase Master: http://localhost:16011" -ForegroundColor White

