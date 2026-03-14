import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/journal_entry.dart';

extension JournalRowToEntity on JournalEntry {
  JournalEntryEntity toEntity() {
    return JournalEntryEntity(
      id: id,
      title: title,
      body: body,
      mood: mood,
      moodLabel: moodLabel,
      tags: parseStringList(tags),
      weatherJson: weather,
      location: location,
      wordCount: wordCount,
      isPinned: isPinned,
      entryDate: DateTime.fromMillisecondsSinceEpoch(entryDate, isUtc: true),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt, isUtc: true),
    );
  }
}

extension JournalEntityToCompanion on JournalEntryEntity {
  JournalEntriesCompanion toCompanion() {
    return JournalEntriesCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      mood: Value(mood),
      moodLabel: Value(moodLabel),
      tags: Value(tags.isEmpty ? null : toJsonString(tags)),
      weather: Value(weatherJson),
      location: Value(location),
      wordCount: Value(wordCount),
      isPinned: Value(isPinned),
      entryDate: Value(entryDate.toUtc().millisecondsSinceEpoch),
      createdAt: Value(createdAt.toUtc().millisecondsSinceEpoch),
      updatedAt: Value(updatedAt.toUtc().millisecondsSinceEpoch),
    );
  }
}
