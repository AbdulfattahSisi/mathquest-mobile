class QuestionOption {
  final String label;
  final String value;

  const QuestionOption({required this.label, required this.value});

  factory QuestionOption.fromJson(Map<String, dynamic> j) =>
      QuestionOption(label: j['label'] as String, value: j['value'] as String);
}

class QuestionModel {
  final String id;
  final String subjectId;
  final String text;
  final List<QuestionOption> options;
  final int difficulty;
  final List<String> tags;
  final bool generatedByAi;
  // Only available from answer endpoint
  final String? correctAnswer;
  final String? explanation;

  const QuestionModel({
    required this.id,
    required this.subjectId,
    required this.text,
    required this.options,
    required this.difficulty,
    required this.tags,
    required this.generatedByAi,
    this.correctAnswer,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> j) => QuestionModel(
        id:             j['id'] as String,
        subjectId:      j['subject_id'] as String,
        text:           j['text'] as String,
        options:        (j['options'] as List)
            .map((o) => QuestionOption.fromJson(o as Map<String, dynamic>))
            .toList(),
        difficulty:     j['difficulty'] as int,
        tags:           (j['tags'] as List?)?.cast<String>() ?? [],
        generatedByAi:  j['generated_by_ai'] as bool? ?? false,
        correctAnswer:  j['correct_answer'] as String?,
        explanation:    j['explanation'] as String?,
      );
}
