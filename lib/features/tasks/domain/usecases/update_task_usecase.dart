import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._repository);
  final TaskRepository _repository;

  Future<Result<TaskEntity>> execute(TaskEntity task) {
    if (task.title.trim().isEmpty) {
      return Future.value(Failure(const ValidationError('Title cannot be empty')));
    }
    return _repository.updateTask(task);
  }
}