import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/journal_table.dart';

part 'journal_dao.g.dart';

@DriftAccessor(tables: [JournalEntries])
class JournalDao extends DatabaseAccessor<AppDatabase> with _$JournalDaoMixin {
  JournalDao(super.db);

  Stream<List<JournalEntry>> watchEntries() => (select(journalEntries)
        ..orderBy([(e) => OrderingTerm.desc(e.entryDate)])
        ..orderBy([(e) => OrderingTerm.desc(e.updatedAt)]))
      .watch();

  Future<List<JournalEntry>> getEntriesInRange(
      int startEpochMs, int endEpochMs) {
    return (select(journalEntries)
          ..where((e) =>
              e.entryDate.isBiggerOrEqualValue(startEpochMs) &
              e.entryDate.isSmallerOrEqualValue(endEpochMs))
          ..orderBy([(e) => OrderingTerm.desc(e.entryDate)]))
        .get();
  }

  Future<JournalEntry?> getByEntryDate(int entryDate) {
    return (select(journalEntries)
          ..where((e) => e.entryDate.equals(entryDate)))
        .getSingleOrNull();
  }

  Future<void> upsertEntry(JournalEntriesCompanion companion) =>
      into(journalEntries).insertOnConflictUpdate(companion);

  Future<void> deleteEntry(String id) =>
      (delete(journalEntries)..where((e) => e.id.equals(id))).go();

  Future<List<JournalEntry>> search(String query) async {
    final sanitized = query.trim().replaceAll("'", "''");
    if (sanitized.isEmpty) return const [];
    final rows = await customSelect(
      "SELECT j.* FROM journal_entries j "
      "JOIN journal_fts f ON j.rowid = f.rowid "
      "WHERE journal_fts MATCH '$sanitized*' "
      "ORDER BY rank;",
      readsFrom: {journalEntries},
    ).get();
    return rows
        .map(
          (row) => JournalEntry(
            id: row.read<String>('id'),
            title: row.readNullable<String>('title'),
            body: row.read<String>('body'),
            mood: row.readNullable<int>('mood'),
            moodLabel: row.readNullable<String>('mood_label'),
            tags: row.readNullable<String>('tags'),
            weather: row.readNullable<String>('weather'),
            location: row.readNullable<String>('location'),
            wordCount: row.read<int>('word_count'),
            isPinned: row.read<bool>('is_pinned'),
            entryDate: row.read<int>('entry_date'),
            createdAt: row.read<int>('created_at'),
            updatedAt: row.read<int>('updated_at'),
          ),
        )
        .toList();
  }
}
