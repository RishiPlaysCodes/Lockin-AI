import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// REAL App Guardian Service
/// This actually detects when user leaves the app during a focus session.
/// Uses WidgetsBindingObserver to track AppLifecycleState changes.
///
/// HOW IT WORKS:
/// 1. When focus session is active, guardian is armed
/// 2. When user presses home/switches app → AppLifecycleState.paused fires
/// 3. We record the exact timestamp they left
/// 4. When they come back → AppLifecycleState.resumed fires
/// 5. We calculate how long they were gone
/// 6. We show a WARNING overlay with exact time wasted
/// 7. Score penalty applied based on duration
/// 8. Everything logged to distraction history
///
/// This is NOT fake. This is REAL detection that works on Android.
class AppGuardianService with WidgetsBindingObserver {
  // State
  bool _isArmed = false; // Guardian monitoring active?
  bool _isAway = false; // User currently away from app?
  DateTime? _leftAt; // When did user leave?
  DateTime? _returnedAt; // When did they come back?
  int _awaySeconds = 0; // Total seconds away this session
  int _distractionCount = 0; // Times user left during session
  final List<DistractionLog> _distractionHistory = [];

  // Session info
  String _currentSessionId = '';
  String _currentSubject = '';

  // Callbacks - UI will set these
  Function(GuardianAlert alert)? onDistraction;
  Function(int awaySeconds, int count)? onReturn;

  // Settings
  int _graceSeconds = 5; // Don't trigger if back within 5 sec (might be accidental)
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Getters
  bool get isArmed => _isArmed;
  bool get isAway => _isAway;
  int get awaySeconds => _awaySeconds;
  int get distractionCount => _distractionCount;
  List<DistractionLog> get history => List.unmodifiable(_distractionHistory);
  String get currentSessionId => _currentSessionId;

  /// Start monitoring - call when focus session begins
  void arm({
    required String sessionId,
    required String subject,
    int graceSeconds = 5,
  }) {
    _isArmed = true;
    _isAway = false;
    _leftAt = null;
    _returnedAt = null;
    _awaySeconds = 0;
    _distractionCount = 0;
    _distractionHistory.clear();
    _currentSessionId = sessionId;
    _currentSubject = subject;
    _graceSeconds = graceSeconds;

    // Register as observer
    WidgetsBinding.instance.addObserver(this);
  }

  /// Stop monitoring - call when session ends
  void disarm() {
    _isArmed = false;
    _isAway = false;
    _leftAt = null;
    _currentSessionId = '';

    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
  }

  /// THIS IS THE REAL DETECTION
  /// Called automatically by Flutter when app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isArmed) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // USER LEFT THE APP (opened Instagram, YouTube, etc.)
        if (!_isAway) {
          _isAway = true;
          _leftAt = DateTime.now();
        }
        break;

      case AppLifecycleState.resumed:
        // USER CAME BACK
        if (_isAway && _leftAt != null) {
          _isAway = false;
          _returnedAt = DateTime.now();

          final duration = _returnedAt!.difference(_leftAt!);
          final seconds = duration.inSeconds;

          // Only count if away longer than grace period
          if (seconds > _graceSeconds) {
            _awaySeconds += seconds;
            _distractionCount++;

            // Log it
            final log = DistractionLog(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              sessionId: _currentSessionId,
              leftAt: _leftAt!,
              returnedAt: _returnedAt!,
              durationSeconds: seconds,
              penalty: _calculatePenalty(seconds),
            );
            _distractionHistory.add(log);

            // Create alert
            final alert = GuardianAlert(
              type: _getAlertSeverity(seconds),
              message: _getAlertMessage(seconds),
              durationAway: seconds,
              timestamp: DateTime.now(),
              penalty: log.penalty,
            );

            // Trigger callbacks
            onDistraction?.call(alert);
            onReturn?.call(_awaySeconds, _distractionCount);

            // Vibrate on return (real haptic feedback)
            if (_vibrationEnabled) {
              HapticFeedback.heavyImpact();
            }
          }

          _leftAt = null;
          _returnedAt = null;
        }
        break;

