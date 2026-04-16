import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/pomodoro_table.dart';

part 'pomodoro_dao.g.dart';

@DriftAccessor(tables: [PomodoroSessions, PomodoroStats])
class PomodoroDao extends DatabaseAccessor<AppDatabase>
    with _$PomodoroDaoMixin {
  PomodoroDao(super.db);

  // ── Sessions ────────────────────────────────────────────────────────────

  Future<void> insertSession(PomodoroSessionsCompanion companion) =>
      into(pomodoroSessions).insert(companion);

  Future<List<PomodoroSession>> getSessionsForDay(
      int startMs, int endMs) =>
      (select(pomodoroSessions)
            ..where((s) =>
                s.completedAt.isBiggerOrEqualValue(startMs) &
                s.completedAt.isSmallerOrEqualValue(endMs))
            ..orderBy([(s) => OrderingTerm.desc(s.completedAt)]))
          .get();

  Future<List<PomodoroSession>> getRecentSessions(int limit) =>
      (select(pomodoroSessions)
            ..orderBy([(s) => OrderingTerm.desc(s.completedAt)])
            ..limit(limit))
          .get();

  // ── Stats ────────────────────────────────────────────────────────────────

  Future<PomodoroStat?> getStatsForDay(int dayEpochMs) =>
      (select(pomodoroStats)
            ..where((s) => s.dayEpochMs.equals(dayEpochMs)))
          .getSingleOrNull();

  /// Upsert stats for a given day atomically.
  Future<void> upsertStats(PomodoroStatsCompanion companion) =>
      into(pomodoroStats).insertOnConflictUpdate(companion);

  Stream<PomodoroStat?> watchStatsForDay(int dayEpochMs) =>
      (select(pomodoroStats)
            ..where((s) => s.dayEpochMs.equals(dayEpochMs)))
          .watchSingleOrNull();

  /// Returns stats for the last N days for streak/history display.
  Future<List<PomodoroStat>> getStatsRange(
      int startDayMs, int endDayMs) =>
      (select(pomodoroStats)
            ..where((s) =>
                s.dayEpochMs.isBiggerOrEqualValue(startDayMs) &
                s.dayEpochMs.isSmallerOrEqualValue(endDayMs))
            ..orderBy([(s) => OrderingTerm.desc(s.dayEpochMs)]))
          .get();
}
