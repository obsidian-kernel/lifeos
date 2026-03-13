import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/project_table.dart';
import '../models/tag_table.dart';

part 'project_dao.g.dart';

@DriftAccessor(tables: [Projects, Tags])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  Future<List<Project>> getActiveProjects() =>
      (select(projects)
            ..where((p) => p.archivedAt.isNull())
            ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
          .get();

  Stream<List<Project>> watchActiveProjects() =>
      (select(projects)
            ..where((p) => p.archivedAt.isNull())
            ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
          .watch();

  Future<void> insertProject(ProjectsCompanion companion) =>
      into(projects).insert(companion);

  Future<bool> updateProjectById(ProjectsCompanion companion) =>
      update(projects).replace(companion);

  Future<List<Tag>> getAllTags() =>
      (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<Tag?> getTagByName(String name) =>
      (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();

  Future<void> insertTag(TagsCompanion companion) =>
      into(tags).insertOnConflictUpdate(companion);
}