import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'chapter_wise_screen.dart';

class SubjectWiseScreen extends StatefulWidget {
  const SubjectWiseScreen({super.key});

  @override
  State<SubjectWiseScreen> createState() => _SubjectWiseScreenState();
}

class _SubjectWiseScreenState extends State<SubjectWiseScreen> {
  final db = DBHelper();
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjects = await db.getSubjects();
    setState(() => _subjects = subjects);
  }

  final Map<String, Color> _subjectColors = {
    'Mathematics': Colors.indigo,
    'Physics': Colors.pink,
    'Chemistry': Colors.blue,
    'Biology': Colors.teal,
    'English': Colors.purple,
    'Mat': Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Fixed: Combined title and subtitle into a Column inside the title parameter
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject Wise'),
            Text('Master individual subjects', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          final name = subject['name'] as String;
          final color = _subjectColors[name] ?? Colors.indigo;
          final icon = subject['icon'] as String? ?? '📚';

          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChapterWiseScreen(
                  subjectId: subject['id'],
                  subjectName: name,
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(icon, style: const TextStyle(fontSize: 24)),
                  ),
                  const Spacer(),
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${subject['question_count'] ?? 0} Questions',
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
