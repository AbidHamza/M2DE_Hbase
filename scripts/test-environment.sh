#!/bin/bash

echo "=========================================="
echo "Test de l'environnement HBase & Hive"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test Hadoop
echo "1. Test Hadoop HDFS..."
if docker exec hbase-hive-learning-lab-hadoop-1 hdfs dfsadmin -report > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Hadoop HDFS est opérationnel${NC}"
else
    echo -e "${RED}✗ Hadoop HDFS n'est pas accessible${NC}"
fi

# Test ZooKeeper
echo "2. Test ZooKeeper..."
if docker exec hbase-hive-learning-lab-zookeeper-1 nc -z localhost 2181 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ ZooKeeper est opérationnel${NC}"
else
    echo -e "${RED}✗ ZooKeeper n'est pas accessible${NC}"
fi

# Test HBase
echo "3. Test HBase..."
if docker exec hbase-hive-learning-lab-hbase-1 hbase shell -n version > /dev/null 2>&1; then
    echo -e "${GREEN}✓ HBase est opérationnel${NC}"
else
    echo -e "${RED}✗ HBase n'est pas accessible${NC}"
fi

# Test Hive Metastore
echo "4. Test Hive Metastore..."
if docker exec hbase-hive-learning-lab-hive-metastore-1 nc -z localhost 9083 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Hive Metastore est opérationnel${NC}"
else
    echo -e "${RED}✗ Hive Metastore n'est pas accessible${NC}"
fi

# Test Hive
echo "5. Test Hive..."
if docker exec hbase-hive-learning-lab-hive-1 hive --version > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Hive est opérationnel${NC}"
else
    echo -e "${RED}✗ Hive n'est pas accessible${NC}"
fi

echo ""
echo "=========================================="
echo "Résumé des services"
echo "=========================================="
docker-compose ps

echo ""
echo "Pour accéder aux interfaces :"
echo "- HDFS Web UI: http://localhost:9870"
echo "- YARN Web UI: http://localhost:8088"
echo "- HBase Web UI: http://localhost:16010"
echo ""
echo "Pour accéder aux shells :"
echo "- HBase: docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell"
echo "- Hive: docker exec -it hbase-hive-learning-lab-hive-1 hive"

