import '../../../../core/error/result.dart';
import '../entities/journal_entry.dart';

abstract interface class JournalRepository {
  Stream<List<JournalEntryEntity>> watchEntries();
  Future<Result<List<JournalEntryEntity>>> search(String query);
  Future<Result<JournalEntryEntity?>> getByDate(DateTime entryDate);
  Future<Result<void>> upsert(JournalEntryEntity entry);
  Future<Result<void>> delete(String id);
}
