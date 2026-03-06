import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// lottie available for future use
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/local_stats_service.dart';
import '../services/xp_level_service.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;
  const ProfileScreen({super.key, required this.apiService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _progress = [];
  // ignore: unused_field
  Map<String, dynamic>? _aiProfile;
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _localSummary;
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;
  int _xpLevel = 1;
  double _xpProgress = 0;
  int _totalXP = 0;
  String _levelTitle = 'Débutant';

  final _statsService = LocalStatsService();
  final _xpService = XpLevelService();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final isGuest = context.read<AuthService>().isGuest;

    // Always load local stats + XP
    _localSummary = await _statsService.getSummary();
    _history = await _statsService.getHistory();
    _xpLevel = await _xpService.getLevel();
    _xpProgress = await _xpService.getLevelProgress();
    _totalXP = await _xpService.getTotalXP();
    _levelTitle = await _xpService.getLevelTitle();

    if (!isGuest) {
      try {
        final p  = await widget.apiService.getProgress();
        final ai = await widget.apiService.getAIProfile();
        final an = await widget.apiService.getAnalytics();
        if (mounted) setState(() { _progress = p; _aiProfile = ai; _analytics = an; _loading = false; });
        return;
      } catch (_) {}
    }

    // Guest / offline — build from local stats
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _exportCSV() async {
    final csv = await _statsService.exportCSV();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.file_download, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Export CSV'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(csv, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final isGuest = auth.isGuest;
    final localPts = _localSummary?['totalPoints'] as int? ?? 0;
    final localGames = _localSummary?['games'] as int? ?? 0;
    final localLevel = _xpLevel;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF6A1B9A)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 20, spreadRadius: 5),
                          ],
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            (user?.username ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user?.username ?? '', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isGuest
                              ? '⭐ Niveau $localLevel · $localPts pts · $localGames duels'
                              : '⭐ Niveau ${user?.level ?? 1} · ${user?.totalPoints ?? 0} pts · 🔥 ${user?.streakDays ?? 0} jours',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isGuest) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.amber.withOpacity(0.3), Colors.orange.withOpacity(0.3)]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(FontAwesomeIcons.userSecret, color: Colors.white, size: 12),
                            SizedBox(width: 6),
                            Text('Mode Invité', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(icon: Icon(FontAwesomeIcons.chartLine, size: 16), text: 'Progression'),
                Tab(icon: Icon(FontAwesomeIcons.clockRotateLeft, size: 16), text: 'Historique'),
                Tab(icon: Icon(FontAwesomeIcons.magnifyingGlassChart, size: 16), text: 'Analyse'),
              ],
            ),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.fileExport, color: Colors.white, size: 18),
                tooltip: 'Exporter CSV',
                onPressed: _exportCSV,
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.rightFromBracket, color: Colors.white, size: 18),
                onPressed: () async {
                  await context.read<AuthService>().logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabCtrl,
                children: [
                  _ProgressTab(progress: _progress, localSummary: _localSummary, isGuest: isGuest, history: _history, xpLevel: _xpLevel, xpProgress: _xpProgress, totalXP: _totalXP, levelTitle: _levelTitle),
                  _HistoryTab(history: _history),
                  isGuest
                      ? _LocalAnalyticsTab(summary: _localSummary)
                      : _AnalyticsTab(analytics: _analytics),
                ],
              ),
      ),
    );
  }
}

// ── Progress Tab ──────────────────────────────────────────────────────────────
class _ProgressTab extends StatelessWidget {
  final List<Map<String, dynamic>> progress;
  final Map<String, dynamic>? localSummary;
  final List<Map<String, dynamic>> history;
  final bool isGuest;
  final int xpLevel;
  final double xpProgress;
  final int totalXP;
  final String levelTitle;
  const _ProgressTab({required this.progress, this.localSummary, this.isGuest = false, this.history = const [], this.xpLevel = 1, this.xpProgress = 0, this.totalXP = 0, this.levelTitle = 'Débutant'});