      default:
        break;
    }
  }

  /// Calculate score penalty based on time away
  int _calculatePenalty(int seconds) {
    if (seconds <= 10) return 3; // Quick peek
    if (seconds <= 30) return 5; // Brief distraction
    if (seconds <= 60) return 8; // 1 min away
    if (seconds <= 180) return 12; // 3 min away
    if (seconds <= 300) return 15; // 5 min away
    return 20; // 5+ min - serious distraction
  }

  /// Get alert severity
  String _getAlertSeverity(int seconds) {
    if (seconds <= 15) return 'mild';
    if (seconds <= 60) return 'warning';
    if (seconds <= 180) return 'serious';
    return 'critical';
  }

  /// Get contextual alert message based on how long user was away
  String _getAlertMessage(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final timeStr = mins > 0 ? '${mins}m ${secs}s' : '${secs}s';

    if (seconds <= 15) {
      final messages = [
        '📱 You were away for $timeStr. Quick peek? Get back to studying!',
        '⚠️ $timeStr wasted. Phone down, book up!',
        '👀 Caught you! $timeStr gone. Stay focused!',
      ];
      return messages[DateTime.now().second % messages.length];
    }

    if (seconds <= 60) {
      final messages = [
        '🚫 You left for $timeStr! That\'s $timeStr of study time WASTED. Don\'t do it again.',
        '😤 $timeStr away from studying. Was scrolling Instagram worth losing focus?',
        '⏰ $timeStr distraction detected. Your exam doesn\'t scroll itself. GET BACK!',
      ];
      return messages[DateTime.now().second % messages.length];
    }

    if (seconds <= 180) {
      final messages = [
        '🔴 SERIOUS: You were gone for $timeStr! That\'s almost a full Pomodoro wasted on distractions!',
        '💀 $timeStr WASTED. That could have been ${mins} revision problems solved. Wake up!',
        '🚨 $timeStr away! This is EXACTLY why you need Focus Guardian. NO MORE EXCUSES.',
      ];
      return messages[DateTime.now().second % messages.length];
    }

    // 3+ minutes
    return '🚨🚨🚨 CRITICAL: You were away for $timeStr!\n\n'
        'That\'s $mins minutes of pure distraction. '
        'Your focus score just dropped significantly.\n\n'
        'If you can\'t stay away from your phone, put it in another room. '
        'Your future self is counting on you RIGHT NOW.';
  }

  /// Get session summary
  Map<String, dynamic> getSessionSummary() {
    return {
      'session_id': _currentSessionId,
      'subject': _currentSubject,
      'total_away_seconds': _awaySeconds,
      'distraction_count': _distractionCount,
      'total_penalty': _distractionHistory.fold<int>(0, (sum, d) => sum + d.penalty),
      'history': _distractionHistory.map((d) => d.toJson()).toList(),
      'worst_distraction': _distractionHistory.isEmpty
          ? 0
          : _distractionHistory.map((d) => d.durationSeconds).reduce((a, b) => a > b ? a : b),
    };
  }

  /// Save distraction history to SharedPreferences
  Future<void> saveHistory() async {
    if (_distractionHistory.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('guardian_history') ?? '[]';
    final list = json.decode(existing) as List;
    list.addAll(_distractionHistory.map((d) => d.toJson()));
    // Keep last 200 entries
    if (list.length > 200) list.removeRange(0, list.length - 200);
    await prefs.setString('guardian_history', json.encode(list));
  }

  /// Load historical data
  static Future<List<DistractionLog>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('guardian_history') ?? '[]';
    final list = json.decode(data) as List;
    return list.map((e) => DistractionLog.fromJson(e)).toList();
  }

  /// Configure settings
  void configure({
    int? graceSeconds,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    if (graceSeconds != null) _graceSeconds = graceSeconds;
    if (soundEnabled != null) _soundEnabled = soundEnabled;
    if (vibrationEnabled != null) _vibrationEnabled = vibrationEnabled;
  }
}

/// A single distraction event (user left app)
class DistractionLog {
  final String id;
  final String sessionId;
  final DateTime leftAt;
  final DateTime returnedAt;
  final int durationSeconds;
  final int penalty;

  DistractionLog({
    required this.id,
    required this.sessionId,
    required this.leftAt,
    required this.returnedAt,
    required this.durationSeconds,
    required this.penalty,
  });

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'session_id': sessionId,
    'left_at': leftAt.toIso8601String(),
    'returned_at': returnedAt.toIso8601String(),
    'duration_seconds': durationSeconds,
    'penalty': penalty,
  };

  factory DistractionLog.fromJson(Map<String, dynamic> json) => DistractionLog(
    id: json['id'] ?? '',
    sessionId: json['session_id'] ?? '',
    leftAt: DateTime.tryParse(json['left_at'] ?? '') ?? DateTime.now(),
    returnedAt: DateTime.tryParse(json['returned_at'] ?? '') ?? DateTime.now(),
    durationSeconds: json['duration_seconds'] ?? 0,
    penalty: json['penalty'] ?? 5,
  );
}

/// Alert shown to user when they return
class GuardianAlert {
  final String type; // mild, warning, serious, critical
  final String message;
  final int durationAway;
  final DateTime timestamp;
  final int penalty;

  GuardianAlert({
    required this.type,
    required this.message,
    required this.durationAway,
    required this.timestamp,
    required this.penalty,
  });

  Color get color {
    switch (type) {
      case 'mild': return const Color(0xFFFECA57);
      case 'warning': return const Color(0xFFFF9F43);
      case 'serious': return const Color(0xFFFF6B6B);
      case 'critical': return const Color(0xFFFF0000);
      default: return const Color(0xFFFF6B6B);
    }
  }

  IconData get icon {
    switch (type) {
      case 'mild': return Icons.info_outline;
      case 'warning': return Icons.warning_amber_rounded;
      case 'serious': return Icons.error_outline;
      case 'critical': return Icons.dangerous;
      default: return Icons.warning;
    }
  }
}
