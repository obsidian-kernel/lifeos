import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/tag_table.dart';
import '../models/task_table.dart';
import '../models/task_tag_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [TaskItems, Tags, TaskTags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Stream<List<TaskItem>> watchActiveTasks({
    int? statusFilter,
    int? priorityFilter,
    String? projectIdFilter,
    bool includeCompleted = true,
  }) {
    return (select(taskItems)
          ..where((t) {
            Expression<bool> expr = t.deletedAt.isNull();
            if (!includeCompleted) {
              expr = expr & t.status.isSmallerThanValue(2);
            }
            if (statusFilter != null) {
              expr = expr & t.status.equals(statusFilter);
            }
            if (priorityFilter != null) {
              expr = expr & t.priority.equals(priorityFilter);
            }
            if (projectIdFilter != null) {
              expr = expr & t.projectId.equals(projectIdFilter);
            }
            return expr;
          })
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  Future<List<TaskItem>> getActiveTasks({
    int? statusFilter,
    int? priorityFilter,
    String? projectIdFilter,
    String? parentTaskIdFilter,
    bool includeCompleted = true,
    bool includeDeleted = false,
    int? dueBefore,
  }) {
    return (select(taskItems)
          ..where((t) {
            Expression<bool> expr = const Constant(true);
            if (!includeDeleted) {
              expr = expr & t.deletedAt.isNull();
            }
            if (!includeCompleted) {
              expr = expr & t.status.isSmallerThanValue(2);
            }
            if (statusFilter != null) {
              expr = expr & t.status.equals(statusFilter);
            }
            if (priorityFilter != null) {
              expr = expr & t.priority.equals(priorityFilter);
            }
            if (projectIdFilter != null) {
              expr = expr & t.projectId.equals(projectIdFilter);
            }
            if (parentTaskIdFilter != null) {
              expr = expr & t.parentTaskId.equals(parentTaskIdFilter);
            }
            if (dueBefore != null) {
              expr = expr &
                  t.dueDate.isNotNull() &
                  t.dueDate.isSmallerOrEqualValue(dueBefore);
            }
            return expr;
          })
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  Future<TaskItem?> getTaskById(String id) =>
      (select(taskItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// FTS5 search — sole justified use of raw SQL in the codebase.
  Future<List<String>> searchTaskIds(String query) async {
    final sanitized = query.trim().replaceAll("'", "''");
    final rows = await customSelect(
      "SELECT t.id AS id "
      "FROM tasks_fts f "
      "JOIN task_items t ON t.rowid = f.rowid "
      "WHERE tasks_fts MATCH '$sanitized*' "
      "ORDER BY rank LIMIT 100",
      readsFrom: {taskItems},
    ).get();
    return rows.map((r) => r.read<String>('id')).toList();
  }

  Future<List<TaskItem>> getTasksByIds(List<String> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(taskItems)..where((t) => t.id.isIn(ids))).get();
  }

  Future<void> insertTask(TaskItemsCompanion companion) =>
      into(taskItems).insert(companion);

  Future<bool> updateTaskById(TaskItemsCompanion companion) =>
      update(taskItems).replace(companion);

  Future<void> softDeleteTask(String id, int deletedAtMs) =>
      (update(taskItems)..where((t) => t.id.equals(id))).write(
        TaskItemsCompanion(
          deletedAt: Value(deletedAtMs),
          updatedAt: Value(deletedAtMs),
        ),
      );

  Future<void> restoreTask(String id, int updatedAtMs) =>
      (update(taskItems)..where((t) => t.id.equals(id))).write(
        TaskItemsCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(updatedAtMs),
        ),
      );

  Future<void> reorderTask(String id, int newSortOrder, int updatedAtMs) =>
      (update(taskItems)..where((t) => t.id.equals(id))).write(
        TaskItemsCompanion(
          sortOrder: Value(newSortOrder),
          updatedAt: Value(updatedAtMs),
        ),
      );

  Future<List<String>> getTagIdsForTask(String taskId) async {
    final rows =
        await (select(taskTags)..where((t) => t.taskId.equals(taskId))).get();
    return rows.map((r) => r.tagId).toList();
  }

  Future<Map<String, List<String>>> getTagIdsForTasks(List<String> taskIds) async {
    if (taskIds.isEmpty) return const {};
    final rows = await (select(taskTags)..where((t) => t.taskId.isIn(taskIds))).get();
    final map = <String, List<String>>{};
    for (final row in rows) {
      (map[row.taskId] ??= <String>[]).add(row.tagId);
    }
    return map;
  }

  Future<List<Tag>> getTagsForTask(String taskId) async {
    final tagIds = await getTagIdsForTask(taskId);
    if (tagIds.isEmpty) return [];
    return (select(tags)..where((t) => t.id.isIn(tagIds))).get();
  }

  Future<void> assignTag(String taskId, String tagId) =>
      into(taskTags).insertOnConflictUpdate(
        TaskTagsCompanion(
          taskId: Value(taskId),
          tagId: Value(tagId),
        ),
      );

  Future<void> removeTag(String taskId, String tagId) =>
      (delete(taskTags)
            ..where((t) => t.taskId.equals(taskId) & t.tagId.equals(tagId)))
          .go();

  Future<void> removeAllTagsForTask(String taskId) =>
      (delete(taskTags)..where((t) => t.taskId.equals(taskId))).go();
}
