import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class PastPapersScreen extends StatefulWidget {
  const PastPapersScreen({super.key});

  @override
  State<PastPapersScreen> createState() => _PastPapersScreenState();
}

class _PastPapersScreenState extends State<PastPapersScreen> {
  final db = DBHelper();
  String _selectedType = 'All';
  String _selectedYear = 'All Years';

  final List<String> _examTypes = ['All', 'BDS', 'MBBS', 'NURSING'];
  final List<String> _years = ['All Years', '2082', '2081', '2080', '2079', '2024', '2023', '2022', '2021', '2020', '2019', '2018'];

  final List<Map<String, dynamic>> _papers = [
    {'name': 'CEE-2021', 'year': '2021', 'type': 'CEE', 'questions': 177, 'status': 'OPEN'},
    {'name': 'IOM-2019', 'year': '2019', 'type': 'IOM', 'questions': 89, 'status': 'OPEN'},
    {'name': 'BPKIHS-2018', 'year': '2018', 'type': 'BPKIHS', 'questions': 130, 'status': 'OPEN'},
    {'name': 'KU-2018', 'year': '2018', 'type': 'KU', 'questions': 98, 'status': 'OPEN'},
    {'name': 'IOM-2018', 'year': '2018', 'type': 'IOM', 'questions': 147, 'status': 'OPEN'},
    {'name': 'CEE-2024', 'year': '2024', 'type': 'CEE', 'questions': 150, 'status': 'LOCKED'},
    {'name': 'CEE-2023', 'year': '2023', 'type': 'CEE', 'questions': 192, 'status': 'LOCKED'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Fixed: Combined title and subtitle into a Column inside the title parameter
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Past Papers'),
            Text('Practice with previous exams', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ..._examTypes.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: _selectedType == type,
                    onSelected: (_) => setState(() => _selectedType = type),
                  ),
                )),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ..._years.map((year) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(year),
                    selected: _selectedYear == year,
                    onSelected: (_) => setState(() => _selectedYear = year),
                  ),
                )),
              ],
            ),
          ),

          // Papers List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _papers.length,
              itemBuilder: (context, index) {
                final paper = _papers[index];
                final isOpen = paper['status'] == 'OPEN';
                final color = _getColorForIndex(index);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          isOpen ? Icons.description : Icons.lock,
                          color: color,
                        ),
                      ),
                    ),
                    title: Text(
                      paper['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(paper['year'], style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(width: 12),
                            Icon(Icons.school, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(paper['type'], style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${paper['questions']} Questions',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: isOpen
                        ? FilledButton(
                            onPressed: () {},
                            child: const Text('Start'),
                          )
                        : OutlinedButton(
                            onPressed: () {},
                            child: const Text('Unlock'),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [Colors.teal, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.pink, Colors.indigo];
    return colors[index % colors.length];
  }
}
