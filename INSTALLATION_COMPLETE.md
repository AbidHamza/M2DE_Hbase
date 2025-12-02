# Guide d'Installation Complet - Débutant Absolu

**Ce guide explique TOUT depuis le début, étape par étape, comme si vous n'avez jamais utilisé un ordinateur.**

---

## Qu'est-ce que vous allez installer ?

Vous avez besoin de **2 programmes** sur votre ordinateur :
1. **Docker Desktop** - Pour faire fonctionner les programmes HBase et Hive
2. **Git** - Pour télécharger le projet depuis Internet

C'est tout ! Mais il faut les installer correctement.

---

## Étape 1 : Installer Docker Desktop

### Qu'est-ce que Docker Desktop ?

**Explication simple :**
Imaginez que votre ordinateur est une maison. Docker Desktop est comme une **boîte magique** qui permet de faire fonctionner plusieurs programmes en même temps sans qu'ils se marchent dessus.

**Pourquoi on en a besoin ?**
- HBase et Hive sont des programmes complexes
- Ils ont besoin d'autres programmes pour fonctionner (Hadoop, ZooKeeper)
- Docker Desktop permet de faire fonctionner TOUT ça ensemble facilement

### Comment Installer Docker Desktop ?

#### Sur Windows :

**1. Ouvrez votre navigateur Internet** (Chrome, Firefox, Edge...)

**2. Allez sur ce site :**
```
https://www.docker.com/products/docker-desktop/
```

**3. Cliquez sur le bouton "Download for Windows"**

**4. Le fichier va se télécharger** (cela peut prendre 5-10 minutes selon votre connexion Internet)

