import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'test_taking_screen.dart';

class MistakeCopyScreen extends StatefulWidget {
  const MistakeCopyScreen({super.key});

  @override
  State<MistakeCopyScreen> createState() => _MistakeCopyScreenState();
}

class _MistakeCopyScreenState extends State<MistakeCopyScreen> {
  final db = DBHelper();
  List<Map<String, dynamic>> _mistakes = [];
  String _filter = 'ALL'; // ALL, AUTO, MANUAL

  @override
  void initState() {
    super.initState();
    _loadMistakes();
  }

  Future<void> _loadMistakes() async {
    final source = _filter == 'ALL' ? null : _filter;
    final mistakes = await db.getMistakeCopy(1, source: source);
    setState(() => _mistakes = mistakes);
  }

  Future<void> _generateTest() async {
    if (_mistakes.isEmpty) return;

    final selected = await showDialog<List<int>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Mistake Test'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _mistakes.length,
            itemBuilder: (context, index) {
              final m = _mistakes[index];
              return CheckboxListTile(
                title: Text(
                  m['question_text'].toString().substring(
                    0,
                    m['question_text'].toString().length > 50
                        ? 50
                        : m['question_text'].toString().length,
                  ) + '...',
                ),
                subtitle: Text('Wrong ${m['wrong_count']}x • ${m['source']}'),
                value: true,
                onChanged: (v) {},
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                _mistakes.map((m) => m['question_id'] as int).toList(),
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (selected != null && selected.isNotEmpty && mounted) {
      // Navigate to test with selected questions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mistake Copy'),
        actions: [
          if (_mistakes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _generateTest,
              tooltip: 'Generate Test',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('AUTO', '🔴 Frequent'),
                const SizedBox(width: 8),
                _buildFilterChip('MANUAL', '📌 Manual'),
              ],
            ),
          ),

          // Mistakes List
          Expanded(
            child: _mistakes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _mistakes.length,
                    itemBuilder: (context, index) {
                      final mistake = _mistakes[index];
                      return _buildMistakeCard(mistake);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _mistakes.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _generateTest,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Test'),
            ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _filter = value);
        _loadMistakes();
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildMistakeCard(Map<String, dynamic> mistake) {
    final isAuto = mistake['source'] == 'AUTO';
    final wrongCount = mistake['wrong_count'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAuto ? Colors.red[50] : Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Text(
            isAuto ? '🔴' : '📌',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        title: Text(
          mistake['question_text'].toString().substring(
            0,
            mistake['question_text'].toString().length > 60
                ? 60
                : mistake['question_text'].toString().length,
          ) + '...',
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: wrongCount >= 10
                    ? Colors.red[100]
                    : wrongCount >= 5
                        ? Colors.orange[100]
                        : Colors.yellow[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Wrong ${mistake['wrong_count']}x',
                style: TextStyle(
                  fontSize: 11,
                  color: wrongCount >= 5 ? Colors.red[700] : Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              mistake['last_wrong_date']?.toString().split('T').first ?? '',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                // Options preview
                _buildOptionPreview('A', mistake['option_a']),
                _buildOptionPreview('B', mistake['option_b']),
                _buildOptionPreview('C', mistake['option_c']),
                _buildOptionPreview('D', mistake['option_d']),
                const SizedBox(height: 8),
                Text(
                  'Correct: ${mistake['correct_option']}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Notes
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Add notes...',
                    prefixIcon: Icon(Icons.edit_note),
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: mistake['notes']),
                  onSubmitted: (text) => db.updateMistakeNotes(mistake['id'], text),
                ),
                const SizedBox(height: 12),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          // Start single question practice
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Practice'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: () async {
                        await db.markAsMastered(mistake['id']);
                        _loadMistakes();
                      },
                      icon: const Icon(Icons.check_circle),
                      tooltip: 'Mark as Mastered',
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: () async {
                        await db.removeFromMistakeCopy(mistake['id']);
                        _loadMistakes();
                      },
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      tooltip: 'Remove',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionPreview(String label, String? text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text ?? '',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No mistakes yet!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Questions you get wrong 5+ times\nwill appear here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Or tap 📌 during any test to save manually.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
