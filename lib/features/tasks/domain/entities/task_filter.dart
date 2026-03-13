import 'task_entity.dart';
import '../../../../core/utils/datetime_utils.dart';

/// Value object — immutable filter descriptor.
/// Null field = no filter applied on that dimension.
class TaskFilter {
  const TaskFilter({
    this.status,
    this.priority,
    this.projectId,
    this.tagId,
    this.dueBefore,
    this.includeDeleted = false,
    this.includeCompleted = true,
    this.parentTaskId,
  });

  final TaskStatus? status;
  final TaskPriority? priority;
  final String? projectId;
  final String? tagId;
  final DateTime? dueBefore;
  final bool includeDeleted;
  final bool includeCompleted;
  final String? parentTaskId;   // null = top-level only if combined with parentTaskId filter

  static const TaskFilter inbox = TaskFilter(
    includeDeleted: false,
    includeCompleted: false,
  );

  static TaskFilter get today => TaskFilter(
        includeDeleted: false,
        includeCompleted: false,
        dueBefore: DateTime.now().toEndOfDayUtc(),
      );

  TaskFilter copyWith({
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    String? tagId,
    DateTime? dueBefore,
    bool? includeDeleted,
    bool? includeCompleted,
    String? parentTaskId,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearProjectId = false,
    bool clearTagId = false,
    bool clearDueBefore = false,
    bool clearParentTaskId = false,
  }) {
    return TaskFilter(
      status: clearStatus ? null : status ?? this.status,
      priority: clearPriority ? null : priority ?? this.priority,
      projectId: clearProjectId ? null : projectId ?? this.projectId,
      tagId: clearTagId ? null : tagId ?? this.tagId,
      dueBefore: clearDueBefore ? null : dueBefore ?? this.dueBefore,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      includeCompleted: includeCompleted ?? this.includeCompleted,
      parentTaskId:
          clearParentTaskId ? null : parentTaskId ?? this.parentTaskId,
    );
  }
}