**5. Une fois téléchargé, double-cliquez sur le fichier** (il s'appelle quelque chose comme "Docker Desktop Installer.exe")

**6. Suivez les instructions à l'écran :**
   - Cliquez sur "Next" ou "Suivant"
   - Acceptez les conditions (cochez la case)
   - Cliquez sur "Install" ou "Installer"
   - Attendez que l'installation se termine (cela peut prendre 10-15 minutes)

**7. À la fin, cliquez sur "Close" ou "Fermer"**

**8. Redémarrez votre ordinateur** si on vous le demande

**9. Après le redémarrage, cherchez "Docker Desktop" dans le menu Démarrer** (en bas à gauche de l'écran)

**10. Cliquez sur "Docker Desktop" pour le lancer**

**11. Attendez que Docker Desktop démarre** :
   - Une fenêtre va s'ouvrir
   - Vous verrez "Docker Desktop is starting..."
   - Attendez jusqu'à ce que vous voyiez "Docker Desktop is running"
   - Cela peut prendre 2-3 minutes

**12. Vérifiez que Docker Desktop fonctionne :**
   - Regardez en bas à droite de votre écran
   - Vous devriez voir une **petite icône de baleine** (c'est le logo de Docker)
   - Si vous voyez cette icône = Docker Desktop est lancé et fonctionne !

#### Sur Mac :

**1. Ouvrez votre navigateur Internet** (Safari, Chrome...)

**2. Allez sur ce site :**
```
https://www.docker.com/products/docker-desktop/
```

**3. Cliquez sur le bouton "Download for Mac"**

**4. Le fichier va se télécharger** (cela peut prendre 5-10 minutes)

**5. Une fois téléchargé, ouvrez le fichier** (il s'appelle "Docker.dmg")

**6. Faites glisser l'icône Docker dans le dossier Applications**

**7. Ouvrez le dossier Applications et double-cliquez sur Docker**

**8. Suivez les instructions à l'écran**

**9. Attendez que Docker Desktop démarre** (2-3 minutes)

**10. Vérifiez que Docker Desktop fonctionne :**
   - Regardez en haut à droite de votre écran (dans la barre de menu)
   - Vous devriez voir une **petite icône de baleine**
   - Si vous voyez cette icône = Docker Desktop est lancé !

#### Sur Linux :

Sur Linux, Docker fonctionne différemment. Demandez de l'aide à votre professeur.

### Comment Vérifier que Docker Desktop est Installé ?

**1. Ouvrez un terminal** :
   - **Windows** : Appuyez sur la touche Windows, tapez "PowerShell", appuyez sur Entrée
   - **Mac** : Appuyez sur Cmd + Espace, tapez "Terminal", appuyez sur Entrée

**2. Dans le terminal, tapez exactement ceci** (copiez-collez si possible) :
```
docker --version
```

**3. Appuyez sur Entrée**

**4. Si Docker est installé, vous verrez quelque chose comme :**
```
Docker version 24.0.0, build abc123
```

**5. Si vous voyez une erreur comme "docker : command not found"** :
   - Docker Desktop n'est pas installé OU
   - Docker Desktop n'est pas lancé
   - Relancez Docker Desktop et réessayez

---

## Étape 2 : Installer Git

### Qu'est-ce que Git ?

**Explication simple :**
Git est un programme qui permet de **télécharger des projets depuis Internet** et de **sauvegarder vos modifications**.

**Pourquoi on en a besoin ?**
- Le projet HBase/Hive est sur Internet (sur GitHub)
- Git permet de le télécharger sur votre ordinateur
- Git permet aussi de mettre à jour le projet quand il y a des corrections

### Comment Installer Git ?

#### Sur Windows :

**1. Ouvrez votre navigateur Internet**

**2. Allez sur ce site :**
```
https://git-scm.com/download/win
```

**3. Le téléchargement va commencer automatiquement** (attendez 2-3 minutes)

**4. Une fois téléchargé, double-cliquez sur le fichier** (il s'appelle "Git-2.x.x-64-bit.exe")

**5. Suivez les instructions :**
   - Cliquez sur "Next" plusieurs fois
   - **IMPORTANT** : Quand on vous demande "Choosing the default editor", choisissez "Use Notepad" (c'est plus simple)
   - Continuez à cliquer sur "Next"
   - Cliquez sur "Install"
   - Attendez que l'installation se termine (2-3 minutes)

**6. Cliquez sur "Finish"**

**7. Redémarrez votre terminal PowerShell** (fermez-le et rouvrez-le)

#### Sur Mac :

**1. Ouvrez votre navigateur Internet**

**2. Allez sur ce site :**
```
https://git-scm.com/download/mac
```

**3. Cliquez sur le bouton de téléchargement**

**4. Une fois téléchargé, ouvrez le fichier et suivez les instructions**

**OU** (plus simple sur Mac) :

**1. Ouvrez le Terminal**

**2. Tapez :**
```
xcode-select --install
```

**3. Suivez les instructions à l'écran**

#### Sur Linux :

**Dans le terminal, tapez :**
```
sudo apt-get install git
```
(Appuyez sur Entrée, tapez votre mot de passe si demandé)

### Comment Vérifier que Git est Installé ?

**1. Ouvrez un terminal**

**2. Tapez exactement ceci :**
```
git --version
```

**3. Appuyez sur Entrée**

**4. Si Git est installé, vous verrez quelque chose comme :**
```
git version 2.40.0
```

**5. Si vous voyez une erreur** :
   - Git n'est pas installé
   - Réinstallez Git en suivant les étapes ci-dessus

---

## Étape 3 : Vérifier les Ressources de votre Ordinateur

### Pourquoi c'est Important ?

Docker Desktop et les programmes HBase/Hive ont besoin de **ressources** de votre ordinateur pour fonctionner :
- **RAM** (mémoire) : Pour faire fonctionner les programmes
- **Espace disque** : Pour stocker les fichiers

Si vous n'avez pas assez de ressources, ça ne fonctionnera pas.

### Comment Vérifier la RAM (Mémoire) ?

#### Sur Windows :

**1. Appuyez sur la touche Windows + X**

**2. Cliquez sur "Système"**

**3. Cherchez "RAM installée" ou "Mémoire installée"**

**4. Vous verrez quelque chose comme "8,00 Go" ou "16,00 Go"**

**Vous avez besoin d'au moins 4 Go de RAM libre.** Si vous avez 8 Go ou plus, c'est bon.

#### Sur Mac :

**1. Cliquez sur le logo Apple en haut à gauche**

**2. Cliquez sur "À propos de ce Mac"**

**3. Cherchez "Mémoire"**

**4. Vous verrez quelque chose comme "8 Go" ou "16 Go"**

**Vous avez besoin d'au moins 4 Go de RAM libre.**

### Comment Vérifier l'Espace Disque ?

#### Sur Windows :

**1. Ouvrez "Ce PC" ou "Poste de travail"**

**2. Regardez le disque C:**

**3. Vous verrez quelque chose comme "50 Go libres sur 500 Go"**

**Vous avez besoin d'au moins 10 Go d'espace libre.**

#### Sur Mac :

**1. Cliquez sur le logo Apple**

**2. Cliquez sur "À propos de ce Mac"**

**3. Cliquez sur "Stockage"**

**4. Regardez l'espace disponible**

**Vous avez besoin d'au moins 10 Go d'espace libre.**

### Que Faire si Vous N'Avez Pas Assez de Ressources ?

**Si vous n'avez pas assez de RAM :**
- Fermez les autres programmes ouverts (navigateur avec beaucoup d'onglets, jeux, etc.)
- Redémarrez votre ordinateur
- Si ça ne suffit pas, contactez votre professeur

**Si vous n'avez pas assez d'espace disque :**
- Supprimez les fichiers que vous n'utilisez plus
- Videz la corbeille
- Si ça ne suffit pas, contactez votre professeur

---

## Étape 4 : Vérifier votre Connexion Internet

### Pourquoi c'est Important ?

Pour installer Docker Desktop, Git, et télécharger le projet, vous avez besoin d'une **connexion Internet stable**.

### Comment Vérifier ?

**1. Ouvrez votre navigateur Internet**

**2. Allez sur Google.com**

**3. Si la page se charge = votre connexion Internet fonctionne**

**4. Si la page ne se charge pas = vous n'avez pas Internet**

### Que Faire si vous N'Avez Pas Internet ?

- Vérifiez que votre Wi-Fi est connecté
- Vérifiez que votre câble Ethernet est branché
- Redémarrez votre routeur/modem
- Contactez votre professeur si le problème persiste

---

## Étape 5 : Vérifier que Tout Fonctionne

### Test Complet

**1. Ouvrez un terminal**

**2. Testez Docker :**
```
docker --version
```
**Résultat attendu :** Une version de Docker (ex: Docker version 24.0.0)

**3. Testez Git :**
```
git --version
```
**Résultat attendu :** Une version de Git (ex: git version 2.40.0)

**4. Testez que Docker Desktop est lancé :**
```
docker ps
```
**Résultat attendu :** Une liste (même si elle est vide, c'est bon signe)

**Si vous voyez des erreurs :**
- Relisez les sections d'installation ci-dessus
- Vérifiez que Docker Desktop est bien lancé (icône baleine visible)
- Redémarrez votre terminal

---

## Résumé - Checklist Finale

Avant de continuer, vérifiez que vous avez :

- [ ] **Docker Desktop installé** (`docker --version` fonctionne)
- [ ] **Docker Desktop lancé** (icône baleine visible)
- [ ] **Git installé** (`git --version` fonctionne)
- [ ] **Au moins 4 Go de RAM libre**
- [ ] **Au moins 10 Go d'espace disque libre**
- [ ] **Connexion Internet qui fonctionne**

**Si TOUS ces points sont cochés = Vous êtes prêt !**

**Si un point n'est pas coché = Relisez la section correspondante ci-dessus**

---

## Prochaine Étape

Une fois que TOUT est installé et vérifié, vous pouvez :

1. Lire le fichier [CHECKLIST_DEPART.md](CHECKLIST_DEPART.md)
2. Suivre les instructions du [README.md](README.md)

**Bon courage !**

