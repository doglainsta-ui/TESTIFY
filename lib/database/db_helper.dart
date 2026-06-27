import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/question_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'testify_quiz.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final now = DateTime.now().toIso8601String();

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        parent_id INTEGER,
        icon TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_text TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        option_e TEXT,
        correct_option TEXT NOT NULL,
        explanation TEXT,
        subject_id INTEGER NOT NULL,
        topic_id INTEGER NOT NULL,
        subtopic_id INTEGER,
        difficulty TEXT NOT NULL,
        is_custom INTEGER DEFAULT 0,
        created_by INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        role TEXT DEFAULT 'USER',
        study_stream TEXT,
        total_tests_taken INTEGER DEFAULT 0,
        total_questions_attempted INTEGER DEFAULT 0,
        accuracy REAL DEFAULT 0.0,
        avg_score REAL DEFAULT 0.0,
        joined_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE test_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        test_type TEXT NOT NULL,
        test_name TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_count INTEGER NOT NULL,
        incorrect_count INTEGER NOT NULL,
        unattempted_count INTEGER NOT NULL,
        score INTEGER NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attempt_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attempt_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        selected_option TEXT,
        is_correct INTEGER NOT NULL,
        time_taken_sec INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE mistake_copy (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        wrong_count INTEGER DEFAULT 1,
        is_manual INTEGER DEFAULT 0,
        added_at TEXT NOT NULL,
        last_reviewed_at TEXT
      )
    ''');

    await db.insert('users', {
      'name': 'Test User',
      'email': 'user@testify.com',
      'study_stream': 'MBBS UG',
      'joined_date': now,
    });

    await db.insert('categories', {'name': 'Mathematics', 'type': 'SUBJECT', 'icon': '🧮', 'created_at': now});
    await db.insert('categories', {'name': 'Physics', 'type': 'SUBJECT', 'icon': '⚛️', 'created_at': now});
    await db.insert('categories', {'name': 'Chemistry', 'type': 'SUBJECT', 'icon': '🧪', 'created_at': now});
    await db.insert('categories', {'name': 'Biology', 'type': 'SUBJECT', 'icon': '🧬', 'created_at': now});
    await db.insert('categories', {'name': 'English', 'type': 'SUBJECT', 'icon': '🇬🇧', 'created_at': now});
    await db.insert('categories', {'name': 'Mat', 'type': 'SUBJECT', 'icon': '🧠', 'created_at': now});

    await _insertSampleQuestionsInternal(db, now);
  }

  Future<void> _insertSampleQuestionsInternal(Database db, String now) async {
    final subjects = await db.query('categories', where: 'type = ?', whereArgs: ['SUBJECT']);
    final mathId = subjects.firstWhere((s) => s['name'] == 'Mathematics')['id'];
    final matId = subjects.firstWhere((s) => s['name'] == 'Mat')['id'];
    final chemId = subjects.firstWhere((s) => s['name'] == 'Chemistry')['id'];

    final algebraId = await db.insert('categories', {'name': 'Algebra', 'type': 'TOPIC', 'parent_id': mathId, 'created_at': now});
    final classificationId = await db.insert('categories', {'name': 'Classification', 'type': 'TOPIC', 'parent_id': matId, 'created_at': now});
    final aminesId = await db.insert('categories', {'name': 'Amines', 'type': 'TOPIC', 'parent_id': chemId, 'created_at': now});

    await db.insert('categories', {'name': 'Quadratic Equations', 'type': 'SUBTOPIC', 'parent_id': algebraId, 'created_at': now});

    final questions = [
      {
        'question_text': 'Which of the following is NOT a city?',
        'option_a': 'Gangtok',
        'option_b': 'Singhbhum',
        'option_c': 'Hyderabad',
        'option_d': 'Chennai',
        'correct_option': 'B',
        'explanation': 'Singhbhum is a district, not a city.',
        'subject_id': matId,
        'topic_id': classificationId,
        'difficulty': 'EASY',
      },
      {
        'question_text': 'Which of the following cities in Nepal is geographically different from the others?',
        'option_a': 'Kathmandu',
        'option_b': 'Bharatpur',
        'option_c': 'Janakpur',
        'option_d': 'Birgunj',
        'correct_option': 'A',
        'explanation': 'Kathmandu is in a valley, others are in plains.',
        'subject_id': matId,
        'topic_id': classificationId,
        'difficulty': 'MEDIUM',
      },
      {
        'question_text': 'How many different isomeric amines correspond to the molecular formula, C4H11N?',
        'option_a': '6',
        'option_b': '7',
        'option_c': '8',
        'option_d': '5',
        'correct_option': 'C',
        'explanation': 'There are 8 isomeric amines for C4H11N.',
        'subject_id': chemId,
        'topic_id': aminesId,
        'difficulty': 'HARD',
      },
      {
        'question_text': 'Which of the following are metamers? (i)N-Ethylethanamine (ii)N-Methylpropan-1-amine (iii)N-Methylpropan-2-amine (iv)N,N-Dimethylethanamine',
        'option_a': '(i)&(iii), (ii)&(iv)',
        'option_b': '(i)&(iv), (ii)&(iii)',
        'option_c': '(i)&(ii), (iii)&(iv)',
        'option_d': 'none of the above',
        'correct_option': 'B',
        'explanation': 'Metamers have same molecular formula but different alkyl groups on N.',
        'subject_id': chemId,
        'topic_id': aminesId,
        'difficulty': 'HARD',
      },
      {
        'question_text': 'What is the derivative of x² with respect to x?',
        'option_a': 'x',
        'option_b': '2x',
        'option_c': 'x²',
        'option_d': '2',
        'correct_option': 'B',
        'explanation': 'd/dx(x²) = 2x by power rule.',
        'subject_id': mathId,
        'topic_id': algebraId,
        'difficulty': 'EASY',
      },
    ];

    for (final q in questions) {
      await db.insert('questions', {
        ...q,
        'is_custom': 0,
        'created_by': 0,
        'created_at': now,
      });
    }
  }

  Future<void> insertSampleQuestions() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM questions')
    );
    if (count != null && count > 0) return;

    await _insertSampleQuestionsInternal(db, now);
  }

  // ==================== FIXED METHODS ====================

  /// Add a new category with optional icon (matches UI calling pattern)
  Future<int> addCategory(String name, String type, int? parentId, {String? icon}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('categories', {
      'name': name,
      'type': type,
      'parent_id': parentId,
      'icon': icon,
      'created_at': now,
    });
  }

  /// Add a new question
  Future<int> addQuestion(Map<String, dynamic> question) async {
    final db = await database;
    return await db.insert('questions', question);
  }

  /// Remove a mistake copy entry by its id
  Future<void> removeFromMistakeCopy(int id) async {
    final db = await database;
    await db.delete('mistake_copy', where: 'id = ?', whereArgs: [id]);
  }

  /// Mark a mistake as mastered (remove from mistake copy)
  Future<void> markAsMastered(int id) async {
    final db = await database;
    await db.delete('mistake_copy', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== QUERY METHODS ====================

  Future<List<Map<String, dynamic>>> getSubjects() async {
    final db = await database;
    return await db.query('categories', where: 'type = ?', whereArgs: ['SUBJECT']);
  }

  Future<List<Map<String, dynamic>>> getTopics(int subjectId) async {
    final db = await database;
    return await db.query('categories', where: 'type = ? AND parent_id = ?', whereArgs: ['TOPIC', subjectId]);
  }

  Future<List<Map<String, dynamic>>> getSubtopics(int topicId) async {
    final db = await database;
    return await db.query('categories', where: 'type = ? AND parent_id = ?', whereArgs: ['SUBTOPIC', topicId]);
  }

  Future<int> insertCustomQuestion(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('questions', row);
  }

  Future<List<Map<String, dynamic>>> getCustomQuestions() async {
    final db = await database;
    return await db.query('questions', where: 'is_custom = 1', orderBy: 'id DESC');
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> startTestAttempt(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('test_attempts', row);
  }

  Future<int> saveAttemptDetail(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('attempt_details', row);
  }

  Future<void> recordWrongAnswer(int userId, int questionId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final existing = await db.query(
      'mistake_copy',
      where: 'user_id = ? AND question_id = ?',
      whereArgs: [userId, questionId],
    );

    if (existing.isNotEmpty) {
      final currentCount = existing.first['wrong_count'] as int;
      await db.update(
        'mistake_copy',
        {'wrong_count': currentCount + 1},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      await db.insert('mistake_copy', {
        'user_id': userId,
        'question_id': questionId,
        'wrong_count': 1,
        'is_manual': 0,
        'added_at': now,
      });
    }
  }

  Future<void> addToMistakeCopyManual(int userId, int questionId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final existing = await db.query(
      'mistake_copy',
      where: 'user_id = ? AND question_id = ?',
      whereArgs: [userId, questionId],
    );

    if (existing.isEmpty) {
      await db.insert('mistake_copy', {
        'user_id': userId,
        'question_id': questionId,
        'wrong_count': 0,
        'is_manual': 1,
        'added_at': now,
      });
    } else {
      await db.update(
        'mistake_copy',
        {'is_manual': 1},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  Future<void> updateUserStats(int userId) async {
    final db = await database;

    final stats = await db.rawQuery('''
      SELECT 
        COUNT(DISTINCT ta.id) as tests_taken,
        COUNT(ad.id) as questions_attempted,
        ROUND(AVG(CASE WHEN ad.is_correct = 1 THEN 100.0 ELSE 0.0 END), 1) as accuracy,
        ROUND(AVG(ta.score), 1) as avg_score
      FROM test_attempts ta
      LEFT JOIN attempt_details ad ON ta.id = ad.attempt_id
      WHERE ta.user_id = ?
    ''', [userId]);

    if (stats.isNotEmpty && stats.first['tests_taken'] != 0) {
      await db.update(
        'users',
        {
          'total_tests_taken': stats.first['tests_taken'],
          'total_questions_attempted': stats.first['questions_attempted'],
          'accuracy': stats.first['accuracy'],
          'avg_score': stats.first['avg_score'],
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
  }
}
