import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'play_circle':
        return Icons.play_circle;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'stars':
        return Icons.stars;
      case 'diamond':
        return Icons.diamond;
      case 'hourglass_bottom':
        return Icons.hourglass_bottom;
      case 'schedule':
        return Icons.schedule;
      case 'alarm':
        return Icons.alarm;
      case 'star':
        return Icons.star;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'shield':
        return Icons.shield;
      case 'gps_fixed':
        return Icons.gps_fixed;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'nightlight':
        return Icons.nightlight;
      case 'directions_run':
        return Icons.directions_run;
      case 'psychology':
        return Icons.psychology;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final earnedBadges = appProvider.earnedBadges;
    final allBadges = AppConstants.badgeTypes;
    final earnedCount = earnedBadges.length;
    final totalCount = allBadges.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Badges'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.secondary.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$earnedCount / $totalCount Earned',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalCount > 0 ? earnedCount / totalCount : 0,
                            minHeight: 6,
                            backgroundColor: AppColors.surface,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${((earnedCount / totalCount) * 100).toStringAsFixed(0)}% complete',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Badge grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: allBadges.length,
              itemBuilder: (context, index) {
                final badge = allBadges[index];
                final isEarned = earnedBadges.contains(badge['type']);
                return _buildBadgeCard(badge, isEarned);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, String> badge, bool isEarned) {
    final icon = _getIconData(badge['icon'] ?? 'star');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isEarned ? AppColors.card : AppColors.card.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEarned ? AppColors.primary.withOpacity(0.4) : AppColors.cardBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isEarned
                  ? const LinearGradient(colors: [AppColors.primary, AppColors.secondary])
                  : null,
              color: isEarned ? null : AppColors.surface,
            ),
            child: Icon(
              icon,
              color: isEarned ? Colors.white : AppColors.textMuted.withOpacity(0.4),
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge['name'] ?? '',
            style: TextStyle(
              color: isEarned ? AppColors.textPrimary : AppColors.textMuted.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isEarned)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.lock,
                size: 12,
                color: AppColors.textMuted.withOpacity(0.4),
              ),
            ),
        ],
      ),
    );
  }
}
