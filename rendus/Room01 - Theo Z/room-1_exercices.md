# Room 1 - Mes exercices HBase  
**Theo Zimmermann**

---

## Exercice 1 : Création de la table

### Commandes exécutées :

#### 1. Création de la table
```
create 'customers', 'info', 'contact'
```

**Résultat :**
```
Created table customers
Took 2.2539 seconds
=> Hbase::Table - customers
```

#### 2. Vérification de la structure
```
describe 'customers'
```

**Résultat :**
```
Table customers is ENABLED
COLUMN FAMILIES DESCRIPTION
{NAME => 'contact', ...}
{NAME => 'info', ...}
2 row(s)
```

### Difficultés rencontrées :
Aucune.

---

## Exercice 2 : Insertion de données

### Commandes exécutées :

### Client CUST001
```
put 'customers', 'CUST001', 'info:name', 'Jean Dupont'
put 'customers', 'CUST001', 'info:city', 'Paris'
put 'customers', 'CUST001', 'info:country', 'France'
put 'customers', 'CUST001', 'contact:email', 'jean.dupont@email.com'
```

### Vérification :
```
get 'customers', 'CUST001'
```

**Sortie :**
```
contact:email   value=jean.dupont@email.com
info:city       value=Paris
info:country    value=France
info:name       value=Jean Dupont
```

---

### Client CUST002
```
put 'customers', 'CUST002', 'info:name', 'Marie Martin'
put 'customers', 'CUST002', 'info:city', 'Lyon'
put 'customers', 'CUST002', 'info:country', 'France'
put 'customers', 'CUST002', 'contact:email', 'marie.martin@email.com'
```

### Client CUST003
```
put 'customers', 'CUST003', 'info:name', 'Pierre Durand'
put 'customers', 'CUST003', 'info:city', 'Marseille'
put 'customers', 'CUST003', 'info:country', 'France'
put 'customers', 'CUST003', 'contact:email', 'pierre.durand@email.com'
```

### Client CUST004
```
put 'customers', 'CUST004', 'info:name', 'Sophie Bernard'
put 'customers', 'CUST004', 'info:city', 'Toulouse'
put 'customers', 'CUST004', 'info:country', 'France'
put 'customers', 'CUST004', 'contact:email', 'sophie.bernard@email.com'
```

### Client CUST005
```
put 'customers', 'CUST005', 'info:name', 'Luc Moreau'
put 'customers', 'CUST005', 'info:city', 'Nice'
put 'customers', 'CUST005', 'info:country', 'France'
put 'customers', 'CUST005', 'contact:email', 'luc.moreau@email.com'
```

---

### Comptage :
```
count 'customers'
```
**Sortie :**
```
5 row(s)
```

---

### Scan complet :
```
scan 'customers'
```
**Sortie (extrait) :**
```
CUST001 info:name=Jean Dupont
CUST002 info:city=Lyon
CUST003 info:city=Marseille
CUST004 info:name=Sophie Bernard
CUST005 info:name=Luc Moreau
```

---

### Observations :
- La syntaxe PUT est simple mais répétitive.
- Chaque PUT génère un timestamp.
- Les row keys sont triées automatiquement.

---

## Exercice 3 : Interrogation des données

### Commandes testées

#### 1. Scan complet
```
scan 'customers'
```

#### 2. GET d’un client
```
get 'customers', 'CUST002'
```

**Sortie :**
```
info:name       value=Marie Martin
info:city       value=Lyon
contact:email   value=marie.martin@email.com
```

#### 3. GET d’une colonne spécifique
```
get 'customers', 'CUST003', {COLUMN => 'contact:email'}
```

#### 4. GET d’une famille
```
get 'customers', 'CUST001', {COLUMN => 'info'}
```

#### 5. Count
```
count 'customers'
```

### Observations :
- GET est bien plus rapide que SCAN.
- SCAN parcourt toute la table, donc peut être lent.

---

## Exercice 4 : Mise à jour et suppression

### Mise à jour

#### Modifier email de CUST001
```
put 'customers', 'CUST001', 'contact:email', 'jean.dupont+new@email.com'
```

#### Ajouter un téléphone puis le supprimer
```
put 'customers', 'CUST002', 'contact:phone', '0612345678'
delete 'customers', 'CUST002', 'contact:phone'
```

### Suppression d’une ligne complète
```
deleteall 'customers', 'CUST004'
```

**Vérification :**
```
count 'customers'
```
→ 4 row(s)

### Observations :
- `put` sert aussi à mettre à jour.
- `deleteall` supprime toute la ligne.
- Les suppressions sont immédiates dans la vue logique.

---

## Exercice 5 : Filtres

### Commandes testées :

#### 1. Clients habitant Paris
```
scan 'customers', {FILTER => "ValueFilter(=, 'binary:Paris')"}
```

#### 2. Filtrer par famille
```
scan 'customers', {COLUMNS => 'info'}
```

#### 3. Limiter les résultats
```
scan 'customers', {LIMIT => 3}
```

#### 4. Combinaison LIMIT + COLUMNS
```
scan 'customers', {COLUMNS => 'info', LIMIT => 2}
```

### Observations :
- COLUMNS est très rapide (lit seulement la famille).
- ValueFilter parcourt toute la table → lent en production.
- LIMIT utile pour les tests.

---

## Réflexions sur le design

### Choix des row keys :
- `CUST001` → simple, clair.
- Limite : hotspots si insertions séquentielles massives.

### Choix des familles :
- `info` pour les données personnelles
- `contact` pour les données de contact
- Séparation propre et logique.

### Améliorations possibles :
- Ajouter une famille `orders`
- Utiliser des row keys structurées (ex : `CUST#FR#0001`)

