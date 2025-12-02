# Checklist de Départ - À Vérifier AVANT de Commencer

**Vérifiez TOUS ces points avant de lancer Docker !**

## ✅ Prérequis Obligatoires

**Vous ne savez pas comment installer ?** 
→ Guide complet étape par étape : [INSTALLATION_COMPLETE.md](INSTALLATION_COMPLETE.md)

### 1. Docker Desktop (Windows/Mac)
- [ ] Docker Desktop est **installé**
- [ ] Docker Desktop est **lancé** (icône visible dans la barre des tâches)
- [ ] Docker Desktop est **complètement démarré** (attendez 1-2 minutes après le lancement)
- [ ] Vérification : `docker --version` fonctionne

**SANS Docker Desktop lancé = RIEN ne fonctionnera sur Windows/Mac !**

### 2. Git
- [ ] Git est installé
- [ ] Vérification : `git --version` fonctionne

### 3. Ressources Système
- [ ] **RAM disponible :** Au moins 4GB libre (8GB recommandé)
- [ ] **Espace disque :** Au moins 10GB libre
- [ ] **Connexion Internet :** Stable (pour télécharger les images Docker)

### 4. Dépôt à Jour
- [ ] Dépôt cloné : `git clone https://github.com/AbidHamza/M2DE_Hbase.git`
- [ ] Dépôt à jour : `git pull origin main` (fait régulièrement)
- [ ] Vous êtes dans le bon dossier : `cd M2DE_Hbase`

## ✅ Vérifications Avant Lancement

### 1. Docker Fonctionne ?
```bash
docker --version
docker ps
```
Si ces commandes ne fonctionnent pas → Docker Desktop n'est pas lancé !

### 2. Ports Disponibles ?
Les ports suivants doivent être libres :
- 9870 (HDFS)
- 8088 (YARN)
- 9000 (HDFS)
- 2181 (ZooKeeper)
- 16011, 16020, 16030 (HBase) - Note: 16011 au lieu de 16010 pour éviter conflit Windows
- 10000, 10002 (Hive)

Si un port est utilisé, arrêtez le programme qui l'utilise.

### 3. Anciennes Instances Docker ?
```bash
docker-compose ps
```
Si des conteneurs sont déjà en cours, arrêtez-les :
```bash
docker-compose down
```

## ✅ Lancement

Une fois TOUT vérifié :

```bash
# Windows
.\scripts\start.ps1
# Ou
docker-compose up -d

# Linux/Mac
./scripts/start.sh
# Ou
docker-compose up -d
```

## ✅ Après Lancement

### Temps d'Attente Normal
- **Premier lancement :** 10-15 minutes MAXIMUM
- **Lancements suivants :** 1-2 minutes

### Vérification
Après 10-15 minutes :
```bash
docker-compose ps
```

Tous les conteneurs doivent être :
- **Status :** "Up"
- **Health :** "healthy" (pour hadoop, zookeeper, hbase)

## ❌ Si Ça Ne Fonctionne Pas

### Erreurs Courantes

**"JAVA_HOME is not set"**
→ Mettez à jour : `git pull origin main` puis reconstruisez

**"exited (127)"**
→ Mettez à jour : `git pull origin main` puis reconstruisez

**"unhealthy"**
→ Consultez [DEPANNAGE_HADOOP.md](DEPANNAGE_HADOOP.md)

**Bloque depuis 30+ minutes**
→ Arrêtez tout, vérifiez votre connexion Internet, reconstruisez

### Diagnostic
```bash
docker-compose logs hadoop
docker-compose logs hbase
docker-compose ps
```

## 📚 Ressources

- **Problèmes généraux** → [FAQ.md](FAQ.md)
- **Erreur Hadoop** → [DEPANNAGE_HADOOP.md](DEPANNAGE_HADOOP.md)
- **README principal** → [README.md](README.md)

---

**IMPORTANT :** Ne lancez JAMAIS Docker sans avoir vérifié cette checklist !

