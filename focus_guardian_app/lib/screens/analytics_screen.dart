import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/focus_monitor_service.dart';
import '../utils/theme.dart';

/// Real Analytics Dashboard - replaces the old reports_screen
/// Shows actual data from completed sessions and focus monitoring.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriod = 7; // days

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final profile = appProvider.profile;
    final cutoff = DateTime.now().subtract(Duration(days: _selectedPeriod));
    final sessions = appProvider.completedSessions
        .where((s) => s.startTime.isAfter(cutoff))
        .toList();

    final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes.round());
    final totalSessions = sessions.length;
    final avgScore = totalSessions > 0
        ? (sessions.fold<int>(0, (sum, s) => sum + s.focusScore) / totalSessions).round()
        : 0;
    final totalDistractions = sessions.fold<int>(0, (sum, s) => sum + s.distractionCount);
    final focusedMinutes = totalMinutes - (totalDistractions * 2); // rough estimate

    // Subject breakdown
    final Map<String, int> subjectMin = {};
    for (final s in sessions) {
      subjectMin[s.subject] = (subjectMin[s.subject] ?? 0) + s.durationMinutes.round();
    }
    final sortedSubjects = subjectMin.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxSubjectMin = sortedSubjects.isNotEmpty ? sortedSubjects.first.value : 1;

    // Daily breakdown for chart
    final Map<String, int> dailyMin = {};
    for (int i = _selectedPeriod - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = '${date.day}/${date.month}';
      final daySessions = sessions.where((s) =>
          s.startTime.year == date.year &&
          s.startTime.month == date.month &&
          s.startTime.day == date.day);
      dailyMin[key] = daySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes.round());
    }
    final maxDailyMin = dailyMin.values.isNotEmpty
        ? dailyMin.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Analytics',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your study performance data',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              // Period selector
              _buildPeriodSelector(),
              const SizedBox(height: 24),

              // Overview stats
              _buildOverviewCards(totalMinutes, totalSessions, avgScore, totalDistractions),
              const SizedBox(height: 24),

              // Daily chart
              _buildDailyChart(dailyMin, maxDailyMin),
              const SizedBox(height: 24),

              // Focus vs Distraction
              _buildFocusBreakdown(totalMinutes, focusedMinutes, totalDistractions),
              const SizedBox(height: 24),

              // Subject breakdown
              _buildSubjectBreakdown(sortedSubjects, maxSubjectMin),
              const SizedBox(height: 24),

              // Recent sessions
              _buildRecentSessions(sessions),
              const SizedBox(height: 24),

              // Guardian report card
              _buildGuardianReport(profile, totalMinutes, avgScore, totalDistractions),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [7, 14, 30].map((days) {
        final isSelected = days == _selectedPeriod;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPeriod = days),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                ),
              ),
              child: Text(
                '$days days',
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOverviewCards(int totalMin, int sessions, int avgScore, int distractions) {
    return Row(
      children: [
        _statCard('Study Time', '${(totalMin / 60).toStringAsFixed(1)}h', AppColors.primary, Icons.schedule),
        const SizedBox(width: 8),
        _statCard('Sessions', '$sessions', AppColors.secondary, Icons.play_circle),
        const SizedBox(width: 8),
        _statCard('Avg Score', '$avgScore', AppColors.success, Icons.gps_fixed),
        const SizedBox(width: 8),
        _statCard('Distractions', '$distractions', AppColors.accent, Icons.warning_amber),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChart(Map<String, int> dailyMin, int maxMin) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text('Daily Study Time', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailyMin.entries.map((entry) {
                final height = maxMin > 0 ? (entry.value / maxMin * 100).clamp(4.0, 100.0) : 4.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (entry.value > 0)
                          Text(
                            '${entry.value}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: entry.value > 0 ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.key,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusBreakdown(int totalMin, int focusedMin, int distractions) {
    final focusPct = totalMin > 0 ? (focusedMin / totalMin * 100).clamp(0, 100) : 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline, color: AppColors.secondary, size: 18),
              SizedBox(width: 8),
              Text('Focus Breakdown', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${focusPct.toStringAsFixed(0)}%',
                      style: const TextStyle(color: AppColors.success, fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    const Text('Focus Rate', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _breakdownRow('Focused', '${focusedMin}m', AppColors.success),
                    const SizedBox(height: 8),
                    _breakdownRow('Distracted', '${totalMin - focusedMin}m', AppColors.accent),
                    const SizedBox(height: 8),
                    _breakdownRow('Events', '$distractions', AppColors.warning),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const Spacer(),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSubjectBreakdown(List<MapEntry<String, int>> subjects, int maxMin) {
    if (subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Center(
          child: Text('No sessions in this period', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.book_outlined, color: AppColors.warning, size: 18),
              SizedBox(width: 8),
              Text('Subject Breakdown', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          ...subjects.take(6).map((entry) {
            final pct = entry.value / maxMin;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('${entry.value}m', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: AppColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(List sessions) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history, color: AppColors.textMuted, size: 18),
            SizedBox(width: 8),
            Text('Recent Sessions', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        ...sessions.take(5).map((s) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _scoreColor(s.focusScore).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${s.focusScore}',
                    style: TextStyle(color: _scoreColor(s.focusScore), fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.subject, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                    Text('${s.durationFormatted} • ${_formatDate(s.startTime)}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              if (s.distractionCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${s.distractionCount}⚠️', style: const TextStyle(fontSize: 11)),
                ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildGuardianReport(profile, int totalMin, int avgScore, int distractions) {
    final rating = avgScore >= 85 ? 'Excellent' : avgScore >= 70 ? 'Good' : avgScore >= 50 ? 'Average' : 'Needs Work';
    final ratingColor = avgScore >= 85 ? AppColors.success : avgScore >= 70 ? AppColors.secondary : avgScore >= 50 ? AppColors.warning : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ratingColor.withOpacity(0.08), ratingColor.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ratingColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: ratingColor, size: 22),
              const SizedBox(width: 10),
              const Text('Guardian Report', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(rating, style: TextStyle(color: ratingColor, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getGuardianFeedback(totalMin, avgScore, distractions),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniStat('Study', '${(totalMin / 60).toStringAsFixed(1)}h', ratingColor),
              const SizedBox(width: 12),
              _miniStat('Score', '$avgScore', ratingColor),
              const SizedBox(width: 12),
              _miniStat('Streak', '${profile.streakDays}d', ratingColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }

  String _getGuardianFeedback(int totalMin, int avgScore, int distractions) {
    if (totalMin == 0) {
      return 'No study activity recorded in this period. Start a session to see your guardian report.';
    }
    if (avgScore >= 85 && distractions <= 2) {
      return 'Outstanding discipline! You maintained excellent focus with minimal distractions. Keep this standard.';
    }
    if (avgScore >= 70) {
      return 'Good effort. Your focus is above average but there\'s room for improvement. Try to reduce distractions by ${(distractions * 0.3).round()} next week.';
    }
    if (avgScore >= 50) {
      return 'Your focus needs attention. $distractions distractions is too many. Try shorter sessions (25min) and use the site blocking feature more aggressively.';
    }
    return 'Critical: Your focus score is below 50. Recommendation: 1) Block all social media, 2) Use 15-min sessions only, 3) Keep phone in another room, 4) Enable camera monitoring.';
  }

  Color _scoreColor(int score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return AppColors.secondary;
    if (score >= 50) return AppColors.warning;
    return AppColors.accent;
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }
}
