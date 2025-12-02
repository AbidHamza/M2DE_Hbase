# FAQ - Questions Fréquentes

## Docker

### Q: "docker-compose : command not found"
**R:** Vérifiez que Docker Desktop est bien lancé sur Windows/Mac. Sur Linux, installez docker-compose séparément.

### Q: Les conteneurs ne démarrent pas
**R:** 
1. Vérifiez les logs : `docker-compose logs`
2. Redémarrez : `docker-compose down` puis `docker-compose up -d`
3. Vérifiez que les ports ne sont pas déjà utilisés

### Q: "Port already in use"
**R:** Un autre programme utilise le port. Arrêtez-le ou modifiez les ports dans `docker-compose.yml`.

## HBase

### Q: "Table already exists"
**R:** La table existe déjà. Utilisez `list` pour voir les tables, puis `disable 'table'` et `drop 'table'` pour la supprimer.

### Q: "Unknown command"
**R:** Vérifiez l'orthographe. En HBase, pas de point-virgule à la fin. Utilisez `help` pour voir toutes les commandes.

### Q: Comment voir toutes les colonnes d'une table ?
**R:** Utilisez `scan 'table_name'` pour voir toutes les données, ou `describe 'table_name'` pour voir la structure.

## Hive

### Q: "ParseException" ou erreur de syntaxe
**R:** Vérifiez que vous avez bien le point-virgule `;` à la fin de chaque commande SQL.

### Q: "Table not found"
**R:** Vérifiez que vous êtes dans la bonne base de données avec `USE database_name;` et listez les tables avec `SHOW TABLES;`.

### Q: Le fichier a disparu après LOAD DATA
**R:** C'est normal ! `LOAD DATA INPATH` DÉPLACE le fichier (pas copie). Le fichier est maintenant dans le warehouse Hive.

## Git

### Q: "fatal: not a git repository"
**R:** Vous n'êtes pas dans un dépôt Git. Utilisez `cd` pour aller dans le dossier du projet.

### Q: "Permission denied" lors du push
**R:** Vérifiez vos identifiants GitHub. Vous devrez peut-être configurer un token d'accès personnel.

### Q: Comment annuler un commit ?
**R:** `git reset --soft HEAD~1` pour annuler le dernier commit mais garder les modifications.

## Scripts Multi-plateforme

### Q: Je suis sur Mac/Linux, les scripts PowerShell ne fonctionnent pas
**R:** Utilisez les scripts `.sh` à la place. Rendez-les exécutables avec `chmod +x scripts/*.sh` puis utilisez `./scripts/start.sh`.

### Q: Je suis sur Windows mais PowerShell n'est pas disponible
**R:** Utilisez les scripts `.bat` à la place : `scripts\start.bat`.

### Q: Comment rendre les scripts exécutables sur Linux/Mac ?
**R:** 
```bash
chmod +x scripts/*.sh
```

### Q: Les scripts ne s'exécutent pas sur Windows
**R:** 
- Pour PowerShell : `.\scripts\start.ps1` (avec le point et le backslash)
- Pour Batch : `scripts\start.bat` (sans le point)
- Vérifiez que vous êtes dans le bon dossier

## Général

### Q: Où sont mes données ?
**R:** Les données sont dans les volumes Docker. Pour les voir, utilisez les commandes `scan` (HBase) ou `SELECT` (Hive).

### Q: Comment réinitialiser complètement ?
**R:** `docker-compose down -v` (ATTENTION : supprime toutes les données !)

### Q: Les services sont lents
**R:** C'est normal au démarrage. Attendez 2-3 minutes que tout soit complètement démarré.

### Q: Comment savoir si je suis dans le bon conteneur ?
**R:** Votre prompt change. Dans Hadoop : `root@hadoop:/#`, dans HBase : `hbase(main):001:0>`, dans Hive : `hive>`.

## Besoin d'Aide ?

1. Consultez le README.md principal
2. Vérifiez les logs : `docker-compose logs`
3. Relisez le README de la room concernée
4. Consultez la documentation officielle HBase/Hive

