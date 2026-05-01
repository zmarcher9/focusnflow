import 'package:flutter/material.dart';
import '../models/room_model.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const RoomCard({
    super.key,
    required this.room,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  Color get _occupancyColor {
    final pct = room.occupancyPercent;
    if (pct < 0.5) return Colors.green;
    if (pct < 0.8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _occupancyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${room.availableSeats} seats open',
                    style: TextStyle(
                      color: _occupancyColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              room.building,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: room.occupancyPercent,
              color: _occupancyColor,
              backgroundColor: _occupancyColor.withOpacity(0.15),
            ),
            const SizedBox(height: 4),
            Text(
              '${room.occupancy} / ${room.capacity} occupied',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (room.amenities.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: room.amenities
                    .map(
                      (a) => Chip(
                        label: Text(a, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCheckOut,
                    child: const Text('Check Out'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: room.availableSeats > 0 ? onCheckIn : null,
                    child: const Text('Check In'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}