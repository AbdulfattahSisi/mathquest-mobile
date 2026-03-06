import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/local_stats_service.dart';
import '../services/daily_streak_service.dart';
import '../services/achievement_service.dart';
import '../services/xp_level_service.dart';
import '../services/daily_goals_service.dart';
import '../services/avatar_service.dart';
import '../models/duel_model.dart';
import '../theme.dart';

/// Hardcoded local subjects matching local_questions.dart slugs
const _localSubjects = [
  SubjectModel(id: 'math',      name: 'Mathématiques',    slug: 'math',      icon: '📐', color: 'blue'),
  SubjectModel(id: 'physics',   name: 'Physique',         slug: 'physics',   icon: '⚡', color: 'purple'),
  SubjectModel(id: 'chemistry', name: 'Chimie',           slug: 'chemistry', icon: '🧪', color: 'green'),
  SubjectModel(id: 'general',   name: 'Culture Générale', slug: 'general',   icon: '🌍', color: 'amber'),
];

class HomeScreen extends StatefulWidget {
  final ApiService apiService;
  const HomeScreen({super.key, required this.apiService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SubjectModel> _subjects = [];
  List<Map<String, dynamic>> _progress = [];
  Map<String, dynamic>? _localStats;
  bool _loading = true;
  final _statsService = LocalStatsService();
  final _dailyService = DailyStreakService();
  final _achievementService = AchievementService();
  final _xpService = XpLevelService();
  final _goalsService = DailyGoalsService();
  final _avatarService = AvatarService();

  int _dailyStreak = 0;
  bool _dailyChallengeCompleted = false;
  // ignore: unused_field
  int _unlockedBadges = 0;
  int _xpLevel = 1;
  double _xpProgress = 0;
  String _levelTitle = 'Débutant';
  List<DailyGoalState> _goalStates = [];
  int _completedGoals = 0;
  String _avatar = '🧑‍💻';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final isGuest = context.read<AuthService>().isGuest;

    // Always load local stats + daily streak + achievements
    _localStats = await _statsService.getSummary();
    _dailyStreak = await _dailyService.getStreak();
    _dailyChallengeCompleted = await _dailyService.isDailyChallengeCompleted();
    final badgeStates = await _achievementService.getAllWithState();
    _unlockedBadges = badgeStates.where((b) => b.isUnlocked).length;
    _xpLevel = await _xpService.getLevel();
    _xpProgress = await _xpService.getLevelProgress();
    _levelTitle = await _xpService.getLevelTitle();
    _goalStates = await _goalsService.getGoalStates();
    _completedGoals = _goalStates.where((g) => g.isCompleted).length;
    _avatar = await _avatarService.getAvatar();

    if (isGuest) {
      // Offline mode — use local subjects, no progress from API
      if (mounted) {
        setState(() {
          _subjects = _localSubjects;
          _progress = [];
          _loading  = false;
        });
      }
      return;
    }

    try {
      final subjects  = await widget.apiService.getSubjects();
      final progress  = await widget.apiService.getProgress();
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _progress = progress;
          _loading  = false;
        });
      }
    } catch (_) {
      // Fallback to local subjects if API fails
      if (mounted) {
        setState(() {
          _subjects = _localSubjects;
          _progress = [];
          _loading  = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Hero App Bar
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                      child: Stack(
                        children: [
                          // Mesh gradient circles
                          Positioned(
                            top: -60, right: -40,
                            child: Container(
                              width: 180, height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [AppTheme.neonPurple.withOpacity(0.3), Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -80, left: -60,
                            child: Container(
                              width: 220, height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [AppTheme.royalBlue.withOpacity(0.25), Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                          // Floating math symbols
                          ..._buildFloatingSymbols(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    // Avatar with glow
                                    GestureDetector(
                                      onTap: () => _showAvatarPicker(context),
                                      child: Container(
                                        width: 48, height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                          boxShadow: [
                                            BoxShadow(color: AppTheme.neonBlue.withOpacity(0.3), blurRadius: 16, spreadRadius: 2),
                                          ],
                                        ),
                                        child: Center(child: Text(_avatar, style: const TextStyle(fontSize: 26))),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bonjour, ${user?.username ?? ''}!',
                                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '$_levelTitle · ${user?.totalPoints ?? 0} pts',
                                            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Level badge with gradient
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppTheme.neonBlue.withOpacity(0.25), AppTheme.neonPurple.withOpacity(0.25)],
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('🌟', style: TextStyle(fontSize: 16)),
                                          const SizedBox(width: 5),
                                          Text('Niv.$_xpLevel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.2)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Enhanced XP progress bar
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: _xpProgress,
                                      backgroundColor: Colors.transparent,
                                      valueColor: AlwaysStoppedAnimation(AppTheme.neonBlue),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFFFFFFFF)],
                      ).createShader(bounds),
                      child: const Text('MathQuest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    ),
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  ),
                  backgroundColor: AppTheme.deepNavy,
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(FontAwesomeIcons.gear, color: Colors.white, size: 18),
                        onPressed: () => context.push('/settings'),
                      ),
                    ),
                  ],
                ),

                // Quick Actions
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Actions rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _quickAction(context, FontAwesomeIcons.bolt,    'Duel Solo',   const Color(0xFF1565C0),   () => context.go('/duel'))),
                            const SizedBox(width: 10),
                            Expanded(child: _quickAction(context, FontAwesomeIcons.stopwatch,   'Chrono',   const Color(0xFFFF6D00), () => _showModePicker(context, 'chrono'))),
                            const SizedBox(width: 10),
                            Expanded(child: _quickAction(context, FontAwesomeIcons.graduationCap,  'Entraîner',   const Color(0xFF00897B),   () => _showModePicker(context, 'training'))),
                            const SizedBox(width: 10),
                            Expanded(child: _quickAction(context, FontAwesomeIcons.trophy,   'Badges',      const Color(0xFFEF6C00), () => context.push('/achievements'))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Daily Challenge Banner ─────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: _buildDailyChallenge(),
                  ),
                ),

                // ── Daily Streak ────────────────────────────────────────────────
                if (_dailyStreak > 0)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$_dailyStreak jour${_dailyStreak > 1 ? 's' : ''} consécutif${_dailyStreak > 1 ? 's' : ''} !',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                                  const Text('Continuez à jouer chaque jour',
                                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ),
                            // Streak fire badges
                            ...List.generate(
                              (_dailyStreak).clamp(0, 5),
                              (i) => const Padding(
                                padding: EdgeInsets.only(left: 2),
                                child: Text('🔥', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
                    ),
                  ),

                // Subjects
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: _buildDailyGoals(),
                  ),
                ),

                // Subjects header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Matières', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        TextButton(onPressed: () => context.go('/duel'), child: const Text('Mode Mixte 🎲')),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _SubjectCard(
                        subject: _subjects[i],
                        progress: _progressFor(_subjects[i].id),
                        onTap: () => context.go(
                          '/duel?subjectId=${_subjects[i].slug}&subjectName=${Uri.encodeComponent(_subjects[i].name)}',
                        ),
                      ),
                      childCount: _subjects.length,
                    ),
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 12)),

                // ── Local Stats Summary ────────────────────────────────────────
                if (_localStats != null && (_localStats!['games'] as int? ?? 0) > 0)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        decoration: AppTheme.gradientCard([AppTheme.royalBlue, const Color(0xFF1E40AF), AppTheme.neonPurple]),
                        child: Stack(
                          children: [
                            // Mesh gradient overlay
                            Positioned(
                              top: -40, right: -40,
                              child: Container(
                                width: 140, height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [AppTheme.neonBlue.withOpacity(0.15), Colors.transparent],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 42, height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                                        ),
                                        child: Lottie.asset('assets/animations/stats.json', repeat: true),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text('Vos statistiques',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.3)),
                                      ),
                                      GestureDetector(
                                        onTap: () => context.push('/profile'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('Détails', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(child: _glassStatTile('${_localStats!['games']}', 'Duels', Icons.sports_esports)),
                                      const SizedBox(width: 10),
                                      Expanded(child: _glassStatTile('${_localStats!['wins']}', 'Victoires', Icons.emoji_events)),
                                      const SizedBox(width: 10),
                                      Expanded(child: _glassStatTile('${_localStats!['winRate']}%', 'Win Rate', Icons.trending_up)),
                                      const SizedBox(width: 10),
                                      Expanded(child: _glassStatTile('${_localStats!['avgAccuracy']}%', 'Précision', Icons.gps_fixed)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.08, end: 0).shimmer(delay: 600.ms, duration: 1000.ms),
                    ),
                  ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
    );
  }

  Widget _buildDailyChallenge() {
    final subject = _dailyService.getDailyChallengeSubjectName();
    // ignore: unused_local_variable
    final emoji = _dailyService.getDailyChallengeEmoji();
    final slug = _dailyService.getDailyChallengeSubject();

    return GestureDetector(
      onTap: _dailyChallengeCompleted
          ? null
          : () => context.go('/duel?subjectId=$slug&subjectName=${Uri.encodeComponent(subject)}'),
      child: Container(
        decoration: BoxDecoration(
          gradient: _dailyChallengeCompleted
              ? AppTheme.successGradient
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFF9333EA), Color(0xFFA855F7)],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_dailyChallengeCompleted ? AppTheme.neonGreen : AppTheme.neonPurple).withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Mesh gradient overlay
            if (!_dailyChallengeCompleted)
              Positioned(
                top: -30, right: -30,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppTheme.neonPink.withOpacity(0.2), Colors.transparent],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    ),
                    child: _dailyChallengeCompleted
                        ? Center(child: Lottie.asset('assets/animations/success.json', repeat: false, width: 40))
                        : Center(child: Lottie.asset('assets/animations/lightning.json', repeat: true, width: 40)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('📅 Défi du Jour',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3)),
                            if (!_dailyChallengeCompleted) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonBlue.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: const Text('NOUVEAU', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dailyChallengeCompleted ? 'Complété ! Revenez demain 🎉' : '$subject — Relevez le défi !',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (!_dailyChallengeCompleted)
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0).shimmer(delay: 800.ms, duration: 1200.ms);
  }

  Widget _buildDailyGoals() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.06), blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Objectifs du jour', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _completedGoals == _goalStates.length && _goalStates.isNotEmpty
                      ? AppTheme.success.withOpacity(0.12)
                      : AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_completedGoals / ${_goalStates.length}',
                  style: TextStyle(
                    color: _completedGoals == _goalStates.length && _goalStates.isNotEmpty
                        ? AppTheme.success
                        : AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _goalStates.isNotEmpty ? _completedGoals / _goalStates.length : 0,
              minHeight: 5,
              backgroundColor: isDark ? AppTheme.darkBg : Colors.grey.shade200,
              color: _completedGoals == _goalStates.length && _goalStates.isNotEmpty
                  ? AppTheme.success
                  : AppTheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          // Goals list
          ...(_goalStates.map((gs) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(gs.goal.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    gs.goal.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: gs.isCompleted ? AppTheme.success : null,
                      decoration: gs.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (gs.isCompleted)
                  const Icon(Icons.check_circle, color: AppTheme.success, size: 18)
                else
                  Text(
                    '${gs.current}/${gs.goal.target}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                  ),
              ],
            ),
          ))),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  void _showAvatarPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Choisir votre avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 6,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: AvatarService.avatarOptions.map((emoji) {
                final isSelected = emoji == _avatar;
                return GestureDetector(
                  onTap: () async {
                    await _avatarService.setAvatar(emoji);
                    setState(() => _avatar = emoji);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showModePicker(BuildContext context, String mode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTraining = mode == 'training';
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text(
              isTraining ? '📚 Choisir une matière' : '⚡ Mode Chrono',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              isTraining ? 'Pratiquez sans pression' : 'Répondez au max en 60 secondes',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            ..._localSubjects.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(s.icon ?? '📚', style: const TextStyle(fontSize: 28)),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? AppTheme.darkMuted : AppTheme.textMuted),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: isDark ? AppTheme.darkBg : const Color(0xFFF5F5F5),
                onTap: () {
                  Navigator.pop(context);
                  final route = isTraining
                      ? '/training?subjectSlug=${s.slug}&subjectName=${Uri.encodeComponent(s.name)}'
                      : '/chrono?subjectSlug=${s.slug}&subjectName=${Uri.encodeComponent(s.name)}';
                  context.push(route);
                },
              ),
            )),
            // Mixed mode
            ListTile(
              leading: const Text('🎲', style: TextStyle(fontSize: 28)),
              title: const Text('Toutes les matières', style: TextStyle(fontWeight: FontWeight.w700)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? AppTheme.darkMuted : AppTheme.textMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: isDark ? AppTheme.darkBg : const Color(0xFFF5F5F5),
              onTap: () {
                Navigator.pop(context);
                final route = isTraining
                    ? '/training?subjectSlug=mixed&subjectName=${Uri.encodeComponent("Toutes les matières")}'
                    : '/chrono?subjectSlug=mixed&subjectName=${Uri.encodeComponent("Toutes les matières")}';
                context.push(route);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  int _progressFor(String subjectId) {
    final p = _progress.firstWhere(
      (p) => p['subject_id'] == subjectId,
      orElse: () => {'progress_percent': 0},
    );
    return p['progress_percent'] as int;
  }

  Future<void> _generateAIQuestions() async {
    final isGuest = context.read<AuthService>().isGuest;
    if (isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Créez un compte pour accéder à la génération IA !'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    if (_subjects.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Générer des questions IA'),
        content: const Text('L\'IA va générer 5 nouvelles questions pour votre première matière.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await widget.apiService.generateQuestions(subjectSlug: _subjects[0].slug, count: 5);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('5 questions générées avec succès !'), backgroundColor: AppTheme.success),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
                }
              }
            },
            child: const Text('Générer'),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      ],
    );
  }

  Widget _glassStatTile(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext ctx, IconData icon, String label, Color color, VoidCallback onTap) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(isDark ? 0.25 : 0.15), color.withOpacity(isDark ? 0.08 : 0.04)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: -0.2), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingSymbols() {
    final rnd = Random(42);
    const symbols = ['π', '∑', '∫', '√', 'Δ', '∞', 'λ', 'θ', '±', 'φ'];
    return List.generate(8, (i) {
      final sym = symbols[i % symbols.length];
      return Positioned(
        left: rnd.nextDouble() * 280,
        top: rnd.nextDouble() * 100,
        child: Text(
          sym,
          style: TextStyle(
            color: Colors.white.withOpacity(0.08 + rnd.nextDouble() * 0.08),
            fontSize: 18 + rnd.nextDouble() * 20,
            fontWeight: FontWeight.w900,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -8 - rnd.nextDouble() * 12, duration: Duration(milliseconds: 2000 + rnd.nextInt(2000)))
            .fadeIn(duration: 1000.ms),
      );
    });
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final int progress;
  final VoidCallback onTap;

  const _SubjectCard({required this.subject, required this.progress, required this.onTap});

  static const Map<String, Color> _colors = {
    'blue': AppTheme.primary,
    'purple': AppTheme.accent,
    'green': AppTheme.success,
    'amber': AppTheme.warning,
  };

  static const Map<String, IconData> _icons = {
    'math': FontAwesomeIcons.squareRootVariable,
    'physics': FontAwesomeIcons.atom,
    'chemistry': FontAwesomeIcons.flask,
    'general': FontAwesomeIcons.earthAmericas,
  };

  static const Map<String, String> _emojis = {
    'math': '📐',
    'physics': '⚡',
    'chemistry': '🧪',
    'general': '🌍',
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[subject.color] ?? AppTheme.primary;
    final icon = _icons[subject.slug] ?? Icons.school_rounded;
    final emoji = _emojis[subject.slug];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [color.withOpacity(0.18), AppTheme.darkCard]
                : [color.withOpacity(0.08), Colors.white],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: color.withOpacity(isDark ? 0.15 : 0.12), blurRadius: 20, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
          border: Border.all(
            color: isDark ? color.withOpacity(0.25) : color.withOpacity(0.18),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Center(child: Icon(icon, color: Colors.white, size: 20)),
                ),
                const Spacer(),
                if (emoji != null)
                  Text(emoji, style: const TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 10),
            Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            const Spacer(),
            Row(
              children: [
                Text('$progress%', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 22)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 6)],
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Jouer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    SizedBox(width: 3),
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: color.withOpacity(0.12),
                color: color,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms);
  }
}
