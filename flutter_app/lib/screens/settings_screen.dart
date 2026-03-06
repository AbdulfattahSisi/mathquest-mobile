import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/local_stats_service.dart';
import '../services/daily_streak_service.dart';
import '../services/achievement_service.dart';
import '../services/xp_level_service.dart';
import '../services/daily_goals_service.dart';
import '../services/avatar_service.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isGuest = auth.isGuest;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF6A1B9A)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(children: [
                      const Icon(FontAwesomeIcons.circleInfo, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      const Text('À propos de MathQuest',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    ]),
                    const SizedBox(height: 4),
                    const Text('Version 2.0.0 — Application Éducative OCP',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
            backgroundColor: AppTheme.primary,
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Tech Stack Section ─────────────────────────────────────────
                const _SectionTitle('🛠️ Stack Technique'),
                const SizedBox(height: 8),
                const _TechCard(
                  icon: '📱',
                  title: 'Frontend Mobile — Flutter / Dart',
                  items: ['Flutter 3.24 / Dart', 'Provider (state)', 'GoRouter (navigation)', 'Material Design 3', 'fl_chart, flutter_animate'],
                ),
                const SizedBox(height: 10),
                const _TechCard(
                  icon: '📱',
                  title: 'Admin Dashboard — React Native',
                  items: ['React Native (Expo)', 'React Navigation', 'react-native-chart-kit', 'Axios (HTTP client)'],
                ),
                const SizedBox(height: 10),
                const _TechCard(
                  icon: '🐍',
                  title: 'Backend API — Python FastAPI',
                  items: ['FastAPI (async)', 'REST API (5 routers)', 'JWT Auth (python-jose)', 'Pydantic v2 validation'],
                ),
                const SizedBox(height: 10),
                const _TechCard(
                  icon: '🟢',
                  title: 'Analytics — Node.js / Express',
                  items: ['Express.js + Socket.IO', 'Real-time WebSocket', 'SSE streaming', 'Rate limiting (Helmet)'],
                ),
                const SizedBox(height: 10),
                const _TechCard(
                  icon: '🐘',
                  title: 'Base de données — PostgreSQL',
                  items: ['PostgreSQL 16', 'SQLAlchemy async (Python)', 'pg driver (Node.js)', '11 tables relationnelles'],
                ),
                const SizedBox(height: 10),
                const _TechCard(
                  icon: '🤖',
                  title: 'Intelligence Artificielle / ML',
                  items: ['scikit-learn (LogisticRegression)', 'OpenAI GPT-4o (génération)', 'Difficulté adaptative', 'Profil IA par utilisateur'],
                ),
                const SizedBox(height: 10),
                const _TechCard(
                  icon: '🐳',
                  title: 'DevOps & Outils',
                  items: ['Docker / Docker Compose', 'Git / GitHub', '3 services orchestrés', 'Multi-plateforme (iOS/Android/Web)'],
                ),

                const SizedBox(height: 24),

                // ── Features Section ──────────────────────────────────────────
                const _SectionTitle('✨ Fonctionnalités'),
                const SizedBox(height: 8),
                _FeatureRow(Icons.bolt, 'Power-ups : 50/50, Freeze, Skip'),
                _FeatureRow(Icons.trending_up, 'Combo multiplicateur de score'),
                _FeatureRow(Icons.bar_chart, 'Graphiques fl_chart (pie, bar, line)'),
                _FeatureRow(Icons.dark_mode, 'Mode sombre avec thème complet'),
                _FeatureRow(Icons.star, 'Système XP et niveaux'),
                _FeatureRow(Icons.military_tech, '18 badges à débloquer'),
                _FeatureRow(Icons.sports_esports, 'Duel interactif contre bot IA avec niveaux de difficulté'),
                _FeatureRow(Icons.people_alt, 'Mode invité sans inscription'),
                _FeatureRow(Icons.emoji_events, 'Classement avec podium animé'),
                _FeatureRow(Icons.auto_awesome, 'Génération dynamique de questions par IA'),
                _FeatureRow(Icons.analytics, 'Analyses et conseils personnalisés'),
                _FeatureRow(Icons.file_download, 'Export CSV de l\'historique'),
                _FeatureRow(Icons.offline_bolt, 'Mode hors ligne (100 questions intégrées)'),
                _FeatureRow(Icons.security, 'Authentification JWT sécurisée'),
                _FeatureRow(Icons.palette, 'Interface Material Design 3 responsive'),
                _FeatureRow(Icons.school, 'Mode Entraînement (pratique sans pression)'),
                _FeatureRow(Icons.timer, 'Mode Chrono (défi de vitesse 60s)'),
                _FeatureRow(Icons.rate_review, 'Revue des questions post-duel'),
                _FeatureRow(Icons.flag, 'Objectifs quotidiens (5 défis/jour)'),
                _FeatureRow(Icons.face, 'Système d\'avatars personnalisables'),
                _FeatureRow(Icons.celebration, 'Confettis et animations de victoire'),

                const SizedBox(height: 24),

                // ── Architecture Section ─────────────────────────────────────
                const _SectionTitle('🏗️ Architecture'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('mathquest-mobile/', style: TextStyle(color: Color(0xFF4FC3F7), fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      _TreeLine('├── flutter_app/         # App Flutter/Dart'),
                      _TreeLine('│   ├── lib/screens/     # 9 écrans'),
                      _TreeLine('│   ├── lib/services/    # 8 services'),
                      _TreeLine('│   ├── lib/models/      # User, Duel, Subject'),
                      _TreeLine('│   └── lib/data/        # 100 questions'),
                      _TreeLine('├── backend/             # API Python FastAPI'),
                      _TreeLine('│   ├── app/routers/     # 5 endpoints REST'),
                      _TreeLine('│   ├── app/services/    # IA, Auth, DB'),
                      _TreeLine('│   └── app/models/      # SQLAlchemy models'),
                      _TreeLine('├── node-analytics/      # Node.js / Express'),
                      _TreeLine('│   ├── routes/          # Analytics, Notif, LB'),
                      _TreeLine('│   └── server.js        # Express + Socket.IO'),
                      _TreeLine('├── admin-app/           # React Native (Expo)'),
                      _TreeLine('│   └── src/screens/     # Dashboard, CRUD'),
                      _TreeLine('├── database/            # Schema PostgreSQL'),
                      _TreeLine('│   ├── schema.sql       # 11 tables'),
                      _TreeLine('│   └── seed.sql         # Données initiales'),
                      _TreeLine('└── docker-compose.yml   # Orchestration'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Actions ──────────────────────────────────────────────────
                if (isGuest) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.person_add, color: Colors.white, size: 32),
                        const SizedBox(height: 8),
                        const Text('Créer un compte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Débloquez l\'IA avancée et synchronisez vos données.',
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await auth.logout();
                            if (context.mounted) context.go('/signup');
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary),
                          child: const Text('S\'inscrire'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Clear local data
                _buildDarkModeToggle(context),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () => _confirmClear(context),
                  icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                  label: const Text('Effacer les données locales', style: TextStyle(color: AppTheme.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                const SizedBox(height: 32),

                // Credits
                const Center(
                  child: Column(
                    children: [
                      Text('MathQuest v2.0.0', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('Projet AE — Application Éducative', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      SizedBox(height: 2),
                      Text('Flutter + FastAPI + PostgreSQL + AI/ML', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(themeProv.isDark ? Icons.dark_mode : Icons.light_mode,
              color: themeProv.isDark ? Colors.amber : AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mode sombre', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(themeProv.isDark ? 'Activé' : 'Désactivé',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            ),
          ),
          Switch(
            value: themeProv.isDark,
            onChanged: (_) => themeProv.toggle(),
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Effacer les données ?'),
        content: const Text('Toutes vos statistiques et historique de duels seront supprimés.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await LocalStatsService().clearAll();
              await DailyStreakService().clearAll();
              await AchievementService().clearAll();
              await XpLevelService().clearAll();
              await DailyGoalsService().clearAll();
              await AvatarService().clearAll();
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Données effacées !'), backgroundColor: AppTheme.success),
                );
              }
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
}

class _TechCard extends StatelessWidget {
  final String icon;
  final String title;
  final List<String> items;
  const _TechCard({required this.icon, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                ...items.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Container(width: 4, height: 4, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Expanded(child: Text(i, style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMuted : AppTheme.textMuted))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _FeatureRow(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    ),
  );
}

class _TreeLine extends StatelessWidget {
  final String text;
  const _TreeLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Color(0xFFA5D6A7), fontFamily: 'monospace', fontSize: 11, height: 1.6));
  }
}
