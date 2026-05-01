class GroupModel {
  final String id;
  final String name;
  final String course;
  final String createdBy;
  final List<String> memberIds;
  final String description;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.course,
    required this.createdBy,
    required this.memberIds,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'course': course,
    'createdBy': createdBy,
    'memberIds': memberIds,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory GroupModel.fromMap(Map<String, dynamic> map) => GroupModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    course: map['course'] ?? '',
    createdBy: map['createdBy'] ?? '',
    memberIds: List<String>.from(map['memberIds'] ?? []),
    description: map['description'] ?? '',
    createdAt: DateTime.parse(
      map['createdAt'] ?? DateTime.now().toIso8601String(),
    ),
  );
}