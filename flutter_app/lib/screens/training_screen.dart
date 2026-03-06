import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/local_questions.dart';
import '../services/xp_level_service.dart';
import '../services/daily_goals_service.dart';
import '../theme.dart';

/// Training / Practice Mode — no timer, no bot, just learning.
class TrainingScreen extends StatefulWidget {
  final String subjectSlug;
  final String subjectName;
  const TrainingScreen({super.key, required this.subjectSlug, required this.subjectName});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> with SingleTickerProviderStateMixin {
  late List<LocalQuestion> _questions;
  int _idx = 0;
  bool _answered = false;
  String? _selectedAnswer;
  int _correct = 0;
  int _total = 0;
  bool _finished = false;
  bool _showExplanation = false;
  final _xpService = XpLevelService();
  final _goalsService = DailyGoalsService();

  late AnimationController _cardAnim;

  @override
  void initState() {
    super.initState();
    _questions = getQuestionsForSubject(widget.subjectSlug, count: 15);
    _cardAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _cardAnim.dispose();
    super.dispose();
  }

  void _onAnswer(String label) {
    if (_answered) return;
    HapticFeedback.lightImpact();
    final q = _questions[_idx];
    final isCorrect = label == q.correctAnswer;
    setState(() {
      _answered = true;
      _selectedAnswer = label;
      _total++;
      if (isCorrect) {
        _correct++;
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _showExplanationToggle() {
    setState(() => _showExplanation = !_showExplanation);
  }

  void _nextQuestion() {
    if (_idx < _questions.length - 1) {
      setState(() {
        _idx++;
        _answered = false;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    } else {
      _finishTraining();
    }
  }

  Future<void> _finishTraining() async {
    final xpEarned = _correct * 15;
    await _xpService.addXP(xpEarned);
    await _goalsService.recordTrainingPlayed();
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResultScreen();
    return _buildQuestionScreen();
  }

  Widget _buildQuestionScreen() {
    final q = _questions[_idx];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_idx + 1) / _questions.length;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bg,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('📚 ', style: TextStyle(fontSize: 20)),
            Text('Entraînement', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppTheme.darkText : AppTheme.textMain)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? AppTheme.darkText : AppTheme.textMain),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_idx + 1} / ${_questions.length}',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                color: AppTheme.primary,
              ),
            ),
          ),

          // Score mini
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                _miniTag('✅ $_correct', AppTheme.success),
                const SizedBox(width: 8),
                _miniTag('❌ ${_total - _correct}', AppTheme.error),
                const Spacer(),
                _miniTag('Niv. ${q.difficulty}', _diffColor(q.difficulty)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Question card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Subject badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.subjectName,
                      style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Question text
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
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: isDark ? AppTheme.darkText : AppTheme.textMain,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 20),

                  // Options
                  ...q.options.asMap().entries.map((e) {
                    final opt = e.value;
                    final i = e.key;
                    final isCorrect = opt.label == q.correctAnswer;
                    final isSelected = _selectedAnswer == opt.label;
                    final isWrong = _answered && isSelected && !isCorrect;

                    Color cardColor = isDark ? AppTheme.darkCard : Colors.white;
                    Color borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
                    IconData? trailingIcon;

                    if (_answered && isCorrect) {
                      cardColor = AppTheme.success.withOpacity(0.12);
                      borderColor = AppTheme.success;
                      trailingIcon = Icons.check_circle;
                    } else if (isWrong) {
                      cardColor = AppTheme.error.withOpacity(0.12);
                      borderColor = AppTheme.error;
                      trailingIcon = Icons.cancel;
                    } else if (isSelected) {
                      cardColor = AppTheme.primary.withOpacity(0.1);
                      borderColor = AppTheme.primary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: _answered ? null : () => _onAnswer(opt.label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              // Label badge
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: (_answered && isCorrect)
                                      ? AppTheme.success
                                      : isWrong
                                          ? AppTheme.error
                                          : AppTheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    opt.label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: (_answered && isCorrect) || isWrong
                                          ? Colors.white
                                          : AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  opt.value,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isDark ? AppTheme.darkText : AppTheme.textMain,
                                  ),
                                ),
                              ),
                              if (trailingIcon != null)
                                Icon(trailingIcon,
                                    color: isWrong ? AppTheme.error : AppTheme.success,
                                    size: 22),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 80 * i), duration: 200.ms),
                    );
                  }),

                  // Explanation
                  if (_answered) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showExplanationToggle,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                const Text('Explication', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF6D4C00))),
                                const Spacer(),
                                Icon(
                                  _showExplanation ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: const Color(0xFF6D4C00),
                                ),
                              ],
                            ),
                            if (_showExplanation) ...[
                              const SizedBox(height: 8),
                              Text(
                                q.explanation,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF6D4C00), height: 1.4),
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _nextQuestion,
                        icon: Icon(_idx < _questions.length - 1 ? Icons.arrow_forward_rounded : Icons.flag_rounded),
                        label: Text(
                          _idx < _questions.length - 1 ? 'Question suivante' : 'Terminer',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final accuracy = _total > 0 ? (_correct / _total * 100) : 0.0;
    final xpEarned = _correct * 15;
    final emoji = accuracy >= 80 ? '🌟' : accuracy >= 60 ? '👍' : accuracy >= 40 ? '💪' : '📚';
    final msg = accuracy >= 80 ? 'Excellent !' : accuracy >= 60 ? 'Bien joué !' : accuracy >= 40 ? 'Pas mal !' : 'Continuez à pratiquer !';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: accuracy >= 60
                ? [const Color(0xFF1A237E), const Color(0xFF3949AB)]
                : [const Color(0xFF4A148C), const Color(0xFF7B1FA2)],
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
                  Text(msg, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900))
                      .animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 6),
                  Text('${widget.subjectName} — Entraînement',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14))
                      .animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 24),

                  // XP earned
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.amber.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text('+$xpEarned XP',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 20)),
                      ],
                    ),
                  ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  // Stats grid
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _resultStat('$_correct / $_total', 'Bonnes réponses', '✅'),
                            _resultStat('${accuracy.toStringAsFixed(0)}%', 'Précision', '🎯'),
                            _resultStat('${_questions.length}', 'Questions', '📝'),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _idx = 0;
                        _answered = false;
                        _selectedAnswer = null;
                        _correct = 0;
                        _total = 0;
                        _finished = false;
                        _showExplanation = false;
                        _questions = getQuestionsForSubject(widget.subjectSlug, count: 15);
                      });
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Recommencer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

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

  Widget _resultStat(String value, String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
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

  Color _diffColor(int d) {
    const cols = [Colors.green, Colors.lightGreen, Colors.orange, Colors.deepOrange, Colors.red];
    return cols[(d - 1).clamp(0, 4)];
  }
}
