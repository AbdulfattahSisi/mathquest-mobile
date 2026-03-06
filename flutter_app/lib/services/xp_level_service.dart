import 'package:shared_preferences/shared_preferences.dart';

/// XP & Level tracking — fully local, persistent.
/// Level formula: level = floor(sqrt(totalXP / 100)) + 1
/// XP to next level: (level)^2 * 100
class XpLevelService {
  static const _kTotalXP = 'xp_total';
  static const _kLastLevelUp = 'xp_last_level';

  SharedPreferences? _prefs;
  Future<SharedPreferences> get _pref async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Current total XP earned.
  Future<int> getTotalXP() async => (await _pref).getInt(_kTotalXP) ?? 0;

  /// Current level derived from XP.
  Future<int> getLevel() async {
    final xp = await getTotalXP();
    return _levelFromXP(xp);
  }

  /// Progress fraction (0.0–1.0) within the current level.
  Future<double> getLevelProgress() async {
    final xp = await getTotalXP();
    final lvl = _levelFromXP(xp);
    final xpForCurrentLevel = _xpForLevel(lvl);
    final xpForNextLevel = _xpForLevel(lvl + 1);
    final range = xpForNextLevel - xpForCurrentLevel;
    if (range <= 0) return 1.0;
    return ((xp - xpForCurrentLevel) / range).clamp(0.0, 1.0);
  }

  /// XP required to reach the start of a given level.
  int _xpForLevel(int level) => ((level - 1) * (level - 1)) * 100;

  int _levelFromXP(int xp) {
    int lvl = 1;
    while (_xpForLevel(lvl + 1) <= xp) {
      lvl++;
    }
    return lvl;
  }

  /// Add XP and return whether we leveled up.
  Future<bool> addXP(int amount) async {
    final prefs = await _pref;
    final before = prefs.getInt(_kTotalXP) ?? 0;
    final after = before + amount;
    await prefs.setInt(_kTotalXP, after);

    final lvlBefore = _levelFromXP(before);
    final lvlAfter = _levelFromXP(after);
    if (lvlAfter > lvlBefore) {
      await prefs.setInt(_kLastLevelUp, lvlAfter);
      return true;
    }
    return false;
  }

  /// XP needed from current to next level.
  Future<int> xpToNextLevel() async {
    final xp = await getTotalXP();
    final lvl = _levelFromXP(xp);
    return _xpForLevel(lvl + 1) - xp;
  }

  /// Title for current level.
  Future<String> getLevelTitle() async {
    final lvl = await getLevel();
    if (lvl <= 2) return 'Débutant';
    if (lvl <= 5) return 'Apprenti';
    if (lvl <= 10) return 'Challenger';
    if (lvl <= 15) return 'Expert';
    if (lvl <= 20) return 'Maître';
    if (lvl <= 30) return 'Légende';
    return 'Mythique';
  }

  Future<void> clearAll() async {
    final prefs = await _pref;
    await prefs.remove(_kTotalXP);
    await prefs.remove(_kLastLevelUp);
  }
}
