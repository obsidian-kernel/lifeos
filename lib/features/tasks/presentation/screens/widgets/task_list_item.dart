import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/task_providers.dart';
import 'priority_indicator.dart';

class TaskListItem extends ConsumerWidget {
  const TaskListItem({super.key, required this.task});
  final TaskEntity task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(selectedTaskIdProvider) == task.id;

    return InkWell(
      onTap: () => ref.read(selectedTaskIdProvider.notifier).select(task.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.accent : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCheckbox(ref),
            const SizedBox(width: 10),
            Expanded(child: _buildContent()),
            PriorityIndicator(priority: task.priority),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (!task.isCompleted) {
          ref.read(taskActionsProvider.notifier).completeTask(task.id);
        }
      },
      child: Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: task.isCompleted ? AppColors.success : AppColors.border,
            width: 1.5,
          ),
          color: task.isCompleted
              ? AppColors.success.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: task.isCompleted
            ? const Icon(Icons.check, size: 12, color: AppColors.success)
            : null,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: AppTypography.bodyLarge.copyWith(
            color: task.isCompleted ? AppColors.onSurfaceMuted : AppColors.onBackground,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (task.dueDate != null) ...[
          const SizedBox(height: 3),
          Text(
            DateFormat('MMM d').format(task.dueDate!.toLocal()),
            style: AppTypography.labelSmall.copyWith(
              color: task.isOverdue ? AppColors.error : AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ],
    );
  }
}