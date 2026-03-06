import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Achievement / badge system — all local, works offline.
class AchievementService {
  static const _kUnlocked = 'achievements_unlocked';

  SharedPreferences? _prefs;
  Future<SharedPreferences> get _pref async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// All possible achievements
  static const List<Achievement> allAchievements = [
    Achievement(id: 'first_duel',    emoji: '⚔️', title: 'Premier Duel',        desc: 'Complétez votre premier duel',                    threshold: 1,  type: AchievementType.games),
    Achievement(id: 'five_duels',    emoji: '🎮', title: 'Joueur Régulier',     desc: 'Complétez 5 duels',                               threshold: 5,  type: AchievementType.games),
    Achievement(id: 'ten_duels',     emoji: '🏅', title: 'Vétéran',             desc: 'Complétez 10 duels',                              threshold: 10, type: AchievementType.games),
    Achievement(id: 'twenty_duels',  emoji: '💎', title: 'Diamant',             desc: 'Complétez 20 duels',                              threshold: 20, type: AchievementType.games),
    Achievement(id: 'first_win',     emoji: '🏆', title: 'Première Victoire',   desc: 'Gagnez votre premier duel',                       threshold: 1,  type: AchievementType.wins),
    Achievement(id: 'five_wins',     emoji: '🌟', title: 'Champion',            desc: 'Gagnez 5 duels',                                  threshold: 5,  type: AchievementType.wins),
    Achievement(id: 'ten_wins',      emoji: '👑', title: 'Roi du Quiz',         desc: 'Gagnez 10 duels',                                 threshold: 10, type: AchievementType.wins),
    Achievement(id: 'streak_3',      emoji: '🔥', title: 'En Feu',              desc: 'Obtenez un combo de 3 réponses correctes',        threshold: 3,  type: AchievementType.streak),
    Achievement(id: 'streak_5',      emoji: '💥', title: 'Inarrêtable',         desc: 'Obtenez un combo de 5 réponses correctes',        threshold: 5,  type: AchievementType.streak),
    Achievement(id: 'streak_8',      emoji: '⚡', title: 'Légendaire',           desc: 'Combo de 8 réponses correctes d\'affilée',        threshold: 8,  type: AchievementType.streak),
    Achievement(id: 'accuracy_80',   emoji: '🎯', title: 'Précis',              desc: 'Atteignez 80% de précision moyenne',              threshold: 80, type: AchievementType.accuracy),
    Achievement(id: 'accuracy_95',   emoji: '💯', title: 'Perfection',          desc: 'Atteignez 95% de précision moyenne',              threshold: 95, type: AchievementType.accuracy),
    Achievement(id: 'points_500',    emoji: '💰', title: 'Collecteur',          desc: 'Accumulez 500 points au total',                   threshold: 500,  type: AchievementType.points),
    Achievement(id: 'points_2000',   emoji: '🤑', title: 'Trésorier',           desc: 'Accumulez 2000 points au total',                  threshold: 2000, type: AchievementType.points),
    Achievement(id: 'points_5000',   emoji: '🏦', title: 'Magnat',              desc: 'Accumulez 5000 points au total',                  threshold: 5000, type: AchievementType.points),
    Achievement(id: 'hard_win',      emoji: '🧠', title: 'Mastermind',          desc: 'Battez le bot Expert',                            threshold: 1,  type: AchievementType.hardWins),
    Achievement(id: 'all_subjects',  emoji: '📚', title: 'Polyvalent',          desc: 'Jouez dans les 4 matières',                       threshold: 4,  type: AchievementType.subjects),
    Achievement(id: 'daily_3',       emoji: '📅', title: 'Assidu',              desc: 'Jouez 3 jours consécutifs',                       threshold: 3,  type: AchievementType.dailyStreak),
  ];

  /// Get all unlocked achievement IDs
  Future<Set<String>> getUnlocked() async {
    final prefs = await _pref;
    final raw = prefs.getString(_kUnlocked);
    if (raw == null) return {};
    return (jsonDecode(raw) as List).cast<String>().toSet();
  }

  /// Check and unlock new achievements based on current stats
  Future<List<Achievement>> checkAndUnlock({
    required int totalGames,
    required int totalWins,
    required int bestStreak,
    required int avgAccuracy,
    required int totalPoints,
    required int hardWins,
    required int subjectsPlayed,
    required int dailyStreak,
  }) async {
    final unlocked = await getUnlocked();
    final newlyUnlocked = <Achievement>[];

    for (final a in allAchievements) {
      if (unlocked.contains(a.id)) continue;

      bool earned = false;
      switch (a.type) {
        case AchievementType.games:
          earned = totalGames >= a.threshold;
        case AchievementType.wins:
          earned = totalWins >= a.threshold;
        case AchievementType.streak:
          earned = bestStreak >= a.threshold;
        case AchievementType.accuracy:
          earned = totalGames >= 3 && avgAccuracy >= a.threshold;
        case AchievementType.points:
          earned = totalPoints >= a.threshold;
        case AchievementType.hardWins:
          earned = hardWins >= a.threshold;
        case AchievementType.subjects:
          earned = subjectsPlayed >= a.threshold;
        case AchievementType.dailyStreak:
          earned = dailyStreak >= a.threshold;
      }

      if (earned) {
        unlocked.add(a.id);
        newlyUnlocked.add(a);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      final prefs = await _pref;
      await prefs.setString(_kUnlocked, jsonEncode(unlocked.toList()));
    }

    return newlyUnlocked;
  }

  /// Get all achievements with their unlock state
  Future<List<AchievementState>> getAllWithState() async {
    final unlocked = await getUnlocked();
    return allAchievements
        .map((a) => AchievementState(achievement: a, isUnlocked: unlocked.contains(a.id)))
        .toList();
  }

  Future<void> clearAll() async {
    final prefs = await _pref;
    await prefs.remove(_kUnlocked);
  }
}

enum AchievementType { games, wins, streak, accuracy, points, hardWins, subjects, dailyStreak }

class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String desc;
  final int threshold;
  final AchievementType type;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.threshold,
    required this.type,
  });
}

class AchievementState {
  final Achievement achievement;
  final bool isUnlocked;
  const AchievementState({required this.achievement, required this.isUnlocked});
}
