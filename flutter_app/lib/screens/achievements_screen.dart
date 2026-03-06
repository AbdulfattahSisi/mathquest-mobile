import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../services/achievement_service.dart';
import '../theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _service = AchievementService();
  List<AchievementState> _achievements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await _service.getAllWithState();
    if (mounted) setState(() { _achievements = all; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _achievements.where((a) => a.isUnlocked).length;
    final total = _achievements.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBF360C), Color(0xFFE65100), Color(0xFFFF9800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                child: Row(
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [
                          const Icon(FontAwesomeIcons.trophy, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          const Text('Badges & Succès',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                        ]),
                        const SizedBox(height: 6),
                        Text('$unlocked / $total débloqués',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: total > 0 ? unlocked / total : 0,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            color: Colors.white,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(width: 12),
                    SizedBox(width: 80, height: 80,
                      child: Lottie.asset('assets/animations/trophy.json', repeat: true)),
                  ],
                ),
              ),
            ),
            backgroundColor: const Color(0xFFE65100),
          ),
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _BadgeCard(state: _achievements[i], index: i),
                  childCount: _achievements.length,
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final AchievementState state;
  final int index;
  const _BadgeCard({required this.state, required this.index});

  @override
  Widget build(BuildContext context) {
    final a = state.achievement;
    final unlocked = state.isUnlocked;

    Widget card = Container(
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked ? AppTheme.warning.withOpacity(0.6) : Colors.grey.shade200,
          width: unlocked ? 2.5 : 1,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(color: AppTheme.warning.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6)),
                BoxShadow(color: AppTheme.warning.withOpacity(0.08), blurRadius: 30, spreadRadius: 2),
              ]
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji / Lock
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: unlocked
                    ? LinearGradient(colors: [AppTheme.warning.withOpacity(0.2), AppTheme.warning.withOpacity(0.08)])
                    : null,
                color: unlocked ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
                boxShadow: unlocked
                    ? [BoxShadow(color: AppTheme.warning.withOpacity(0.15), blurRadius: 8)]
                    : [],
              ),
              child: Center(
                child: unlocked
                    ? Text(a.emoji, style: const TextStyle(fontSize: 30))
                    : Shimmer.fromColors(
                        baseColor: Colors.grey.shade400,
                        highlightColor: Colors.grey.shade200,
                        child: const Icon(FontAwesomeIcons.lock, size: 20, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              a.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: unlocked ? AppTheme.textMain : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              a.desc,
              style: TextStyle(
                fontSize: 10,
                color: unlocked ? AppTheme.textMuted : Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (unlocked) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF43A047)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_rounded, color: Colors.white, size: 12),
                  SizedBox(width: 3),
                  Text('Débloqué', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ],
        ),
      ),
    );

    return card.animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0);
  }
}
