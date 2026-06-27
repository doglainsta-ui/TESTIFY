class Question {
  final int? id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String? optionE;
  final String correctOption;
  final String? explanation;
  final int? subjectId;
  final int? topicId;
  final int? subtopicId;
  final String difficulty;
  final bool isCustom;
  final DateTime createdAt;

  Question({
    this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    this.optionE,
    required this.correctOption,
    this.explanation,
    this.subjectId,
    this.topicId,
    this.subtopicId,
    this.difficulty = 'MEDIUM',
    this.isCustom = true,
    required this.createdAt,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      questionText: map['question_text'],
      optionA: map['option_a'],
      optionB: map['option_b'],
      optionC: map['option_c'],
      optionD: map['option_d'],
      optionE: map['option_e'],
      correctOption: map['correct_option'],
      explanation: map['explanation'],
      subjectId: map['subject_id'],
      topicId: map['topic_id'],
      subtopicId: map['subtopic_id'],
      difficulty: map['difficulty'] ?? 'MEDIUM',
      isCustom: (map['is_custom'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'option_e': optionE,
      'correct_option': correctOption,
      'explanation': explanation,
      'subject_id': subjectId,
      'topic_id': topicId,
      'subtopic_id': subtopicId,
      'difficulty': difficulty,
      'is_custom': isCustom ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  List<String> get options {
    final list = [optionA, optionB, optionC, optionD];
    if (optionE != null && optionE!.isNotEmpty) list.add(optionE!);
    return list;
  }
}
