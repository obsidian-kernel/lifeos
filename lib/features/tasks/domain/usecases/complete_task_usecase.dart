import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CompleteTaskUseCase {
  const CompleteTaskUseCase(this._repository);
  final TaskRepository _repository;

  Future<Result<TaskEntity>> execute(String taskId) async {
    final result = await _repository.getTaskById(taskId);
    return result.fold(
      onSuccess: (task) {
        if (task == null) {
          return Future.value(Failure(const NotFoundError('Task not found')));
        }
        final completed = task.copyWith(
          status: TaskStatus.done,
          completedAt: nowUtc(),
          updatedAt: nowUtc(),
        );
        return _repository.updateTask(completed);
      },
      onFailure: (error) => Future.value(Failure(error)),
    );
  }
}