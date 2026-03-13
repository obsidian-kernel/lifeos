import '../../../../core/error/result.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class SearchTasksUseCase {
  const SearchTasksUseCase(this._repository);
  final TaskRepository _repository;

  Future<Result<List<TaskEntity>>> execute(String query) =>
      _repository.searchTasks(query);
}