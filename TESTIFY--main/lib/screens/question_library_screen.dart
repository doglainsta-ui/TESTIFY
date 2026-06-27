import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'question_adder_screen.dart';

class QuestionLibraryScreen extends StatefulWidget {
  const QuestionLibraryScreen({super.key});

  @override
  State<QuestionLibraryScreen> createState() => _QuestionLibraryScreenState();
}

class _QuestionLibraryScreenState extends State<QuestionLibraryScreen> {
  final db = DBHelper();
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await db.getCustomQuestions();
    setState(() => _questions = questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuestionAdderScreen()),
              );
              _loadQuestions();
            },
          ),
        ],
      ),
      body: _questions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No custom questions yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuestionAdderScreen()),
                      );
                      _loadQuestions();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Question'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      q['question_text'].toString().substring(
                        0,
                        q['question_text'].toString().length > 60
                            ? 60
                            : q['question_text'].toString().length,
                      ) + '...',
                    ),
                    subtitle: Text(
                      'Correct: ${q['correct_option']} • ${q['difficulty']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOption('A', q['option_a'], q['correct_option'] == 'A'),
                            _buildOption('B', q['option_b'], q['correct_option'] == 'B'),
                            _buildOption('C', q['option_c'], q['correct_option'] == 'C'),
                            _buildOption('D', q['option_d'], q['correct_option'] == 'D'),
                            if (q['option_e'] != null)
                              _buildOption('E', q['option_e'], q['correct_option'] == 'E'),
                            if (q['explanation'] != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Explanation: ${q['explanation']}',
                                  style: TextStyle(color: Colors.blue[800], fontSize: 13),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildOption(String label, String text, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          if (isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}
