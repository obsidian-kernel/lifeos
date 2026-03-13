import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../../../../core/database/app_database.dart' show TagsCompanion, TaskItem;
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/tag_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/repositories/task_repository.dart';
import '../daos/project_dao.dart';
import '../daos/task_dao.dart';
import '../models/task_mapper.dart';

// TaskItem is the Drift-generated data class for the TaskItems table.
// It is accessible via task_dao.dart → app_database.dart → task_table.dart.
// No direct import needed — it comes through the DAO's generated part file.

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required TaskDao taskDao,
    required ProjectDao projectDao,
  })  : _taskDao = taskDao,
        _projectDao = projectDao;

  final TaskDao _taskDao;
  final ProjectDao _projectDao;
  static const _uuid = Uuid();

  // ── Tasks ─────────────────────────────────────────────────────────────

  @override
  Future<Result<TaskEntity>> createTask(TaskEntity task) async {
    try {
      final now = nowUtc();
      final entity = task.copyWith(
        id: task.id.isEmpty ? _uuid.v4() : task.id,
        createdAt: now,
        updatedAt: now,
      );
      await _taskDao.attachedDatabase.transaction(() async {
        await _taskDao.insertTask(entity.toCompanion());
        for (final tagId in entity.tags) {
          await _taskDao.assignTag(entity.id, tagId);
        }
      });
      return Success(entity);
    } catch (e) {
      return Failure(DatabaseError('Failed to create task: $e'));
    }
  }

  @override
  Future<Result<TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final updated = task.copyWith(updatedAt: nowUtc());
      late final bool updatedRow;
      await _taskDao.attachedDatabase.transaction(() async {
        updatedRow = await _taskDao.updateTaskById(updated.toCompanion());
        if (!updatedRow) return;
        await _taskDao.removeAllTagsForTask(task.id);
        for (final tagId in updated.tags) {
          await _taskDao.assignTag(updated.id, tagId);
        }
      });
      if (!updatedRow) {
        return Failure(NotFoundError('Task not found: ${task.id}'));
      }
      return Success(updated);
    } catch (e) {
      return Failure(DatabaseError('Failed to update task: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    try {
      await _taskDao.softDeleteTask(id, nowUtc().millisecondsSinceEpoch);
      return Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to delete task: $e'));
    }
  }

  @override
  Future<Result<void>> restoreTask(String id) async {
    try {
      await _taskDao.restoreTask(id, nowUtc().millisecondsSinceEpoch);
      return Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to restore task: $e'));
    }
  }

  @override
  Future<Result<TaskEntity?>> getTaskById(String id) async {
    try {
      final row = await _taskDao.getTaskById(id);
      if (row == null) return Success(null);
      final tagIds = await _taskDao.getTagIdsForTask(id);
      return Success(row.toEntity(tags: tagIds));
    } catch (e) {
      return Failure(DatabaseError('Failed to get task: $e'));
    }
  }

  @override
  Future<Result<List<TaskEntity>>> getTasks(TaskFilter filter) async {
    try {
      final rows = await _taskDao.getActiveTasks(
        statusFilter: filter.status?.index,
        priorityFilter: filter.priority?.index,
        projectIdFilter: filter.projectId,
        parentTaskIdFilter: filter.parentTaskId,
        includeCompleted: filter.includeCompleted,
        includeDeleted: filter.includeDeleted,
        dueBefore: filter.dueBefore?.millisecondsSinceEpoch,
      );
      final tagMap =
          await _taskDao.getTagIdsForTasks(rows.map((r) => r.id).toList());
      final entities = await Future.wait(
        rows.map((row) async {
          return row.toEntity(tags: tagMap[row.id] ?? const []);
        }),
      );
      return Success(entities);
    } catch (e) {
      return Failure(DatabaseError('Failed to get tasks: $e'));
    }
  }

  @override
  Future<Result<List<TaskEntity>>> searchTasks(String query) async {
    try {
      if (query.trim().isEmpty) return Success([]);
      final ids = await _taskDao.searchTaskIds(query);
      if (ids.isEmpty) return Success([]);
      final rows = await _taskDao.getTasksByIds(ids);
      final orderedRows = <TaskItem>[];
      final byId = {for (final row in rows) row.id: row};
      for (final id in ids) {
        final row = byId[id];
        if (row != null && row.deletedAt == null) {
          orderedRows.add(row);
        }
      }
      final tagMap = await _taskDao.getTagIdsForTasks(ids);
      final results = orderedRows
          .map((row) => row.toEntity(tags: tagMap[row.id] ?? const []))
          .toList()
          .cast<TaskEntity>();
      return Success(results);
    } catch (e) {
      return Failure(DatabaseError('Search failed: $e'));
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasks(TaskFilter filter) {
    return _taskDao
        .watchActiveTasks(
          statusFilter: filter.status?.index,
          priorityFilter: filter.priority?.index,
          projectIdFilter: filter.projectId,
          includeCompleted: filter.includeCompleted,
        )
        .asyncMap((rows) async {
          final tagMap =
              await _taskDao.getTagIdsForTasks(rows.map((r) => r.id).toList());
          final entities = await Future.wait(
            rows.map((row) async {
              return row.toEntity(tags: tagMap[row.id] ?? const []);
            }),
          );
          return entities;
        });
  }

  @override
  Future<Result<void>> reorderTask(String id, int newSortOrder) async {
    try {
      await _taskDao.reorderTask(id, newSortOrder, nowUtc().millisecondsSinceEpoch);
      return Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to reorder: $e'));
    }
  }

  // ── Projects ──────────────────────────────────────────────────────────

  @override
  Future<Result<ProjectEntity>> createProject(ProjectEntity project) async {
    try {
      final entity = ProjectEntity(
        id: _uuid.v4(),
        name: project.name,
        color: project.color,
        sortOrder: project.sortOrder,
        createdAt: nowUtc(),
      );
      await _projectDao.insertProject(entity.toCompanion());
      return Success(entity);
    } catch (e) {
      return Failure(DatabaseError('Failed to create project: $e'));
    }
  }

  @override
  Future<Result<ProjectEntity>> updateProject(ProjectEntity project) async {
    try {
      await _projectDao.updateProjectById(project.toCompanion());
      return Success(project);
    } catch (e) {
      return Failure(DatabaseError('Failed to update project: $e'));
    }
  }

  @override
  Future<Result<List<ProjectEntity>>> getProjects() async {
    try {
      final rows = await _projectDao.getActiveProjects();
      return Success(rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Failure(DatabaseError('Failed to get projects: $e'));
    }
  }

  @override
  Stream<List<ProjectEntity>> watchProjects() {
    return _projectDao
        .watchActiveProjects()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  // ── Tags ──────────────────────────────────────────────────────────────

  @override
  Future<Result<TagEntity>> createTag(String name) async {
    try {
      final trimmed = name.trim();
      if (trimmed.isEmpty) {
        return Failure(const ValidationError('Tag name cannot be empty'));
      }
      final existing = await _projectDao.getTagByName(trimmed);
      if (existing != null) return Success(existing.toEntity());

      final companion = TagsCompanion(
        id: Value(_uuid.v4()),
        name: Value(trimmed),
        createdAt: Value(nowUtc().millisecondsSinceEpoch),
      );
      await _projectDao.insertTag(companion);
      final created = await _projectDao.getTagByName(trimmed);
      return Success(created!.toEntity());
    } catch (e) {
      return Failure(DatabaseError('Failed to create tag: $e'));
    }
  }

  @override
  Future<Result<List<TagEntity>>> getTags() async {
    try {
      final rows = await _projectDao.getAllTags();
      return Success(rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Failure(DatabaseError('Failed to get tags: $e'));
    }
  }

  @override
  Future<Result<void>> assignTag(String taskId, String tagId) async {
    try {
      await _taskDao.assignTag(taskId, tagId);
      return Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to assign tag: $e'));
    }
  }

  @override
  Future<Result<void>> removeTag(String taskId, String tagId) async {
    try {
      await _taskDao.removeTag(taskId, tagId);
      return Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to remove tag: $e'));
    }
  }
}
