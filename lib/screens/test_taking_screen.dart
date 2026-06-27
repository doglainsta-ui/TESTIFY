import 'dart:async';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/question_model.dart'; // Fixed path statement
import '../widgets/timer_widget.dart';
import '../widgets/test_progress_bar.dart'; // Fixed path statement
import '../widgets/question_card.dart';
import 'results_screen.dart';

class TestTakingScreen extends StatefulWidget {
  final String testName;
  final List<Question> questions;
  final int timeLimitMinutes;

  const TestTakingScreen({
    super.key,
    required this.testName,
    required this.questions,
    this.timeLimitMinutes = 10,
  });

  @override
  State<TestTakingScreen> createState() => _TestTakingScreenState();
}

class _TestTakingScreenState extends State<TestTakingScreen> {
  final db = DBHelper();
  int _currentIndex = 0;
  final Map<int, String> _answers = {}; // question index -> selected option
  final Set<int> _flaggedQuestions = {};
  final Set<int> _mistakeCopyQuestions = {};
  bool _isSubmitting = false;

  late final int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.timeLimitMinutes * 60;
  }

  Question? get _currentQuestion =>
      widget.questions.isNotEmpty && _currentIndex < widget.questions.length
          ? widget.questions[_currentIndex]
          : null;

  void _selectAnswer(String option) {
    setState(() {
      _answers[_currentIndex] = option;
    });
  }

  void _toggleFlag() {
    setState(() {
      if (_flaggedQuestions.contains(_currentIndex)) {
        _flaggedQuestions.remove(_currentIndex);
      } else {
        _flaggedQuestions.add(_currentIndex);
      }
    });
  }

  Future<void> _addToMistakeCopy() async {
    if (_currentQuestion == null) return;

    final questionIndex = _currentIndex;
    setState(() => _mistakeCopyQuestions.add(questionIndex));

    await db.addToMistakeCopyManual(1, _currentQuestion!.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to Mistake Copy'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showQuestionMap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Question Map',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: widget.questions.length,
                    itemBuilder: (context, index) {
                      final isAnswered = _answers.containsKey(index);
                      final isCurrent = index == _currentIndex;

                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? Theme.of(context).colorScheme.primary
                                : isAnswered
                                    ? Colors.green[100]
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: isCurrent
                                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? Colors.white
                                    : isAnswered
                                        ? Colors.green[700]
                                        : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitTest();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Submit Test Now'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitTest() async {
    if (_isSubmitting) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Test?'),
        content: Text(
          'You have answered ${_answers.length} out of ${widget.questions.length} questions.\nAre you sure you want to submit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    int correct = 0;
    int incorrect = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final selected = _answers[i];

      if (selected == null) continue;

      final isCorrect = selected == question.correctOption;

      if (isCorrect) {
        correct++;
      } else {
        incorrect++;
        await db.recordWrongAnswer(1, question.id!);
      }
    }

    final unattempted = widget.questions.length - _answers.length;
    final score = correct;

    final attemptId = await db.startTestAttempt({
      'user_id': 1,
      'test_type': 'PRACTICE',
      'test_name': widget.testName,
      'total_questions': widget.questions.length,
      'correct_count': correct,
      'incorrect_count': incorrect,
      'unattempted_count': unattempted,
      'score': score,
      'completed_at': DateTime.now().toIso8601String(),
    });

    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final selected = _answers[i];

      await db.saveAttemptDetail({
        'attempt_id': attemptId,
        'question_id': question.id,
        'selected_option': selected,
        'is_correct': selected == question.correctOption ? 1 : 0,
        'time_taken_sec': 0,
      });
    }

    await db.updateUserStats(1);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            totalQuestions: widget.questions.length,
            correct: correct,
            incorrect: incorrect,
            unattempted: unattempted,
            score: score,
            attemptId: attemptId,
          ),
        ),
      );
    }
  }

  void _onTimeUp() {
    _submitTest();
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;

    if (question == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isLastQuestion = _currentIndex == widget.questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.testName, style: const TextStyle(fontSize: 16)),
            TimerWidget(
              totalSeconds: _totalSeconds,
              onTimeUp: _onTimeUp,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _showQuestionMap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.grid_view, size: 18),
                const SizedBox(width: 4),
                Text('${_currentIndex + 1}/${widget.questions.length}'),
              ],
            ),
          ),
          TextButton(
            onPressed: _submitTest,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TestProgressBar(
              current: _currentIndex + 1,
              total: widget.questions.length,
              answered: _answers.length,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: QuestionCard(
                question: question,
                selectedOption: _answers[_currentIndex],
                onSelect: _selectAnswer,
                onFlag: _toggleFlag,
                onMistakeCopy: _addToMistakeCopy,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  IconButton.filledTonal(
                    onPressed: () => setState(() => _currentIndex--),
                    icon: const Icon(Icons.arrow_back),
                  )
                else
                  const SizedBox(width: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      if (isLastQuestion) {
                        _submitTest();
                      } else {
                        setState(() => _currentIndex++);
                      }
                    },
                    icon: Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
                    label: Text(isLastQuestion ? 'Submit Test' : 'Next Question'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: isLastQuestion ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
