import '../models/task_model.dart';

class ScheduledBlock {
  final TaskModel task;
  final DateTime scheduledDate;
  final int allocatedHours;
  final double priorityScore;
  final String reason;

  const ScheduledBlock({
    required this.task,
    required this.scheduledDate,
    required this.allocatedHours,
    required this.priorityScore,
    required this.reason,
  });
}

class StudyPlanEngine {
  static const int maxHoursPerDay = 4;

  /// Priority score formula (transparent, shown to user):
  ///   score = (courseWeight * 0.4) + (urgencyScore * 0.4) + (effortScore * 0.2)
  ///
  /// urgencyScore = 1.0 if due in <=1 day
  ///              = 0.8 if due in <=3 days
  ///              = 0.5 if due in <=7 days
  ///              = 0.2 otherwise
  ///
  /// effortScore  = 1.0 if effortHours >= 5
  ///              = 0.6 if effortHours >= 3
  ///              = 0.3 otherwise

  static double _urgencyScore(DateTime due) {
    final daysLeft = due.difference(DateTime.now()).inDays;
    if (daysLeft <= 1) return 1.0;
    if (daysLeft <= 3) return 0.8;
    if (daysLeft <= 7) return 0.5;
    return 0.2;
  }

  static double _effortScore(int hours) {
    if (hours >= 5) return 1.0;
    if (hours >= 3) return 0.6;
    return 0.3;
  }

  static double priorityScore(TaskModel task) {
    return (task.courseWeight * 0.4) +
        (_urgencyScore(task.dueDate) * 0.4) +
        (_effortScore(task.effortHours) * 0.2);
  }

  static String _reasonFor(TaskModel task) {
    final daysLeft = task.dueDate.difference(DateTime.now()).inDays;
    final parts = <String>[];
    if (daysLeft <= 1) parts.add('due very soon');
    if (task.courseWeight >= 0.8) parts.add('high-weight course');
    if (task.effortHours >= 5) parts.add('high effort needed');
    return parts.isEmpty ? 'standard priority' : parts.join(', ');
  }

  /// Generate a weekly schedule.
  /// Returns a map of date -> list of ScheduledBlocks for that day.
  static Map<DateTime, List<ScheduledBlock>> generateWeeklyPlan(
    List<TaskModel> tasks,
  ) {
    final incomplete = tasks
        .where((t) => !t.isCompleted)
        .toList()
      ..sort((a, b) => priorityScore(b).compareTo(priorityScore(a)));

    final plan = <DateTime, List<ScheduledBlock>>{};
    final today = DateTime.now();

    // Build 7-day window with available hour tracking
    final availableHours = <DateTime, int>{};
    for (int i = 0; i < 7; i++) {
      final day = DateTime(today.year, today.month, today.day + i);
      availableHours[day] = maxHoursPerDay;
      plan[day] = [];
    }

    for (final task in incomplete) {
      int hoursLeft = task.effortHours;

      for (final day in availableHours.keys) {
        if (hoursLeft <= 0) break;

        // Don't schedule past the due date
        if (day.isAfter(task.dueDate)) continue;

        final slot = availableHours[day]!;
        if (slot <= 0) continue;

        final allocated = hoursLeft.clamp(0, slot);
        hoursLeft -= allocated;
        availableHours[day] = slot - allocated;

        plan[day]!.add(ScheduledBlock(
          task: task,
          scheduledDate: day,
          allocatedHours: allocated,
          priorityScore: priorityScore(task),
          reason: _reasonFor(task),
        ));
      }
    }

    return plan;
  }

  /// Check for conflicts (same course double-booked on same day)
  static List<String> conflictCheck(Map<DateTime, List<ScheduledBlock>> plan) {
    final conflicts = <String>[];
    for (final entry in plan.entries) {
      final courses = entry.value.map((b) => b.task.course).toList();
      final seen = <String>{};
      for (final c in courses) {
        if (!seen.add(c)) {
          conflicts.add('${c} scheduled twice on ${entry.key.month}/${entry.key.day}');
        }
      }
    }
    return conflicts;
  }
}