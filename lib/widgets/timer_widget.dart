import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class TimerWidget extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback onTimeUp;
  final Function(Duration remaining)? onTick;

  const TimerWidget({
    super.key,
    required this.totalSeconds,
    required this.onTimeUp,
    this.onTick,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;
  late int _remainingSeconds;
  bool _isWarning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        widget.onTimeUp();
        return;
      }

      setState(() {
        _remainingSeconds--;
        _isWarning = _remainingSeconds <= 60; // Last minute warning
      });

      widget.onTick?.call(Duration(seconds: _remainingSeconds));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: _remainingSeconds);
    final timeString = Helpers.formatDuration(duration);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isWarning ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isWarning ? Colors.red : Colors.blue,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 18,
            color: _isWarning ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 6),
          Text(
            timeString,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isWarning ? Colors.red : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}
