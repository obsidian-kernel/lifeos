import 'package:uuid/uuid.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../daos/journal_dao.dart';
import '../models/journal_mapper.dart';

class JournalRepositoryImpl implements JournalRepository {
  JournalRepositoryImpl(this._dao);

  final JournalDao _dao;
  static const _uuid = Uuid();

  @override
  Stream<List<JournalEntryEntity>> watchEntries() {
    return _dao.watchEntries().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  @override
  Future<Result<List<JournalEntryEntity>>> search(String query) async {
    try {
      final rows = await _dao.search(query);
      return Success(rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Failure(DatabaseError('Search failed: $e'));
    }
  }

  @override
  Future<Result<JournalEntryEntity?>> getByDate(DateTime entryDate) async {
    try {
      final utc = entryDate.toStartOfDayUtc();
      final row = await _dao.getByEntryDate(utc.millisecondsSinceEpoch);
      return Success(row?.toEntity());
    } catch (e) {
      return Failure(DatabaseError('Fetch failed: $e'));
    }
  }

  @override
  Future<Result<void>> upsert(JournalEntryEntity entry) async {
    try {
      await _dao.upsertEntry(entry.toCompanion());
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseError('Save failed: $e'));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dao.deleteEntry(id);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseError('Delete failed: $e'));
    }
  }

  /// Convenience factory to build an entry for today (one per day).
  JournalEntryEntity buildEntry({
    String? existingId,
    String? title,
    required String body,
    int? mood,
    String? moodLabel,
    List<String> tags = const [],
    String? weatherJson,
    String? location,
    bool isPinned = false,
    DateTime? entryDate,
    DateTime? createdAt,
  }) {
    final now = nowUtc();
    final date = (entryDate ?? now).toStartOfDayUtc();
    return JournalEntryEntity(
      id: existingId ?? _uuid.v4(),
      title: (title ?? '').trim().isEmpty ? null : title?.trim(),
      body: body,
      mood: mood,
      moodLabel: moodLabel,
      tags: tags,
      weatherJson: weatherJson,
      location: location,
      wordCount: _wordCount(body),
      isPinned: isPinned,
      entryDate: date,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
  }

  int _wordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\\s+')).length;
  }
}
