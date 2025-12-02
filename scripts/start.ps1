# Script PowerShell pour démarrer l'environnement
# Usage: .\scripts\start.ps1

Write-Host "Démarrage de l'environnement HBase & Hive..." -ForegroundColor Green

# Exécuter la vérification complète AVANT de démarrer
$checkScript = Join-Path $PSScriptRoot "check-before-start.ps1"

if (Test-Path $checkScript) {
    Write-Host ""
    Write-Host "⚠️  VÉRIFICATION PRÉ-LANCEMENT OBLIGATOIRE" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow
    & $checkScript
    $checkExit = $LASTEXITCODE
    
    if ($checkExit -ne 0) {
        Write-Host ""
        Write-Host "❌ La vérification a échoué. Corrigez les erreurs avant de continuer." -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Démarrer les services
Write-Host "Lancement des conteneurs Docker..." -ForegroundColor Cyan
docker-compose up -d

# Attendre un peu que les services démarrent
Write-Host "Attente du démarrage des services (30 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Vérifier l'état
Write-Host "`nVérification de l'état des services..." -ForegroundColor Cyan
docker-compose ps

Write-Host "`nEnvironnement démarré !" -ForegroundColor Green
Write-Host "Pour accéder aux services:" -ForegroundColor Yellow
Write-Host "  - HBase Shell: .\scripts\hbase-shell.ps1" -ForegroundColor White
Write-Host "  - Hive CLI: .\scripts\hive-cli.ps1" -ForegroundColor White
Write-Host "  - Vérifier l'état: .\scripts\status.ps1" -ForegroundColor White

