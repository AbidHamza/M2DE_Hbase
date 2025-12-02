@echo off
REM Script Batch pour ouvrir le shell HBase (Windows)
REM Usage: scripts\hbase-shell.bat

echo Ouverture du shell HBase...
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell

