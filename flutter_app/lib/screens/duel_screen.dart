import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../data/local_questions.dart';
import '../services/local_stats_service.dart';
import '../services/daily_streak_service.dart';
import '../services/achievement_service.dart';
import '../services/xp_level_service.dart';
import '../services/daily_goals_service.dart';
import '../theme.dart';

// ─── Power-up definitions ────────────────────────────────────────────────────
enum PowerUp {
  fiftyFifty('50/50', '✂️', 'Éliminer 2 mauvaises réponses', Color(0xFF2196F3)),
  timeFreeze('Freeze', '🧊', '+10 secondes', Color(0xFF00BCD4)),
  skipQuestion('Skip', '⏭️', 'Passer cette question', Color(0xFFFF9800));

  final String label;
  final String emoji;
  final String desc;
  final Color color;
  const PowerUp(this.label, this.emoji, this.desc, this.color);
}

// ─── Bot difficulty presets ───────────────────────────────────────────────────
enum BotLevel {
  easy('Facile 🤖', 0.45, 12, 20),
  medium('Normal 🤖', 0.65, 6, 14),
  hard('Expert 🤖', 0.85, 2, 8);

  final String label;
  /// Probability bot answers correctly
  final double accuracy;
  /// Min seconds before bot "answers"
  final int minDelay;
  /// Max seconds before bot "answers"
  final int maxDelay;

  const BotLevel(this.label, this.accuracy, this.minDelay, this.maxDelay);
}

// ─── Local subjects for picker ───────────────────────────────────────────────
class _SubjectChoice {
  final String slug;
  final String name;
  final String emoji;
  final Color color;
  const _SubjectChoice(this.slug, this.name, this.emoji, this.color);
}

