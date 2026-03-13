import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../entities/project_entity.dart';
import '../repositories/task_repository.dart';

class CreateProjectUseCase {
  const CreateProjectUseCase(this._repository);
  final TaskRepository _repository;

  Future<Result<ProjectEntity>> execute({
    required String name,
    required int color,
    int sortOrder = 0,
  }) {
    if (name.trim().isEmpty) {
      return Future.value(Failure(const ValidationError('Project name cannot be empty')));
    }
    final project = ProjectEntity(
      id: '',
      name: name.trim(),
      color: color,
      sortOrder: sortOrder,
      createdAt: nowUtc(),
    );
    return _repository.createProject(project);
  }
}