class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String course;
  final DateTime dueDate;
  final int effortHours;
  final double courseWeight;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.course,
    required this.dueDate,
    required this.effortHours,
    required this.courseWeight,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'course': course,
    'dueDate': dueDate.toIso8601String(),
    'effortHours': effortHours,
    'courseWeight': courseWeight,
    'isCompleted': isCompleted,
  };

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    title: map['title'] ?? '',
    course: map['course'] ?? '',
    dueDate: DateTime.parse(
      map['dueDate'] ?? DateTime.now().toIso8601String(),
    ),
    effortHours: map['effortHours'] ?? 1,
    courseWeight: (map['courseWeight'] ?? 1.0).toDouble(),
    isCompleted: map['isCompleted'] ?? false,
  );
}