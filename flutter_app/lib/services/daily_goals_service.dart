import 'package:shared_preferences/shared_preferences.dart';

/// Daily goals system — tracks daily objectives & rewards.
class DailyGoalsService {
  static const _kGoalsDate = 'goals_date';
  static const _kGoalGames = 'goal_games_done';
  static const _kGoalCorrect = 'goal_correct_done';
  static const _kGoalStreak = 'goal_streak_done';
  static const _kGoalChrono = 'goal_chrono_done';
  static const _kGoalTraining = 'goal_training_done';

  // Daily goals configuration
  static const goals = [
    DailyGoal(id: 'play3', title: 'Jouer 3 duels', emoji: '🎮', target: 3, type: GoalType.games),
    DailyGoal(id: 'correct15', title: '15 bonnes réponses', emoji: '✅', target: 15, type: GoalType.correct),
    DailyGoal(id: 'streak5', title: 'Combo de 5', emoji: '🔥', target: 5, type: GoalType.streak),
    DailyGoal(id: 'chrono1', title: '1 mode chrono', emoji: '⚡', target: 1, type: GoalType.chrono),
    DailyGoal(id: 'training1', title: '1 entraînement', emoji: '📚', target: 1, type: GoalType.training),
  ];

  Future<String> _today() async {
    return DateTime.now().toIso8601String().substring(0, 10);
  }

  Future<void> _resetIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString(_kGoalsDate) ?? '';
    final today = await _today();
    if (storedDate != today) {
      await prefs.setString(_kGoalsDate, today);
      await prefs.setInt(_kGoalGames, 0);
      await prefs.setInt(_kGoalCorrect, 0);
      await prefs.setInt(_kGoalStreak, 0);
      await prefs.setInt(_kGoalChrono, 0);
      await prefs.setInt(_kGoalTraining, 0);
    }
  }

  Future<void> recordGamePlayed({int correctAnswers = 0, int maxStreak = 0}) async {
    await _resetIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGoalGames, (prefs.getInt(_kGoalGames) ?? 0) + 1);
    await prefs.setInt(_kGoalCorrect, (prefs.getInt(_kGoalCorrect) ?? 0) + correctAnswers);
    final current = prefs.getInt(_kGoalStreak) ?? 0;
    if (maxStreak > current) {
      await prefs.setInt(_kGoalStreak, maxStreak);
    }
  }

  Future<void> recordChronoPlayed() async {
    await _resetIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGoalChrono, (prefs.getInt(_kGoalChrono) ?? 0) + 1);
  }

  Future<void> recordTrainingPlayed() async {
    await _resetIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGoalTraining, (prefs.getInt(_kGoalTraining) ?? 0) + 1);
  }

  Future<List<DailyGoalState>> getGoalStates() async {
    await _resetIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    final games = prefs.getInt(_kGoalGames) ?? 0;
    final correct = prefs.getInt(_kGoalCorrect) ?? 0;
    final streak = prefs.getInt(_kGoalStreak) ?? 0;
    final chrono = prefs.getInt(_kGoalChrono) ?? 0;
    final training = prefs.getInt(_kGoalTraining) ?? 0;

    return goals.map((g) {
      int current;
      switch (g.type) {
        case GoalType.games:
          current = games;
          break;
        case GoalType.correct:
          current = correct;
          break;
        case GoalType.streak:
          current = streak;
          break;
        case GoalType.chrono:
          current = chrono;
          break;
        case GoalType.training:
          current = training;
          break;
      }
      return DailyGoalState(goal: g, current: current);
    }).toList();
  }

  Future<int> getCompletedCount() async {
    final states = await getGoalStates();
    return states.where((s) => s.isCompleted).length;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGoalsDate);
    await prefs.remove(_kGoalGames);
    await prefs.remove(_kGoalCorrect);
    await prefs.remove(_kGoalStreak);
    await prefs.remove(_kGoalChrono);
    await prefs.remove(_kGoalTraining);
  }
}

enum GoalType { games, correct, streak, chrono, training }

class DailyGoal {
  final String id;
  final String title;
  final String emoji;
  final int target;
  final GoalType type;
  const DailyGoal({required this.id, required this.title, required this.emoji, required this.target, required this.type});
}

class DailyGoalState {
  final DailyGoal goal;
  final int current;
  DailyGoalState({required this.goal, required this.current});

  bool get isCompleted => current >= goal.target;
  double get progress => (current / goal.target).clamp(0.0, 1.0);
}
