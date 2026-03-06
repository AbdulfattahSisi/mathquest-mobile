import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/local_questions.dart';
import '../services/xp_level_service.dart';
import '../services/daily_goals_service.dart';
import '../theme.dart';

/// Speed Challenge Mode — 60 seconds, answer as many questions as possible.
class ChronoScreen extends StatefulWidget {
  final String subjectSlug;
  final String subjectName;
  const ChronoScreen({super.key, required this.subjectSlug, required this.subjectName});

  @override
  State<ChronoScreen> createState() => _ChronoScreenState();
}

class _ChronoScreenState extends State<ChronoScreen> with TickerProviderStateMixin {
  static const _gameDuration = 60; // seconds

  late List<LocalQuestion> _allQuestions;
  late LocalQuestion _currentQuestion;
  int _questionIndex = 0;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _score = 0;
  int _timeLeft = _gameDuration;
  Timer? _timer;
  bool _started = false;
  bool _finished = false;
  bool _answered = false;
  String? _selectedAnswer;

  late AnimationController _pulseAnim;
  late AnimationController _shakeAnim;

  final _xpService = XpLevelService();
  final _goalsService = DailyGoalsService();

  @override
  void initState() {
    super.initState();
    // Get a large pool of questions
    _allQuestions = getQuestionsForSubject(widget.subjectSlug, count: 50);
    _allQuestions.shuffle(Random());
    _currentQuestion = _allQuestions[0];
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseAnim.dispose();
    _shakeAnim.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() => _started = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 10) {
        _pulseAnim.forward(from: 0);
      }
      if (_timeLeft <= 0) {
        _timer?.cancel();
        _endGame();
      }
    });
  }

  void _onAnswer(String label) {
    if (_answered || _finished) return;
    HapticFeedback.lightImpact();
    final isCorrect = label == _currentQuestion.correctAnswer;

    setState(() {
      _answered = true;
      _selectedAnswer = label;
    });

    if (isCorrect) {
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;
      final bonus = min(_streak, 5); // streak bonus caps at 5
      _score += 100 + (bonus * 20);
      _correct++;
      HapticFeedback.mediumImpact();
    } else {
      _streak = 0;
      _wrong++;
      HapticFeedback.heavyImpact();
      _shakeAnim.forward(from: 0);
    }

    // Quick transition to next question
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted || _finished) return;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    _questionIndex++;
    if (_questionIndex >= _allQuestions.length) {
      // Reshuffle if we run out
      _allQuestions.shuffle(Random());
      _questionIndex = 0;
    }
    setState(() {
      _currentQuestion = _allQuestions[_questionIndex];
      _answered = false;
      _selectedAnswer = null;
    });
  }

  Future<void> _endGame() async {
    final xpEarned = _score ~/ 2;
    await _xpService.addXP(xpEarned);
    await _goalsService.recordChronoPlayed();
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) return _buildCountdown();
    if (_finished) return _buildResultScreen();
    return _buildGameScreen();
  }

  Widget _buildCountdown() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6D00), Color(0xFFFF9100), Color(0xFFFFAB40)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 80))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 800.ms),
                const SizedBox(height: 16),
                const Text('Mode Chrono', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900))
                    .animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  widget.subjectName,
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      const Text('🕐', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      const Text('60 secondes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                        'Répondez au maximum de questions\navant la fin du temps !',
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ruleChip('🎯 +100 pts/bonne'),
                          const SizedBox(width: 8),
                          _ruleChip('🔥 Streak bonus'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: const Text('GO !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF6D00),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retour', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ruleChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildGameScreen() {
    final q = _currentQuestion;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final danger = _timeLeft <= 10;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Timer bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  // Timer
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) => Transform.scale(
                      scale: danger ? 1.0 + _pulseAnim.value * 0.1 : 1.0,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: danger ? AppTheme.error.withOpacity(0.15) : AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: danger ? AppTheme.error : AppTheme.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, size: 18,
                              color: danger ? AppTheme.error : AppTheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            '${_timeLeft}s',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: danger ? AppTheme.error : AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('⭐ $_score', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.amber)),
                  ),
                  const SizedBox(width: 8),
                  // Streak
                  if (_streak >= 2)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('🔥 $_streak', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.orange)),
                    ),
                ],
              ),
            ),

            // Progress: correct / wrong
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  _miniTag('✅ $_correct', AppTheme.success),
                  const SizedBox(width: 8),
                  _miniTag('❌ $_wrong', AppTheme.error),
                  const Spacer(),
                  Text('Q${_questionIndex + 1}', style: TextStyle(color: isDark ? AppTheme.darkMuted : AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),

            // Time progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _timeLeft / _gameDuration,
                  minHeight: 5,
                  backgroundColor: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                  color: danger ? AppTheme.error : const Color(0xFFFF9100),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Question
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        q.text,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          color: isDark ? AppTheme.darkText : AppTheme.textMain,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Options — 2x2 grid for speed
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.2,
                      children: q.options.map((opt) {
                        final isCorrect = opt.label == q.correctAnswer;
                        final isSelected = _selectedAnswer == opt.label;
                        final isWrong = _answered && isSelected && !isCorrect;
                        final showCorrect = _answered && isCorrect;

                        Color bg = isDark ? AppTheme.darkCard : Colors.white;
                        Color border = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300;

                        if (showCorrect) {
                          bg = AppTheme.success.withOpacity(0.15);
                          border = AppTheme.success;
                        } else if (isWrong) {
                          bg = AppTheme.error.withOpacity(0.15);
                          border = AppTheme.error;
                        }

                        return GestureDetector(
                          onTap: _answered ? null : () => _onAnswer(opt.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: border, width: 2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: showCorrect
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
                                          color: (showCorrect || isWrong) ? Colors.white : AppTheme.primary,
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    opt.value,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppTheme.darkText : AppTheme.textMain,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final accuracy = (_correct + _wrong) > 0
        ? (_correct / (_correct + _wrong) * 100)
        : 0.0;
    final xpEarned = _score ~/ 2;
    final questionsAnswered = _correct + _wrong;
    final emoji = _score >= 2000 ? '🏆' : _score >= 1000 ? '⚡' : _score >= 500 ? '👍' : '💪';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 72))
                      .animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  const Text('Temps écoulé !', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900))
                      .animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 6),
                  Text(widget.subjectName, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),

                  const SizedBox(height: 24),

                  // Big score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Column(
                      children: [
                        Text('$_score', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
                        const Text('POINTS', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
                      ],
                    ),
                  ).animate().scale(delay: 300.ms, duration: 500.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  // XP earned
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('⭐ +$xpEarned XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _resultCol('$questionsAnswered', 'Questions', '📝'),
                        _resultCol('$_correct', 'Correctes', '✅'),
                        _resultCol('${accuracy.toStringAsFixed(0)}%', 'Précision', '🎯'),
                        _resultCol('$_maxStreak', 'Max Streak', '🔥'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _questionIndex = 0;
                        _correct = 0;
                        _wrong = 0;
                        _streak = 0;
                        _maxStreak = 0;
                        _score = 0;
                        _timeLeft = _gameDuration;
                        _started = false;
                        _finished = false;
                        _answered = false;
                        _selectedAnswer = null;
                        _allQuestions.shuffle(Random());
                        _currentQuestion = _allQuestions[0];
                      });
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Rejouer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFF6D00),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text('Retour', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultCol(String value, String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
      ],
    );
  }

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
