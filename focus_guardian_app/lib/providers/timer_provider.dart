import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider extends ChangeNotifier {
  Timer? _timer;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;
  String? _activeSessionId;

  int get totalSeconds => _totalSeconds;
  int get remainingSeconds => _remainingSeconds;
  int get elapsedSeconds => _totalSeconds - _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  String? get activeSessionId => _activeSessionId;

  double get progress {
    if (_totalSeconds == 0) return 0;
    return 1.0 - (_remainingSeconds / _totalSeconds);
  }

  String get displayTime {
    int mins = _remainingSeconds ~/ 60;
    int secs = _remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get elapsedFormatted {
    int elapsed = elapsedSeconds;
    int mins = elapsed ~/ 60;
    int secs = elapsed % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  void startTimer(int durationMinutes, String sessionId) {
    _totalSeconds = durationMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _isRunning = true;
    _isPaused = false;
    _activeSessionId = sessionId;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          stopTimer();
        }
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    _isPaused = true;
    notifyListeners();
  }

  void resumeTimer() {
    _isPaused = false;
    notifyListeners();
  }

  void togglePause() {
    if (_isPaused) {
      resumeTimer();
    } else {
      pauseTimer();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _remainingSeconds = _totalSeconds;
    _activeSessionId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
