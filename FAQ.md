# FAQ - Questions Fréquentes

**Consultez ce fichier si vous rencontrez un problème.**

**Retour au README principal → [README.md](README.md)**

---

## Docker

### Q: "docker-compose : command not found" ou "Cannot connect to Docker"
**R:** 
- **Windows/Mac :** Docker Desktop DOIT être lancé ! Ouvrez Docker Desktop et attendez qu'il soit complètement démarré (icône visible dans la barre des tâches)
- **Linux :** Installez docker-compose séparément ou utilisez `docker compose` (sans tiret)

**Vérification :** Tapez `docker --version`. Si ça ne fonctionne pas, Docker Desktop n'est pas lancé.

### Q: Les conteneurs ne démarrent pas
**R:** 
1. Vérifiez les logs : `docker-compose logs`
2. Redémarrez : `docker-compose down` puis `docker-compose up -d`
3. Vérifiez que les ports ne sont pas déjà utilisés

### Q: "Port already in use"
**R:** Un autre programme utilise le même port. Arrêtez-le ou changez les ports dans `docker-compose.yml`.

### Q: Les conteneurs sont "Exited" (arrêtés)
**R:** Regardez les logs :
```bash
docker-compose logs
docker-compose logs hbase
docker-compose logs hive
```

### Q: "TLS handshake timeout" ou "failed to resolve source metadata"
**R:** Problème de connexion réseau avec Docker Hub. Solutions :

1. **Vérifiez votre connexion Internet**
2. **Réessayez après quelques minutes** (Docker Hub peut être temporairement indisponible)
3. **Utilisez un VPN** si vous êtes derrière un pare-feu
4. **Configurez un proxy Docker** si nécessaire
5. **Videz le cache Docker** :
   ```bash
   docker system prune -a
   docker-compose build --no-cache
   docker-compose up -d
   ```

### Q: "the attribute 'version' is obsolete"
**R:** C'est juste un avertissement. Le champ `version` a été supprimé du `docker-compose.yml` dans les versions récentes. Vous pouvez l'ignorer ou mettre à jour votre dépôt.

### Q: Comment réinitialiser complètement ?
**R:** 
```bash
docker-compose down -v
docker-compose up -d
```
**ATTENTION :** Cela supprimera toutes les données !

---

## HBase

### Q: "Table already exists"
**R:** La table existe déjà. Utilisez `list` pour voir les tables, puis `disable 'table'` et `drop 'table'` pour la supprimer.

### Q: "Unknown command"
**R:** Vérifiez l'orthographe. En HBase, pas de point-virgule à la fin. Utilisez `help` pour voir toutes les commandes.

### Q: Comment voir toutes les colonnes d'une table ?
**R:** Utilisez `scan 'table_name'` pour voir toutes les données, ou `describe 'table_name'` pour voir la structure.

---

## Hive

### Q: "ParseException" ou erreur de syntaxe
**R:** Vérifiez que vous avez bien le point-virgule `;` à la fin de chaque commande SQL.

### Q: "Table not found"
**R:** Vérifiez que vous êtes dans la bonne base de données avec `USE database_name;` et listez les tables avec `SHOW TABLES;`.

### Q: Le fichier a disparu après LOAD DATA
**R:** C'est normal ! `LOAD DATA INPATH` DÉPLACE le fichier (pas copie). Le fichier est maintenant dans le warehouse Hive.

---

## Git

### Q: "fatal: not a git repository"
**R:** Vous n'êtes pas dans un dépôt Git. Utilisez `cd` pour aller dans le dossier du projet.

### Q: "Permission denied" lors du push
**R:** Vérifiez vos identifiants GitHub. Vous devrez peut-être configurer un token d'accès personnel.

### Q: Comment annuler un commit ?
**R:** `git reset --soft HEAD~1` pour annuler le dernier commit mais garder les modifications.

---

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

**Pour plus d'infos sur les scripts → [scripts/README.md](scripts/README.md)**

---

## Général

### Q: Où sont mes données ?
**R:** Les données sont dans les volumes Docker. Pour les voir, utilisez les commandes `scan` (HBase) ou `SELECT` (Hive).

### Q: Les services sont lents - 30 minutes c'est normal ?
**R:** Non, 30 minutes c'est trop long. Vérifiez :

1. **Regardez les logs** pour voir où ça bloque :
   ```bash
   docker-compose logs
   docker-compose logs hadoop
   docker-compose logs hbase
   ```

2. **Vérifiez l'état des conteneurs** :
   ```bash
   docker-compose ps
   ```
   Si certains sont "Restarting" en boucle, il y a un problème.

3. **Problèmes courants** :
   - **Connexion Internet lente** : Les téléchargements peuvent prendre du temps
   - **Manque de ressources** : Docker a besoin de RAM (minimum 4GB recommandé)
   - **Problème de réseau** : Timeout lors du téléchargement des images

4. **Solution rapide** :
   ```bash
   # Arrêtez tout
   docker-compose down
   
   # Vérifiez votre connexion
   docker pull eclipse-temurin:8-jdk
   
   # Si ça fonctionne, relancez
   docker-compose up -d
   ```

**Temps normal :** 
- Premier lancement : 10-15 minutes maximum
- Lancements suivants : 1-2 minutes

### Q: Comment savoir si je suis dans le bon conteneur ?
**R:** Votre prompt change. Dans Hadoop : `root@hadoop:/#`, dans HBase : `hbase(main):001:0>`, dans Hive : `hive>`.

---

## Besoin d'Aide ?

1. **Erreur Hadoop "unhealthy" ?** → [DEPANNAGE_HADOOP.md](DEPANNAGE_HADOOP.md)
2. Consultez le [README.md](README.md) principal
3. Vérifiez les logs : `docker-compose logs`
4. Relisez le README de la room concernée
5. Consultez la documentation officielle HBase/Hive