  @override
  Widget build(BuildContext context) {
    if (isGuest || progress.isEmpty) {
      return _buildLocalProgress(context);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildXPCard(),
        const SizedBox(height: 16),
        ...progress.map((p) => _ProgressCard(data: p)),
      ],
    );
  }

  Widget _buildXPCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text('$xpLevel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(levelTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 2),
                    Text('$totalXP XP au total', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
              ),
              const Text('🌟', style: TextStyle(fontSize: 32)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: xpProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 6),
          Text('${(xpProgress * 100).round()}% vers le niveau ${xpLevel + 1}',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLocalProgress(BuildContext context) {
    final subjects = (localSummary?['subjects'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final games = localSummary?['games'] as int? ?? 0;
    final wins = localSummary?['wins'] as int? ?? 0;
    final winRate = localSummary?['winRate'] as int? ?? 0;
    final pts = localSummary?['totalPoints'] as int? ?? 0;
    final streak = localSummary?['bestStreak'] as int? ?? 0;

    if (games == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Aucune partie jouée', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Lancez un duel pour commencer !', style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // XP Level Card
        _buildXPCard(),
        const SizedBox(height: 16),

        // Summary cards
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat('$games', 'Duels', Icons.sports_esports),
              _MiniStat('$wins', 'Victoires', Icons.emoji_events),
              _MiniStat('$winRate%', 'Win Rate', Icons.percent),
              _MiniStat('🔥$streak', 'Streak', Icons.local_fire_department),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
        const SizedBox(height: 8),
        Center(
          child: Text('$pts points au total',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primary)),
        ),

        // Win/Loss pie chart
        if (games >= 2) ...[
          const SizedBox(height: 24),
          const Text('📊 Victoires / Défaites', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: PieChart(PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: wins.toDouble(),
                  title: '$wins V',
                  color: AppTheme.success,
                  radius: 50,
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                ),
                PieChartSectionData(
                  value: (games - wins).toDouble(),
                  title: '${games - wins} D',
                  color: AppTheme.error,
                  radius: 50,
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ],
            )),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        ],

        // Subject accuracy bar chart
        if (subjects.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('📈 Précision par matière', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 32,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                )),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= subjects.length) return const SizedBox();
                    final icons = {'math': '📐', 'physics': '⚡', 'chemistry': '🧪', 'general': '🌍'};
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(icons[subjects[idx]['slug']] ?? '📚', style: const TextStyle(fontSize: 16)),
                    );
                  },
                )),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25),
              barGroups: subjects.asMap().entries.map((e) {
                final colors = [AppTheme.primary, AppTheme.accent, AppTheme.success, AppTheme.warning];
                return BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(
                    toY: (e.value['accuracy'] as int? ?? 0).toDouble(),
                    color: colors[e.key % colors.length],
                    width: 24,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: Colors.grey.withOpacity(0.1)),
                  ),
                ]);
              }).toList(),
            )),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        ],

        // Performance trend (last 10 games)
        if (history.length >= 3) ...[
          const SizedBox(height: 24),
          const Text('📉 Tendance des scores', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 200),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 40,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                )),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _recentSpots(),
                  isCurved: true,
                  color: AppTheme.primary,
                  barWidth: 3,
                  dotData: FlDotData(show: true, getDotPainter: (s, _, __, ___) =>
                      FlDotCirclePainter(radius: 4, color: AppTheme.primary, strokeColor: Colors.white, strokeWidth: 2)),
                  belowBarData: BarAreaData(show: true, color: AppTheme.primary.withOpacity(0.1)),
                ),
              ],
            )),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        ],

        const SizedBox(height: 24),
        const Text('Par matière', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...subjects.asMap().entries.map((e) {
          final s = e.value;
          final name = s['name'] as String? ?? '';
          final acc = s['accuracy'] as int? ?? 0;
          final sg = s['games'] as int? ?? 0;
          final sw = s['wins'] as int? ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('$acc%', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: acc / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text('$sg duels · $sw victoires', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * e.key), duration: 400.ms).slideX(begin: 0.05, end: 0);
        }),
      ],
    );
  }

  List<FlSpot> _recentSpots() {
    final recent = history.take(10).toList().reversed.toList();
    return recent.asMap().entries.map((e) {
      final score = (e.value['playerScore'] as int? ?? 0).toDouble();
      return FlSpot(e.key.toDouble(), score);
    }).toList();
  }

  Widget _MiniStat(String value, String label, IconData icon) => Column(
    children: [
      Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
    ],
  );
}

