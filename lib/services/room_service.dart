import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Real-time stream of all rooms
  Stream<List<RoomModel>> roomsStream() {
    return _db.collection('rooms').snapshots().map(
      (snap) => snap.docs
          .map((doc) => RoomModel.fromMap(doc.data()))
          .toList(),
    );
  }

  // Increment occupancy using a Firestore transaction
  Future<void> checkIn(String roomId) async {
    final ref = _db.collection('rooms').doc(roomId);
    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      final current = snap.data()?['occupancy'] ?? 0;
      final capacity = snap.data()?['capacity'] ?? 0;
      if (current < capacity) {
        transaction.update(ref, {'occupancy': current + 1});
      } else {
        throw Exception('Room is full');
      }
    });
  }

  // Decrement occupancy using a Firestore transaction
  Future<void> checkOut(String roomId) async {
    final ref = _db.collection('rooms').doc(roomId);
    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      final current = snap.data()?['occupancy'] ?? 0;
      if (current > 0) {
        transaction.update(ref, {'occupancy': current - 1});
      }
    });
  }

  // Seed sample rooms (run once during setup)
  Future<void> seedRooms() async {
    final rooms = [
      {'id': 'lib-101', 'name': 'Room 101', 'building': 'Library', 'capacity': 8, 'occupancy': 0, 'amenities': ['Whiteboard', 'Outlets'], 'isAvailable': true},
      {'id': 'lib-102', 'name': 'Room 102', 'building': 'Library', 'capacity': 12, 'occupancy': 0, 'amenities': ['TV', 'Whiteboard', 'Outlets'], 'isAvailable': true},
      {'id': 'stu-a1', 'name': 'Pod A1', 'building': 'Student Center', 'capacity': 4, 'occupancy': 0, 'amenities': ['Outlets'], 'isAvailable': true},
      {'id': 'stu-a2', 'name': 'Pod A2', 'building': 'Student Center', 'capacity': 4, 'occupancy': 0, 'amenities': ['Outlets'], 'isAvailable': true},
      {'id': 'csc-200', 'name': 'Lab 200', 'building': 'CS Building', 'capacity': 20, 'occupancy': 0, 'amenities': ['Computers', 'Projector'], 'isAvailable': true},
    ];

    final batch = _db.batch();
    for (final room in rooms) {
      batch.set(_db.collection('rooms').doc(room['id'] as String), room);
    }
    await batch.commit();
  }
}