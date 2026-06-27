class User {
  final int? id;
  final String name;
  final String email;
  final String studyStream;
  final DateTime joinedDate;
  final int totalTestsTaken;
  final int totalQuestionsAttempted;
  final double accuracy;
  final double avgScore;

  User({
    this.id,
    required this.name,
    required this.email,
    this.studyStream = 'UG (MBBS/BDS/Nursing)',
    required this.joinedDate,
    this.totalTestsTaken = 0,
    this.totalQuestionsAttempted = 0,
    this.accuracy = 0.0,
    this.avgScore = 0.0,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      studyStream: map['study_stream'],
      joinedDate: DateTime.parse(map['joined_date']),
      totalTestsTaken: map['total_tests_taken'] ?? 0,
      totalQuestionsAttempted: map['total_questions_attempted'] ?? 0,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      avgScore: (map['avg_score'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'study_stream': studyStream,
      'joined_date': joinedDate.toIso8601String(),
      'total_tests_taken': totalTestsTaken,
      'total_questions_attempted': totalQuestionsAttempted,
      'accuracy': accuracy,
      'avg_score': avgScore,
    };
  }
}
