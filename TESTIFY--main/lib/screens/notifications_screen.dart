import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, dynamic>> notifications = const [
    {
      'title': 'FIFA 2026 Is Here!',
      'body': 'Enjoy the excitement of FIFA 2026 with us! Use code FIFA2026 and get 10% OFF.',
      'date': '6/11/2026',
      'icon': Icons.sports_soccer,
      'color': 0xFF6366F1,
    },
    {
      'title': 'Weekly Test',
      'body': 'Weekly test is happening now. Join and do your best.',
      'date': '6/10/2026',
      'icon': Icons.edit_note,
      'color': 0xFF10B981,
    },
    {
      'title': 'Maintenance',
      'body': 'Server maintenance undergoing. Some interruptions may be expected.',
      'date': '6/9/2026',
      'icon': Icons.build,
      'color': 0xFFF59E0B,
    },
    {
      'title': 'Eid Mubarak',
      'body': 'Eid Mubarak from the EduLocus family! May Allah bless you.',
      'date': '6/8/2026',
      'icon': Icons.celebration,
      'color': 0xFFEC4899,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              // Mark all as read
            },
            tooltip: 'Mark all read',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final isUnread = index < 2; // First 2 unread

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: isUnread ? Colors.blue[50] : null,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(notif['color'] as int).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notif['icon'] as IconData,
                  color: Color(notif['color'] as int),
                ),
              ),
              title: Row(
                children: [
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      notif['title'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notif['body'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notif['date'],
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
              onTap: () {
                // Open notification detail
              },
            ),
          );
        },
      ),
    );
  }
}
