import 'package:drift/drift.dart';

import '../app_database.dart';

MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createFts5(db);
      await _createIndexes(db);
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(db.taskItems);
        await m.createTable(db.projects);
        await m.createTable(db.tags);
        await m.createTable(db.taskTags);
        await _createFts5(db);
        await _createIndexes(db);
      }
    },
    beforeOpen: (details) async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await db.customStatement('PRAGMA journal_mode = WAL');
      await db.customStatement('PRAGMA synchronous = NORMAL');
      await db.customStatement('PRAGMA cache_size = -8000'); // 8MB
      await db.customStatement('PRAGMA temp_store = MEMORY');
    },
  );
}

Future<void> _createFts5(AppDatabase db) async {
  await db.customStatement('''
    CREATE VIRTUAL TABLE IF NOT EXISTS tasks_fts
    USING fts5(
      title,
      description,
      content=task_items,
      content_rowid=rowid
    )
  ''');

  // Triggers to keep FTS index in sync
  await db.customStatement('''
    CREATE TRIGGER IF NOT EXISTS tasks_fts_insert
    AFTER INSERT ON task_items BEGIN
      INSERT INTO tasks_fts(rowid, title, description)
      VALUES (new.rowid, new.title, new.description);
    END
  ''');

  await db.customStatement('''
    CREATE TRIGGER IF NOT EXISTS tasks_fts_update
    AFTER UPDATE ON task_items BEGIN
      INSERT INTO tasks_fts(tasks_fts, rowid, title, description)
      VALUES ('delete', old.rowid, old.title, old.description);
      INSERT INTO tasks_fts(rowid, title, description)
      VALUES (new.rowid, new.title, new.description);
    END
  ''');

  await db.customStatement('''
    CREATE TRIGGER IF NOT EXISTS tasks_fts_delete
    AFTER DELETE ON task_items BEGIN
      INSERT INTO tasks_fts(tasks_fts, rowid, title, description)
      VALUES ('delete', old.rowid, old.title, old.description);
    END
  ''');
}

Future<void> _createIndexes(AppDatabase db) async {
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_tasks_status ON task_items(status)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON task_items(due_date)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON task_items(project_id)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_tasks_parent_task_id ON task_items(parent_task_id)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_tasks_deleted_at ON task_items(deleted_at)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_tasks_sort_order ON task_items(sort_order)',
  );
}