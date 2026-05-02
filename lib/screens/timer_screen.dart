import 'package:flutter/material.dart';
import 'dart:async';
import '../models/group_model.dart';
import '../services/timer_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TimerScreen extends StatefulWidget {
  final GroupModel group;
  const TimerScreen({super.key, required this.group});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _timerService = TimerService();
  Timer? _localTick;
  int _localSeconds = 1500;
  bool _localRunning = false;
  bool _synced = false;

  @override
  void dispose() {
    _localTick?.cancel();
    super.dispose();
  }

  void _startLocalTick() {
    _localTick?.cancel();
    _localTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_localRunning && _localSeconds > 0) {
        setState(() => _localSeconds--);
      }
    });
  }

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user!.uid;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.group.name} — Timer')),
      body: StreamBuilder<TimerState>(
        stream: _timerService.timerStream(widget.group.id),
        builder: (context, snapshot) {
          final state = snapshot.data;

          // Sync local state from Firestore when changed remotely
          if (state != null && !_synced) {
            _localSeconds = state.secondsRemaining;
            _localRunning = state.isRunning;
            _synced = true;
            if (_localRunning) _startLocalTick();
          }

          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state?.phase == 'break' ? 'Break Time' : 'Focus Time',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                Text(
                  _format(_localSeconds),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                Text('Round ${state?.round ?? 1} of 4'),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(_localRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(_localRunning ? 'Pause' : 'Start'),
                      onPressed: () {
                        if (_localRunning) {
                          _timerService.pauseTimer(
                            widget.group.id,
                            _localSeconds,
                          );
                          setState(() => _localRunning = false);
                          _localTick?.cancel();
                        } else {
                          _timerService.startTimer(widget.group.id, userId);
                          setState(() => _localRunning = true);
                          _startLocalTick();
                        }
                        _synced = false;
                      },
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      onPressed: () {
                        _timerService.resetTimer(widget.group.id);
                        _localTick?.cancel();
                        setState(() {
                          _localSeconds = 1500;
                          _localRunning = false;
                          _synced = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}