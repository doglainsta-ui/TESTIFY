import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class QuestionAdderScreen extends StatefulWidget {
  const QuestionAdderScreen({super.key});

  @override
  State<QuestionAdderScreen> createState() => _QuestionAdderScreenState();
}

class _QuestionAdderScreenState extends State<QuestionAdderScreen> {
  final db = DBHelper();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _questionController = TextEditingController();
  final _optAController = TextEditingController();
  final _optBController = TextEditingController();
  final _optCController = TextEditingController();
  final _optDController = TextEditingController();
  final _optEController = TextEditingController();
  final _explanationController = TextEditingController();

  String _correctOption = 'A';
  String _difficulty = 'MEDIUM';

  // Hierarchy
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _topics = [];
  List<Map<String, dynamic>> _subtopics = [];

  int? _selectedSubjectId;
  int? _selectedTopicId;
  int? _selectedSubtopicId;

  bool _hasOptionE = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjects = await db.getSubjects();
    setState(() => _subjects = subjects);
  }

  Future<void> _loadTopics(int subjectId) async {
    final topics = await db.getTopics(subjectId);
    setState(() {
      _topics = topics;
      _selectedTopicId = null;
      _subtopics = [];
      _selectedSubtopicId = null;
    });
  }

  Future<void> _loadSubtopics(int topicId) async {
    final subtopics = await db.getSubtopics(topicId);
    setState(() {
      _subtopics = subtopics;
      _selectedSubtopicId = null;
    });
  }

  Future<void> _addNewCategory(String type, int? parentId) async {
    final controller = TextEditingController();
    final iconController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New ${type.toLowerCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter ${type.toLowerCase()} name',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            if (type == 'SUBJECT') ...[
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  hintText: 'Icon emoji (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'name': controller.text.trim(),
                  'icon': iconController.text.trim(),
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      final id = await db.addCategory(
        result['name']!,
        type,
        parentId,
        icon: result['icon'],
      );

      // Refresh lists
      if (type == 'SUBJECT') {
        await _loadSubjects();
        setState(() => _selectedSubjectId = id);
        await _loadTopics(id);
      } else if (type == 'TOPIC') {
        await _loadTopics(parentId!);
        setState(() => _selectedTopicId = id);
        await _loadSubtopics(id);
      } else if (type == 'SUBTOPIC') {
        await _loadSubtopics(parentId!);
        setState(() => _selectedSubtopicId = id);
      }
    }
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    await db.addQuestion({
      'question_text': _questionController.text,
      'option_a': _optAController.text,
      'option_b': _optBController.text,
      'option_c': _optCController.text,
      'option_d': _optDController.text,
      'option_e': _hasOptionE ? _optEController.text : null,
      'correct_option': _correctOption,
      'explanation': _explanationController.text.isEmpty
          ? null
          : _explanationController.text,
      'subject_id': _selectedSubjectId,
      'topic_id': _selectedTopicId,
      'subtopic_id': _selectedSubtopicId,
      'difficulty': _difficulty,
      'is_custom': 1,
      'created_by': 1, // current user id
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Question'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveQuestion,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Question Text
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'Type your question here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Options
            const Text('Options', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            _buildOptionField('A', _optAController),
            _buildOptionField('B', _optBController),
            _buildOptionField('C', _optCController),
            _buildOptionField('D', _optDController),

            if (_hasOptionE) _buildOptionField('E', _optEController),

            TextButton.icon(
              onPressed: () => setState(() => _hasOptionE = !_hasOptionE),
              icon: Icon(_hasOptionE ? Icons.remove : Icons.add),
              label: Text(_hasOptionE ? 'Remove Option E' : 'Add Option E'),
            ),

            const SizedBox(height: 16),

            // Correct Answer
            const Text('Correct Answer', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: ['A', 'B', 'C', 'D', if (_hasOptionE) 'E']
                  .map((e) => ButtonSegment(value: e, label: Text(e)))
                  .toList(),
              selected: {_correctOption},
              onSelectionChanged: (set) => setState(() => _correctOption = set.first),
            ),

            const SizedBox(height: 16),

            // Explanation
            TextFormField(
              controller: _explanationController,
              decoration: const InputDecoration(
                labelText: 'Explanation (Optional)',
                hintText: 'Why is this the correct answer?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // HIERARCHY WITH + BUTTONS
            const Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Subject Dropdown with +
            _buildHierarchyDropdown(
              label: 'Subject',
              value: _selectedSubjectId,
              items: _subjects,
              onChanged: (id) {
                setState(() => _selectedSubjectId = id);
                if (id != null) _loadTopics(id);
              },
              onAdd: () => _addNewCategory('SUBJECT', null),
              hint: 'Select subject',
            ),

            const SizedBox(height: 12),

            // Topic Dropdown with +
            _buildHierarchyDropdown(
              label: 'Topic',
              value: _selectedTopicId,
              items: _topics,
              onChanged: (id) {
                setState(() => _selectedTopicId = id);
                if (id != null) _loadSubtopics(id);
              },
              onAdd: _selectedSubjectId == null
                  ? null
                  : () => _addNewCategory('TOPIC', _selectedSubjectId!),
              hint: _selectedSubjectId == null
                  ? 'Select subject first'
                  : 'Select topic (optional)',
            ),

            const SizedBox(height: 12),

            // Subtopic Dropdown with +
            _buildHierarchyDropdown(
              label: 'Subtopic',
              value: _selectedSubtopicId,
              items: _subtopics,
              onChanged: (id) => setState(() => _selectedSubtopicId = id),
              onAdd: _selectedTopicId == null
                  ? null
                  : () => _addNewCategory('SUBTOPIC', _selectedTopicId!),
              hint: _selectedTopicId == null
                  ? 'Select topic first'
                  : 'Select subtopic (optional)',
            ),

            const SizedBox(height: 16),

            // Difficulty
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
              items: ['EASY', 'MEDIUM', 'HARD']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _difficulty = v!),
            ),

            const SizedBox(height: 32),

            // Save Button
            FilledButton.icon(
              onPressed: _saveQuestion,
              icon: const Icon(Icons.save),
              label: const Text('Save to Library', style: TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _correctOption == label ? Colors.green : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: _correctOption == label ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          hintText: 'Option $label',
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
      ),
    );
  }

  Widget _buildHierarchyDropdown({
    required String label,
    required int? value,
    required List<Map<String, dynamic>> items,
    required Function(int?) onChanged,
    required VoidCallback? onAdd,
    required String hint,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            items: items.map((item) {
              final icon = item['icon'] as String?;
              return DropdownMenuItem<int>(
                value: item['id'] as int,
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Text(icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        item['name'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onAdd == null ? null : (v) => onChanged(v),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Add new $label',
          child: IconButton.filledTonal(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            style: IconButton.styleFrom(
              backgroundColor: onAdd == null ? Colors.grey[200] : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optAController.dispose();
    _optBController.dispose();
    _optCController.dispose();
    _optDController.dispose();
    _optEController.dispose();
    _explanationController.dispose();
    super.dispose();
  }
}
