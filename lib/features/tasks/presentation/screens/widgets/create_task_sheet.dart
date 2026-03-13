import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/task_providers.dart';

class CreateTaskSheet extends ConsumerStatefulWidget {
  const CreateTaskSheet({super.key});

  @override
  ConsumerState<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<CreateTaskSheet> {
  final _titleController = TextEditingController();
  TaskPriority _priority = TaskPriority.none;
  DateTime? _dueDate;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Task', style: AppTypography.titleLarge.copyWith(color: AppColors.onBackground)),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            autofocus: true,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.onBackground),
            decoration: InputDecoration(
              hintText: 'Task title…',
              hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceMuted),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPrioritySelector(),
              const SizedBox(width: 8),
              _buildDueDateButton(),
              const Spacer(),
              _buildSubmitButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return PopupMenuButton<TaskPriority>(
      initialValue: _priority,
      color: AppColors.surface,
      onSelected: (p) => setState(() => _priority = p),
      itemBuilder: (_) => [
        _priorityItem(TaskPriority.none, 'No priority'),
        _priorityItem(TaskPriority.low, 'Low'),
        _priorityItem(TaskPriority.medium, 'Medium'),
        _priorityItem(TaskPriority.high, 'High'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 14, color: _priorityColor()),
            const SizedBox(width: 4),
            Text(
              _priorityLabel(),
              style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<TaskPriority> _priorityItem(TaskPriority p, String label) {
    return PopupMenuItem(
      value: p,
      child: Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface)),
    );
  }

  Widget _buildDueDateButton() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.onSurfaceMuted),
            const SizedBox(width: 4),
            Text(
              _dueDate != null ? '${_dueDate!.day}/${_dueDate!.month}' : 'Due date',
              style: AppTypography.labelLarge.copyWith(
                color: _dueDate != null ? AppColors.onSurface : AppColors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: _submitting ? null : _submit,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _submitting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text('Add', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _submitting = true);
    await ref.read(taskActionsProvider.notifier).createTask(
          title: title,
          priority: _priority,
          dueDate: _dueDate,
        );
    if (!mounted) return;
    final actionState = ref.read(taskActionsProvider);
    setState(() => _submitting = false);
    if (!actionState.hasError) {
      Navigator.pop(context);
    }
  }

  Color _priorityColor() => switch (_priority) {
        TaskPriority.high => AppColors.priorityHigh,
        TaskPriority.medium => AppColors.priorityMedium,
        TaskPriority.low => AppColors.priorityLow,
        TaskPriority.none => AppColors.onSurfaceMuted,
      };

  String _priorityLabel() => switch (_priority) {
        TaskPriority.high => 'High',
        TaskPriority.medium => 'Medium',
        TaskPriority.low => 'Low',
        TaskPriority.none => 'Priority',
      };
}
