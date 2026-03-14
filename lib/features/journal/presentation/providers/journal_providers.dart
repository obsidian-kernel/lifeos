import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../../../../shared/providers/core_providers.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';

part 'journal_providers.g.dart';

@Riverpod(keepAlive: true)
JournalRepository journalRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return JournalRepositoryImpl(db.journalDao);
}

@riverpod
class JournalSearchQuery extends _$JournalSearchQuery {
  @override
  String build() => '';
  void set(String q) => state = q;
  void clear() => state = '';
}

@riverpod
Stream<List<JournalEntryEntity>> journalEntries(Ref ref) {
  final repo = ref.watch(journalRepositoryProvider);
  final query = ref.watch(journalSearchQueryProvider);
  if (query.isEmpty) {
    return repo.watchEntries();
  }
  return repo.watchEntries().map((list) {
    final q = query.toLowerCase();
    return list
        .where((e) =>
            (e.title ?? '').toLowerCase().contains(q) ||
            e.body.toLowerCase().contains(q))
        .toList();
  });
}

@riverpod
class JournalEditor extends _$JournalEditor {
  @override
  void build() {}

  JournalRepository get _repo => ref.read(journalRepositoryProvider);

  Future<Result<void>> save({
    String? id,
    required String body,
    String? title,
    int? mood,
    String? moodLabel,
    List<String> tags = const [],
    String? weatherJson,
    String? location,
    bool isPinned = false,
    DateTime? entryDate,
    DateTime? createdAt,
  }) async {
    if (body.trim().isEmpty) {
      return Failure(const ValidationError('Entry body cannot be empty'));
    }
    final builder = _repo as JournalRepositoryImpl;
    final entry = builder.buildEntry(
      existingId: id,
      title: title,
      body: body,
      mood: mood,
      moodLabel: moodLabel,
      tags: tags,
      weatherJson: weatherJson,
      location: location,
      isPinned: isPinned,
      entryDate: entryDate,
      createdAt: createdAt,
    );
    return _repo.upsert(entry);
  }

  Future<Result<void>> delete(String id) => _repo.delete(id);
}
