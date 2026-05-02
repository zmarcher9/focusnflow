import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/study_plan_service.dart';
import '../models/task_model.dart';
import '../utils/study_plan_engine.dart';

class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  final _planService = StudyPlanService();

  void _showAddTaskDialog(BuildContext context, String userId) {
    final titleCtrl = TextEditingController();
    final courseCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));
    int effortHours = 2;
    double courseWeight = 0.5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: courseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Course (e.g. CSC 4360)',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Due Date: ${DateFormat('MMM d').format(selectedDate)}',
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: const Text('Pick due date'),
                ),
                Text('Effort: $effortHours hours'),
                Slider(
                  value: effortHours.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$effortHours hrs',
                  onChanged: (v) =>
                      setDialogState(() => effortHours = v.toInt()),
                ),
                Text(
                  'Course Weight: ${courseWeight.toStringAsFixed(1)}',
                ),
                Slider(
                  value: courseWeight,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: courseWeight.toStringAsFixed(1),
                  onChanged: (v) =>
                      setDialogState(() => courseWeight = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _planService.addTask(
                  userId: userId,
                  title: titleCtrl.text.trim(),
                  course: courseCtrl.text.trim().toUpperCase(),
                  dueDate: selectedDate,
                  effortHours: effortHours,
                  courseWeight: courseWeight,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Study Plan')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, userId),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _planService.tasksStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(
              child: Text('Add tasks to generate your study plan.'),
            );
          }

          final plan = _planService.generatePlan(tasks);
          final conflicts = StudyPlanEngine.conflictCheck(plan);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scoring explanation card
                Card(
                  color: Colors.blue.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How priority is calculated',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'score = (course weight × 0.4) + (urgency × 0.4) + (effort × 0.2)',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Conflict warnings
                if (conflicts.isNotEmpty) ...[
                  ...conflicts.map(
                    (c) => Card(
                      color: Colors.orange.withOpacity(0.1),
                      child: ListTile(
                        leading: const Icon(Icons.warning, color: Colors.orange),
                        title: Text(c, style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Weekly schedule
                ...plan.entries.map((entry) {
                  final day = entry.key;
                  final blocks = entry.value;
                  if (blocks.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          DateFormat('EEEE, MMM d').format(day),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...blocks.map(
                        (block) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.withOpacity(0.15),
                              child: Text(
                                block.priorityScore.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(block.task.title),
                            subtitle: Text(
                              '${block.task.course} • ${block.allocatedHours}h • ${block.reason}',
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                block.task.isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: block.task.isCompleted
                                    ? Colors.green
                                    : null,
                              ),
                              onPressed: () => _planService.toggleComplete(
                                block.task.id,
                                !block.task.isCompleted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}