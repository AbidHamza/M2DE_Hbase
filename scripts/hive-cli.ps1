# Script PowerShell pour ouvrir le CLI Hive
# Usage: .\scripts\hive-cli.ps1

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

Write-Host "Vérification du conteneur Hive..." -ForegroundColor Cyan
$containerName = Invoke-Expression "$composeCmd ps -q hive"

if ([string]::IsNullOrEmpty($containerName)) {
    Write-Host "ERREUR: Le conteneur Hive n'est pas démarré." -ForegroundColor Red
    Write-Host "Vérifiez l'état avec: $composeCmd ps" -ForegroundColor Yellow
    Write-Host "Démarrez avec: $composeCmd up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "Ouverture du CLI Hive..." -ForegroundColor Cyan
docker exec -it $containerName hive

