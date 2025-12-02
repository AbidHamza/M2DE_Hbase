#!/bin/bash

# Script d'initialisation HDFS pour les rooms

echo "Initialisation des répertoires HDFS..."

docker exec hbase-hive-learning-lab-hadoop-1 hdfs dfs -mkdir -p /user/hive/warehouse
docker exec hbase-hive-learning-lab-hadoop-1 hdfs dfs -mkdir -p /data
docker exec hbase-hive-learning-lab-hadoop-1 hdfs dfs -chmod -R 777 /user/hive/warehouse
docker exec hbase-hive-learning-lab-hadoop-1 hdfs dfs -chmod -R 777 /data

echo "Répertoires HDFS créés avec succès !"
docker exec hbase-hive-learning-lab-hadoop-1 hdfs dfs -ls -R /

