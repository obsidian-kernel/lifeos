import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListStreamProvider);
    return tasks.when(
      data: (list) {
        final task = list.where((t) => t.id == taskId).firstOrNull;
        if (task == null) return const _EmptyDetail();
        return _TaskDetail(task: task);
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => const _EmptyDetail(),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Select a task',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceMuted),
        ),
      ),
    );
  }
}

class _TaskDetail extends ConsumerStatefulWidget {
  const _TaskDetail({required this.task});
  final TaskEntity task;

  @override
  ConsumerState<_TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends ConsumerState<_TaskDetail> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskPriority _priority;
  late TaskStatus _status;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _syncFromTask(widget.task);
  }

  @override
  void didUpdateWidget(_TaskDetail old) {
    super.didUpdateWidget(old);
    if (old.task.id != widget.task.id) {
      _titleController.dispose();
      _descController.dispose();
      _syncFromTask(widget.task);
    }
  }

  void _syncFromTask(TaskEntity task) {
    _titleController = TextEditingController(text: task.title);
    _descController = TextEditingController(text: task.description ?? '');
    _priority = task.priority;
    _status = task.status;
    _dueDate = task.dueDate?.toLocal();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      priority: _priority,
      status: _status,
      dueDate: _dueDate?.toUtc(),
      clearDueDate: _dueDate == null,
    );
    await ref.read(taskActionsProvider.notifier).updateTask(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 18, color: AppColors.onSurface),
          onPressed: () => ref.read(selectedTaskIdProvider.notifier).clear(),
        ),
        title: Text('Task', style: AppTypography.bodyLarge.copyWith(color: AppColors.onBackground)),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 20),
          _buildMetaRow('Priority', _buildPrioritySelector()),
          _buildMetaRow('Status', _buildStatusSelector()),
          _buildMetaRow('Due Date', _buildDueDateRow()),
          const SizedBox(height: 24),
          _buildDestructiveRow(),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      style: AppTypography.displayMedium.copyWith(color: AppColors.onBackground, fontSize: 20),
      decoration: InputDecoration(
        hintText: 'Task title',
        hintStyle: AppTypography.displayMedium.copyWith(
          color: AppColors.onSurfaceMuted,
          fontSize: 20,
        ),
        border: InputBorder.none,
      ),
      maxLines: null,
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descController,
      style: AppTypography.bodyLarge.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: 'Add description…',
        hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceMuted),
        border: InputBorder.none,
      ),
      maxLines: null,
    );
  }

  Widget _buildMetaRow(String label, Widget control) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted),
            ),
          ),
          control,
        ],
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return DropdownButton<TaskPriority>(
      value: _priority,
      dropdownColor: AppColors.surface,
      underline: const SizedBox.shrink(),
      style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
      items: TaskPriority.values
          .map((p) => DropdownMenuItem(
                value: p,
                child: Text(
                  p.name.toUpperCase(),
                  style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
                ),
              ))
          .toList(),
      onChanged: (p) => setState(() => _priority = p!),
    );
  }

  Widget _buildStatusSelector() {
    return DropdownButton<TaskStatus>(
      value: _status,
      dropdownColor: AppColors.surface,
      underline: const SizedBox.shrink(),
      style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
      items: TaskStatus.values
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text(
                  s.name.toUpperCase(),
                  style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
                ),
              ))
          .toList(),
      onChanged: (s) => setState(() => _status = s!),
    );
  }

  Widget _buildDueDateRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: _pickDate,
          child: Text(
            _dueDate != null
                ? DateFormat('MMM d, yyyy').format(_dueDate!)
                : 'Set due date',
            style: AppTypography.bodyMedium.copyWith(
              color: _dueDate != null ? AppColors.onSurface : AppColors.onSurfaceMuted,
            ),
          ),
        ),
        if (_dueDate != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _dueDate = null),
            child: const Icon(Icons.close, size: 14, color: AppColors.onSurfaceMuted),
          ),
        ],
      ],
    );
  }

  Widget _buildDestructiveRow() {
    return TextButton(
      onPressed: () {
        ref.read(taskActionsProvider.notifier).deleteTask(widget.task.id);
        ref.read(selectedTaskIdProvider.notifier).clear();
      },
      child: Text(
        'Delete Task',
        style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
}