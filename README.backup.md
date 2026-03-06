# MathQuest Mobile

Application mobile d'apprentissage gamifié des mathématiques — Projet de stage AE.

---

## 🛠️ Stack Technique Complète

| Couche | Technologie | Rôle |
|--------|-------------|------|
| 📱 **App Mobile** | **Flutter / Dart** | Application principale (iOS, Android, Web) |
| 📱 **App Admin** | **React Native (Expo)** | Dashboard d'administration |
| 🐍 **Backend API** | **Python FastAPI** | API REST principale, auth JWT, CRUD |
| 🟢 **Analytics** | **Node.js / Express** | Microservice analytics, WebSocket temps réel |
| 🐘 **Base de données** | **PostgreSQL** | Base relationnelle (11 tables) |
| 🔗 **Communication** | **API REST** | Endpoints RESTful + Socket.IO |
| 🤖 **IA / ML** | **scikit-learn + OpenAI GPT-4o** | Difficulté adaptative + génération de questions |
| 🐳 **DevOps** | **Docker / Docker Compose** | Orchestration multi-services |

---

## 📁 Structure du Projet

```
mathquest-mobile/
├── flutter_app/              # 📱 Application Flutter (Mobile + Web)
│   ├── lib/
│   │   ├── main.dart               # Point d'entrée + GoRouter
│   │   ├── theme.dart              # Thème Material Design 3
│   │   ├── models/                 # User, Question, Duel, Subject
│   │   ├── services/               # 8 services (API, Auth, Stats, XP, Goals...)
│   │   ├── screens/                # 9 écrans (Home, Duel, Training, Chrono...)
│   │   └── data/                   # 100 questions intégrées (offline)
│   └── pubspec.yaml
│
├── backend/                  # 🐍 API Python FastAPI
│   ├── app/
│   │   ├── main.py                 # FastAPI app + CORS
│   │   ├── config.py               # Settings (.env)
│   │   ├── database.py             # SQLAlchemy async + asyncpg
│   │   ├── models.py               # ORM models (User, Question, Duel...)
│   │   ├── schemas.py              # Pydantic validation schemas
│   │   ├── security.py             # JWT auth (python-jose + bcrypt)
│   │   ├── routers/                # 5 endpoints REST
│   │   │   ├── auth.py             #   POST /login, /signup
│   │   │   ├── questions.py        #   GET/POST questions, AI generation
│   │   │   ├── duels.py            #   CRUD duels
│   │   │   ├── leaderboard.py      #   GET classement
│   │   │   └── profile.py          #   GET/PUT profil utilisateur
│   │   └── services/
│   │       └── ai_service.py       # 🤖 ML: LogisticRegression + GPT generation
│   ├── requirements.txt
│   └── Dockerfile
│
├── node-analytics/           # 🟢 Microservice Node.js / Express
│   ├── server.js                   # Express + Socket.IO server
│   ├── db.js                       # PostgreSQL connection (pg)
│   ├── middleware/
│   │   └── auth.js                 # JWT verification (shared secret)
│   ├── routes/
│   │   ├── analytics.js            # DAU, retention, performance metrics
│   │   ├── notifications.js        # Push notifications + broadcast
│   │   └── leaderboard.js          # Real-time leaderboard + SSE stream
│   ├── package.json
│   └── Dockerfile
│
├── admin-app/                # 📱 React Native Admin Dashboard (Expo)
│   ├── App.js                      # Navigation + Auth flow
│   ├── app.json                    # Expo config
│   ├── src/
│   │   ├── screens/
│   │   │   ├── LoginScreen.js      # Admin authentication
│   │   │   ├── DashboardScreen.js  # KPIs + Charts (react-native-chart-kit)
│   │   │   ├── QuestionsScreen.js  # Question CRUD + search + filter
│   │   │   ├── UsersScreen.js      # User management + notifications
│   │   │   └── SettingsScreen.js   # Broadcast + tech info + logout
│   │   └── services/
│   │       └── api.js              # Axios clients (FastAPI + Node.js)
│   └── package.json
│
├── database/                 # 🐘 PostgreSQL
│   ├── schema.sql                  # 11 tables + indexes
│   └── seed.sql                    # Données initiales (matières, questions)
│
├── docker-compose.yml        # 🐳 Orchestration (db + api + analytics)
└── .gitignore
```

---

## 🚀 Démarrage Rapide

### 1. Cloner le projet

