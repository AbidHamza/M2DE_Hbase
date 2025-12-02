# Script PowerShell pour démarrer l'environnement
# Usage: .\scripts\start.ps1

Write-Host "Démarrage de l'environnement HBase & Hive..." -ForegroundColor Green

# Vérifier que Docker est installé
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERREUR: Docker n'est pas installé ou pas dans le PATH" -ForegroundColor Red
    Write-Host "Téléchargez Docker depuis: https://www.docker.com/get-started" -ForegroundColor Yellow
    exit 1
}

# Vérifier que docker-compose est disponible
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "ERREUR: docker-compose n'est pas disponible" -ForegroundColor Red
    exit 1
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

