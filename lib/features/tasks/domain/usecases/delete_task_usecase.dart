import '../../../../core/error/result.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);
  final TaskRepository _repository;

  Future<Result<void>> execute(String taskId) =>
      _repository.deleteTask(taskId);
}