```bash
git clone https://github.com/YOUR_USER/mathquest-mobile.git
cd mathquest-mobile
```

### 2. Configurer les variables d'environnement

```bash
cp backend/.env.example backend/.env
cp node-analytics/.env.example node-analytics/.env
# Éditer les fichiers .env (clé OpenAI, JWT secret...)
```

### 3. Lancer avec Docker Compose (PostgreSQL + FastAPI + Node.js)

```bash
docker-compose up --build
```

| Service | URL |
|---------|-----|
| PostgreSQL | `localhost:5432` |
| FastAPI (Python) | `http://localhost:8000` — [Docs Swagger](http://localhost:8000/docs) |
| Node.js Analytics | `http://localhost:3001` |

### 4. Lancer l'application Flutter (Mobile + Web)

```bash
cd flutter_app
flutter pub get
flutter run                  # Mobile (émulateur)
flutter build web --release  # Web
```

### 5. Lancer l'admin React Native

```bash
cd admin-app
npm install
npx expo start               # Démarre Expo dev server
# Appuyer sur 'w' pour web, 'a' pour Android, 'i' pour iOS
```

---

## 📱 Fonctionnalités — App Flutter

| Catégorie | Fonctionnalités |
|-----------|----------------|
| **Modes de jeu** | Duel vs Bot IA, Mode Chrono (60s), Mode Entraînement |
| **Gamification** | Power-ups (50/50, Freeze, Skip), Combo multiplicateur, XP & niveaux |
| **Progression** | 18 badges, Objectifs quotidiens (5/jour), Streak journalier, Défi du jour |
| **Social** | Classement avec podium animé, Avatars personnalisables |
| **Analytics** | Graphiques fl_chart (pie, bar, line), Export CSV, Profil détaillé |
| **Contenu** | 100 questions intégrées (4 matières), Génération IA GPT |
| **UX/UI** | Mode sombre, Confettis, Micro-animations, Glassmorphism, Onboarding |
| **Offline** | Mode hors ligne complet, Mode invité sans inscription |

## 🤖 Fonctionnalités — IA / Machine Learning

| Fonctionnalité | Technologie |
|----------------|-------------|
| Difficulté adaptative | **scikit-learn** `LogisticRegression` — ajuste le niveau selon la performance |
| Génération de questions | **OpenAI GPT-4o-mini** — génère des MCQ par matière et difficulté |
| Recommandation de difficulté | Heuristique zone proximale + ML quand >20 sessions |
| Analyse de performance | Prédiction de score et conseils personnalisés |

## 🟢 Fonctionnalités — Node.js Analytics

| Endpoint | Description |
|----------|-------------|
| `GET /api/analytics/overview` | KPIs globaux (users, duels, accuracy) |
| `GET /api/analytics/daily` | DAU + parties/jour (30 derniers jours) |
| `GET /api/analytics/performance` | Précision par matière |
| `GET /api/analytics/retention` | Rétention J+1 (7 jours) |
| `WebSocket` | Leaderboard temps réel + notifications push |
| `SSE /api/leaderboard-live/stream` | Stream Server-Sent Events |

## 📱 Fonctionnalités — Admin React Native

| Écran | Fonctionnalités |
|-------|----------------|
| **Dashboard** | KPIs temps réel, graphiques DAU, précision par matière |
| **Questions** | Liste par matière, recherche, filtre difficulté, badge IA |
| **Utilisateurs** | Classement, stats par joueur, envoi de notifications |
| **Paramètres** | Broadcast global WebSocket, infos stack technique |

---

## 🗄️ Base de Données PostgreSQL

**11 tables :**

| Table | Description |
|-------|-------------|
| `users` | Comptes utilisateurs (username, email, points, streak) |
| `subjects` | Matières (math, physics, chemistry, general) |
| `questions` | Banque de questions (options JSONB, difficulté 1-5) |
| `user_progress` | Progression par matière par utilisateur |
| `duels` | Historique des duels (score, gagnant, mode) |
| `duel_answers` | Réponses détaillées par question par duel |
| `achievements` | Définitions des badges |
| `user_achievements` | Badges débloqués par utilisateur |
| `ai_learning_profiles` | Profil ML par utilisateur (historique, prédictions) |
| `notifications` | Notifications push (Node.js → utilisateur) |
| `analytics_events` | Événements analytiques (Node.js tracking) |

---

## 📄 Licence

Projet éducatif — Stage AE, Application Éducative
