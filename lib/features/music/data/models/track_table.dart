import 'package:drift/drift.dart';

/// Stores indexed audio tracks.
/// path has a UNIQUE constraint — prevents duplicate indexing.
/// isAvailable is updated during reconciliation runs.
class Tracks extends Table {
  TextColumn get id => text()();
  TextColumn get path => text().unique()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get albumArtist => text().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get year => integer().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get extension => text()();
  BoolColumn get isAvailable =>
      boolean().withDefault(const Constant(true))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  IntColumn get lastPlayedAt => integer().nullable()();
  IntColumn get lastPositionMs => integer().withDefault(const Constant(0))();
  IntColumn get indexedAt => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get artworkPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
