class AppConstants {
  // Colors
  static const primaryColor = 0xFF6366F1;
  static const successColor = 0xFF22C55E;
  static const errorColor = 0xFFEF4444;
  static const warningColor = 0xFFF59E0B;

  // Test Types
  static const String testTypeModel = 'MODEL_TEST';
  static const String testTypePastPaper = 'PAST_PAPER';
  static const String testTypeSubject = 'SUBJECT_WISE';
  static const String testTypeChapter = 'CHAPTER_WISE';
  static const String testTypeCustom = 'CUSTOM_TEST';
  static const String testTypeRandom = 'RANDOM_TEST';
  static const String testTypeDifficulty = 'DIFFICULTY_BASED';
  static const String testTypeRevision = 'REVISION_TEST';
  static const String testTypeRetake = 'RETAKE_TEST';
  static const String testTypeMistake = 'MISTAKE_COPY_TEST';

  // Difficulty
  static const String easy = 'EASY';
  static const String medium = 'MEDIUM';
  static const String hard = 'HARD';

  // Default user (for personal use, single user)
  static const int defaultUserId = 1;

  // Mistake Copy
  static const int mistakeCopyThreshold = 5;
  static const int masteredConsecutiveCorrect = 2;
}
