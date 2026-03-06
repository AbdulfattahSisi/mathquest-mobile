class UserModel {
  final String id;
  final String username;
  final String email;
  final int level;
  final int totalPoints;
  final String? avatarUrl;
  final int streakDays;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.level,
    required this.totalPoints,
    this.avatarUrl,
    required this.streakDays,
    required this.createdAt,
  });

  /// Guest user — no account, no API calls
  factory UserModel.guest() => UserModel(
        id:          'guest',
        username:    'Invité',
        email:       '',
        level:       1,
        totalPoints: 0,
        streakDays:  0,
        createdAt:   DateTime.now(),
      );

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id:          j['id'] as String,
        username:    j['username'] as String,
        email:       j['email'] as String,
        level:       j['level'] as int,
        totalPoints: j['total_points'] as int,
        avatarUrl:   j['avatar_url'] as String?,
        streakDays:  j['streak_days'] as int? ?? 0,
        createdAt:   DateTime.parse(j['created_at'] as String),
      );

  /// XP needed for next level
  int get pointsToNextLevel => ((level) * 1000) - totalPoints;

  /// 0.0 – 1.0 progress within current level
  double get levelProgress {
    final base = (level - 1) * 1000;
    final top  = level * 1000;
    return ((totalPoints - base) / (top - base)).clamp(0.0, 1.0);
  }
}
