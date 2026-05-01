class RoomModel {
  final String id;
  final String name;
  final String building;
  final int capacity;
  int occupancy;
  final List<String> amenities;
  final bool isAvailable;

  RoomModel({
    required this.id,
    required this.name,
    required this.building,
    required this.capacity,
    required this.occupancy,
    required this.amenities,
    required this.isAvailable,
  });

  int get availableSeats => capacity - occupancy;
  double get occupancyPercent => occupancy / capacity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'building': building,
    'capacity': capacity,
    'occupancy': occupancy,
    'amenities': amenities,
    'isAvailable': isAvailable,
  };

  factory RoomModel.fromMap(Map<String, dynamic> map) => RoomModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    building: map['building'] ?? '',
    capacity: map['capacity'] ?? 0,
    occupancy: map['occupancy'] ?? 0,
    amenities: List<String>.from(map['amenities'] ?? []),
    isAvailable: map['isAvailable'] ?? true,
  );
}