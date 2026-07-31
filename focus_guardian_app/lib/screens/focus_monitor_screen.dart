import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/focus_monitor_service.dart';
import '../services/ai_service.dart';
import '../utils/theme.dart';

/// Real-time Focus Monitor Screen
/// Shows actual focus status, distraction log, and guardian alerts.
/// NO fake simulation buttons.
class FocusMonitorScreen extends StatefulWidget {
  const FocusMonitorScreen({super.key});

  @override
  State<FocusMonitorScreen> createState() => _FocusMonitorScreenState();
}

class _FocusMonitorScreenState extends State<FocusMonitorScreen> {
  final AIService _aiService = AIService();
  final List<_AlertMessage> _alerts = [];

  @override
  void initState() {
    super.initState();
    _aiService.initialize();

    // Setup alert callbacks
    final monitor = Provider.of<FocusMonitorService>(context, listen: false);
    monitor.onAlertTriggered = (type, message) {
      setState(() {
        _alerts.insert(0, _AlertMessage(
          type: type,
          message: message,
          timestamp: DateTime.now(),
        ));
        if (_alerts.length > 20) _alerts.removeLast();
      });
    };
    monitor.onStatusChanged = (status) {
      setState(() {}); // Rebuild UI on status change
    };
  }

  @override
  Widget build(BuildContext context) {
    final monitor = context.watch<FocusMonitorService>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(monitor),
              const SizedBox(height: 24),
              _buildStatusCard(monitor),
              const SizedBox(height: 20),
              _buildStatsRow(monitor),
              const SizedBox(height: 24),
              if (monitor.isMonitoring) ...[
                _buildControlButtons(monitor),
                const SizedBox(height: 24),
              ],
              _buildAlertSection(),
              const SizedBox(height: 24),
              if (monitor.distractionLog.isNotEmpty) _buildDistractionLog(monitor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(FocusMonitorService monitor) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Guardian',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'AI monitors your focus in real-time',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        // Start/Stop monitoring button
        GestureDetector(
          onTap: () {
            if (monitor.isMonitoring) {
              monitor.stopMonitoring();
              monitor.saveSessionData();
            } else {
              monitor.startMonitoring();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: monitor.isMonitoring
                  ? AppColors.accent.withOpacity(0.15)
                  : AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: monitor.isMonitoring
                    ? AppColors.accent.withOpacity(0.3)
                    : AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  monitor.isMonitoring ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: monitor.isMonitoring ? AppColors.accent : AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  monitor.isMonitoring ? 'Stop' : 'Start',
                  style: TextStyle(
                    color: monitor.isMonitoring ? AppColors.accent : AppColors.success,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(FocusMonitorService monitor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            monitor.statusColor.withOpacity(0.12),
            monitor.statusColor.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: monitor.statusColor.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          // Status icon with pulsing animation
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: monitor.statusColor.withOpacity(0.15),
              border: Border.all(color: monitor.statusColor.withOpacity(0.4), width: 3),
            ),
            child: Icon(monitor.statusIcon, color: monitor.statusColor, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            monitor.statusText.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: monitor.statusColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          if (monitor.isMonitoring)
            Text(
              'Session: ${_formatDuration(monitor.totalSessionSeconds)}',
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            )
          else
            const Text(
              'Tap Start to begin monitoring',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          if (monitor.isMonitoring) ...[
            const SizedBox(height: 16),
            // Focus percentage bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: monitor.focusPercentage / 100,
                minHeight: 8,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  monitor.focusPercentage >= 80
                      ? AppColors.success
                      : monitor.focusPercentage >= 50
                          ? AppColors.warning
                          : AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${monitor.focusPercentage.toStringAsFixed(1)}% focused',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: monitor.focusPercentage >= 80
                    ? AppColors.success
                    : monitor.focusPercentage >= 50
                        ? AppColors.warning
                        : AppColors.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(FocusMonitorService monitor) {
    return Row(
      children: [
        _buildStatCard(
          'Focused',
          _formatDuration(monitor.focusedSeconds),
          Icons.visibility,
          AppColors.success,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          'Distracted',
          _formatDuration(monitor.distractedSeconds),
          Icons.warning_amber,
          AppColors.accent,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          'Events',
          '${monitor.distractionEvents}',
          Icons.notification_important_outlined,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(FocusMonitorService monitor) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: monitor.currentStatus == FocusStatus.onBreak ? 'End Break' : 'Take Break',
            icon: monitor.currentStatus == FocusStatus.onBreak ? Icons.play_arrow : Icons.coffee,
            color: AppColors.secondary,
            onTap: () {
              if (monitor.currentStatus == FocusStatus.onBreak) {
                monitor.endBreak();
              } else {
                monitor.startBreak();
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            label: 'Report Distraction',
            icon: Icons.front_hand_rounded,
            color: AppColors.accent,
            onTap: () => _showReportDialog(monitor),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text(
              'Guardian Alerts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_alerts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.success, size: 32),
                SizedBox(height: 10),
                Text(
                  'No alerts yet',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  'Your AI guardian will alert you here when distractions are detected',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._alerts.take(5).map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(_AlertMessage alert) {
    final color = alert.type == 'distraction'
        ? AppColors.accent
        : alert.type == 'inactivity'
            ? AppColors.warning
            : alert.type == 'encouragement'
                ? AppColors.success
                : AppColors.primary;

    final icon = alert.type == 'distraction'
        ? Icons.warning_rounded
        : alert.type == 'inactivity'
            ? Icons.hourglass_empty
            : alert.type == 'encouragement'
                ? Icons.thumb_up
                : Icons.chat_bubble_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(alert.timestamp),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistractionLog(FocusMonitorService monitor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.list_alt, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Distraction Log',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${monitor.distractionLog.length} events',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...monitor.distractionLog.take(10).map((event) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.appName,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
              ),
              Text(
                _formatTime(event.timestamp),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _showReportDialog(FocusMonitorService monitor) {
    final reasons = [
      'Picked up phone',
      'Checked social media',
      'Talking to someone',
      'Daydreaming',
      'Eating/drinking',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('What distracted you?', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((reason) => ListTile(
            dense: true,
            title: Text(reason, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            leading: const Icon(Icons.circle_outlined, size: 18, color: AppColors.textMuted),
            onTap: () {
              monitor.reportManualDistraction(reason);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Distraction logged. Get back to studying!'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    if (min < 60) return '${min}m ${sec}s';
    final hr = min ~/ 60;
    return '${hr}h ${min % 60}m';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _AlertMessage {
  final String type;
  final String message;
  final DateTime timestamp;

  _AlertMessage({required this.type, required this.message, required this.timestamp});
}
