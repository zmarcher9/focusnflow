import 'package:flutter/material.dart';
import '../services/room_service.dart';
import '../models/room_model.dart';
import '../widgets/room_card.dart';

class RoomFinderScreen extends StatelessWidget {
  const RoomFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roomService = RoomService();

    return Scaffold(
      appBar: AppBar(title: const Text('Study Rooms')),
      body: StreamBuilder<List<RoomModel>>(
        stream: roomService.roomsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return const Center(child: Text('No rooms available'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, i) => RoomCard(
              room: rooms[i],
              onCheckIn: () => roomService.checkIn(rooms[i].id),
              onCheckOut: () => roomService.checkOut(rooms[i].id),
            ),
          );
        },
      ),
    );
  }
}