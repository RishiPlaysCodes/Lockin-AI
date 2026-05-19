import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Real Focus Monitoring Service
/// Tracks app lifecycle, detects inactivity, manages focus states.
///
/// What it CAN do (Flutter limitations noted):
/// - Track when user leaves this app (AppLifecycleState)
/// - Track inactivity (no touch/interaction)
/// - Measure time away from app
/// - Generate distraction events with real context
/// - Maintain focus state machine
///
/// What requires NATIVE plugins (TODO with proper architecture):
/// - Reading active window name (needs UsageStats API on Android)
/// - Webcam-based attention detection (needs camera + ML)
/// - Actual app blocking at system level (needs Accessibility Service)
///
/// Architecture is ready for these - just needs native plugin integration.
class FocusMonitorService extends ChangeNotifier {
  // Focus State Machine
  FocusStatus _currentStatus = FocusStatus.idle;
  DateTime? _sessionStartTime;
  DateTime? _lastInteractionTime;
  DateTime? _lastStatusChangeTime;
  Timer? _inactivityTimer;
  Timer? _checkInTimer;

  // Tracking data
  int _focusedSeconds = 0;
  int _distractedSeconds = 0;
  int _awaySeconds = 0;
  int _distractionEvents = 0;
  final List<DistractionEvent> _distractionLog = [];
  final List<FocusStateChange> _stateHistory = [];

  // Settings
  int _inactivityThresholdSeconds = 120; // 2 min without interaction = inactive
  int _checkInIntervalSeconds = 600; // Check-in every 10 min
  bool _isMonitoringActive = false;

  // Callbacks for UI notifications
  Function(String alertType, String message)? onAlertTriggered;
  Function(FocusStatus newStatus)? onStatusChanged;

  // Getters
  FocusStatus get currentStatus => _currentStatus;
  bool get isMonitoring => _isMonitoringActive;
  int get focusedSeconds => _focusedSeconds;
  int get distractedSeconds => _distractedSeconds;
  int get awaySeconds => _awaySeconds;
  int get distractionEvents => _distractionEvents;
  List<DistractionEvent> get distractionLog => List.unmodifiable(_distractionLog);
  List<FocusStateChange> get stateHistory => List.unmodifiable(_stateHistory);

  double get focusPercentage {
    final total = _focusedSeconds + _distractedSeconds + _awaySeconds;
    if (total == 0) return 100;
    return (_focusedSeconds / total * 100).clamp(0, 100);
  }

  int get totalSessionSeconds => _focusedSeconds + _distractedSeconds + _awaySeconds;

  String get statusText {
    switch (_currentStatus) {
      case FocusStatus.focused:
        return 'Focused';
      case FocusStatus.distracted:
        return 'Distracted';
      case FocusStatus.away:
        return 'Away';
      case FocusStatus.inactive:
        return 'Inactive';
      case FocusStatus.onBreak:
        return 'On Break';
      case FocusStatus.idle:
        return 'Not Studying';
    }
  }

  Color get statusColor {
    switch (_currentStatus) {
      case FocusStatus.focused:
        return const Color(0xFF06D6A0);
      case FocusStatus.distracted:
        return const Color(0xFFFF6B6B);
      case FocusStatus.away:
        return const Color(0xFFFECA57);
      case FocusStatus.inactive:
        return const Color(0xFF94A3B8);
      case FocusStatus.onBreak:
        return const Color(0xFF4ECDC4);
      case FocusStatus.idle:
        return const Color(0xFF64748B);
    }
  }

  IconData get statusIcon {
    switch (_currentStatus) {
      case FocusStatus.focused:
        return Icons.visibility;
      case FocusStatus.distracted:
        return Icons.warning_amber_rounded;
      case FocusStatus.away:
        return Icons.person_off;
      case FocusStatus.inactive:
        return Icons.hourglass_empty;
      case FocusStatus.onBreak:
        return Icons.coffee;
      case FocusStatus.idle:
        return Icons.power_settings_new;
    }
  }

