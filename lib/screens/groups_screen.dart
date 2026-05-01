import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/group_service.dart';
import '../models/group_model.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  void _showCreateGroupDialog(BuildContext context, String userId) {
    final nameCtrl = TextEditingController();
    final courseCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final groupService = GroupService();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Study Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            TextField(
              controller: courseCtrl,
              decoration: const InputDecoration(labelText: 'Course (e.g. CSC 4360)'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await groupService.createGroup(
                name: nameCtrl.text.trim(),
                course: courseCtrl.text.trim().toUpperCase(),
                createdBy: userId,
                description: descCtrl.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user!.uid;
    final groupService = GroupService();

    return Scaffold(
      appBar: AppBar(title: const Text('Study Groups')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context, userId),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<GroupModel>>(
        stream: groupService.userGroupsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final groups = snapshot.data ?? [];
          if (groups.isEmpty) {
            return const Center(
              child: Text('No groups yet. Create one or join by course.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, i) => ListTile(
              leading: CircleAvatar(child: Text(groups[i].course[0])),
              title: Text(groups[i].name),
              subtitle: Text(groups[i].course),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupDetailScreen(group: groups[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}