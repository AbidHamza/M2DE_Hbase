@echo off
REM Script Batch pour ouvrir le CLI Hive (Windows)
REM Usage: scripts\hive-cli.bat

echo Ouverture du CLI Hive...
docker exec -it hbase-hive-learning-lab-hive-1 hive

