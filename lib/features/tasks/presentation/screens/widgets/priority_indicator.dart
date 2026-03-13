import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/task_entity.dart';

class PriorityIndicator extends StatelessWidget {
  const PriorityIndicator({super.key, required this.priority});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = _color();
    if (priority == TaskPriority.none) return const SizedBox.shrink();
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.only(top: 6, left: 6),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Color _color() => switch (priority) {
        TaskPriority.high => AppColors.priorityHigh,
        TaskPriority.medium => AppColors.priorityMedium,
        TaskPriority.low => AppColors.priorityLow,
        TaskPriority.none => Colors.transparent,
      };
}