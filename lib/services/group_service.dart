import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Stream groups the current user is a member of
  Stream<List<GroupModel>> userGroupsStream(String userId) {
    return _db
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => GroupModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Create a new group
  Future<GroupModel> createGroup({
    required String name,
    required String course,
    required String createdBy,
    required String description,
  }) async {
    final id = _uuid.v4();
    final group = GroupModel(
      id: id,
      name: name,
      course: course,
      createdBy: createdBy,
      memberIds: [createdBy],
      description: description,
      createdAt: DateTime.now(),
    );
    await _db.collection('groups').doc(id).set(group.toMap());
    return group;
  }

  // Join an existing group
  Future<void> joinGroup(String groupId, String userId) async {
    await _db.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  // Leave a group
  Future<void> leaveGroup(String groupId, String userId) async {
    await _db.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  // Search groups by course code
  Future<List<GroupModel>> searchByCourse(String course) async {
    final snap = await _db
        .collection('groups')
        .where('course', isEqualTo: course.toUpperCase())
        .get();
    return snap.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
  }
}