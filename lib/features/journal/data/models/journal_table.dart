import 'package:drift/drift.dart';

/// Stores daily journal entries.
class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  TextColumn get body => text()();
  IntColumn get mood => integer().nullable()(); // 1-5 scale
  TextColumn get moodLabel => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON array of strings
  TextColumn get weather => text().nullable()(); // JSON payload
  TextColumn get location => text().nullable()();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get entryDate => integer()(); // UTC midnight epoch ms
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
