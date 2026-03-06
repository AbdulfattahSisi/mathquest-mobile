import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/local_questions.dart';
import '../theme.dart';

/// Post-duel question review — see all questions with correct answers.
class ReviewScreen extends StatelessWidget {
  final List<LocalQuestion> questions;
  final List<String?> playerAnswers;
  final String subjectName;

  const ReviewScreen({
    super.key,
    required this.questions,
    required this.playerAnswers,
    required this.subjectName,
  });

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
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem('📝', '${questions.length}', 'Questions'),
                _summaryItem('✅', '$correct', 'Correctes'),
                _summaryItem('❌', '${questions.length - correct}', 'Fausses'),
                _summaryItem('🎯', '${questions.length > 0 ? (correct / questions.length * 100).round() : 0}%', 'Précision'),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),

          Text(subjectName, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkText : AppTheme.textMain,
          )),
          const SizedBox(height: 12),

          // Question list
          ...questions.asMap().entries.map((entry) {
            final i = entry.key;
            final q = entry.value;
            final playerAnswer = i < playerAnswers.length ? playerAnswers[i] : null;
            final wasCorrect = playerAnswer == q.correctAnswer;
            final skipped = playerAnswer == null;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(
                    color: skipped ? AppTheme.warning : wasCorrect ? AppTheme.success : AppTheme.error,
                    width: 4,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: (skipped ? AppTheme.warning : wasCorrect ? AppTheme.success : AppTheme.error).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      skipped ? '⏭️' : wasCorrect ? '✅' : '❌',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                title: Text(
                  'Q${i + 1}: ${q.text}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? AppTheme.darkText : AppTheme.textMain,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  skipped
                      ? 'Passée'
                      : wasCorrect
                          ? 'Bonne réponse : ${q.correctAnswer}'
                          : 'Votre réponse : $playerAnswer → Correct : ${q.correctAnswer}',
                  style: TextStyle(
                    fontSize: 11,
                    color: skipped ? AppTheme.warning : wasCorrect ? AppTheme.success : AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  // All options
                  ...q.options.map((opt) {
                    final isCorrectOpt = opt.label == q.correctAnswer;
                    final isPlayerPick = opt.label == playerAnswer;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCorrectOpt
                            ? AppTheme.success.withOpacity(0.1)
                            : isPlayerPick && !isCorrectOpt
                                ? AppTheme.error.withOpacity(0.1)
                                : (isDark ? AppTheme.darkBg : const Color(0xFFF5F5F5)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCorrectOpt ? AppTheme.success.withOpacity(0.5) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: isCorrectOpt
                                  ? AppTheme.success
                                  : isPlayerPick
                                      ? AppTheme.error
                                      : (isDark ? AppTheme.darkMuted.withOpacity(0.3) : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(opt.label, style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w900,
                                color: (isCorrectOpt || isPlayerPick) ? Colors.white : (isDark ? AppTheme.darkText : AppTheme.textMain),
                              )),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(opt.value, style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppTheme.darkText : AppTheme.textMain,
                            )),
                          ),
                          if (isCorrectOpt)
                            const Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                          if (isPlayerPick && !isCorrectOpt)
                            const Icon(Icons.cancel, color: AppTheme.error, size: 18),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  // Explanation
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(q.explanation, style: const TextStyle(fontSize: 12, color: Color(0xFF6D4C00)))),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 50 * i), duration: 300.ms).slideY(begin: 0.03, end: 0);
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _summaryItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
      ],
    );
  }
}
