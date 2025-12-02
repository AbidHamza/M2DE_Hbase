# Resources - Datasets

**Ce dossier contient tous les datasets utilisés dans les différentes rooms.**

**Retour au README principal → [README.md](../README.md)**

---

## Structure

- **customers/** : Données clients pour les exercices d'analyse
- **iot-logs/** : Logs IoT pour les exercices sur les données temporelles
- **sales/** : Données de ventes pour les analyses business
- **sensors/** : Données de capteurs pour les cas d'usage IoT

---

## Utilisation

Les datasets sont automatiquement montés dans les conteneurs Docker et accessibles via :
- `/data/resources/` dans les conteneurs
- `./resources/` dans le dépôt local

---

## Format des Fichiers

- **CSV** : Données tabulaires standard (séparées par virgules)
- **JSON** : Données structurées pour les intégrations (une ligne par objet JSON)

---

## Où sont Utilisés ces Datasets ?

- **customers.csv** : Room 1, Room 3, Room 4
- **sample-logs.csv** : Room 2, Room 6
- **sales-data.csv** : Room 4, Room 6
- **sensor-readings.json** : Room 2, Room 5, Room 6

Consultez le README de chaque room pour savoir quels datasets utiliser.