  /// Start monitoring a study session
  void startMonitoring() {
    _isMonitoringActive = true;
    _sessionStartTime = DateTime.now();
    _lastInteractionTime = DateTime.now();
    _lastStatusChangeTime = DateTime.now();
    _focusedSeconds = 0;
    _distractedSeconds = 0;
    _awaySeconds = 0;
    _distractionEvents = 0;
    _distractionLog.clear();
    _stateHistory.clear();

    _changeStatus(FocusStatus.focused);
    _startInactivityTimer();
    _startCheckInTimer();
    notifyListeners();
  }

  /// Stop monitoring
  void stopMonitoring() {
    _isMonitoringActive = false;
    _inactivityTimer?.cancel();
    _checkInTimer?.cancel();
    _changeStatus(FocusStatus.idle);
    notifyListeners();
  }

  /// Call this when user interacts with the app (tap, scroll, type)
  void registerInteraction() {
    if (!_isMonitoringActive) return;
    _lastInteractionTime = DateTime.now();

    // If we were inactive/away, return to focused
    if (_currentStatus == FocusStatus.inactive || _currentStatus == FocusStatus.away) {
      _changeStatus(FocusStatus.focused);
      // Restart inactivity timer
      _startInactivityTimer();
    }
  }

  /// Call when app goes to background (AppLifecycleState.paused)
  void onAppPaused() {
    if (!_isMonitoringActive) return;
    if (_currentStatus == FocusStatus.onBreak) return; // Don't trigger if on break

    _changeStatus(FocusStatus.away);

    // Log this as a distraction event
    _logDistraction(
      appName: 'App Switched',
      type: DistractionType.appSwitch,
      description: 'Left Focus Guardian app',
    );
  }

  /// Call when app comes back to foreground (AppLifecycleState.resumed)
  void onAppResumed() {
    if (!_isMonitoringActive) return;

    final awayDuration = _lastStatusChangeTime != null
        ? DateTime.now().difference(_lastStatusChangeTime!).inSeconds
        : 0;

    _changeStatus(FocusStatus.focused);
    _lastInteractionTime = DateTime.now();
    _startInactivityTimer();

    // Trigger alert if was away for too long
    if (awayDuration > 30) {
      onAlertTriggered?.call(
        'distraction',
        'You were away for ${_formatDuration(awayDuration)}. Let\'s get back to studying.',
      );
    }
  }

