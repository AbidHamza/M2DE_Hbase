# Script PowerShell pour vérifier l'état des services
# Usage: .\scripts\status.ps1

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

Write-Host "État des services Docker:" -ForegroundColor Cyan
Invoke-Expression "$composeCmd ps"

Write-Host "`nInterfaces Web disponibles:" -ForegroundColor Cyan
Write-Host "  - HDFS NameNode: http://localhost:9870" -ForegroundColor White
Write-Host "  - YARN ResourceManager: http://localhost:8088" -ForegroundColor White
Write-Host "  - HBase Master: http://localhost:16011" -ForegroundColor White

