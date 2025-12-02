# HBase & Hive Learning Lab

**Parcours d'apprentissage complet et guidé pour maîtriser HBase et Hive**

**NOUVEAU : Consultez [COMMENCER.md](COMMENCER.md) pour un guide ultra-simple en 5 étapes !**

---

## Démarrage Rapide (3 Étapes)

### 1. Cloner le dépôt
```bash
git clone https://github.com/AbidHamza/M2DE_Hbase.git
cd M2DE_Hbase
```

### 2. Lancer l'environnement

**Windows :**
```powershell
.\scripts\start.ps1
# Ou si PowerShell indisponible :
scripts\start.bat
```

**Linux/Mac :**
```bash
chmod +x scripts/*.sh
./scripts/start.sh
```

**Ou manuellement (toutes plateformes) :**
```bash
docker-compose up -d
```

### 3. Commencer les rooms
```bash
cd rooms/room-0_introduction
# Lisez le README.md de cette room
```

**C'est tout !** Pour plus de détails, continuez la lecture ci-dessous.

---

## 📚 Table des Matières

1. [Bienvenue](#bienvenue)
2. [Objectifs](#objectifs)
3. [Mise en Route Détaillée](#mise-en-route-détaillée)
4. [Référence des Commandes](#référence-des-commandes)
5. [Fonctionnement des Rooms](#fonctionnement-des-rooms)
6. [Instructions Git](#instructions-git)
7. [Règles de Travail](#règles-de-travail)
8. [En Cas de Problème](#en-cas-de-problème)

---

## Bienvenue

Ce module vous accompagne pas à pas dans l'apprentissage de **HBase** et **Hive**, deux technologies essentielles de l'écosystème Hadoop.

**Ce que vous allez apprendre :**
- Comment stocker et interroger des données avec HBase
- Comment analyser des données avec Hive (SQL sur Hadoop)
- Comment intégrer HBase et Hive dans un workflow complet
- Comment appliquer ces technologies à des cas réels

**Aucun prérequis avancé nécessaire** - Tout est fourni et expliqué étape par étape.

---

## Objectifs

À la fin de ce parcours, vous serez capable de :

- Comprendre Hadoop, HBase et Hive et leur rôle dans le Big Data
- Créer et manipuler des tables HBase (CRUD complet)
- Analyser des données avec Hive (requêtes SQL)
- Intégrer HBase et Hive dans un workflow analytique
- Appliquer ces notions à des datasets réels

---

## Mise en Route Détaillée

### Étape 1 : Vérifier les Prérequis

**Docker est-il installé ?**
```bash
docker --version
```
Si ça ne fonctionne pas : https://www.docker.com/get-started

**Git est-il installé ?**
```bash
git --version
```
Si ça ne fonctionne pas : https://git-scm.com/downloads

### Étape 2 : Cloner le Dépôt

```bash
git clone https://github.com/AbidHamza/M2DE_Hbase.git
cd M2DE_Hbase
```

### Étape 3 : Lancer l'Environnement

**Méthode Simple (Recommandée) :**

**Windows :**
- PowerShell : `.\scripts\start.ps1`
- Batch : `scripts\start.bat`

**Linux/Mac :**
```bash
chmod +x scripts/*.sh
./scripts/start.sh
```

**Méthode Manuelle :**
```bash
docker-compose up -d
```

**Attendez 2-3 minutes** que tous les services démarrent.

### Étape 4 : Vérifier que Tout Fonctionne

```bash
docker-compose ps
```

Tous les services doivent être "Up".

**Test rapide :**

**HBase :**
```bash
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell
# Tapez : version
# Puis : exit
```

**Hive :**
```bash
docker exec -it hbase-hive-learning-lab-hive-1 hive
# Tapez : SHOW DATABASES;
# Puis : exit;
```

### Étape 5 : Accéder aux Interfaces Web

Ouvrez dans votre navigateur :
- **HDFS** : http://localhost:9870
- **YARN** : http://localhost:8088
- **HBase** : http://localhost:16010

### Étape 6 : Commencer les Rooms

```bash
cd rooms/room-0_introduction
# Ouvrez et lisez le README.md
```

---

## Référence des Commandes

### Commandes Docker Essentielles

```bash
docker-compose up -d          # Démarrer
docker-compose down           # Arrêter
docker-compose ps             # Vérifier l'état
docker-compose logs           # Voir les logs
```

### Accès aux Services

**HBase Shell :**
```bash
docker exec -it hbase-hive-learning-lab-hbase-1 hbase shell
```

**Hive CLI :**
```bash
docker exec -it hbase-hive-learning-lab-hive-1 hive
```

**Hadoop Bash :**
```bash
docker exec -it hbase-hive-learning-lab-hadoop-1 bash
```

### Commandes HBase de Base

```hbase
list                                    # Lister les tables
create 'table', 'famille'              # Créer une table
put 'table', 'row', 'colonne', 'valeur' # Insérer des données
get 'table', 'row'                     # Récupérer une ligne
scan 'table'                           # Voir toutes les données
count 'table'                          # Compter les lignes
delete 'table', 'row'                  # Supprimer une ligne
exit                                    # Quitter
```

### Commandes Hive de Base

```sql
SHOW DATABASES;                        # Lister les bases
CREATE DATABASE nom_db;                # Créer une base
USE nom_db;                            # Utiliser une base
SHOW TABLES;                           # Lister les tables
CREATE TABLE nom_table (...);          # Créer une table
SELECT * FROM table;                   # Voir les données
DROP TABLE table;                      # Supprimer une table
exit;                                  # Quitter (avec ;)
```

**Note importante :** Hive nécessite un point-virgule `;` à la fin de chaque commande. HBase non.

**Pour la référence complète, consultez [COMMANDES_RAPIDES.md](COMMANDES_RAPIDES.md)**

---

## Fonctionnement des Rooms

### Structure Simple

Chaque room est un dossier avec un **README.md** qui contient :
- Les objectifs de la room
- Les rappels théoriques nécessaires
- Les exercices pratiques étape par étape
- Les fichiers à créer

### Progression Guidée

1. **Lire** le README de la room
2. **Comprendre** les concepts expliqués
3. **Faire** les exercices dans l'ordre
4. **Créer** les fichiers demandés
5. **Valider** que vous avez tout fait
6. **Passer** à la room suivante

### Liste des Rooms (Dans l'Ordre)

1. **Room 0** : Introduction - Prise en main
2. **Room 1** : HBase Basics - Opérations de base
3. **Room 2** : HBase Advanced - Filtres et optimisation
4. **Room 3** : Hive Introduction - Premières requêtes SQL
5. **Room 4** : Hive Advanced - Jointures et partitions
6. **Room 5** : Intégration HBase-Hive
7. **Room 6** : Cas d'usage réels
8. **Room 7** : Projet final

**Règle d'or :** Ne passez pas à la room suivante tant que vous n'avez pas terminé la précédente.

### Fichiers à Créer

Dans chaque room, vous créerez des fichiers comme :
- `room-X_exercices.md` - Documentation de vos exercices
- `room-X_commandes.hbase` ou `.hql` - Vos commandes
- `room-X_observations.md` - Vos réflexions

**Template disponible :** Copiez `rooms/template_exercices.md` pour commencer.

---

## Instructions Git

### Configuration Initiale (Une Seule Fois)

```bash
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"
```

### Enregistrer son Travail (Après Chaque Room)

**1. Ajouter les fichiers modifiés**
```bash
git add rooms/room-X_nom/*
```

**2. Créer un commit**
```bash
git commit -m "Room X terminée"
```

**3. Envoyer sur GitHub**
```bash
git push origin main
```

### Exemple Complet

```bash
# Après avoir terminé la Room 1
git add rooms/room-1_hbase_basics/*
git commit -m "Room 1 : bases de HBase complétées"
git push origin main
```

**Conseil :** Faites un commit après chaque room terminée.

---

## Règles de Travail

### Règles Importantes

1. **Travaillez uniquement dans `/rooms`** - Ne modifiez pas `/docker`, `/scripts`, `/resources`
2. **Un commit par room minimum** - Validez régulièrement votre travail
3. **Suivez l'ordre des rooms** - Chaque room prépare la suivante
4. **Documentez votre travail** - Créez les fichiers demandés dans chaque room

### Bonnes Pratiques

- Lisez attentivement chaque README de room
- Testez vos commandes avant de les documenter
- Notez vos difficultés et comment vous les avez résolues
- Demandez de l'aide si vous êtes bloqué plus de 30 minutes

---

## En Cas de Problème

### Problèmes Courants

**Les conteneurs ne démarrent pas :**
```bash
docker-compose down
docker-compose ps
docker-compose up -d
```

**Erreur "Port already in use" :**
- Un autre programme utilise le port
- Arrêtez-le ou modifiez les ports dans `docker-compose.yml`

**Les conteneurs sont "Exited" :**
```bash
docker-compose logs
```
Cela vous dira pourquoi ils se sont arrêtés.

**Réinitialiser complètement (ATTENTION : supprime les données) :**
```bash
docker-compose down -v
docker-compose up -d
```

### Aide Supplémentaire

- **FAQ** : Consultez [FAQ.md](FAQ.md) pour les questions fréquentes
- **Commandes** : Consultez [COMMANDES_RAPIDES.md](COMMANDES_RAPIDES.md)
- **Plateformes** : Consultez [PLATEFORMES.md](PLATEFORMES.md) pour Windows/Linux/Mac

---

## Structure du Dépôt

```
M2DE_Hbase/
├── README.md              ← Vous êtes ici
├── COMMANDES_RAPIDES.md    ← Référence des commandes
├── FAQ.md                  ← Questions fréquentes
├── PLATEFORMES.md          ← Instructions par plateforme
│
├── docker-compose.yml      ← Configuration Docker
│
├── rooms/                  ← Vos travaux ici
│   ├── room-0_introduction/
│   ├── room-1_hbase_basics/
│   └── ...
│
├── resources/              ← Datasets pour les exercices
├── docker/                 ← Configuration (ne pas modifier)
└── scripts/                ← Scripts d'aide (Windows/Linux/Mac)
```

---

## Prochaines Étapes

1. ✅ Vérifiez que Docker et Git sont installés
2. ✅ Clonez le dépôt
3. ✅ Lancez l'environnement (`docker-compose up -d` ou scripts)
4. ✅ Vérifiez que tout fonctionne
5. ✅ Allez dans `rooms/room-0_introduction`
6. ✅ Lisez le README.md de cette room
7. ✅ Commencez les exercices

**Bon apprentissage !**

---

## Ressources Utiles

- **Commandes rapides** : [COMMANDES_RAPIDES.md](COMMANDES_RAPIDES.md)
- **FAQ** : [FAQ.md](FAQ.md)
- **Support multi-plateforme** : [PLATEFORMES.md](PLATEFORMES.md)
- **Scripts d'aide** : [scripts/README.md](scripts/README.md)
