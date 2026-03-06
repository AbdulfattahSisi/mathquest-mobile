import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/local_stats_service.dart';
import '../services/xp_level_service.dart';
import '../theme.dart';

class LeaderboardScreen extends StatefulWidget {
  final ApiService apiService;
  const LeaderboardScreen({super.key, required this.apiService});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _entries = [];
  Map<String, dynamic>? _myStats;
  bool _loading = true;
  late TabController _tabCtrl;

  final _statsService = LocalStatsService();
  // ignore: unused_field
  final _xpService = XpLevelService();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final isGuest = context.read<AuthService>().isGuest;

    // Always load local stats
    _myStats = await _statsService.getSummary();

    if (!isGuest) {
      try {
        final data = await widget.apiService.getLeaderboard();
        if (mounted) setState(() { _entries = data; _loading = false; });
        return;
      } catch (_) {}
    }

    // Guest / offline → generate mock leaderboard with bot players
    _entries = _generateMockLeaderboard();
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> _generateMockLeaderboard() {
    final myPts = _myStats?['totalPoints'] as int? ?? 0;
    final myGames = _myStats?['games'] as int? ?? 0;
    final bots = <Map<String, dynamic>>[
      {'username': 'AlgoMaster',    'total_points': 12500, 'level': 13, 'games': 95, 'avatar': '🧑‍💻'},
      {'username': 'MathWizard',    'total_points': 9800,  'level': 10, 'games': 72, 'avatar': '🧙'},
      {'username': 'QuantumBrain',  'total_points': 8200,  'level': 9,  'games': 60, 'avatar': '🧠'},
      {'username': 'DataNinja',     'total_points': 6500,  'level': 7,  'games': 48, 'avatar': '🥷'},
      {'username': 'LogicPro',      'total_points': 5100,  'level': 6,  'games': 38, 'avatar': '🤖'},
      {'username': 'NeuralNet42',   'total_points': 3800,  'level': 4,  'games': 30, 'avatar': '🚀'},
      {'username': 'BinaryBoss',    'total_points': 2200,  'level': 3,  'games': 20, 'avatar': '👑'},
      {'username': 'CodeRunner',    'total_points': 1500,  'level': 2,  'games': 14, 'avatar': '⚡'},
      {'username': 'PixelSolver',   'total_points': 800,   'level': 1,  'games': 8,  'avatar': '🎮'},
      {'username': 'ByteCrafter',   'total_points': 300,   'level': 1,  'games': 3,  'avatar': '🔧'},
    ];
    // Insert real player
    bots.add({
      'username': 'Vous (Invité)',
      'total_points': myPts,
      'level': (myPts ~/ 1000) + 1,
      'games': myGames,
      'isMe': true,
    });
    bots.sort((a, b) => (b['total_points'] as int).compareTo(a['total_points'] as int));
    for (int i = 0; i < bots.length; i++) {
      bots[i]['rank'] = i + 1;
    }
    return bots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF6A1B9A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Row(
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [
                          const Icon(FontAwesomeIcons.rankingStar, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          const Text('Classement',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                        ]),
                        const SizedBox(height: 4),
                        Text('Grimpez les rangs et devenez le meilleur !',
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                      ],
                    )),
                    SizedBox(width: 60, height: 60,
                      child: Lottie.asset('assets/animations/trophy.json', repeat: true)),
                  ],
                ),
              ),
            ),
            backgroundColor: AppTheme.primary,
            bottom: TabBar(
              controller: _tabCtrl,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Global'),
                Tab(text: 'Mes Stats'),
              ],
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildLeaderboardTab(),
                  _buildMyStatsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    if (_entries.isEmpty) {
      return const Center(child: Text('Aucun joueur pour l\'instant.'));
    }
    // Top 3 podium + remaining list
    final top3 = _entries.take(3).toList();
    final rest = _entries.length > 3 ? _entries.sublist(3) : <Map<String, dynamic>>[];
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        if (top3.length >= 3) _buildPodium(top3),
        const SizedBox(height: 8),
        ...rest.asMap().entries.map((e) => _LeaderboardTile(entry: e.value)
            .animate().fadeIn(delay: Duration(milliseconds: 50 * e.key), duration: 300.ms)
            .slideX(begin: 0.05, end: 0)),
      ],
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          Expanded(child: _podiumColumn(top3[1], 2, 90, const Color(0xFFC0C0C0))),
          const SizedBox(width: 8),
          // 1st place
          Expanded(child: _podiumColumn(top3[0], 1, 120, const Color(0xFFFFD700))),
          const SizedBox(width: 8),
          // 3rd place
          Expanded(child: _podiumColumn(top3[2], 3, 70, const Color(0xFFCD7F32))),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _podiumColumn(Map<String, dynamic> entry, int rank, double height, Color color) {
    final name = entry['username'] as String;
    final pts = entry['total_points'] as int;
    final avatar = entry['avatar'] as String? ?? name[0];
    final isMe = entry['isMe'] == true;
    final medals = ['🥇', '🥈', '🥉'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medals[rank - 1], style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, spreadRadius: 1)],
            border: Border.all(color: color.withOpacity(0.6), width: 3),
          ),
          child: CircleAvatar(
            radius: rank == 1 ? 32 : 26,
            backgroundColor: isMe ? AppTheme.primary : color.withOpacity(0.3),
            child: Text(avatar.length <= 2 ? avatar : name[0].toUpperCase(),
                style: TextStyle(fontSize: rank == 1 ? 26 : 20)),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: isMe ? AppTheme.primary : null),
            overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center),
        Text('${_fmtPts(pts)}', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.5)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: Center(
            child: Text('#$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget _buildMyStatsTab() {
    if (_myStats == null) return const Center(child: Text('Jouez un duel pour voir vos stats !'));
    final games = _myStats!['games'] as int? ?? 0;
    final wins = _myStats!['wins'] as int? ?? 0;
    final winRate = _myStats!['winRate'] as int? ?? 0;
    final pts = _myStats!['totalPoints'] as int? ?? 0;
    final streak = _myStats!['bestStreak'] as int? ?? 0;
    final acc = _myStats!['avgAccuracy'] as int? ?? 0;
    final subjects = (_myStats!['subjects'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats cards row
        Row(
          children: [
            Expanded(child: _StatMini(icon: Icons.sports_esports, label: 'Duels', value: '$games', color: AppTheme.primary)),
            const SizedBox(width: 8),
            Expanded(child: _StatMini(icon: Icons.emoji_events, label: 'Victoires', value: '$wins', color: AppTheme.success)),
            const SizedBox(width: 8),
            Expanded(child: _StatMini(icon: Icons.percent, label: 'Win Rate', value: '$winRate%', color: AppTheme.accent)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatMini(icon: Icons.star, label: 'Points', value: _fmtPts(pts), color: AppTheme.warning)),
            const SizedBox(width: 8),
            Expanded(child: _StatMini(icon: Icons.local_fire_department, label: 'Meilleur Streak', value: '🔥 $streak', color: AppTheme.error)),
            const SizedBox(width: 8),
            Expanded(child: _StatMini(icon: Icons.track_changes, label: 'Précision', value: '$acc%', color: AppTheme.primary)),
          ],
        ),
        if (subjects.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('Performance par matière', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...subjects.map((s) => _SubjectStatCard(
            name: s['name'] as String? ?? '',
            games: s['games'] as int? ?? 0,
            wins: s['wins'] as int? ?? 0,
            accuracy: s['accuracy'] as int? ?? 0,
          )),
        ],
        if (games == 0) ...[
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Icons.sports_esports_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('Jouez votre premier duel !', style: TextStyle(fontSize: 16, color: AppTheme.textMuted)),
                const Text('Vos statistiques apparaîtront ici.', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _fmtPts(int pts) {
    if (pts >= 1000) return '${(pts / 1000).toStringAsFixed(1)}k';
    return '$pts';
  }
}

class _LeaderboardTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _LeaderboardTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final rank  = entry['rank'] as int;
    final name  = entry['username'] as String;
    final pts   = entry['total_points'] as int;
    final level = entry['level'] as int;
    final isMe  = entry['isMe'] == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color rankColor = AppTheme.textMuted;
    IconData? crown;
    if (rank == 1) { rankColor = const Color(0xFFFFD700); crown = Icons.emoji_events; }
    if (rank == 2) { rankColor = const Color(0xFFC0C0C0); crown = Icons.emoji_events; }
    if (rank == 3) { rankColor = const Color(0xFFCD7F32); crown = Icons.emoji_events; }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppTheme.primary.withOpacity(0.1)
            : rank <= 3
                ? rankColor.withOpacity(0.06)
                : isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        border: isMe
            ? Border.all(color: AppTheme.primary, width: 2)
            : rank <= 3
                ? Border.all(color: rankColor.withOpacity(0.3))
                : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: crown != null
                ? Icon(crown, color: rankColor, size: 24)
                : Text('#$rank', style: TextStyle(fontWeight: FontWeight.w700, color: rankColor, fontSize: 16)),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: isMe ? AppTheme.primary : AppTheme.primary.withOpacity(0.15),
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: isMe ? Colors.white : AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name & level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isMe ? AppTheme.primary : null)),
                Text('Niveau $level', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          // Points
          Text(
            '${_formatPts(pts)} pts',
            style: TextStyle(fontWeight: FontWeight.w800, color: rank <= 3 ? rankColor : AppTheme.primary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  String _formatPts(int pts) {
    if (pts >= 1000) return '${(pts / 1000).toStringAsFixed(1)}k';
    return pts.toString();
  }
}

class _StatMini extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatMini({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SubjectStatCard extends StatelessWidget {
  final String name;
  final int games;
  final int wins;
  final int accuracy;
  const _SubjectStatCard({required this.name, required this.games, required this.wins, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text('$games duels · $wins victoires', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$accuracy%', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}