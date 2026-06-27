import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'test_taking_screen.dart';

class ChapterWiseScreen extends StatefulWidget {
  final int? subjectId;
  final String? subjectName;

  const ChapterWiseScreen({
    super.key,
    this.subjectId,
    this.subjectName,
  });

  @override
  State<ChapterWiseScreen> createState() => _ChapterWiseScreenState();
}

class _ChapterWiseScreenState extends State<ChapterWiseScreen> {
  final db = DBHelper();
  List<Map<String, dynamic>> _topics = [];
  List<Map<String, dynamic>> _chapters = [];
  int? _selectedTopicId;

  @override
  void initState() {
    super.initState();
    if (widget.subjectId != null) {
      _loadTopics(widget.subjectId!);
    }
  }

  Future<void> _loadTopics(int subjectId) async {
    final topics = await db.getTopics(subjectId);
    setState(() => _topics = topics);
  }

  Future<void> _loadChapters(int topicId) async {
    final subtopics = await db.getSubtopics(topicId);
    setState(() {
      _chapters = subtopics;
      _selectedTopicId = topicId;
    });
  }

  final List<Color> _chapterColors = [
    Colors.indigo, Colors.teal, Colors.orange, Colors.pink,
    Colors.purple, Colors.cyan, Colors.green, Colors.amber,
    Colors.deepPurple, Colors.blue, Colors.red, Colors.lime,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Fixed: Combined title and subtitle into a Column inside the title parameter
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subjectName ?? 'Chapter Wise'),
            const Text('Focus on specific topics', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Topic Selector
          if (_topics.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select topic'),
                items: _topics.map((topic) {
                  return DropdownMenuItem<int>(
                    value: topic['id'] as int,
                    child: Text(topic['name']),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id != null) _loadChapters(id);
                },
              ),
            ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search topics...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Chapters List
          Expanded(
            child: _chapters.isEmpty
                ? const Center(child: Text('Select a topic to see chapters'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = _chapters[index];
                      final color = _chapterColors[index % _chapterColors.length];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 4,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          title: Text(
                            chapter['name'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${chapter['question_count'] ?? 0} Questions',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: color,
                            child: const Icon(Icons.play_arrow, color: Colors.white),
                          ),
                          onTap: () {
                            // Start chapter test
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
