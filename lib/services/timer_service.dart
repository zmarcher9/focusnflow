import 'package:cloud_firestore/cloud_firestore.dart';

class TimerState {
  final bool isRunning;
  final int secondsRemaining;
  final int round;
  final String phase; // 'focus' | 'break'
  final String startedBy;
  final DateTime? startedAt;

  const TimerState({
    required this.isRunning,
    required this.secondsRemaining,
    required this.round,
    required this.phase,
    required this.startedBy,
    this.startedAt,
  });

  Map<String, dynamic> toMap() => {
    'isRunning': isRunning,
    'secondsRemaining': secondsRemaining,
    'round': round,
    'phase': phase,
    'startedBy': startedBy,
    'startedAt': startedAt?.toIso8601String(),
  };

  factory TimerState.fromMap(Map<String, dynamic> map) => TimerState(
    isRunning: map['isRunning'] ?? false,
    secondsRemaining: map['secondsRemaining'] ?? 1500,
    round: map['round'] ?? 1,
    phase: map['phase'] ?? 'focus',
    startedBy: map['startedBy'] ?? '',
    startedAt: map['startedAt'] != null
        ? DateTime.parse(map['startedAt'])
        : null,
  );
}

class TimerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Real-time stream of shared timer state
  Stream<TimerState> timerStream(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((snap) {
      final timerData = snap.data()?['timer'];
      if (timerData == null) {
        return const TimerState(
          isRunning: false,
          secondsRemaining: 1500,
          round: 1,
          phase: 'focus',
          startedBy: '',
        );
      }
      return TimerState.fromMap(Map<String, dynamic>.from(timerData));
    });
  }

  Future<void> startTimer(String groupId, String userId) async {
    await _db.collection('groups').doc(groupId).update({
      'timer': TimerState(
        isRunning: true,
        secondsRemaining: 1500,
        round: 1,
        phase: 'focus',
        startedBy: userId,
        startedAt: DateTime.now(),
      ).toMap(),
    });
  }

  Future<void> pauseTimer(String groupId, int secondsRemaining) async {
    await _db.collection('groups').doc(groupId).update({
      'timer.isRunning': false,
      'timer.secondsRemaining': secondsRemaining,
    });
  }

  Future<void> resetTimer(String groupId) async {
    await _db.collection('groups').doc(groupId).update({
      'timer': const TimerState(
        isRunning: false,
        secondsRemaining: 1500,
        round: 1,
        phase: 'focus',
        startedBy: '',
      ).toMap(),
    });
  }
}