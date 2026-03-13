import 'package:equatable/equatable.dart';

enum TaskPriority { none, low, medium, high }
enum TaskStatus { todo, inProgress, done, archived }

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    this.projectId,
    this.parentTaskId,
    this.recurrenceRule,
    required this.tags,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.deletedAt,
  });

  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;       // UTC
  final String? projectId;
  final String? parentTaskId;
  final String? recurrenceRule;
  final List<String> tags;       // tag IDs
  final int sortOrder;
  final DateTime createdAt;      // UTC
  final DateTime updatedAt;      // UTC
  final DateTime? completedAt;   // UTC
  final DateTime? deletedAt;     // UTC — null means not deleted

  bool get isDeleted => deletedAt != null;
  bool get isCompleted => status == TaskStatus.done;
  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now().toUtc()) &&
      !isCompleted;

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    String? projectId,
    String? parentTaskId,
    String? recurrenceRule,
    List<String>? tags,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? deletedAt,
    bool clearDueDate = false,
    bool clearProjectId = false,
    bool clearParentTaskId = false,
    bool clearCompletedAt = false,
    bool clearDeletedAt = false,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      projectId: clearProjectId ? null : projectId ?? this.projectId,
      parentTaskId: clearParentTaskId ? null : parentTaskId ?? this.parentTaskId,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, title, description, priority, status, dueDate,
        projectId, parentTaskId, recurrenceRule, tags, sortOrder,
        createdAt, updatedAt, completedAt, deletedAt,
      ];
}