class _ProgressCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ProgressCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final name    = data['subject_name'] as String;
    final pct     = data['progress_percent'] as int;
    final correct = data['correct_answers'] as int;
    final total   = data['questions_answered'] as int;
    final acc     = total > 0 ? (correct / total * 100).round() : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('$pct%', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: pct / 100, minHeight: 8, backgroundColor: Colors.grey.shade200, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Text('$correct/$total corrects • Précision : $acc%', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ── AI Profile Tab ────────────────────────────────────────────────────────────
class _AITab extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const _AITab({this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile == null) return const Center(child: Text('Profil IA non disponible.'));
    final skills  = (profile!['skill_vector'] as Map?)?.cast<String, dynamic>() ?? {};
    final recDiff = (profile!['recommended_difficulty'] as Map?)?.cast<String, dynamic>() ?? {};
    final acc     = (profile!['avg_accuracy'] as num?)?.toDouble() ?? 0;
    final sessions = profile!['total_sessions'] as int? ?? 0;
    final pred    = (profile!['predicted_score'] as num?)?.toDouble() ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(icon: Icons.psychology, title: 'Sessions totales', value: '$sessions'),
        const SizedBox(height: 12),
        _InfoCard(icon: Icons.track_changes, title: 'Précision moyenne', value: '${(acc * 100).toStringAsFixed(1)}%'),
        const SizedBox(height: 12),
        _InfoCard(icon: Icons.trending_up, title: 'Score prédit', value: '${(pred * 100).toStringAsFixed(1)}%'),
        const SizedBox(height: 20),
        const Text('Niveaux de compétence par matière', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        ...skills.entries.map((e) => _SkillBar(subject: e.key, skill: (e.value as num).toDouble())),
        if (recDiff.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Difficulté recommandée', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          ...recDiff.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('Niveau ${e.value}/5', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }
}

// ── History Tab (local game history) ─────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _HistoryTab({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('Pas encore d\'historique', style: TextStyle(fontSize: 16, color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (ctx, i) {
        final g = history[i];
        final date = DateTime.tryParse(g['date'] ?? '');
        final dateStr = date != null
            ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
            : '';
        final won = g['won'] == true;
        final ps = g['playerScore'] as int? ?? 0;
        final bs = g['botScore'] as int? ?? 0;
        final draw = ps == bs;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(
                color: draw ? AppTheme.warning : won ? AppTheme.success : AppTheme.error,
                width: 4,
              ),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Row(
            children: [
              // Result icon
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: (draw ? AppTheme.warning : won ? AppTheme.success : AppTheme.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  draw ? Icons.handshake : won ? Icons.emoji_events : Icons.close,
                  color: draw ? AppTheme.warning : won ? AppTheme.success : AppTheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g['subjectName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      '${g['correct']}/${g['total']} · Bot ${g['botLevel']} · $dateStr',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$ps', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: won ? AppTheme.success : AppTheme.textMain)),
                  Text('vs $bs', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Local Analytics Tab (guest mode) ────────────────────────────────────────
class _LocalAnalyticsTab extends StatelessWidget {
  final Map<String, dynamic>? summary;
  const _LocalAnalyticsTab({this.summary});

  @override
  Widget build(BuildContext context) {
    final games = summary?['games'] as int? ?? 0;
    if (games == 0) {
      return const Center(child: Text('Jouez des duels pour voir vos analyses !', style: TextStyle(color: AppTheme.textMuted)));
    }

    final winRate = summary?['winRate'] as int? ?? 0;
    final avgAcc = summary?['avgAccuracy'] as int? ?? 0;
    final streak = summary?['bestStreak'] as int? ?? 0;
    final subjects = (summary?['subjects'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // Generate tips based on data
    final tips = <String>[];
    if (winRate < 50) tips.add('Essayez le niveau Facile pour construire votre confiance avant de monter en difficulté.');
    if (avgAcc < 60) tips.add('Prenez votre temps pour lire chaque question — la précision compte plus que la vitesse.');
    if (streak < 3) tips.add('Visez des séries de 3+ bonnes réponses pour maximiser vos points combo.');
    if (games < 5) tips.add('Continuez à jouer ! Plus vous jouez, plus l\'analyse sera précise.');
    if (winRate >= 70) tips.add('Excellent taux de victoire ! Essayez le niveau Expert pour vous challenger.');
    if (avgAcc >= 80) tips.add('Votre précision est remarquable. Vous maîtrisez bien les concepts.');

    // Find strengths & weaknesses
    final strengths = subjects.where((s) => (s['accuracy'] as int? ?? 0) >= 70).map((s) => s['name'] as String).toList();
    final weaknesses = subjects.where((s) => (s['accuracy'] as int? ?? 0) < 50).map((s) => s['name'] as String).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (strengths.isNotEmpty) ...[
          _SectionHeader('💪 Points forts', AppTheme.success),
          ...strengths.map((s) => _AnalyticsTile(text: s, color: AppTheme.success, icon: Icons.check_circle_outline)),
          const SizedBox(height: 16),
        ],
        if (weaknesses.isNotEmpty) ...[
          _SectionHeader('📚 À améliorer', AppTheme.warning),
          ...weaknesses.map((s) => _AnalyticsTile(text: s, color: AppTheme.warning, icon: Icons.trending_up)),
          const SizedBox(height: 16),
        ],
        _SectionHeader('💡 Conseils personnalisés', AppTheme.primary),
        ...tips.map((t) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(t, style: const TextStyle(fontSize: 14))),
              ],
            ),
          ),
        )),
        const SizedBox(height: 20),
        // CTA to create account
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              const Text('Débloquez l\'IA avancée', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Créez un compte pour accéder aux analyses IA et à la génération de questions.',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _SectionHeader(String title, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color)),
  );
}

class _SkillBar extends StatelessWidget {
  final String subject;
  final double skill;
  const _SkillBar({required this.subject, required this.skill});

  @override
  Widget build(BuildContext context) {
    final pct = (skill * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(subject, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$pct%', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: skill,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppTheme.primary.withOpacity(0.1), child: Icon(icon, color: AppTheme.primary)),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.primary)),
      ),
    );
  }
}

// ── Analytics Tab ─────────────────────────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  final Map<String, dynamic>? analytics;
  const _AnalyticsTab({this.analytics});

  @override
  Widget build(BuildContext context) {
    if (analytics == null) return const Center(child: Text('Analyses non disponibles.'));
    final strengths = (analytics!['strengths'] as List?)?.cast<String>() ?? [];
    final weaknesses = (analytics!['weaknesses'] as List?)?.cast<String>() ?? [];
    final tips = (analytics!['improvement_tips'] as List?)?.cast<String>() ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (strengths.isNotEmpty) ...[
          _SectionHeader('💪 Points forts', AppTheme.success),
          ...strengths.map((s) => _AnalyticsTile(text: s, color: AppTheme.success, icon: Icons.check_circle_outline)),
          const SizedBox(height: 16),
        ],
        if (weaknesses.isNotEmpty) ...[
          _SectionHeader('📚 À améliorer', AppTheme.warning),
          ...weaknesses.map((s) => _AnalyticsTile(text: s, color: AppTheme.warning, icon: Icons.trending_up)),
          const SizedBox(height: 16),
        ],
        if (tips.isNotEmpty) ...[
          _SectionHeader('💡 Conseils IA', AppTheme.primary),
          ...tips.map((t) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(t, style: const TextStyle(fontSize: 14))),
                ],
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _SectionHeader(String title, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color)),
  );
}

class _AnalyticsTile extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _AnalyticsTile({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
