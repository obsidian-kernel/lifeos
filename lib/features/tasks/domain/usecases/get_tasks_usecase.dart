import '../../../../core/error/result.dart';
import '../entities/task_entity.dart';
import '../entities/task_filter.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  const GetTasksUseCase(this._repository);
  final TaskRepository _repository;

  Future<Result<List<TaskEntity>>> execute(TaskFilter filter) =>
      _repository.getTasks(filter);

  Stream<List<TaskEntity>> watch(TaskFilter filter) =>
      _repository.watchTasks(filter);
}