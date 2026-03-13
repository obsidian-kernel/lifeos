import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/tasks/data/daos/project_dao.dart';
import '../../features/tasks/data/daos/task_dao.dart';
import '../../features/tasks/data/models/project_table.dart';
import '../../features/tasks/data/models/tag_table.dart';
import '../../features/tasks/data/models/task_table.dart';
import '../../features/tasks/data/models/task_tag_table.dart';
import 'migrations/migration_strategy.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [TaskItems, Projects, Tags, TaskTags],
  daos: [TaskDao, ProjectDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openProductionConnection());
  AppDatabase.forTesting() : super(_openTestingConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);

  static QueryExecutor _openProductionConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'lifeos.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  static QueryExecutor _openTestingConnection() {
    return NativeDatabase.memory();
  }
}