import '../../../../core/error/result.dart';
import '../entities/project_entity.dart';
import '../repositories/task_repository.dart';

class GetProjectsUseCase {
  const GetProjectsUseCase(this._repository);
  final TaskRepository _repository;

  Future<Result<List<ProjectEntity>>> execute() => _repository.getProjects();
  Stream<List<ProjectEntity>> watch() => _repository.watchProjects();
}