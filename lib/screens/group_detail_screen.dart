import 'package:flutter/material.dart';
import '../models/group_model.dart';
import 'chat_screen.dart';
import 'timer_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.course,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(group.description),
            const SizedBox(height: 8),
            Text('${group.memberIds.length} members'),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Group Chat'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(group: group),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Shared Pomodoro Timer'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TimerScreen(group: group),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}