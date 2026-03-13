import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/task_providers.dart';

class TaskFilterBar extends ConsumerWidget {
  const TaskFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(activeTaskFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          _chip(
            label: 'All',
            selected: filter.status == null && filter.priority == null,
            onTap: () => ref.read(activeTaskFilterProvider.notifier).clearFilters(),
          ),
          _chip(
            label: 'In Progress',
            selected: filter.status == TaskStatus.inProgress,
            onTap: () => ref.read(activeTaskFilterProvider.notifier).setStatus(TaskStatus.inProgress),
          ),
          _chip(
            label: 'High Priority',
            selected: filter.priority == TaskPriority.high,
            onTap: () => ref.read(activeTaskFilterProvider.notifier).setPriority(TaskPriority.high),
          ),
          _chip(
            label: 'Done',
            selected: filter.status == TaskStatus.done,
            onTap: () => ref.read(activeTaskFilterProvider.notifier).setStatus(TaskStatus.done),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: selected ? Colors.white : AppColors.onSurfaceMuted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}