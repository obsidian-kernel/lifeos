import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';
import 'task_detail_screen.dart';
import 'widgets/create_task_sheet.dart';
import 'widgets/task_filter_bar.dart';
import 'widgets/task_list_item.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width > 800;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isWide ? const _DesktopTaskLayout() : const _MobileTaskLayout(),
    );
  }
}

class _DesktopTaskLayout extends ConsumerWidget {
  const _DesktopTaskLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedTaskIdProvider);
    return Row(
      children: [
        Expanded(flex: 5, child: const _TaskListPane()),
        if (selectedId != null) ...[
          VerticalDivider(width: 1, color: AppColors.border),
          Expanded(flex: 4, child: TaskDetailScreen(taskId: selectedId)),
        ],
      ],
    );
  }
}

class _MobileTaskLayout extends ConsumerWidget {
  const _MobileTaskLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedTaskIdProvider);
    if (selectedId != null) return TaskDetailScreen(taskId: selectedId);
    return const _TaskListPane();
  }
}

class _TaskListPane extends ConsumerStatefulWidget {
  const _TaskListPane();

  @override
  ConsumerState<_TaskListPane> createState() => _TaskListPaneState();
}

class _TaskListPaneState extends ConsumerState<_TaskListPane> {
  bool _searchActive = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        const TaskFilterBar(),
        const Divider(height: 1, color: AppColors.border),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.surface,
      child: Row(
        children: [
          if (_searchActive)
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.onBackground),
                decoration: InputDecoration(
                  hintText: 'Search tasks…',
                  hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceMuted),
                  border: InputBorder.none,
                ),
                onChanged: (q) => ref.read(taskSearchQueryProvider.notifier).setQuery(q),
              ),
            )
          else ...[
            Text('Tasks', style: AppTypography.titleLarge.copyWith(color: AppColors.onBackground)),
            const Spacer(),
          ],
          IconButton(
            icon: Icon(
              _searchActive ? Icons.close : Icons.search,
              color: AppColors.onSurface,
              size: 20,
            ),
            onPressed: () {
              setState(() => _searchActive = !_searchActive);
              if (!_searchActive) {
                _searchController.clear();
                ref.read(taskSearchQueryProvider.notifier).clear();
              }
            },
          ),
          if (!_searchActive)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.accent, size: 22),
              onPressed: () => _showCreateSheet(context),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final query = ref.watch(taskSearchQueryProvider);
    if (query.isNotEmpty) return _buildSearchResults();
    return _buildTaskList();
  }

  Widget _buildSearchResults() {
    final results = ref.watch(taskSearchResultsProvider);
    return results.when(
      data: (tasks) => tasks.isEmpty
          ? _buildEmptyState('No results found')
          : _buildListView(tasks),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => _buildEmptyState('Search failed'),
    );
  }

  Widget _buildTaskList() {
    final tasks = ref.watch(taskListStreamProvider);
    return tasks.when(
      data: (list) => list.isEmpty
          ? _buildEmptyState('No tasks. Press + to add one.')
          : _buildGroupedList(list),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (e, _) => _buildEmptyState('Error loading tasks'),
    );
  }

  Widget _buildGroupedList(List<TaskEntity> tasks) {
    final active = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        ...active.map((t) => TaskListItem(task: t)),
        if (completed.isNotEmpty) ...[
          _buildSectionHeader('Completed (${completed.length})'),
          ...completed.map((t) => TaskListItem(task: t)),
        ],
      ],
    );
  }

  Widget _buildListView(List<TaskEntity> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (_, i) => TaskListItem(task: tasks[i]),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted)),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Text(msg, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceMuted)),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => const CreateTaskSheet(),
    );
  }
}