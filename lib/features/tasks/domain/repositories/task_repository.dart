import '../../../../core/error/result.dart';
import '../entities/project_entity.dart';
import '../entities/tag_entity.dart';
import '../entities/task_entity.dart';
import '../entities/task_filter.dart';

abstract interface class TaskRepository {
  // ── Tasks ──────────────────────────────────────────────────────────────
  Future<Result<TaskEntity>> createTask(TaskEntity task);
  Future<Result<TaskEntity>> updateTask(TaskEntity task);

  /// Soft delete — sets deletedAt, does not remove row.
  Future<Result<void>> deleteTask(String id);

  /// Clears deletedAt, restoring the task to active state.
  Future<Result<void>> restoreTask(String id);

  Future<Result<TaskEntity?>> getTaskById(String id);
  Future<Result<List<TaskEntity>>> getTasks(TaskFilter filter);
  Future<Result<List<TaskEntity>>> searchTasks(String query);
  Stream<List<TaskEntity>> watchTasks(TaskFilter filter);
  Future<Result<void>> reorderTask(String id, int newSortOrder);

  // ── Projects ───────────────────────────────────────────────────────────
  Future<Result<ProjectEntity>> createProject(ProjectEntity project);
  Future<Result<ProjectEntity>> updateProject(ProjectEntity project);
  Future<Result<List<ProjectEntity>>> getProjects();
  Stream<List<ProjectEntity>> watchProjects();

  // ── Tags ───────────────────────────────────────────────────────────────
  Future<Result<TagEntity>> createTag(String name);
  Future<Result<List<TagEntity>>> getTags();
  Future<Result<void>> assignTag(String taskId, String tagId);
  Future<Result<void>> removeTag(String taskId, String tagId);
}