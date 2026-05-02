import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../utils/study_plan_engine.dart';

class StudyPlanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Stream<List<TaskModel>> tasksStream(String userId) {
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => TaskModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<TaskModel> addTask({
    required String userId,
    required String title,
    required String course,
    required DateTime dueDate,
    required int effortHours,
    required double courseWeight,
  }) async {
    final id = _uuid.v4();
    final task = TaskModel(
      id: id,
      userId: userId,
      title: title,
      course: course,
      dueDate: dueDate,
      effortHours: effortHours,
      courseWeight: courseWeight,
    );
    await _db.collection('tasks').doc(id).set(task.toMap());
    return task;
  }

  Future<void> toggleComplete(String taskId, bool isCompleted) async {
    await _db
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': isCompleted});
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  Map<DateTime, List<ScheduledBlock>> generatePlan(List<TaskModel> tasks) {
    return StudyPlanEngine.generateWeeklyPlan(tasks);
  }
}