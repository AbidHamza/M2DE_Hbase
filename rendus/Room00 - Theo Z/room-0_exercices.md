# Room 0 - Exercices (Théo Zimmermann)

## 🎯 Objectif de la Room 0
Vérifier que l’environnement fonctionne et manipuler les outils suivants :
- HDFS
- HBase
- Hive (théorie uniquement dans mon cas)

---

# 🧩 Exercice 1 : HDFS

### ✔️ 1. Vérification HDFS

```bash
docker exec -it hbase-hive-learning-lab-hadoop bash
hdfs dfsadmin -report