  /// Manually report a distraction (e.g., picked up phone)
  void reportManualDistraction(String reason) {
    if (!_isMonitoringActive) return;

    _logDistraction(
      appName: reason,
      type: DistractionType.selfReported,
      description: 'User reported: $reason',
    );

    _changeStatus(FocusStatus.distracted);

    // Auto-return to focused after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (_currentStatus == FocusStatus.distracted) {
        _changeStatus(FocusStatus.focused);
      }
    });
  }

  /// Start a break (intentional - no penalty)
  void startBreak() {
    if (!_isMonitoringActive) return;
    _changeStatus(FocusStatus.onBreak);
    _inactivityTimer?.cancel();
  }

  /// End break, resume monitoring
  void endBreak() {
    if (!_isMonitoringActive) return;
    _changeStatus(FocusStatus.focused);
    _lastInteractionTime = DateTime.now();
    _startInactivityTimer();
  }

  /// Configure monitoring sensitivity
  void configure({
    int? inactivityThresholdSeconds,
    int? checkInIntervalSeconds,
  }) {
    if (inactivityThresholdSeconds != null) {
      _inactivityThresholdSeconds = inactivityThresholdSeconds;
    }
    if (checkInIntervalSeconds != null) {
      _checkInIntervalSeconds = checkInIntervalSeconds;
    }
  }

  // ============================================================
  // PRIVATE METHODS
  // ============================================================

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isMonitoringActive) return;

      // Update time counters based on current status
      switch (_currentStatus) {
        case FocusStatus.focused:
          _focusedSeconds++;
          break;
        case FocusStatus.distracted:
          _distractedSeconds++;
          break;
        case FocusStatus.away:
        case FocusStatus.inactive:
          _awaySeconds++;
          break;
        default:
          break;
      }

      // Check for inactivity
      if (_lastInteractionTime != null && _currentStatus == FocusStatus.focused) {
        final inactiveDuration = DateTime.now().difference(_lastInteractionTime!).inSeconds;
        if (inactiveDuration >= _inactivityThresholdSeconds) {
          _changeStatus(FocusStatus.inactive);
          onAlertTriggered?.call(
            'inactivity',
            'No activity detected for ${_formatDuration(inactiveDuration)}. Are you still studying?',
          );
        }
      }

      // Notify UI every 5 seconds to update displays
      if (totalSessionSeconds % 5 == 0) {
        notifyListeners();
      }
    });
  }

  void _startCheckInTimer() {
    _checkInTimer?.cancel();
    _checkInTimer = Timer.periodic(Duration(seconds: _checkInIntervalSeconds), (_) {
      if (!_isMonitoringActive) return;
      if (_currentStatus == FocusStatus.focused) {
        onAlertTriggered?.call(
          'checkin',
          '${totalSessionSeconds ~/ 60} minutes of study completed. Keep going!',
        );
      }
    });
  }

  void _changeStatus(FocusStatus newStatus) {
    if (newStatus == _currentStatus) return;

    final oldStatus = _currentStatus;
    _currentStatus = newStatus;
    _lastStatusChangeTime = DateTime.now();

    _stateHistory.add(FocusStateChange(
      fromStatus: oldStatus,
      toStatus: newStatus,
      timestamp: DateTime.now(),
    ));

    onStatusChanged?.call(newStatus);
    notifyListeners();
  }

  void _logDistraction({
    required String appName,
    required DistractionType type,
    String description = '',
  }) {
    _distractionEvents++;
    _distractionLog.add(DistractionEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      appName: appName,
      type: type,
      description: description,
      timestamp: DateTime.now(),
      durationSeconds: 0,
    ));
    notifyListeners();
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    if (min < 60) return '${min}m ${sec}s';
    final hr = min ~/ 60;
    return '${hr}h ${min % 60}m';
  }

  /// Get session summary data
  Map<String, dynamic> getSessionSummary() {
    return {
      'total_seconds': totalSessionSeconds,
      'focused_seconds': _focusedSeconds,
      'distracted_seconds': _distractedSeconds,
      'away_seconds': _awaySeconds,
      'focus_percentage': focusPercentage,
      'distraction_events': _distractionEvents,
      'distraction_log': _distractionLog.map((d) => d.toJson()).toList(),
      'state_changes': _stateHistory.length,
    };
  }

  /// Save session data to preferences
  Future<void> saveSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getString('monitor_sessions') ?? '[]';
    final list = json.decode(sessions) as List;
    list.add({
      ...getSessionSummary(),
      'session_date': DateTime.now().toIso8601String(),
    });
    // Keep last 100 sessions
    if (list.length > 100) list.removeRange(0, list.length - 100);
    await prefs.setString('monitor_sessions', json.encode(list));
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _checkInTimer?.cancel();
    super.dispose();
  }
}

// ============================================================
// DATA MODELS
// ============================================================

enum FocusStatus {
  focused,
  distracted,
  away,
  inactive,
  onBreak,
  idle,
}

enum DistractionType {
  appSwitch,
  inactivity,
  selfReported,
  blockedSite,
  phoneUsage,
  // TODO: These require native plugins
  // activeWindow, // Needs UsageStats API
  // gazeAway,     // Needs camera + ML
  // drowsiness,   // Needs camera + ML
}

class DistractionEvent {
  final String id;
  final String appName;
  final DistractionType type;
  final String description;
  final DateTime timestamp;
  final int durationSeconds;

  DistractionEvent({
    required this.id,
    required this.appName,
    required this.type,
    this.description = '',
    required this.timestamp,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'app_name': appName,
    'type': type.name,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'duration_seconds': durationSeconds,
  };
}

class FocusStateChange {
  final FocusStatus fromStatus;
  final FocusStatus toStatus;
  final DateTime timestamp;

  FocusStateChange({
    required this.fromStatus,
    required this.toStatus,
    required this.timestamp,
  });
}
