import 'package:shared_preferences/shared_preferences.dart';

/// User avatar selection — choose from 24 emoji avatars.
class AvatarService {
  static const _kAvatar = 'user_avatar';

  static const avatarOptions = [
    '🧑‍💻', '👩‍🔬', '🧙', '🦸', '🧠', '🥷',
    '🚀', '🤖', '👑', '🎮', '⚡', '🔧',
    '🦊', '🐺', '🦁', '🐯', '🦅', '🐉',
    '🌟', '💎', '🔮', '🎯', '🏆', '🧬',
  ];

  Future<String> getAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAvatar) ?? '🧑‍💻';
  }

  Future<void> setAvatar(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatar, emoji);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAvatar);
  }
}
