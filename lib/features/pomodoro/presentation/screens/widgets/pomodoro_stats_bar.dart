import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../providers/pomodoro_providers.dart';

/// Persistent bar at the bottom of the Pomodoro screen
/// showing today's completed sessions and total focus time.
class PomodoroStatsBar extends ConsumerWidget {
  const PomodoroStatsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(pomodoroTodayStatsProvider);
    final stats = statsAsync.valueOrNull;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.check_circle_outline_rounded,
            label: 'Sessions',
            value: '${stats?.workSessionsCompleted ?? 0}',
            color: AppColors.accent,
          ),
          _Divider(),
          _StatItem(
            icon: Icons.timer_outlined,
            label: 'Focus time',
            value: stats?.formattedFocusTime ?? '0m',
            color: AppColors.success,
          ),
          _Divider(),
          _StatItem(
            icon: Icons.coffee_outlined,
            label: 'Breaks',
            value: _breakCount(stats?.totalBreakSeconds ?? 0),
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  String _breakCount(int totalBreakSeconds) {
    if (totalBreakSeconds == 0) return '0';
    final minutes = totalBreakSeconds ~/ 60;
    return '${minutes}m';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall
              .copyWith(color: AppColors.onSurfaceMuted),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.border,
    );
  }
}
