# COMMENCER ICI - Guide Ultra-Simple

**Vous êtes nouveau ? Suivez ces 5 étapes simples.**

## Étape 1 : Installer Docker et Git

**Docker :** https://www.docker.com/get-started
**Git :** https://git-scm.com/downloads

Vérifiez l'installation :
```bash
docker --version
git --version
```

## Étape 2 : Cloner le Dépôt

```bash
git clone https://github.com/AbidHamza/M2DE_Hbase.git
cd M2DE_Hbase
```

## Étape 3 : Lancer l'Environnement

**Windows :**
```powershell
.\scripts\start.ps1
```

**Linux/Mac :**
```bash
chmod +x scripts/*.sh
./scripts/start.sh
```

**Ou simplement :**
```bash
docker-compose up -d
```

Attendez 2-3 minutes.

## Étape 4 : Vérifier

```bash
docker-compose ps
```

Tous doivent être "Up".

## Étape 5 : Commencer

```bash
cd rooms/room-0_introduction
# Ouvrez README.md et suivez les instructions
```

**C'est tout !**

---

**Besoin d'aide ?** Consultez le [README.md](README.md) principal.

