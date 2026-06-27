import 'package:flutter/material.dart';
import 'question_adder_screen.dart';
import 'past_papers_screen.dart';
import 'subject_wise_screen.dart';
import 'chapter_wise_screen.dart';
import 'question_library_screen.dart';
import 'test_taking_screen.dart';

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'Model Tests',
      'subtitle': 'Full length model sets based on syllabus',
      'icon': Icons.school,
      'color': 0xFF6366F1,
      'popular': true,
    },
    {
      'title': 'Past Papers',
      'subtitle': 'Collection of past papers from various exams',
      'icon': Icons.history_edu,
      'color': 0xFF10B981,
    },
    {
      'title': 'Subject Wise',
      'subtitle': 'Test focused on a specific subject',
      'icon': Icons.menu_book,
      'color': 0xFFF59E0B,
    },
    {
      'title': 'Chapter Wise',
      'subtitle': 'Test focused on specific chapters',
      'icon': Icons.bookmark,
      'color': 0xFFEC4899,
    },
    {
      'title': 'Custom Test',
      'subtitle': 'Create your own test with custom settings',
      'icon': Icons.build,
      'color': 0xFF8B5CF6,
    },
    {
      'title': 'Difficulty Based',
      'subtitle': 'Test based on easy, medium, or hard questions',
      'icon': Icons.trending_up,
      'color': 0xFFEF4444,
    },
    {
      'title': 'Random Test',
      'subtitle': 'Randomly selected questions for variety',
      'icon': Icons.shuffle,
      'color': 0xFF06B6D4,
    },
    {
      'title': 'Revision Test',
      'subtitle': 'Practice questions you got wrong or skipped',
      'icon': Icons.refresh,
      'color': 0xFF84CC16,
    },
    {
      'title': 'Retake Test',
      'subtitle': 'Retake a previously completed test',
      'icon': Icons.replay,
      'color': 0xFF14B8A6,
    },
    {
      'title': 'Bookmarks',
      'subtitle': 'Review your bookmarked questions',
      'icon': Icons.bookmark_border,
      'color': 0xFFF97316,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuestionAdderScreen()),
            ),
            tooltip: 'Add Question',
          ),
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuestionLibraryScreen()),
            ),
            tooltip: 'Question Library',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore UG (MBBS/BDS/Nursing)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CEE, MBBS, BDS, NURSING',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.explore),
                    label: const Text('Explore Now'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.layers, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Free Practice',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Categories Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCategoryCard(context, categories[index]),
                childCount: categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    final color = Color(category['color'] as int);

    return InkWell(
      onTap: () => _onCategoryTap(context, category['title'] as String),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[100]!,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category['icon'] as IconData, color: color, size: 24),
                ),
                if (category['popular'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              category['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              category['subtitle'] as String,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _onCategoryTap(BuildContext context, String title) {
    switch (title) {
      case 'Past Papers':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PastPapersScreen()));
        break;
      case 'Subject Wise':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectWiseScreen()));
        break;
      case 'Chapter Wise':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChapterWiseScreen()));
        break;
      case 'Model Tests':
      case 'Custom Test':
      case 'Random Test':
      case 'Difficulty Based':
        _startQuickTest(context, title);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title coming soon!')),
        );
    }
  }

  void _startQuickTest(BuildContext context, String type) {
    // For demo - would fetch appropriate questions
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestTakingScreen(
          testName: type,
          questions: [], // Would fetch from DB
          timeLimitMinutes: type == 'Model Tests' ? 30 : 10,
        ),
      ),
    );
  }
}
