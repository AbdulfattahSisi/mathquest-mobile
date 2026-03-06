import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _PageData(
      lottie: 'assets/animations/lightning.json',
      bgIcon: Icons.bolt_rounded,
      title: 'Duels Interactifs',
      subtitle: 'Affrontez un bot IA avec 3 niveaux de difficulté.\nRépondez vite pour gagner des points bonus !',
      gradient: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
      features: ['3 niveaux de difficulté', 'Power-ups stratégiques', 'Combo multiplicateur'],
    ),
    _PageData(
      lottie: 'assets/animations/stats.json',
      bgIcon: Icons.insights_rounded,
      title: 'Suivez vos Progrès',
      subtitle: 'Statistiques détaillées, graphiques interactifs\net analyse intelligente de vos performances.',
      gradient: [Color(0xFF4A148C), Color(0xFF7B1FA2), Color(0xFFAB47BC)],
      features: ['Graphiques en temps réel', 'Historique complet', 'Export CSV'],
    ),
    _PageData(
      lottie: 'assets/animations/trophy.json',
      bgIcon: Icons.emoji_events_rounded,
      title: 'Badges & Classement',
      subtitle: 'Débloquez 18 badges uniques, grimpez dans le classement\net devenez le champion !',
      gradient: [Color(0xFFBF360C), Color(0xFFE65100), Color(0xFFFF9800)],
      features: ['18 badges à débloquer', 'Podium en temps réel', 'Streak journalier'],
    ),
    _PageData(
      lottie: 'assets/animations/brain.json',
      bgIcon: Icons.psychology_rounded,
      title: 'Intelligence Artificielle',
      subtitle: 'Questions générées par IA, difficulté adaptative\net conseils personnalisés pour progresser.',
      gradient: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF66BB6A)],
      features: ['IA GPT-4 intégrée', 'Difficulté adaptative', '4 matières scientifiques'],
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _buildPage(_pages[i], i),
          ),
          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text('MathQuest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                ]).animate().fadeIn(duration: 600.ms),
                TextButton(
                  onPressed: _finish,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text('Passer ›', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          // Bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 32 : 8, height: 8,
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.white30,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: active ? [BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 8)] : [],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _page == _pages.length - 1
                          ? _finish
                          : () => _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
                            BoxShadow(color: _pages[_page].gradient.first.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_page == _pages.length - 1 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                                color: _pages[_page].gradient[1], size: 22),
                            const SizedBox(width: 10),
                            Text(
                              _page == _pages.length - 1 ? 'Commencer l\'aventure !' : 'Suivant',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _pages[_page].gradient[1]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_PageData data, int pageIndex) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: data.gradient),
      ),
      child: Stack(
        children: [
          ..._buildParticles(pageIndex),
          Positioned(right: -40, top: 80, child: Icon(data.bgIcon, size: 200, color: Colors.white.withOpacity(0.05))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 40, spreadRadius: 10)],
                    ),
                    child: Center(child: SizedBox(width: 140, height: 140, child: Lottie.asset(data.lottie, repeat: true))),
                  )
                      .animate()
                      .scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1), duration: 700.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 500.ms),
                  const SizedBox(height: 20),
                  Text(data.title,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5, height: 1.1),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 12),
                  Text(data.subtitle,
                    style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.85), height: 1.6),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center, spacing: 8, runSpacing: 8,
                    children: data.features.asMap().entries.map((e) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white.withOpacity(0.9), size: 16),
                        const SizedBox(width: 6),
                        Text(e.value, style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    ).animate().fadeIn(delay: Duration(milliseconds: 500 + e.key * 100), duration: 400.ms).slideX(begin: 0.2, end: 0)).toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles(int seed) {
    final rnd = Random(seed * 42 + 7);
    return List.generate(12, (i) {
      final size = 4.0 + rnd.nextDouble() * 8;
      return Positioned(
        left: rnd.nextDouble() * 400, top: rnd.nextDouble() * 700,
        child: Container(width: size, height: size,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.08 + rnd.nextDouble() * 0.12), shape: BoxShape.circle),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -15 - rnd.nextDouble() * 25, duration: Duration(milliseconds: 2500 + rnd.nextInt(2500)))
            .fadeIn(duration: Duration(milliseconds: 1000 + rnd.nextInt(1500))),
      );
    });
  }
}

class _PageData {
  final String lottie;
  final IconData bgIcon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final List<String> features;
  const _PageData({required this.lottie, required this.bgIcon, required this.title, required this.subtitle, required this.gradient, required this.features});
}