const _availableSubjects = [
  _SubjectChoice('math',      'Mathématiques',    '📐', Color(0xFF1E88E5)),
  _SubjectChoice('physics',   'Physique',         '⚡', Color(0xFF8E24AA)),
  _SubjectChoice('chemistry', 'Chimie',           '🧪', Color(0xFF43A047)),
  _SubjectChoice('general',   'Culture Générale', '🌍', Color(0xFFFFB300)),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class DuelScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final dynamic apiService; // kept for route compat, not used in bot mode

  const DuelScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.apiService,
  });

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> with TickerProviderStateMixin {
  static const _totalQuestions = 8;
  static const _questionSeconds = 20;

  // ── Subject (may be picked if not provided) ─────────────────────────────────
  late String _subjectId;
  late String _subjectName;
  bool _subjectPicked = false;

  // ── Game data ────────────────────────────────────────────────────────────────
  late List<LocalQuestion> _questions;
  int _idx = 0;
  bool _answered = false;
  String? _playerChoice;
  String? _botChoice;
  bool _botAnswered = false;
  bool _finished = false;
  bool _choosing = false;
  BotLevel _botLevel = BotLevel.medium;
  bool _levelPicked = false;
  bool _statsSaved = false;

  // ── Scores ───────────────────────────────────────────────────────────────────
  int _playerScore = 0;
  int _botScore    = 0;
  int _playerCorrect = 0;
  int _botCorrect    = 0;

  // ── Timer ────────────────────────────────────────────────────────────────────
  int _timeLeft = _questionSeconds;
  Timer? _timer;
  Timer? _botTimer;
  late AnimationController _timerAnim;

  // ── Result animation ─────────────────────────────────────────────────────────
  late AnimationController _resultAnim;
  late Animation<double> _resultScale;

  // ── Streak & combo ──────────────────────────────────────────────────────────
  int _streak = 0;
  int _maxStreak = 0;
  double _comboMultiplier = 1.0;
  bool _showComboPopup = false;

  // ── Power-ups ────────────────────────────────────────────────────────────────
  final Map<PowerUp, int> _powerUps = {
    PowerUp.fiftyFifty: 1,
    PowerUp.timeFreeze: 1,
    PowerUp.skipQuestion: 1,
  };
  Set<String> _eliminatedOptions = {};
  bool _levelUpOccurred = false;

  final _sw = Stopwatch();
  final Random _rand = Random();
  final _statsService = LocalStatsService();
  final _dailyService = DailyStreakService();
  final _achievementService = AchievementService();
  final _xpService = XpLevelService();
  final _goalsService = DailyGoalsService();
  List<Achievement> _newBadges = [];
  List<String?> _playerAnswers = [];

  @override
  void initState() {
    super.initState();
    _subjectId = widget.subjectId;
    _subjectName = widget.subjectName;
    _subjectPicked = _subjectId.isNotEmpty;
    _timerAnim = AnimationController(
        vsync: this, duration: const Duration(seconds: _questionSeconds));
    _resultAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _resultScale =
        CurvedAnimation(parent: _resultAnim, curve: Curves.elasticOut);
    if (_subjectPicked) {
      _questions =
          getQuestionsForSubject(_subjectId, count: _totalQuestions);
      _playerAnswers = List<String?>.filled(_totalQuestions, null);
    } else {
      _questions = [];
      _playerAnswers = [];
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _botTimer?.cancel();
    _timerAnim.dispose();
    _resultAnim.dispose();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _botTimer?.cancel();
    _timeLeft = _questionSeconds;
    _timerAnim.reset();
    _timerAnim.forward();
    _sw.reset();
    _sw.start();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _onTimeout();
    });

    _scheduleBotAnswer();
  }

  void _scheduleBotAnswer() {
    final range = _botLevel.maxDelay - _botLevel.minDelay + 1;
    final delay = _botLevel.minDelay + _rand.nextInt(range);
    final capped = min(delay, _questionSeconds - 1);
    setState(() {
      _botAnswered = false;
      _botChoice = null;
      _choosing = true;
    });
    _botTimer = Timer(Duration(seconds: capped), () {
      if (!mounted || _answered) return;
      _handleBotAnswer();
    });
  }

  void _handleBotAnswer() {
    final q = _questions[_idx];
    final correct = _rand.nextDouble() < _botLevel.accuracy;
    final answer = correct ? q.correctAnswer : _randomWrong(q);
    setState(() {
      _botChoice = answer;
      _botAnswered = true;
      _choosing = false;
    });
  }

  String _randomWrong(LocalQuestion q) {
    final wrong = q.options
        .map((o) => o.label)
        .where((l) => l != q.correctAnswer)
        .toList()
      ..shuffle(_rand);
    return wrong.first;
  }

  void _onTimeout() {
    if (_answered) return;
    if (!_botAnswered) _handleBotAnswer();
    _revealAndAdvance(null);
  }

  // ── Player answers ────────────────────────────────────────────────────────────
  void _onPlayerTap(String label) {
    if (_answered) return;
    _timer?.cancel();
    _sw.stop();
    if (!_botAnswered) {
      _botTimer?.cancel();
      _handleBotAnswer();
    }
    _revealAndAdvance(label);
  }

  void _revealAndAdvance(String? playerAnswer) {
    if (_answered) return;
    final q = _questions[_idx];
    setState(() {
      _answered = true;
      _playerChoice = playerAnswer;
      _choosing = false;
    });
    // Track answer for review screen
    if (_idx < _playerAnswers.length) {
      _playerAnswers[_idx] = playerAnswer;
    }

    final playerOk = playerAnswer == q.correctAnswer;
    final botOk = _botChoice == q.correctAnswer;

    final timeBonus = playerAnswer != null
        ? max(0, (_questionSeconds * 1000 - _sw.elapsedMilliseconds) ~/ 500)
        : 0;
    final botBonus = 40 + _rand.nextInt(60);

    if (playerOk) {
      _streak++;
      _comboMultiplier = 1.0 + (_streak - 1) * 0.25; // 1x, 1.25x, 1.5x, 1.75x, 2x...
      final rawScore = 100 + timeBonus;
      final boosted = (rawScore * _comboMultiplier).round();
      _playerScore += boosted;
      _playerCorrect++;
      if (_streak > _maxStreak) _maxStreak = _streak;
      if (_streak >= 2) {
        _showComboPopup = true;
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) setState(() => _showComboPopup = false);
        });
      }
      HapticFeedback.mediumImpact();
    } else {
      _streak = 0;
      _comboMultiplier = 1.0;
      if (playerAnswer != null) HapticFeedback.heavyImpact();
    }
    if (botOk) {
      _botScore += 100 + botBonus;
      _botCorrect++;
    }

    setState(() {});

    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      if (_idx < _questions.length - 1) {
        setState(() {
          _idx++;
          _answered = false;
          _playerChoice = null;
          _botChoice = null;
          _botAnswered = false;
          _eliminatedOptions = {};
        });
        _startTimer();
      } else {
        setState(() => _finished = true);
        _resultAnim.forward();
        _saveStats();
      }
    });
  }

  // ── Save stats ─────────────────────────────────────────────────────────────
  Future<void> _saveStats() async {
    if (_statsSaved) return;
    _statsSaved = true;
    await _statsService.recordGame(
      subject: _subjectId,
      subjectName: _subjectName,
      playerScore: _playerScore,
      botScore: _botScore,
      correctAnswers: _playerCorrect,
      totalQuestions: _totalQuestions,
      botLevel: _botLevel.label,
      maxStreak: _maxStreak,
    );

    // Record daily play & check achievements
    await _dailyService.recordDailyPlay();
    final summary = await _statsService.getSummary();
    final history = await _statsService.getHistory();
    final streak = await _dailyService.getStreak();

    // Count hard wins & subjects
    final hardWins = history.where((g) => g['won'] == true && (g['botLevel'] as String?)?.contains('Expert') == true).length;
    final subjects = history.map((g) => g['subject']).toSet().length;

    final newBadges = await _achievementService.checkAndUnlock(
      totalGames: summary['games'] as int? ?? 0,
      totalWins: summary['wins'] as int? ?? 0,
      bestStreak: summary['bestStreak'] as int? ?? _maxStreak,
      avgAccuracy: summary['avgAccuracy'] as int? ?? 0,
      totalPoints: summary['totalPoints'] as int? ?? 0,
      hardWins: hardWins,
      subjectsPlayed: subjects,
      dailyStreak: streak,
    );

    if (mounted && newBadges.isNotEmpty) {
      setState(() => _newBadges = newBadges);
    }

    // Track XP
    _levelUpOccurred = await _xpService.addXP(_playerScore);

    // Track daily goals
    await _goalsService.recordGamePlayed(correctAnswers: _playerCorrect, maxStreak: _maxStreak);
  }

  // ─── Power-up handlers ────────────────────────────────────────────────────
  void _usePowerUp(PowerUp pu) {
    if (_answered || (_powerUps[pu] ?? 0) <= 0) return;
    HapticFeedback.lightImpact();
    setState(() => _powerUps[pu] = (_powerUps[pu] ?? 1) - 1);

    switch (pu) {
      case PowerUp.fiftyFifty:
        _useFiftyFifty();
        break;
      case PowerUp.timeFreeze:
        _useTimeFreeze();
        break;
      case PowerUp.skipQuestion:
        _useSkip();
        break;
    }
  }

  void _useFiftyFifty() {
    final q = _questions[_idx];
    final wrong = q.options
        .where((o) => o.label != q.correctAnswer)
        .map((o) => o.label)
        .toList()..shuffle(_rand);
    setState(() {
      _eliminatedOptions = wrong.take(2).toSet();
    });
  }

  void _useTimeFreeze() {
    setState(() => _timeLeft = min(_timeLeft + 10, 30));
  }

  void _useSkip() {
    _timer?.cancel();
    _botTimer?.cancel();
    if (_idx < _questions.length - 1) {
      setState(() {
        _idx++;
        _answered = false;
        _playerChoice = null;
        _botChoice = null;
        _botAnswered = false;
        _eliminatedOptions = {};
      });
      _startTimer();
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_subjectPicked) return _buildSubjectPicker();
    if (!_levelPicked) return _buildLevelPicker();
    if (_finished) return _buildResultScreen();
    return _buildGameScreen();
  }

  // ─── Subject picker ──────────────────────────────────────────────────────────
  Widget _buildSubjectPicker() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0F19), Color(0xFF1A1145), Color(0xFF0F2B4C)],
          ),
        ),
        child: Stack(
          children: [
            // Mesh gradient circles
            Positioned(
              top: -80, right: -60,
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.neonPurple.withOpacity(0.25), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100, left: -80,
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.royalBlue.withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(color: AppTheme.neonBlue.withOpacity(0.3), blurRadius: 40, spreadRadius: 8),
                          ],
                        ),
                        child: Lottie.asset('assets/animations/rocket.json', repeat: true),
                      ).animate().scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1), duration: 700.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 18),
                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.neonGradient.createShader(bounds),
                        child: const Text('Choisir une matière',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.8)),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      const SizedBox(height: 8),
                      Text('Sélectionnez le sujet de votre duel',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w500))
                          .animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 32),
                      ..._availableSubjects.asMap().entries.map((e) {
                        final s = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _subjectId = s.slug;
                                _subjectName = s.name;
                                _subjectPicked = true;
                                _questions = getQuestionsForSubject(s.slug, count: _totalQuestions);
                                _playerAnswers = List<String?>.filled(_totalQuestions, null);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: s.color.withOpacity(0.3), width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: s.color.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [s.color, s.color.withOpacity(0.6)]),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(color: s.color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 26))),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Text(s.name,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.2)),
                                  ),
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: s.color.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.arrow_forward_rounded, color: s.color, size: 18),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: 400 + e.key * 80), duration: 400.ms).slideX(begin: 0.12, end: 0),
                        );
                      }),
                      const SizedBox(height: 8),
                      // Mixed mode - premium card
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _subjectId = 'mixed';
                            _subjectName = 'Toutes les matières';
                            _subjectPicked = true;
                            _questions = getQuestionsForSubject('mixed', count: _totalQuestions);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppTheme.neonGradient,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(color: AppTheme.neonPurple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                              BoxShadow(color: AppTheme.neonBlue.withOpacity(0.2), blurRadius: 30, spreadRadius: 2),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: const Center(child: Text('🎲', style: TextStyle(fontSize: 26))),
                              ),
                              const SizedBox(width: 18),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mode Mixte',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.3)),
                                    Text('Questions de toutes les matières',
                                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms, duration: 500.ms).shimmer(delay: 1000.ms, duration: 1500.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Level picker ─────────────────────────────────────────────────────────────
  Widget _buildLevelPicker() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: Stack(
          children: [
            // Mesh gradients
            Positioned(
              top: -60, left: -60,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.neonBlue.withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80, right: -40,
              child: Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.neonPink.withOpacity(0.15), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                          boxShadow: [
                            BoxShadow(color: AppTheme.neonPurple.withOpacity(0.3), blurRadius: 40, spreadRadius: 6),
                          ],
                        ),
                        child: Lottie.asset('assets/animations/lightning.json', repeat: true),
                      ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 700.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 20),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFFFFFFFF)],
                        ).createShader(bounds),
                        child: const Text('Duel contre Bot',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.8)),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('📚', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(_subjectName,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 32),
                      Text('Choisissez le niveau du bot',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w700))
                          .animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 18),
                      ...BotLevel.values.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LevelCard(
                              level: e.value,
                              selected: _botLevel == e.value,
                              onTap: () => setState(() => _botLevel = e.value),
                            ).animate().fadeIn(delay: Duration(milliseconds: 500 + e.key * 80), duration: 400.ms).slideX(begin: -0.1, end: 0),
                          )),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () {
                          setState(() => _levelPicked = true);
                          _startTimer();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D4FF), Color(0xFF0EA5E9)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: AppTheme.neonBlue.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.play, size: 18, color: Colors.white),
                              SizedBox(width: 12),
                              Text('Commencer le duel !',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.2)),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms, duration: 500.ms).shimmer(delay: 1000.ms, duration: 1200.ms),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text('Annuler',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600)),
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Game screen ──────────────────────────────────────────────────────────────
  Widget _buildGameScreen() {
    final q = _questions[_idx];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  _buildScoreBar(),
                  const SizedBox(height: 4),
                  _buildTimerRing(),
                  const SizedBox(height: 4),
                  _buildPowerUpBar(),
                  const SizedBox(height: 4),
                  Expanded(child: _buildQuestionCard(q)),
                  const SizedBox(height: 10),
                ],
              ),
              // Combo popup
              if (_showComboPopup)
                Positioned(
                  top: 100,
                  left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFF9100)]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
                        ],
                      ),
                      child: Text(
                        '🔥 COMBO x${_comboMultiplier.toStringAsFixed(_comboMultiplier == _comboMultiplier.roundToDouble() ? 0 : 2)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                    ).animate()
                        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 300.ms, curve: Curves.elasticOut)
                        .fadeOut(delay: 900.ms, duration: 300.ms),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Power-up bar
  Widget _buildPowerUpBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: PowerUp.values.map((pu) {
          final remaining = _powerUps[pu] ?? 0;
          final canUse = remaining > 0 && !_answered;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: canUse ? () => _usePowerUp(pu) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: canUse
                      ? pu.color.withOpacity(0.25)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: canUse ? pu.color : Colors.white.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(pu.emoji, style: TextStyle(fontSize: 16, color: canUse ? null : Colors.white30)),
                    const SizedBox(width: 4),
                    Text(pu.label,
                        style: TextStyle(
                            color: canUse ? Colors.white : Colors.white30,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                    if (remaining > 0) ...[const SizedBox(width: 3), Text('$remaining', style: TextStyle(color: pu.color, fontSize: 10, fontWeight: FontWeight.w900))],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Top bar: avatars + question counter
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _avatar('Toi', AppTheme.primary, Icons.person),
          const Spacer(),
          Column(
            children: [
              Text('Q ${_idx + 1} / ${_questions.length}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(_subjectName,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 11)),
            ],
          ),
          const Spacer(),
          _avatar(_botLevel.label, Colors.redAccent, Icons.smart_toy),
        ],
      ),
    );
  }

  Widget _avatar(String label, Color color, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.9),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // Score bar
  Widget _buildScoreBar() {
    final total = _playerScore + _botScore;
    final pFrac = total == 0
        ? 0.5
        : (_playerScore / total).clamp(0.05, 0.95);
    final screenW = MediaQuery.of(context).size.width - 32;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_playerScore pts',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17)),
              Text('$_botScore pts',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: screenW * pFrac,
                    color: AppTheme.primary,
                  ),
                  Expanded(child: Container(color: Colors.redAccent)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Timer ring
  Widget _buildTimerRing() {
    final danger = _timeLeft <= 5;
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _timerAnim,
            builder: (_, __) => CircularProgressIndicator(
              value: 1 - _timerAnim.value,
              strokeWidth: 7,
              backgroundColor: Colors.white.withOpacity(0.25),
              color: danger ? AppTheme.error : Colors.white,
            ),
          ),
          Text('$_timeLeft',
              style: TextStyle(
                  color: danger ? Colors.orange : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22)),
        ],
      ),
    );
  }

  // Question card
  Widget _buildQuestionCard(LocalQuestion q) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15), blurRadius: 18)
        ],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                _diffBadge(q.difficulty),
                const Spacer(),
                if (_streak >= 2) _badge('🔥 ×$_streak', Colors.orange),
                const SizedBox(width: 8),
                _botStatusBadge(),
              ],
            ),
          ),
          // Question text
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(q.text,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5)),
          ),
          const Divider(height: 1),
          // Options grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.0,
                physics: const NeverScrollableScrollPhysics(),
                children: q.options
                    .map((opt) => _buildOption(opt, q))
                    .toList(),
              ),
            ),
          ),
          // Explanation
          if (_answered && _playerChoice != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(q.explanation,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B5000))),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(LocalOption opt, LocalQuestion q) {
    final isEliminated = _eliminatedOptions.contains(opt.label);
    if (isEliminated) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.15), width: 2),
        ),
        child: Center(
          child: Text('✂️', style: TextStyle(fontSize: 20, color: Colors.grey.withOpacity(0.4))),
        ),
      );
    }
    final isSelected = _playerChoice == opt.label;
    final isCorrect = _answered && opt.label == q.correctAnswer;
    final isWrong =
        _answered && isSelected && opt.label != q.correctAnswer;
    final isBotPick =
        _botAnswered && _botChoice == opt.label && _answered;

    Color bg = const Color(0xFFF3F4F6);
    Color border = Colors.transparent;

    if (isCorrect) {
      bg = AppTheme.success.withOpacity(0.15);
      border = AppTheme.success;
    }
    if (isWrong) {
      bg = AppTheme.error.withOpacity(0.15);
      border = AppTheme.error;
    }
    if (isSelected && !isCorrect && !isWrong) {
      bg = AppTheme.primary.withOpacity(0.1);
      border = AppTheme.primary;
    }

    return GestureDetector(
      onTap: _answered ? null : () => _onPlayerTap(opt.label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppTheme.success
                        : isWrong
                            ? AppTheme.error
                            : AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(opt.label,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: (isCorrect || isWrong)
                                ? Colors.white
                                : AppTheme.primary)),
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.person, size: 14, color: AppTheme.primary),
                const SizedBox(width: 2),
                if (isBotPick)
                  const Icon(Icons.smart_toy,
                      size: 14, color: Colors.redAccent),
              ],
            ),
            const SizedBox(height: 4),
            Text(opt.value,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _diffBadge(int d) {
    final cols = [
      Colors.green,
      Colors.lightGreen,
      Colors.orange,
      Colors.deepOrange,
      Colors.red
    ];
    final c = cols[(d - 1).clamp(0, 4)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: c.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20)),
      child: Text('Niv. $d',
          style: TextStyle(
              color: c, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _botStatusBadge() {
    if (_answered) {
      final ok = _botChoice == _questions[_idx].correctAnswer;
      return _badge(ok ? '🤖 Correct' : '🤖 Raté',
          ok ? AppTheme.success : AppTheme.error);
    }
    if (_botAnswered) return _badge('🤖 Répondu ✓', AppTheme.success);
    if (_choosing) return _badge('🤖 Réfléchit…', Colors.grey);
    return const SizedBox();
  }

  // ─── Result screen ─────────────────────────────────────────────────────────────
  Widget _buildResultScreen() {
    final playerWon = _playerScore > _botScore;
    final draw = _playerScore == _botScore;
    final lottie = playerWon ? 'assets/animations/trophy.json' : draw ? 'assets/animations/success.json' : 'assets/animations/lightning.json';
    final msg = draw ? 'Égalité !' : playerWon ? 'Victoire !' : 'Défaite…';
    final sub = draw
        ? 'Personne ne s\'incline !'
        : playerWon
            ? 'Tu as écrasé le bot !'
            : 'Le bot t\'a dominé cette fois.';

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: playerWon
                    ? [const Color(0xFF1A237E), const Color(0xFF3949AB)]
                    : draw
                        ? [const Color(0xFF1B5E20), const Color(0xFF388E3C)]
                        : [const Color(0xFF4A0000), const Color(0xFFB71C1C)],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _resultScale,
                        child: SizedBox(width: 120, height: 120,
                          child: Lottie.asset(lottie, repeat: true)),
                      ),
                      const SizedBox(height: 16),
                      Text(msg,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900))
                          .animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 4),
                      Text(sub,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15))
                          .animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: 20),

                      // XP gained badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text('+$_playerScore XP',
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 20)),
                          ],
                        ),
                      ).animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), delay: 600.ms, duration: 500.ms, curve: Curves.elasticOut),

                      // Level up indicator
                      if (_levelUpOccurred) ...[  
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 16)],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🌟', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text('NIVEAU SUPÉRIEUR !', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                            ],
                          ),
                        ).animate()
                            .scale(begin: const Offset(0, 0), end: const Offset(1, 1), delay: 700.ms, duration: 600.ms, curve: Curves.elasticOut)
                            .shimmer(delay: 1200.ms, duration: 1500.ms),
                      ],

                      const SizedBox(height: 20),
                      _buildScoreComparison(),
                      const SizedBox(height: 20),
                      _buildStatsGrid(),

                      // New badges unlocked
                      if (_newBadges.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text('🎉 Nouveaux badges !',
                            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w800, fontSize: 16))
                            .animate().fadeIn(delay: 800.ms),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _newBadges.asMap().entries.map((e) =>
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.amber.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(e.value.emoji, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(e.value.title,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                ],
                              ),
                            ).animate()
                                .fadeIn(delay: Duration(milliseconds: 900 + e.key * 200))
                                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut),
                          ).toList(),
                        ),
                      ],

                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _replay,
                        icon: const Icon(Icons.replay),
                        label: const Text('Rejouer',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => _ReviewScreenInline(
                              questions: _questions,
                              playerAnswers: _playerAnswers,
                              subjectName: _subjectName,
                            ),
                          ));
                        },
                        icon: const Icon(Icons.quiz_outlined, color: Colors.white),
                        label: const Text('Revoir les questions', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ).animate().fadeIn(delay: 750.ms),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.home_outlined,
                            color: Colors.white),
                        label: const Text('Accueil',
                            style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Confetti particles overlay for victory
          if (playerWon)
            ..._buildConfettiOverlay(),
        ],
      ),
    );
  }

  List<Widget> _buildConfettiOverlay() {
    final rnd = Random(DateTime.now().millisecondsSinceEpoch);
    final screenW = MediaQuery.of(context).size.width;
    return List.generate(20, (i) {
      final colors = [Colors.amber, Colors.blue, Colors.green, Colors.red, Colors.purple, Colors.orange, Colors.pink];
      final color = colors[rnd.nextInt(colors.length)];
      final left = rnd.nextDouble() * screenW;
      final size = 6.0 + rnd.nextDouble() * 10;
      final delay = rnd.nextInt(2000);
      final duration = 2000 + rnd.nextInt(3000);
      return Positioned(
        left: left,
        top: -20,
        child: Container(
          width: size,
          height: size * (0.5 + rnd.nextDouble()),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .moveY(begin: 0, end: MediaQuery.of(context).size.height + 40, duration: Duration(milliseconds: duration), delay: Duration(milliseconds: delay))
            .rotate(begin: 0, end: rnd.nextDouble() * 4 - 2, duration: Duration(milliseconds: duration))
            .fadeOut(delay: Duration(milliseconds: duration - 500), duration: 500.ms),
      );
    });
  }

  Widget _buildScoreComparison() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _scoreCol('Toi', _playerScore, Icons.person, AppTheme.primary),
          Text('VS',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w900,
                  fontSize: 20)),
          _scoreCol(
              _botLevel.label, _botScore, Icons.smart_toy, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _scoreCol(String name, int score, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.8),
            child: Icon(icon, color: Colors.white, size: 26)),
        const SizedBox(height: 8),
        Text(score.toString(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900)),
        Text('pts',
            style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 4),
        Text(name,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final acc = _totalQuestions == 0
        ? 0.0
        : _playerCorrect / _totalQuestions * 100;
    final items = [
      ('✅ Bonnes rép.', '$_playerCorrect / $_totalQuestions'),
      ('🎯 Précision', '${acc.toStringAsFixed(0)}%'),
      ('🔥 Max combo', '×$_maxStreak'),
      ('🤖 Bot correct', '$_botCorrect / $_totalQuestions'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: items
          .map((e) => _statTile(e.$1, e.$2))
          .toList(),
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  void _replay() {
    setState(() {
      _idx = 0;
      _answered = false;
      _playerChoice = null;
      _botChoice = null;
      _botAnswered = false;
      _finished = false;
      _levelPicked = false;
      _statsSaved = false;
      _playerScore = 0;
      _botScore = 0;
      _playerCorrect = 0;
      _botCorrect = 0;
      _streak = 0;
      _maxStreak = 0;
      _timeLeft = _questionSeconds;
      _newBadges = [];
      _comboMultiplier = 1.0;
      _showComboPopup = false;
      _eliminatedOptions = {};
      _levelUpOccurred = false;
      _powerUps[PowerUp.fiftyFifty] = 1;
      _powerUps[PowerUp.timeFreeze] = 1;
      _powerUps[PowerUp.skipQuestion] = 1;
      _questions =
          getQuestionsForSubject(_subjectId, count: _totalQuestions);
      _playerAnswers = List<String?>.filled(_totalQuestions, null);
    });
    _resultAnim.reset();
    _timerAnim.reset();
  }
}

// ─── Level card widget ─────────────────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
  final BotLevel level;
  final bool selected;
  final VoidCallback onTap;

  const _LevelCard(
      {required this.level, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const descs = {
      BotLevel.easy: 'Répond lentement, se trompe souvent.',
      BotLevel.medium: 'Vitesse et précision moyennes.',
      BotLevel.hard: 'Répond vite et est presque parfait !',
    };
    const colors = {
      BotLevel.easy: Colors.green,
      BotLevel.medium: Colors.orange,
      BotLevel.hard: Colors.redAccent,
    };
    final c = colors[level]!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.25) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? c : Colors.white30,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(Icons.smart_toy, color: c, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  Text(descs[level]!,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12)),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: c),
          ],
        ),
      ),
    );
  }
}

