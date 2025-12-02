@echo off
REM Script Batch pour arrêter l'environnement (Windows)
REM Usage: scripts\stop.bat

echo Arrêt de l'environnement HBase ^& Hive...
docker-compose down
echo Environnement arrêté.

