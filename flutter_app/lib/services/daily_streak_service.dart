import 'package:shared_preferences/shared_preferences.dart';

/// Tracks daily play streak and daily challenge completion.
class DailyStreakService {
  static const _kLastPlayDate = 'daily_last_play';
  static const _kStreak = 'daily_streak';
  static const _kChallengeDate = 'daily_challenge_date';
  static const _kChallengeCompleted = 'daily_challenge_completed';
  static const _kDailyBestScore = 'daily_best_score';

  SharedPreferences? _prefs;
  Future<SharedPreferences> get _pref async =>
      _prefs ??= await SharedPreferences.getInstance();

  String _today() => DateTime.now().toIso8601String().substring(0, 10);

  /// Record that user played today. Updates streak.
  Future<int> recordDailyPlay() async {
    final prefs = await _pref;
    final today = _today();
    final lastPlay = prefs.getString(_kLastPlayDate);
    int streak = prefs.getInt(_kStreak) ?? 0;

    if (lastPlay == today) {
      // Already played today
      return streak;
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1))
        .toIso8601String().substring(0, 10);

    if (lastPlay == yesterday) {
      streak++;
    } else {
      streak = 1; // Reset streak
    }

    await prefs.setString(_kLastPlayDate, today);
    await prefs.setInt(_kStreak, streak);
    return streak;
  }

  /// Get current daily streak
  Future<int> getStreak() async {
    final prefs = await _pref;
    final lastPlay = prefs.getString(_kLastPlayDate);
    if (lastPlay == null) return 0;

    final today = _today();
    final yesterday = DateTime.now().subtract(const Duration(days: 1))
        .toIso8601String().substring(0, 10);

    if (lastPlay == today || lastPlay == yesterday) {
      return prefs.getInt(_kStreak) ?? 0;
    }
    // Streak broken
    return 0;
  }

  /// Check if daily challenge is completed today
  Future<bool> isDailyChallengeCompleted() async {
    final prefs = await _pref;
    final date = prefs.getString(_kChallengeDate);
    return date == _today() && (prefs.getBool(_kChallengeCompleted) ?? false);
  }

  /// Mark daily challenge as completed
  Future<void> completeDailyChallenge({required int score}) async {
    final prefs = await _pref;
    await prefs.setString(_kChallengeDate, _today());
    await prefs.setBool(_kChallengeCompleted, true);

    final best = prefs.getInt(_kDailyBestScore) ?? 0;
    if (score > best) {
      await prefs.setInt(_kDailyBestScore, score);
    }
  }

  /// Get daily best score
  Future<int> getDailyBestScore() async {
    final prefs = await _pref;
    return prefs.getInt(_kDailyBestScore) ?? 0;
  }

  /// Get daily challenge subject (rotates daily)
  String getDailyChallengeSubject() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    const subjects = ['math', 'physics', 'chemistry', 'general'];
    return subjects[dayOfYear % subjects.length];
  }

  String getDailyChallengeSubjectName() {
    const names = {
      'math': 'Mathématiques',
      'physics': 'Physique',
      'chemistry': 'Chimie',
      'general': 'Culture Générale',
    };
    return names[getDailyChallengeSubject()] ?? 'Mathématiques';
  }

  String getDailyChallengeEmoji() {
    const emojis = {
      'math': '📐',
      'physics': '⚡',
      'chemistry': '🧪',
      'general': '🌍',
    };
    return emojis[getDailyChallengeSubject()] ?? '📐';
  }

  Future<void> clearAll() async {
    final prefs = await _pref;
    await prefs.remove(_kLastPlayDate);
    await prefs.remove(_kStreak);
    await prefs.remove(_kChallengeDate);
    await prefs.remove(_kChallengeCompleted);
    await prefs.remove(_kDailyBestScore);
  }
}
