class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String major;
  final List<String> courses;
  final String campusLocation;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.major,
    required this.courses,
    required this.campusLocation,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'major': major,
    'courses': courses,
    'campusLocation': campusLocation,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] ?? '',
    email: map['email'] ?? '',
    displayName: map['displayName'] ?? '',
    major: map['major'] ?? '',
    courses: List<String>.from(map['courses'] ?? []),
    campusLocation: map['campusLocation'] ?? '',
    createdAt: DateTime.parse(
      map['createdAt'] ?? DateTime.now().toIso8601String(),
    ),
  );
}