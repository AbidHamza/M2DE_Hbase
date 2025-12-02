@echo off
REM Script Batch pour vérifier l'état des services (Windows)
REM Usage: scripts\status.bat

echo État des services Docker:
docker-compose ps

echo.
echo Interfaces Web disponibles:
echo   - HDFS NameNode: http://localhost:9870
echo   - YARN ResourceManager: http://localhost:8088
echo   - HBase Master: http://localhost:16010

