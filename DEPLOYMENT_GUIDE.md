# 📦 Guide de Déploiement MathQuest

Ce document vous guide pour mettre votre projet sur GitHub et partager l'APK via Google Drive.

---

## 🚀 Partie 1 : Upload sur GitHub

### Étape 1 : Créer un repo GitHub

1. **Connectez-vous sur [GitHub](https://github.com)**
2. Cliquez sur **"+"** (en haut à droite) → **"New repository"**
3. Remplissez :
   - **Repository name** : `mathquest-mobile`
   - **Description** : `Application mobile gamifiée d'apprentissage - Flutter + FastAPI + PostgreSQL`
   - **Visibility** : `Public` (pour le partager dans votre candidature)
   - ✅ **Add .gitignore** : Skip (vous avez déjà un .gitignore)
   - ✅ **Add a README** : Skip (vous avez déjà un README.md)
4. Cliquez sur **"Create repository"**

### Étape 2 : Initialiser Git localement

Ouvrez PowerShell dans le répertoire du projet :

```powershell
cd "C:\Users\LEGIONE 5I PRO\Desktop\AE 2.0\mathquest-mobile"

# Initialiser Git (si pas déjà fait)
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "🎮 Initial commit - MathQuest v1.0.0

✨ Features:
- Flutter app (12 screens, 8 services)
- Python FastAPI backend (11 endpoints)
- PostgreSQL database (11 tables)
- Node.js analytics microservice
- React Native admin app
- 7 technologies integrated
- APK build (23.1 MB)
- Web build ready
"

# Configurer votre identité Git (si première fois)
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@emines.um6p.ma"
```

### Étape 3 : Pousser sur GitHub

```powershell
# Lier au repo GitHub (remplacez VOTRE_USERNAME)
git remote add origin https://github.com/VOTRE_USERNAME/mathquest-mobile.git

# Vérifier la branche
git branch -M main

# Pousser le code
git push -u origin main
```

### Étape 4 : Mettre à jour le README avec le lien GitHub

Une fois poussé, mettez à jour le lien GitHub dans README.md :

```markdown
# Ligne 19 du README.md
git clone https://github.com/VOTRE_USERNAME/mathquest-mobile.git
```

Puis :

```powershell
git add README.md
git commit -m "📝 Update GitHub clone URL"
git push
```

---

## 📱 Partie 2 : Upload APK sur Google Drive

### Étape 1 : Localiser l'APK

L'APK se trouve ici :
```
C:\Users\LEGIONE 5I PRO\Desktop\AE 2.0\mathquest-mobile\flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

**Taille** : 23.1 MB

### Étape 2 : Upload sur Google Drive

1. **Allez sur [Google Drive](https://drive.google.com)**
2. Cliquez sur **"Nouveau"** → **"Importer un fichier"**
3. Sélectionnez `app-release.apk`
4. Attendez la fin de l'upload

### Étape 3 : Générer un lien partageable

1. **Clic droit** sur le fichier `app-release.apk` dans Drive
2. Cliquez sur **"Obtenir le lien"**
3. Dans **"Accès général"** :
   - Sélectionnez **"Tous les utilisateurs disposant du lien"**
   - Type : **"Lecteur"** (pour permettre le téléchargement)
4. Cliquez sur **"Copier le lien"**
5. Vous obtiendrez un lien du type :
   ```
   https://drive.google.com/file/d/XXXXXXXXXXXXX/view?usp=sharing
   ```

### Étape 4 : Mettre à jour le README avec le lien APK

Éditez `README.md` ligne ~198 :

```markdown
### 📱 APK Android
- **Version** : 1.0.0
- **Taille** : 23.1 MB
- **Minimum SDK** : Android 6.0 (API 23)
- **Lien** : [📦 Télécharger APK sur Google Drive](https://drive.google.com/file/d/VOTRE_ID_DRIVE/view?usp=sharing)
```

Remplacez `VOTRE_ID_DRIVE` par l'ID de votre fichier.

Puis commitez :

```powershell
git add README.md
git commit -m "📱 Add Google Drive APK download link"
git push
```

---

## 📊 Partie 3 : Ajouter des Screenshots (Optionnel mais recommandé)

### Option A : Screenshots depuis le web build

1. Servez l'app web :
   ```powershell
   cd "C:\Users\LEGIONE 5I PRO\Desktop\AE 2.0\mathquest-mobile\flutter_app\build\web"
   python -m http.server 3000
   ```
2. Ouvrez http://localhost:3000 dans votre navigateur
3. Prenez des captures d'écran (touches `Win + Shift + S`)
4. Créez un dossier `screenshots/` dans le repo :
   ```powershell
   cd "C:\Users\LEGIONE 5I PRO\Desktop\AE 2.0\mathquest-mobile"
   mkdir screenshots
   ```
5. Copiez vos screenshots dedans
6. Commitez :
   ```powershell
   git add screenshots/
   git commit -m "📸 Add app screenshots"
   git push
   ```

### Option B : Upload screenshots sur Imgur

1. Allez sur [Imgur](https://imgur.com)
2. Cliquez sur **"New post"**
3. Uploadez vos screenshots
4. Copiez les liens directs des images
5. Ajoutez-les dans le README :

```markdown
## 📱 Screenshots

### Login Screen
![Login](https://i.imgur.com/XXXXX.png)

### Home Screen
![Home](https://i.imgur.com/YYYYY.png)
```

---

## 📝 Partie 4 : Créer une Release GitHub (Optionnel)

Créez une release officielle pour votre APK :

1. Sur GitHub, allez dans l'onglet **"Releases"**
2. Cliquez sur **"Create a new release"**
3. Remplissez :
   - **Tag version** : `v1.0.0`
   - **Release title** : `MathQuest v1.0.0 - Initial Release`
   - **Description** :
     ```markdown
     ## 🎮 MathQuest v1.0.0
     
     Première version stable de l'application mobile MathQuest.
     
     ### ✨ Fonctionnalités
     - 12 écrans Flutter
     - Mode Duel, Chrono, Entraînement
     - 18 badges débloquables
     - Système XP (10 niveaux)
     - Mode offline
     - Export CSV
     
     ### 📥 Downloads
     - APK Android (23.1 MB)
     ```
4. Dans **"Attach binaries"**, uploadez `app-release.apk`
5. Cliquez sur **"Publish release"**

Vous aurez alors un lien direct vers l'APK sur GitHub :
```
https://github.com/VOTRE_USERNAME/mathquest-mobile/releases/download/v1.0.0/app-release.apk
```

---

## 🎯 Résumé des liens à fournir dans votre candidature

Une fois tout fait, vous aurez :

### 1. Lien GitHub
```
https://github.com/VOTRE_USERNAME/mathquest-mobile
```

### 2. Lien APK (Google Drive)
```
https://drive.google.com/file/d/VOTRE_ID_DRIVE/view?usp=sharing
```

### 3. Lien APK (GitHub Release - optionnel)
```
https://github.com/VOTRE_USERNAME/mathquest-mobile/releases/tag/v1.0.0
```

### 4. Vidéo démo (optionnel mais fortement recommandé)

Enregistrez une démo vidéo de 2-3 minutes avec [OBS Studio](https://obsproject.com/) ou [Loom](https://www.loom.com/) :
- Login & signup
- Navigation home
- Lancer un duel
- Voir les achievements
- Profil & stats

Uploadez sur YouTube (unlisted) ou Google Drive et ajoutez le lien.

---

## ✅ Checklist finale

Avant de soumettre votre candidature, vérifiez :

- [ ] ✅ Repo GitHub créé et code poussé
- [ ] ✅ README.md complet avec badges et documentation
- [ ] ✅ .gitignore propre (pas de secrets, node_modules, build inutiles)
- [ ] ✅ APK uploadé sur Google Drive avec lien partageable
- [ ] ✅ Lien APK ajouté dans le README
- [ ] ✅ Screenshots ajoutés (optionnel)
- [ ] ✅ Release GitHub créée (optionnel)
- [ ] ✅ Vidéo démo enregistrée (optionnel mais recommandé)

---

## 🆘 Besoin d'aide ?

Si vous rencontrez des problèmes :

### Erreur Git : "Permission denied"
```powershell
# Configurez SSH ou utilisez HTTPS avec token
# Allez dans Settings → Developer settings → Personal access tokens
# Créez un token et utilisez-le comme mot de passe
```

### Erreur : "Large files detected"
```powershell
# Fichiers > 100 MB ne peuvent pas être push sur GitHub
# Utilisez Git LFS ou excluez-les via .gitignore
git lfs install
git lfs track "*.apk"
```

### APK trop volumineux pour Google Drive
- Compressez en ZIP (mais l'APK fait 23 MB, ça devrait passer)
- Ou uploadez sur alternatives : Dropbox, WeTransfer, MediaFire

---

**Bon courage pour votre candidature OCP Khouribga ! 🚀**
