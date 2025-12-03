# Script PowerShell pour ouvrir le shell HBase
# Usage: .\scripts\hbase-shell.ps1

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

Write-Host "Vérification du conteneur HBase..." -ForegroundColor Cyan

# Méthode robuste : essayer plusieurs façons de trouver le conteneur
$containerName = $null

# Méthode 1 : docker compose ps -q
try {
    $result = Invoke-Expression "$composeCmd ps -q hbase" 2>&1
    if ($LASTEXITCODE -eq 0 -and $result -and $result -notmatch "error|Error|ERROR") {
        $containerName = $result.Trim()
    }
} catch {
    # Continuer avec méthode alternative
}

# Méthode 2 : docker ps directement
if ([string]::IsNullOrEmpty($containerName)) {
    try {
        $result = docker ps --filter "name=hbase-hive-learning-lab-hbase" --format "{{.ID}}" 2>&1
        if ($LASTEXITCODE -eq 0 -and $result -and $result -notmatch "error|Error|ERROR") {
            $containerName = $result.Trim()
        }
    } catch {
        # Continuer
    }
}

if ([string]::IsNullOrEmpty($containerName)) {
    Write-Host "ERREUR: Le conteneur HBase n'est pas démarré." -ForegroundColor Red
    Write-Host ""
    Write-Host "Solutions:" -ForegroundColor Yellow
    Write-Host "  1. Vérifiez l'état: $composeCmd ps" -ForegroundColor White
    Write-Host "  2. Démarrez l'environnement: $composeCmd up -d" -ForegroundColor White
    Write-Host "  3. OU utilisez le script start: .\scripts\start.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Attendez 2-3 minutes après le démarrage pour que HBase soit prêt." -ForegroundColor Yellow
    exit 1
}

Write-Host "Ouverture du shell HBase..." -ForegroundColor Cyan
Write-Host "(Si vous voyez 'Server is not running yet', attendez 1-2 minutes)" -ForegroundColor Yellow
Write-Host ""
docker exec -it $containerName hbase shell

