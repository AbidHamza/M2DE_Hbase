────────────────────────────────────────────────────────────
📄 FICHIER : README.md
────────────────────────────────────────────────────────────

# Room 00 – Rendu par Théo Zimmermann

Ce dossier contient mon travail pour la **Room 0 – Introduction à l’environnement Hadoop/HBase/Hive**.

---

## 📁 Fichiers fournis

### `room-0_exercices.md`
→ Contient toutes les commandes exécutées et les résultats réels obtenus dans :
- HDFS
- HBase
- (Hive théorique)

---

## ✔️ Résumé du travail effectué

### 🔹 HDFS
- Accès au conteneur Hadoop
- Vérification de l’état du cluster (`dfsadmin -report`)
- Création du dossier `/data/test`
- Création d’un fichier local `/tmp/test.txt`
- Copie dans HDFS
- Lecture du fichier depuis HDFS (`hdfs dfs -cat`)

### 🔹 HBase
- Accès au shell HBase
- Vérification du cluster (`version`, `status`, `list`)
- Création de la table `test_table`
- Insertion de données (`put`)
- Lecture avec `scan` + `get`

### 🔹 Hive
- CLI lancé correctement
- Problème technique lors du test
- Commandes théoriques comprises et listées

---

## 👤 Auteur
**Théo Zimmermann – M2 Data Engineering**

Rendu dans :  
`rendus/Room00 - Theo Z/`

────────────────────────────────────────────────────────────
📄 FICHIER : room-0_exercices.md
────────────────────────────────────────────────────────────

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
```

**Résultat :**
- 1 datanode Alive
- Aucun bloc manquant/corrompu
- HDFS OK

---

### ✔️ 2. Listing de la racine HDFS

```bash
hdfs dfs -ls /
```

Résultat :
```
/hbase
/tmp
```

---

### ✔️ 3. Création du dossier `/data/test`

```bash
hdfs dfs -mkdir -p /data/test
hdfs dfs -ls /data
```

Résultat :
```
drwxr-xr-x   - root supergroup 0 /data/test
```

---

### ✔️ 4. Création du fichier + upload dans HDFS

Création locale :

```bash
echo "Ceci est un test" > /tmp/test.txt
cat /tmp/test.txt
```

Résultat :
```
Ceci est un test
```

Upload vers HDFS :

```bash
hdfs dfs -put /tmp/test.txt /data/test/
hdfs dfs -ls /data/test/
hdfs dfs -cat /data/test/test.txt
```

Résultat :
```
Ceci est un test
```

➡️ HDFS validé avec succès 🎉

---

# 🧩 Exercice 2 : HBase

### ✔️ 1. Lancement du shell

```bash
exit
docker exec -it hbase-hive-learning-lab-hbase hbase shell
```

Prompt :
```
hbase:001:0>
```

---

### ✔️ 2. Vérifications de base

```hbase
version
status
list
```

Résultat :
- Version : 2.5.0
- 1 active master
- 0 dead servers
- Liste vide → OK

---

### ✔️ 3. Création de la table

```hbase
create 'test_table', 'info'
describe 'test_table'
```

Résultat :
- Table ENABLED
- Famille de colonnes : `info`

---

### ✔️ 4. Insertions

```hbase
put 'test_table', 'row1', 'info:name', 'Test'
put 'test_table', 'row1', 'info:age', '25'
```

---

### ✔️ 5. Lecture

```hbase
scan 'test_table'
```

Résultat :
```
row1 info:name Test
row1 info:age 25
```

```hbase
get 'test_table', 'row1'
```

➡️ HBase validé 🎉

---

# 🧩 Exercice 3 : Hive (théorique)

Hive ne fonctionnait pas correctement sur ma machine, mais voici les commandes attendues :

```sql
SHOW DATABASES;
CREATE DATABASE test_db;
USE test_db;
SHOW TABLES;
SELECT current_database();
DROP DATABASE test_db;
exit;
```

➡️ Compréhension OK  
➡️ Exécution pratique reportée

---

# 🟢 Conclusion

J’ai réussi :
- Les opérations HDFS
- La manipulation complète d’une table HBase
- La compréhension de Hive
