import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/timer_provider.dart';
import '../services/app_guardian_service.dart';
import '../utils/theme.dart';

/// Timer Screen with REAL guardian monitoring.
/// When user leaves app during focus mode, it DETECTS immediately.
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  final _subjectController = TextEditingController();
  int _selectedDuration = 25;
  String _selectedMood = 'neutral';

  // REAL Guardian
  final AppGuardianService _guardian = AppGuardianService();
  GuardianAlert? _lastAlert;
  bool _showAlert = false;

  final List<int> _durations = [15, 25, 45, 60, 90];
  final List<Map<String, dynamic>> _moods = [
    {'label': 'Tired', 'emoji': '\u{1F634}', 'value': 'tired'},
    {'label': 'Neutral', 'emoji': '\u{1F610}', 'value': 'neutral'},
    {'label': 'Good', 'emoji': '\u{1F60A}', 'value': 'good'},
    {'label': 'Focused', 'emoji': '\u{1F525}', 'value': 'focused'},
    {'label': 'Excited', 'emoji': '\u{1F680}', 'value': 'excited'},
  ];

  @override
  void initState() {
    super.initState();
    // Setup guardian callbacks
    _guardian.onDistraction = (alert) {
      if (mounted) {
        setState(() {
          _lastAlert = alert;
          _showAlert = true;
        });
        // Auto-hide after 8 seconds
        Future.delayed(const Duration(seconds: 8), () {
          if (mounted) setState(() => _showAlert = false);
        });
      }
    };
    _guardian.onReturn = (awaySeconds, count) {
      if (mounted) {
        // Update app provider with distraction
        final timerProvider = Provider.of<TimerProvider>(context, listen: false);
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        final sessionId = timerProvider.activeSessionId;
        if (sessionId != null) {
          appProvider.logDistraction(sessionId, 'Left app (${awaySeconds}s)', 'app_switch');
        }
      }
    };
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _guardian.disarm();
    super.dispose();
  }

  void _startSession() {
    final subject = _subjectController.text.trim().isEmpty
        ? 'General Study'
        : _subjectController.text.trim();

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    final session = appProvider.startSession(subject, _selectedDuration, _selectedMood);
    timerProvider.startTimer(_selectedDuration, session.id);

    // ARM THE REAL GUARDIAN
    _guardian.arm(sessionId: session.id, subject: subject);
  }

  void _stopSession() {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final sessionId = timerProvider.activeSessionId;
    timerProvider.stopTimer();

    // DISARM guardian and save history
    _guardian.saveHistory();
    _guardian.disarm();

    if (sessionId != null) {
      final result = appProvider.endSession(sessionId);
      _showSummaryDialog(result);
    }
  }

  void _showSummaryDialog(Map<String, dynamic> result) {
    if (result.isEmpty) return;
    final guardianSummary = _guardian.getSessionSummary();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Session Complete!',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Score circle
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      (result['score'] ?? 0) >= 80
                          ? AppColors.secondary
                          : AppColors.accent,
                      AppColors.primary,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '${result['score'] ?? 0}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _summaryRow('Duration', '${result['duration_minutes'] ?? 0} min'),
              _summaryRow('Distractions', '${result['distractions'] ?? 0}'),
              _summaryRow('Completed', (result['is_completed'] ?? false) ? 'Yes ✅' : 'No'),
              _summaryRow('Streak', '${result['streak'] ?? 0} days 🔥'),

              // Guardian report
              if (guardianSummary['distraction_count'] > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield, color: AppColors.accent, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Guardian Report',
                            style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _summaryRow('Times left app', '${guardianSummary['distraction_count']}'),
                      _summaryRow('Total time away', '${guardianSummary['total_away_seconds']}s'),
                      _summaryRow('Score penalty', '-${guardianSummary['total_penalty']} pts'),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.success.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: AppColors.success, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'PERFECT! Zero distractions detected!',
                        style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],

              // Badges
              if ((result['new_badges'] as List?)?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                const Text('New Badges!', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: (result['new_badges'] as List).map((b) {
                    return Chip(
                      label: Text(b.toString(), style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: const TextStyle(color: AppColors.textPrimary),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Provider.of<TimerProvider>(context, listen: false).reset();
            },
            child: const Text('Done', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    final appProvider = context.watch<AppProvider>();

    return Stack(
      children: [
        // Main content
        timerProvider.isRunning
            ? _buildActiveTimer(timerProvider, appProvider)
            : _buildSetupView(),

        // REAL ALERT OVERLAY (shows when user returns from distraction)
        if (_showAlert && _lastAlert != null)
          _buildAlertOverlay(_lastAlert!),
      ],
    );
  }

  /// Alert overlay - shown on TOP of everything when user returns from distraction
  Widget _buildAlertOverlay(GuardianAlert alert) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showAlert = false),
        child: Container(
          color: alert.color.withOpacity(0.92),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(alert.icon, color: Colors.white, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    alert.type == 'critical' ? '🚨 FOCUS LOST!' : '⚠️ DISTRACTION!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Away for ${alert.durationAway}s | -${alert.penalty} pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      alert.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Tap anywhere to dismiss',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupView() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start Focus Session',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Guardian will monitor you. Leave the app = instant detection.',
              style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // Subject
            const Text('Subject', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                hintText: 'e.g. Mathematics, Physics...',
                prefixIcon: Icon(Icons.book_outlined, color: AppColors.textMuted),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),

            // Duration
            const Text('Duration', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _durations.map((d) {
                final isSelected = d == _selectedDuration;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDuration = d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                    ),
                    child: Text(
                      '$d min',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textMuted,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Mood
            const Text('Mood', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _moods.map((mood) {
                final isSelected = mood['value'] == _selectedMood;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood['value']),
                  child: Column(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.card,
                          border: isSelected
                              ? Border.all(color: AppColors.primary, width: 2)
                              : Border.all(color: AppColors.cardBorder),
                        ),
                        child: Center(child: Text(mood['emoji'], style: const TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(height: 4),
                      Text(mood['label'], style: TextStyle(fontSize: 9, color: isSelected ? AppColors.primary : AppColors.textMuted)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            // Start button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 24),
                    SizedBox(width: 8),
                    Text('Start Focus Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent.withOpacity(0.15)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: AppColors.accent, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Guardian will detect if you leave this app. Every second away is tracked and penalized.',
                      style: TextStyle(color: AppColors.accent, fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTimer(TimerProvider timerProvider, AppProvider appProvider) {
    final sessionId = timerProvider.activeSessionId;
    final session = sessionId != null
        ? appProvider.sessions.where((s) => s.id == sessionId).firstOrNull
        : null;
    final distractions = session?.distractionCount ?? 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Guardian status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _guardian.isAway
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _guardian.isAway
                      ? AppColors.accent.withOpacity(0.3)
                      : AppColors.success.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _guardian.isAway ? Icons.warning_rounded : Icons.shield,
                    color: _guardian.isAway ? AppColors.accent : AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _guardian.isAway
                        ? '⚠️ YOU LEFT THE APP!'
                        : '🛡️ Guardian Active • ${_guardian.distractionCount} distraction${_guardian.distractionCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: _guardian.isAway ? AppColors.accent : AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Timer circle
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: timerProvider.progress,
                      strokeWidth: 10,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        timerProvider.isPaused ? AppColors.warning : AppColors.primary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerProvider.displayTime,
                        style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timerProvider.isPaused ? 'PAUSED' : 'FOCUS MODE',
                        style: TextStyle(
                          fontSize: 13,
                          color: timerProvider.isPaused ? AppColors.accent : AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _timerStat('Elapsed', timerProvider.elapsedFormatted, Icons.schedule, AppColors.secondary),
                _timerStat('Away', '${_guardian.awaySeconds}s', Icons.phone_android, AppColors.accent),
                _timerStat('Distractions', '$distractions', Icons.warning_amber, AppColors.warning),
              ],
            ),
            const Spacer(),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: timerProvider.togglePause,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withOpacity(0.15),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                    ),
                    child: Icon(
                      timerProvider.isPaused ? Icons.play_arrow : Icons.pause,
                      color: AppColors.secondary,
                      size: 30,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _stopSession,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFFFF4444)]),
                      boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 12, spreadRadius: 2)],
                    ),
                    child: const Icon(Icons.stop, color: Colors.white, size: 34),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _timerStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}
