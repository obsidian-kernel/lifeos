import 'package:drift/drift.dart';
import '../app_database.dart';

MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createTaskFts5(db);
      await _createTaskIndexes(db);
      await _createMusicFts5(db);
      await _createMusicIndexes(db);
    },
    onUpgrade: (m, from, to) async {
      // V1→V2: Initial task tables
      if (from < 2) {
        await m.createTable(db.taskItems);
        await m.createTable(db.projects);
        await m.createTable(db.tags);
        await m.createTable(db.taskTags);
        await _createTaskFts5(db);
        await _createTaskIndexes(db);
      }
      // V2→V3: Music tables
      if (from < 3) {
        await m.createTable(db.tracks);
        await m.createTable(db.playlists);
        await m.createTable(db.playlistTracks);
        await _createMusicFts5(db);
        await _createMusicIndexes(db);
      }
    },
    beforeOpen: (details) async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await db.customStatement('PRAGMA journal_mode = WAL');
      await db.customStatement('PRAGMA synchronous = NORMAL');
      await db.customStatement('PRAGMA cache_size = -8000');
      await db.customStatement('PRAGMA temp_store = MEMORY');
    },
  );
}

// ── Tasks FTS5 ─────────────────────────────────────────────────────────────

Future<void> _createTaskFts5(AppDatabase db) async {
  await db.customStatement('''
    CREATE VIRTUAL TABLE IF NOT EXISTS tasks_fts
    USING fts5(
      title, description,
      content=task_items,
      content_rowid=rowid
    )
  ''');
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

Future<void> _createTaskIndexes(AppDatabase db) async {
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tasks_status ON task_items(status)');
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON task_items(due_date)');
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON task_items(project_id)');
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tasks_parent_task_id ON task_items(parent_task_id)');
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tasks_deleted_at ON task_items(deleted_at)');
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tasks_sort_order ON task_items(sort_order)');
}

// ── Music FTS5 ─────────────────────────────────────────────────────────────

Future<void> _createMusicFts5(AppDatabase db) async {
  await db.customStatement('''
    CREATE VIRTUAL TABLE IF NOT EXISTS tracks_fts
    USING fts5(
      title, artist, album,
      content=tracks,
      content_rowid=rowid
    )
  ''');
  await db.customStatement('''
    CREATE TRIGGER IF NOT EXISTS tracks_fts_insert
    AFTER INSERT ON tracks BEGIN
      INSERT INTO tracks_fts(rowid, title, artist, album)
      VALUES (new.rowid, new.title, new.artist, new.album);
    END
  ''');
  await db.customStatement('''
    CREATE TRIGGER IF NOT EXISTS tracks_fts_update
    AFTER UPDATE ON tracks BEGIN
      INSERT INTO tracks_fts(tracks_fts, rowid, title, artist, album)
      VALUES ('delete', old.rowid, old.title, old.artist, old.album);
      INSERT INTO tracks_fts(rowid, title, artist, album)
      VALUES (new.rowid, new.title, new.artist, new.album);
    END
  ''');
  await db.customStatement('''
    CREATE TRIGGER IF NOT EXISTS tracks_fts_delete
    AFTER DELETE ON tracks BEGIN
      INSERT INTO tracks_fts(tracks_fts, rowid, title, artist, album)
      VALUES ('delete', old.rowid, old.title, old.artist, old.album);
    END
  ''');
}

Future<void> _createMusicIndexes(AppDatabase db) async {
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_artist ON tracks(artist)');
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_album ON tracks(album)');
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_is_available ON tracks(is_available)');
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_last_played ON tracks(last_played_at)');
  await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_playlist_tracks_playlist_id ON playlist_tracks(playlist_id)');
}