// ─── Inline Review Screen (navigated from result) ──────────────────────────
class _ReviewScreenInline extends StatelessWidget {
  final List<LocalQuestion> questions;
  final List<String?> playerAnswers;
  final String subjectName;
  const _ReviewScreenInline({required this.questions, required this.playerAnswers, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (i < playerAnswers.length && playerAnswers[i] == questions[i].correctAnswer) correct++;
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bg,
      appBar: AppBar(
        title: const Text('📋 Revue des questions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppTheme.darkText : AppTheme.textMain,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _col('📝', '${questions.length}', 'Questions'),
                _col('✅', '$correct', 'Correctes'),
                _col('❌', '${questions.length - correct}', 'Fausses'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...questions.asMap().entries.map((entry) {
            final i = entry.key;
            final q = entry.value;
            final pa = i < playerAnswers.length ? playerAnswers[i] : null;
            final ok = pa == q.correctAnswer;
            final skipped = pa == null;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(
                  color: skipped ? AppTheme.warning : ok ? AppTheme.success : AppTheme.error,
                  width: 4,
                )),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 8)],
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                leading: Text(skipped ? '⏭️' : ok ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
                title: Text('Q${i + 1}: ${q.text}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? AppTheme.darkText : AppTheme.textMain), maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  skipped ? 'Passée' : ok ? 'Correct : ${q.correctAnswer}' : 'Vous : $pa → Correct : ${q.correctAnswer}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: skipped ? AppTheme.warning : ok ? AppTheme.success : AppTheme.error),
                ),
                children: [
                  ...q.options.map((opt) {
                    final isOk = opt.label == q.correctAnswer;
                    final isPick = opt.label == pa;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isOk ? AppTheme.success.withOpacity(0.1) : isPick && !isOk ? AppTheme.error.withOpacity(0.1) : (isDark ? AppTheme.darkBg : const Color(0xFFF5F5F5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(color: isOk ? AppTheme.success : isPick ? AppTheme.error : Colors.grey.shade300, borderRadius: BorderRadius.circular(6)),
                            child: Center(child: Text(opt.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: (isOk || isPick) ? Colors.white : AppTheme.textMain))),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(opt.value, style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkText : AppTheme.textMain))),
                          if (isOk) const Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                          if (isPick && !isOk) const Icon(Icons.cancel, color: AppTheme.error, size: 16),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(q.explanation, style: const TextStyle(fontSize: 11, color: Color(0xFF6D4C00)))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _col(String emoji, String val, String label) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 2),
      Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
    ],
  );
}
