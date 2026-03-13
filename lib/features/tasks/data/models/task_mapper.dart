import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/tag_entity.dart';
import '../../domain/entities/task_entity.dart';

extension TaskItemToEntity on TaskItem {
  TaskEntity toEntity({List<String> tags = const []}) {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      priority: TaskPriority.values[priority],
      status: TaskStatus.values[status],
      dueDate: dueDate != null
          ? DateTime.fromMillisecondsSinceEpoch(dueDate!, isUtc: true)
          : null,
      projectId: projectId,
      parentTaskId: parentTaskId,
      recurrenceRule: recurrenceRule,
      tags: tags,
      sortOrder: sortOrder,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt, isUtc: true),
      completedAt: completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(completedAt!, isUtc: true)
          : null,
      deletedAt: deletedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(deletedAt!, isUtc: true)
          : null,
    );
  }
}

extension TaskEntityToCompanion on TaskEntity {
  TaskItemsCompanion toCompanion() {
    return TaskItemsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      priority: Value(priority.index),
      status: Value(status.index),
      dueDate: Value(dueDate?.millisecondsSinceEpoch),
      projectId: Value(projectId),
      parentTaskId: Value(parentTaskId),
      recurrenceRule: Value(recurrenceRule),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      updatedAt: Value(updatedAt.millisecondsSinceEpoch),
      completedAt: Value(completedAt?.millisecondsSinceEpoch),
      deletedAt: Value(deletedAt?.millisecondsSinceEpoch),
    );
  }
}

// Drift generates: Projects table → Project data class
extension ProjectToEntity on Project {
  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      name: name,
      color: color,
      sortOrder: sortOrder,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
      archivedAt: archivedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(archivedAt!, isUtc: true)
          : null,
    );
  }
}

extension ProjectEntityToCompanion on ProjectEntity {
  ProjectsCompanion toCompanion() {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      archivedAt: Value(archivedAt?.millisecondsSinceEpoch),
    );
  }
}

// Drift generates: Tags table → Tag data class
extension TagToEntity on Tag {
  TagEntity toEntity() {
    return TagEntity(
      id: id,
      name: name,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
    );
  }
}