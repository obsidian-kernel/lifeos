import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/core_providers.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/search_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

part 'task_providers.g.dart';

// ── Repository ────────────────────────────────────────────────────────────

@riverpod
TaskRepository taskRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TaskRepositoryImpl(
    taskDao: db.taskDao,
    projectDao: db.projectDao,
  );
}

// ── Use Cases ─────────────────────────────────────────────────────────────

@riverpod
CreateTaskUseCase createTaskUseCase(Ref ref) =>
    CreateTaskUseCase(ref.watch(taskRepositoryProvider));

@riverpod
UpdateTaskUseCase updateTaskUseCase(Ref ref) =>
    UpdateTaskUseCase(ref.watch(taskRepositoryProvider));

@riverpod
CompleteTaskUseCase completeTaskUseCase(Ref ref) =>
    CompleteTaskUseCase(ref.watch(taskRepositoryProvider));

@riverpod
DeleteTaskUseCase deleteTaskUseCase(Ref ref) =>
    DeleteTaskUseCase(ref.watch(taskRepositoryProvider));

@riverpod
GetTasksUseCase getTasksUseCase(Ref ref) =>
    GetTasksUseCase(ref.watch(taskRepositoryProvider));

@riverpod
SearchTasksUseCase searchTasksUseCase(Ref ref) =>
    SearchTasksUseCase(ref.watch(taskRepositoryProvider));

@riverpod
CreateProjectUseCase createProjectUseCase(Ref ref) =>
    CreateProjectUseCase(ref.watch(taskRepositoryProvider));

@riverpod
GetProjectsUseCase getProjectsUseCase(Ref ref) =>
    GetProjectsUseCase(ref.watch(taskRepositoryProvider));

// ── State: Active Filter ──────────────────────────────────────────────────

@riverpod
class ActiveTaskFilter extends _$ActiveTaskFilter {
  @override
  TaskFilter build() => TaskFilter.inbox;

  void setFilter(TaskFilter filter) => state = filter;
  void setProjectId(String? projectId) =>
      state = state.copyWith(projectId: projectId);
  void setStatus(TaskStatus? status) =>
      state = state.copyWith(status: status);
  void setPriority(TaskPriority? priority) =>
      state = state.copyWith(priority: priority);
  void clearFilters() => state = TaskFilter.inbox;
}

// ── State: Search ─────────────────────────────────────────────────────────

@riverpod
class TaskSearchQuery extends _$TaskSearchQuery {
  @override
  String build() => '';
  void setQuery(String q) => state = q;
  void clear() => state = '';
}

// ── Stream: Task List ─────────────────────────────────────────────────────

@riverpod
Stream<List<TaskEntity>> taskListStream(Ref ref) {
  final filter = ref.watch(activeTaskFilterProvider);
  final useCase = ref.watch(getTasksUseCaseProvider);
  return useCase.watch(filter);
}

// ── Async: Search Results ─────────────────────────────────────────────────

@riverpod
Future<List<TaskEntity>> taskSearchResults(Ref ref) async {
  final query = ref.watch(taskSearchQueryProvider);
  if (query.isEmpty) return [];
  final useCase = ref.watch(searchTasksUseCaseProvider);
  final result = await useCase.execute(query);
  return result.fold(onSuccess: (tasks) => tasks, onFailure: (_) => []);
}

// ── Stream: Projects ──────────────────────────────────────────────────────

@riverpod
Stream<List<ProjectEntity>> projectListStream(Ref ref) {
  final useCase = ref.watch(getProjectsUseCaseProvider);
  return useCase.watch();
}

// ── State: Selected Task ID (for detail panel) ────────────────────────────

@riverpod
class SelectedTaskId extends _$SelectedTaskId {
  @override
  String? build() => null;
  void select(String id) => state = id;
  void clear() => state = null;
}

// ── Async: Task Actions (exposed for UI) ──────────────────────────────────

@riverpod
class TaskActions extends _$TaskActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> createTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.none,
    DateTime? dueDate,
    String? projectId,
    List<String> tags = const [],
  }) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(createTaskUseCaseProvider);
    final result = await useCase.execute(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      projectId: projectId,
      tags: tags,
    );
    state = result.fold(
      onSuccess: (_) => const AsyncValue.data(null),
      onFailure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  Future<void> completeTask(String id) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(completeTaskUseCaseProvider);
    final result = await useCase.execute(id);
    state = result.fold(
      onSuccess: (_) => const AsyncValue.data(null),
      onFailure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(deleteTaskUseCaseProvider);
    final result = await useCase.execute(id);
    state = result.fold(
      onSuccess: (_) => const AsyncValue.data(null),
      onFailure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  Future<void> updateTask(TaskEntity task) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(updateTaskUseCaseProvider);
    final result = await useCase.execute(task);
    state = result.fold(
      onSuccess: (_) => const AsyncValue.data(null),
      onFailure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }
}
