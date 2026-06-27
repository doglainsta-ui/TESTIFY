class TestAttempt {
  final int? id;
  final int userId;
  final String testType;
  final String testName;
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;
  final int unattemptedCount;
  final int score;
  final DateTime completedAt;

  TestAttempt({
    this.id,
    required this.userId,
    required this.testType,
    required this.testName,
    required this.totalQuestions,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.unattemptedCount = 0,
    this.score = 0,
    required this.completedAt,
  });

  factory TestAttempt.fromMap(Map<String, dynamic> map) {
    return TestAttempt(
      id: map['id'],
      userId: map['user_id'],
      testType: map['test_type'],
      testName: map['test_name'],
      totalQuestions: map['total_questions'],
      correctCount: map['correct_count'] ?? 0,
      incorrectCount: map['incorrect_count'] ?? 0,
      unattemptedCount: map['unattempted_count'] ?? 0,
      score: map['score'] ?? 0,
      completedAt: DateTime.parse(map['completed_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'test_type': testType,
      'test_name': testName,
      'total_questions': totalQuestions,
      'correct_count': correctCount,
      'incorrect_count': incorrectCount,
      'unattempted_count': unattemptedCount,
      'score': score,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  double get accuracy => totalQuestions > 0
      ? (correctCount / totalQuestions) * 100
      : 0.0;
}
