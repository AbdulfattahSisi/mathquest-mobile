class DuelModel {
  final String id;
  final String? subjectId;
  final String mode;
  final String status;
  final int player1Score;
  final int player2Score;
  final int totalQuestions;
  final DateTime createdAt;

  const DuelModel({
    required this.id,
    this.subjectId,
    required this.mode,
    required this.status,
    required this.player1Score,
    required this.player2Score,
    required this.totalQuestions,
    required this.createdAt,
  });

  factory DuelModel.fromJson(Map<String, dynamic> j) => DuelModel(
        id:              j['id'] as String,
        subjectId:       j['subject_id'] as String?,
        mode:            j['mode'] as String,
        status:          j['status'] as String,
        player1Score:    j['player1_score'] as int,
        player2Score:    j['player2_score'] as int,
        totalQuestions:  j['total_questions'] as int,
        createdAt:       DateTime.parse(j['created_at'] as String),
      );
}

class DuelResult {
  final String duelId;
  final int yourScore;
  final int opponentScore;
  final String? winner;
  final int pointsEarned;
  final int newLevel;
  final double accuracyPct;

  const DuelResult({
    required this.duelId,
    required this.yourScore,
    required this.opponentScore,
    this.winner,
    required this.pointsEarned,
    required this.newLevel,
    required this.accuracyPct,
  });

  factory DuelResult.fromJson(Map<String, dynamic> j) => DuelResult(
        duelId:        j['duel_id'] as String,
        yourScore:     j['your_score'] as int,
        opponentScore: j['opponent_score'] as int,
        winner:        j['winner'] as String?,
        pointsEarned:  j['points_earned'] as int,
        newLevel:      j['new_level'] as int,
        accuracyPct:   (j['accuracy_pct'] as num).toDouble(),
      );
}

class SubjectModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? color;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.color,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> j) => SubjectModel(
        id:          j['id'] as String,
        name:        j['name'] as String,
        slug:        j['slug'] as String,
        description: j['description'] as String?,
        icon:        j['icon'] as String?,
        color:       j['color'] as String?,
      );
}
