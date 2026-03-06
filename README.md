# 🎮 MathQuest - Application Mobile Gamifiée d'Apprentissage

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24.3-02569B?logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-FastAPI-009688?logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql&logoColor=white)
![React Native](https://img.shields.io/badge/React_Native-Expo-61DAFB?logo=react&logoColor=black)
![Node.js](https://img.shields.io/badge/Node.js-Express-339933?logo=node.js&logoColor=white)

**Application mobile full-stack de gestion de l'apprentissage gamifiée**  
*Projet de stage OCP Khouribga - 2026*

[📱 Télécharger APK](#-téléchargements) • [🌐 Démo Web](#-démo-en-ligne) • [📚 Documentation](#-documentation)

</div>

---

## 📋 Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Fonctionnalités](#-fonctionnalités)
- [Technologies](#️-technologies)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Téléchargements](#-téléchargements)
- [Screenshots](#-screenshots)
- [Auteur](#-auteur)

---

## 🎯 Vue d'ensemble

**MathQuest** est une application mobile complète permettant aux utilisateurs d'apprendre les mathématiques, la physique, la chimie et la culture générale via une approche gamifiée. L'application intègre un système de progression avec XP, badges, objectifs quotidiens, et modes de jeu variés.

### Problématique adressée
- Apprentissage traditionnel peu engageant
- Manque de suivi de progression personnalisé
- Besoin d'accessibilité hors connexion

### Solution apportée
- Interface moderne et intuitive avec dark mode
- Système de gamification complet (XP, badges, streak)
- Mode offline natif avec synchronisation
- Export de données pour suivi personnalisé

---

## ✨ Fonctionnalités

### 🎮 Modes de jeu
- **Duel contre Bot** : Affrontez une IA avec 3 niveaux de difficulté (Facile, Normal, Expert)
- **Mode Chrono** : Répondez au maximum de questions en 60 secondes
- **Mode Entraînement** : Pratiquez sans pression de temps
- **Mode Mixte** : Questions aléatoires de toutes les matières

### 🏆 Système de progression
- **18 badges débloquables** : Première Victoire, Perfectionniste, Expert Math, Marathon, etc.
- **Système XP & Niveaux** : 10 niveaux de progression (Débutant → Légende)
- **Objectifs quotidiens** : 5 objectifs renouvelables chaque jour
- **Streak tracking** : Compteur de jours consécutifs avec bonus visuel

### 🎨 Expérience utilisateur
- **Dark/Light mode** automatique
- **24 avatars personnalisables** (emojis)
- **Animations Lottie** : 8 animations premium (confetti, brain, rocket, trophy, etc.)
- **Glassmorphisme & Gradients neon** : Design moderne et attractif
- **Haptic feedback** : Vibration lors des interactions clés

### 📊 Gestion des données
- **Statistiques détaillées** : Win rate, précision, temps moyen, historique
- **Export CSV** : Téléchargement des statistiques personnelles
- **Graphiques interactifs** : Visualisation de la progression (fl_chart)
- **Leaderboard local** : Classement des meilleurs joueurs

### 🔒 Fonctionnalités techniques
- **Mode offline complet** : Fonctionnement sans connexion internet (100 questions locales)
- **Authentification JWT** : Sécurisation des accès utilisateurs
- **Gestion de rôles** : Utilisateur, Invité
- **API REST** : Communication backend sécurisée
- **Génération IA** : Questions générées par intelligence artificielle (GPT-4o)

---

## 🛠️ Technologies

### Mobile (Flutter 3.24.3)
```yaml
Dependencies principales:
- go_router: 14.8.1          # Navigation
- provider: 6.1.2            # State management
- lottie: 3.2.0              # Animations
- fl_chart: 0.68.0           # Graphiques
- google_fonts: 6.3.0        # Poppins font
- font_awesome_flutter: 10.7.0
- flutter_animate: 4.5.0
- shimmer: 3.0.0
- sqflite: 2.4.1             # SQLite local
- shared_preferences: 2.5.3
```

### Backend (Python FastAPI)
```python
# Stack backend
- FastAPI                    # Framework API REST
- PostgreSQL 16              # Base de données
- SQLAlchemy                 # ORM
- Pydantic                   # Validation
- JWT                        # Authentication
- OpenAI API                 # Génération IA
```

### Analytics (Node.js + Express)
```json
{
  "express": "^4.18.2",
  "socket.io": "^4.6.1",
  "pg": "^8.11.0"
}
```

### Admin (React Native - Expo)
```json
{
  "expo": "~50.0.0",
  "react-native": "0.73.4",
  "react-navigation": "^6.1.9"
}
```

---

## 🏗 Architecture

### Structure du projet
```
mathquest-mobile/
├── flutter_app/                    # Application mobile Flutter
│   ├── lib/
│   │   ├── screens/               # 12 écrans (login, home, duel, etc.)
│   │   ├── services/              # 8 services (auth, API, stats, etc.)
│   │   ├── models/                # Modèles de données
│   │   ├── data/                  # Questions locales (100)
│   │   └── theme.dart             # Thème & styles
│   ├── assets/
│   │   └── animations/            # 8 animations Lottie
│   ├── build/
│   │   ├── app/outputs/           # APK Android (23 MB)
│   │   └── web/                   # Build web
│   └── pubspec.yaml
│
├── backend/                        # API Python FastAPI
│   ├── app/
│   │   ├── models/                # 11 modèles PostgreSQL
│   │   ├── routes/                # 11 endpoints REST
│   │   ├── database.py
│   │   └── main.py
│   └── requirements.txt
│
├── node-analytics/                 # Microservice analytics
│   ├── server.js                  # Express + Socket.IO
│   └── package.json
│
└── admin-app/                      # Admin React Native
    ├── src/
    └── package.json
```

### Base de données PostgreSQL (11 tables)
```sql
- users                  # Utilisateurs
- questions              # Questions
- subjects               # Matières
- duels                  # Historique duels
- scores                 # Scores individuels
- achievements           # Badges
- achievement_unlocks    # Badges débloqués
- daily_streaks          # Compteur streak
- xp_levels              # Niveaux XP
- daily_goals            # Objectifs quotidiens
- progress               # Progression par matière
```

### API REST (11 endpoints)
```
POST   /auth/register          # Inscription
POST   /auth/login             # Connexion
GET    /subjects               # Liste matières
GET    /questions?subject=X    # Questions filtrées
POST   /duels                  # Créer duel
GET    /progress               # Progression utilisateur
GET    /achievements           # Liste badges
POST   /ai/generate            # Générer questions IA
GET    /leaderboard            # Classement
GET    /stats                  # Statistiques
POST   /export/csv             # Export données
```

---

## 🚀 Installation

### Prérequis
- Flutter SDK 3.24.3+
- Python 3.11+
- PostgreSQL 16
- Node.js 18+

### 1️⃣ Application Mobile (Flutter)

```bash
# Cloner le repo
git clone https://github.com/VOTRE_USERNAME/mathquest-mobile.git
cd mathquest-mobile/flutter_app

# Installer les dépendances
flutter pub get

# Lancer sur Android/iOS
flutter run

# Build APK
flutter build apk --release

# Build Web
flutter build web --release
```

### 2️⃣ Backend (Python FastAPI)

```bash
cd backend

# Créer environnement virtuel
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Installer dépendances
pip install -r requirements.txt

# Configurer PostgreSQL
createdb mathquest

# Lancer serveur (port 8000)
uvicorn app.main:app --reload
```

### 3️⃣ Analytics (Node.js)

```bash
cd node-analytics

# Installer dépendances
npm install

# Lancer serveur (port 3001)
node server.js
```

### 4️⃣ Admin (React Native)

```bash
cd admin-app

# Installer dépendances
npm install

# Lancer Expo
npm start
```

---

## 📥 Téléchargements

### 📱 APK Android
- **Version** : 1.0.0
- **Taille** : 23.1 MB
- **Minimum SDK** : Android 6.0 (API 23)
- **Lien** : [📦 Télécharger APK sur Google Drive](VOTRE_LIEN_GOOGLE_DRIVE)
  - *Remplacez `VOTRE_LIEN_GOOGLE_DRIVE` par votre lien après upload*

### 🌐 Démo en ligne
- **Build Web** : Disponible après `flutter build web --release`
- **Emplacement** : `flutter_app/build/web/`
- **Serveur local** : `python -m http.server 3000`

---

## 📱 Screenshots

### Écrans principaux

#### 🔐 Authentification
- **Login** : Dark glassmorphism, mesh gradients, 18 symboles flottants
- **Signup** : Validation complète, 4 champs sécurisés, animations Lottie

#### 🏠 Home & Navigation
- **Home Screen** : Hero gradient navy-purple, 4 quick actions, daily challenge, stats section
- **Subject Cards** : 4 matières, progress bars, mode mixte

#### ⚔️ Modes de jeu
- **Duel Screen** : Bot AI (3 niveaux), timer 20s, power-ups, combo multiplier
- **Subject Picker** : Glass cards, mesh backgrounds, staggered animations

#### 🏆 Progression
- **Achievements** : 18 badges, shimmer locks, gradient cards
- **Profile** : Stats détaillées, graphiques fl_chart, export CSV

---

## 🎨 Design System

### Palette de couleurs (Poppins Font)
```dart
// Brand colors
primary: #1E88E5 (Blue)
accent: #8E24AA (Purple)
success: #43A047 (Green)
warning: #FFB300 (Amber)

// Neon palette
neonBlue: #00D4FF
neonPurple: #7C3AED
neonPink: #EC4899
neonGreen: #10B981

// Dark theme
darkBg: #0B0F19
darkCard: #1A2235
```

### Composants réutilisables
- `glassCard()` - Cartes glassmorphes
- `glowCard()` - Cartes avec glow effect
- `gradientCard()` - Cartes à gradient
- `sectionHeader()` - En-têtes de sections

---

## 📊 Statistiques du projet

- **12** écrans Flutter
- **8** services métier
- **100** questions locales (4 matières × 25)
- **18** badges débloquables
- **10** niveaux XP
- **8** animations Lottie
- **24** avatars personnalisables
- **11** tables PostgreSQL
- **11** endpoints API
- **7** technologies intégrées

---

## 🔐 Sécurité

- Authentification JWT avec refresh tokens
- Validation Pydantic côté backend
- Sanitization des entrées utilisateur
- HTTPS requis en production
- SQLAlchemy ORM (protection SQL injection)
- Rate limiting sur API

---

## 🧪 Tests

```bash
# Tests unitaires Flutter
flutter test

# Tests d'intégration
flutter test integration_test/

# Tests backend
pytest backend/tests/
```

---

## 📈 Roadmap

### Version 1.1 (À venir)
- [ ] Mode multijoueur en ligne (Socket.IO)
- [ ] Notifications push (FCM)
- [ ] Mode révision avec flashcards
- [ ] Intégration Google Sign-In
- [ ] Rangs compétitifs (Bronze → Diamant)

### Version 2.0 (Futur)
- [ ] Mode examen blanc
- [ ] Génération de questions par IA GPT-4
- [ ] Analyse de performance par IA
- [ ] Duels en temps réel

---

## 👨‍💻 Auteur

**Iliass** - Élève Ingénieur 4ème année EMINES  
📧 Email: votre.email@emines.um6p.ma  
💼 LinkedIn: [Votre profil LinkedIn](https://linkedin.com/in/votre-profil)  
🎓 Projet de stage OCP Khouribga - 2026

---

## 📄 Licence

Ce projet est développé dans le cadre d'un stage académique à OCP Khouribga.

---

## 🙏 Remerciements

- **OCP Khouribga** - Encadrement du projet
- **EMINES** - Formation en génie informatique
- **Flutter Community** - Documentation et ressources
- **LottieFiles** - Animations premium

---

<div align="center">

**⭐ Si ce projet vous intéresse, n'hésitez pas à le star !**

Made with ❤️ by Iliass | 2026

</div>
