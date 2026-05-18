import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/timer_provider.dart';
import '../utils/theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _subjectController = TextEditingController();
  int _selectedDuration = 25;
  String _selectedMood = 'neutral';

  final List<int> _durations = [15, 25, 45, 60, 90];
  final List<Map<String, dynamic>> _moods = [
    {'label': 'Tired', 'emoji': '\u{1F634}', 'value': 'tired'},
    {'label': 'Neutral', 'emoji': '\u{1F610}', 'value': 'neutral'},
    {'label': 'Good', 'emoji': '\u{1F60A}', 'value': 'good'},
    {'label': 'Focused', 'emoji': '\u{1F525}', 'value': 'focused'},
    {'label': 'Excited', 'emoji': '\u{1F680}', 'value': 'excited'},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
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
  }

  void _stopSession() {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final sessionId = timerProvider.activeSessionId;
    timerProvider.stopTimer();

    if (sessionId != null) {
      final result = appProvider.endSession(sessionId);
      _showSummaryDialog(result);
    }
  }

  void _simulateDistraction(String appName) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final sessionId = timerProvider.activeSessionId;
    if (sessionId != null) {
      appProvider.logDistraction(sessionId, appName, 'app_switch');
    }
  }

  void _showSummaryDialog(Map<String, dynamic> result) {
    if (result.isEmpty) return;
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _summaryRow('Duration', '${result['duration_minutes'] ?? 0} min'),
            _summaryRow('Distractions', '${result['distractions'] ?? 0}'),
            _summaryRow('Completed', (result['is_completed'] ?? false) ? 'Yes' : 'No'),
            _summaryRow('Streak', '${result['streak'] ?? 0} days'),
            if ((result['new_badges'] as List?)?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              const Text(
                'New Badges Earned!',
                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
              ),
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final timerProvider = Provider.of<TimerProvider>(context, listen: false);
              timerProvider.reset();
            },
            child: const Text('Done', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

    if (timerProvider.isRunning) {
      return _buildActiveTimer(timerProvider, appProvider);
    }
    return _buildSetupView();
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
            const SizedBox(height: 6),
            const Text(
              'Set up your study session',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 28),

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
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      ),
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
            const Text('Current Mood', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
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
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.card,
                          border: isSelected
                              ? Border.all(color: AppColors.primary, width: 2)
                              : Border.all(color: AppColors.cardBorder),
                        ),
                        child: Center(
                          child: Text(mood['emoji'], style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['label'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

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
                    Text('Start Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
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
            const Spacer(),
            // Circular progress
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
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerProvider.displayTime,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
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
            const SizedBox(height: 32),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _timerStat('Elapsed', timerProvider.elapsedFormatted, Icons.schedule),
                _timerStat('Distractions', '$distractions', Icons.warning_amber),
              ],
            ),
            const Spacer(),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Pause/Resume
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
                // Stop
                GestureDetector(
                  onTap: _stopSession,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, Color(0xFFFF4444)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.stop, color: Colors.white, size: 34),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Distraction simulation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  const Text(
                    'Simulate Distraction (for testing)',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _distractionBtn('Instagram', Icons.camera_alt),
                      _distractionBtn('YouTube', Icons.play_circle),
                      _distractionBtn('Twitter', Icons.alternate_email),
                      _distractionBtn('TikTok', Icons.music_note),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _timerStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _distractionBtn(String name, IconData icon) {
    return GestureDetector(
      onTap: () => _simulateDistraction(name),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accent, size: 18),
          ),
          const SizedBox(height: 2),
          Text(name, style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
        ],
      ),
    );
  }
}
