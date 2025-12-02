# Problème Port Bloqué sur Windows

**Erreur : "access forbidden by its access permissions" sur le port 16010**

## Explication

Sur Windows, certains ports peuvent être **réservés par le système** ou bloqués par des restrictions de sécurité. Le port 16010 (HBase Master Web UI) est dans ce cas.

## Solutions

### Solution 1 : Vérifier quel programme utilise le port

**Dans PowerShell (en tant qu'administrateur) :**
```powershell
netstat -ano | findstr :16011
```

Cela vous dira quel processus utilise le port. Notez le PID (dernier nombre).

**Pour arrêter le processus :**
```powershell
taskkill /PID <numéro_PID> /F
```

### Solution 2 : Changer le port dans docker-compose.yml

**Modifiez le fichier `docker-compose.yml` :**

Trouvez la section `hbase` et changez :
```yaml
ports:
  - "16010:16010"  # HBase Master Web UI
```

Par :
```yaml
ports:
  - "16011:16010"  # HBase Master Web UI (port changé)
```

**Puis relancez :**
```bash
docker-compose down
docker-compose up -d
```

**Note :** Le port a été changé par défaut à 16011 dans le dépôt. L'interface HBase est maintenant accessible sur http://localhost:16011

### Solution 3 : Redémarrer Docker Desktop en Administrateur

1. Fermez Docker Desktop complètement
2. Clic droit sur Docker Desktop → "Exécuter en tant qu'administrateur"
3. Attendez qu'il démarre complètement
4. Réessayez : `docker-compose up -d`

### Solution 4 : Redémarrer l'ordinateur

Parfois Windows libère les ports réservés après un redémarrage.

### Solution 5 : Vérifier les ports réservés Windows

**Dans PowerShell (en tant qu'administrateur) :**
```powershell
netsh interface ipv4 show excludedportrange protocol=tcp
```

Cela montre les plages de ports réservés par Windows. Si 16011 est dans une plage réservée, utilisez la Solution 2 pour changer le port.

## Ports Utilisés par le Dépôt

Si plusieurs ports posent problème, voici tous les ports utilisés :

- **9870** : HDFS NameNode Web UI
- **8088** : YARN ResourceManager Web UI
- **9000** : HDFS
- **2181** : ZooKeeper
- **16011** : HBase Master Web UI (changé de 16010 pour éviter conflit Windows)
- **16020** : HBase RegionServer Web UI
- **16030** : HBase REST API
- **10000** : HiveServer2
- **10002** : Hive Web UI

Vous pouvez changer n'importe lequel de ces ports dans `docker-compose.yml` si nécessaire.

## Vérification

**Après avoir appliqué une solution :**
```bash
docker-compose ps
```

Tous les conteneurs doivent être "Up" et "healthy".

---

**Retour au README principal → [README.md](README.md)**

