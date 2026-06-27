import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class ResultsScreen extends StatelessWidget {
  final int totalQuestions;
  final int correct;
  final int incorrect;
  final int unattempted;
  final int score;
  final int attemptId;

  const ResultsScreen({
    super.key,
    required this.totalQuestions,
    required this.correct,
    required this.incorrect,
    required this.unattempted,
    required this.score,
    required this.attemptId,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = totalQuestions > 0 ? (correct / totalQuestions) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // PDF download logic
            },
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  'Total Questions',
                  totalQuestions.toString(),
                  Icons.quiz,
                  Colors.indigo,
                ),
                _buildStatCard(
                  'Correct',
                  correct.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Incorrect',
                  incorrect.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
                _buildStatCard(
                  'Score',
                  score.toString(),
                  Icons.star,
                  Colors.amber,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Performance by Chapter
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Performance by Chapter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: ExpansionTile(
                title: const Text('Mat'),
                subtitle: Text('$totalQuestions Questions'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildMiniStat(Icons.check_circle, Colors.green, correct),
                        const SizedBox(width: 16),
                        _buildMiniStat(Icons.cancel, Colors.red, incorrect),
                        const SizedBox(width: 16),
                        _buildMiniStat(Icons.remove_circle, Colors.grey, unattempted),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      // Review questions
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Review'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
