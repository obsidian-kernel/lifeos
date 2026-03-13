import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);
  final TaskRepository _repository;

  Future<Result<TaskEntity>> execute({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.none,
    DateTime? dueDate,
    String? projectId,
    String? parentTaskId,
    List<String> tags = const [],
    int sortOrder = 0,
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return Future.value(Failure(const ValidationError('Title cannot be empty')));
    }
    final now = nowUtc();
    final task = TaskEntity(
      id: '',
      title: trimmed,
      description: description?.trim(),
      priority: priority,
      status: TaskStatus.todo,
      dueDate: dueDate?.toUtc(),
      projectId: projectId,
      parentTaskId: parentTaskId,
      tags: tags,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.createTask(task);
  }
}