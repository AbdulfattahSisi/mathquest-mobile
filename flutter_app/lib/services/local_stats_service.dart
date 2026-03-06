import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks all game statistics locally (SharedPreferences).
/// Works in guest AND authenticated mode — survives app restarts.
class LocalStatsService {
  static const _kGames      = 'stats_games';
  static const _kHistory    = 'stats_history';
  static const _kTotalPts   = 'stats_total_points';
  static const _kBestStreak = 'stats_best_streak';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _pref async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ── Record a completed duel ────────────────────────────────────────────────
  Future<void> recordGame({
    required String subject,
    required String subjectName,
    required int playerScore,
    required int botScore,
    required int correctAnswers,
    required int totalQuestions,
    required String botLevel,
    required int maxStreak,
  }) async {
    final prefs = await _pref;

    // Increment game count
    final games = (prefs.getInt(_kGames) ?? 0) + 1;
    await prefs.setInt(_kGames, games);

    // Total points
    final totalPts = (prefs.getInt(_kTotalPts) ?? 0) + playerScore;
    await prefs.setInt(_kTotalPts, totalPts);

    // Best streak
    final bestStreak = prefs.getInt(_kBestStreak) ?? 0;
    if (maxStreak > bestStreak) {
      await prefs.setInt(_kBestStreak, maxStreak);
    }

    // Game history (keep last 50)
    final history = await getHistory();
    history.insert(0, {
      'date': DateTime.now().toIso8601String(),
      'subject': subject,
      'subjectName': subjectName,
      'playerScore': playerScore,
      'botScore': botScore,
      'correct': correctAnswers,
      'total': totalQuestions,
      'botLevel': botLevel,
      'maxStreak': maxStreak,
      'won': playerScore > botScore,
    });
    if (history.length > 50) history.removeLast();
    await prefs.setString(_kHistory, jsonEncode(history));
  }

  // ── Getters ────────────────────────────────────────────────────────────────
  Future<int> get totalGames async => (await _pref).getInt(_kGames) ?? 0;
  Future<int> get totalPoints async => (await _pref).getInt(_kTotalPts) ?? 0;
  Future<int> get bestStreak async => (await _pref).getInt(_kBestStreak) ?? 0;

  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await _pref;
    final raw = prefs.getString(_kHistory);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getSummary() async {
    final history = await getHistory();
    final games = history.length;
    final wins = history.where((g) => g['won'] == true).length;
    final totalCorrect = history.fold<int>(0, (s, g) => s + (g['correct'] as int? ?? 0));
    final totalQ = history.fold<int>(0, (s, g) => s + (g['total'] as int? ?? 0));
    final avgAccuracy = totalQ > 0 ? (totalCorrect / totalQ * 100).round() : 0;

    // Per-subject breakdown
    final subjects = <String, Map<String, int>>{};
    for (final g in history) {
      final slug = g['subject'] as String? ?? 'unknown';
      final name = g['subjectName'] as String? ?? slug;
      subjects.putIfAbsent(slug, () => {'games': 0, 'wins': 0, 'correct': 0, 'total': 0});
      subjects[slug]!['games'] = (subjects[slug]!['games'] ?? 0) + 1;
      if (g['won'] == true) subjects[slug]!['wins'] = (subjects[slug]!['wins'] ?? 0) + 1;
      subjects[slug]!['correct'] = (subjects[slug]!['correct'] ?? 0) + (g['correct'] as int? ?? 0);
      subjects[slug]!['total'] = (subjects[slug]!['total'] ?? 0) + (g['total'] as int? ?? 0);
      subjects[slug]!['name'] = name.hashCode; // store name separately
    }

    // Subject list with names
    final subjectStats = <Map<String, dynamic>>[];
    for (final g in history) {
      final slug = g['subject'] as String? ?? 'unknown';
      final name = g['subjectName'] as String? ?? slug;
      if (subjectStats.any((s) => s['slug'] == slug)) continue;
      final s = subjects[slug]!;
      final total = s['total'] ?? 1;
      subjectStats.add({
        'slug': slug,
        'name': name,
        'games': s['games'],
        'wins': s['wins'],
        'accuracy': total > 0 ? ((s['correct'] ?? 0) / total * 100).round() : 0,
      });
    }

    return {
      'games': games,
      'wins': wins,
      'winRate': games > 0 ? (wins / games * 100).round() : 0,
      'totalPoints': await totalPoints,
      'bestStreak': await bestStreak,
      'avgAccuracy': avgAccuracy,
      'subjects': subjectStats,
    };
  }

  // ── Export as CSV ──────────────────────────────────────────────────────────
  Future<String> exportCSV() async {
    final history = await getHistory();
    final buf = StringBuffer();
    buf.writeln('Date,Matière,Score Joueur,Score Bot,Correct,Total,Niveau Bot,Streak Max,Victoire');
    for (final g in history) {
      final date = DateTime.tryParse(g['date'] ?? '')?.toLocal().toString().substring(0, 16) ?? '';
      buf.writeln('$date,${g['subjectName']},${g['playerScore']},${g['botScore']},${g['correct']},${g['total']},${g['botLevel']},${g['maxStreak']},${g['won'] ? 'Oui' : 'Non'}');
    }
    return buf.toString();
  }

  Future<void> clearAll() async {
    final prefs = await _pref;
    await prefs.remove(_kGames);
    await prefs.remove(_kHistory);
    await prefs.remove(_kTotalPts);
    await prefs.remove(_kBestStreak);
  }
}
