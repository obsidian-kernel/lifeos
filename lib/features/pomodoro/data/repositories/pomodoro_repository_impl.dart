import 'package:drift/drift.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../../domain/entities/pomodoro_entity.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../daos/pomodoro_dao.dart';
import '../models/pomodoro_mapper.dart';

class PomodoroRepositoryImpl implements PomodoroRepository {
  PomodoroRepositoryImpl(this._dao);

  final PomodoroDao _dao;

  @override
  Future<Result<void>> recordSession(PomodoroSessionEntity session) async {
    try {
      final dayEpochMs =
          session.completedAt.toStartOfDayUtc().millisecondsSinceEpoch;
      final now = nowUtc().millisecondsSinceEpoch;

      await _dao.attachedDatabase.transaction(() async {
        // Insert completed session record
        await _dao.insertSession(session.toCompanion());

        // Upsert daily stats — increment the correct counters
        final existing = await _dao.getStatsForDay(dayEpochMs);

        final isWork = session.sessionType == PomodoroSessionType.work;
        final focusDelta = isWork ? session.durationSeconds : 0;
        final breakDelta = isWork ? 0 : session.durationSeconds;
        final workDelta = isWork ? 1 : 0;

        final companion = PomodoroStatsCompanion(
          dayEpochMs: Value(dayEpochMs),
          workSessionsCompleted: Value(
              (existing?.workSessionsCompleted ?? 0) + workDelta),
          totalFocusSeconds:
              Value((existing?.totalFocusSeconds ?? 0) + focusDelta),
          totalBreakSeconds:
              Value((existing?.totalBreakSeconds ?? 0) + breakDelta),
          updatedAt: Value(now),
        );
        await _dao.upsertStats(companion);
      });

      return const Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to record session: $e'));
    }
  }

  @override
  Future<Result<PomodoroStatsEntity?>> getTodayStats() async {
    try {
      final dayMs = nowUtc().toStartOfDayUtc().millisecondsSinceEpoch;
      final row = await _dao.getStatsForDay(dayMs);
      return Success(row?.toEntity());
    } catch (e) {
      return Failure(DatabaseError('Failed to get today stats: $e'));
    }
  }

  @override
  Stream<PomodoroStatsEntity?> watchTodayStats() {
    final dayMs = nowUtc().toStartOfDayUtc().millisecondsSinceEpoch;
    return _dao
        .watchStatsForDay(dayMs)
        .map((row) => row?.toEntity());
  }

  @override
  Future<Result<List<PomodoroStatsEntity>>> getRecentStats(
      {int days = 7}) async {
    try {
      final now = nowUtc();
      final endMs = now.toStartOfDayUtc().millisecondsSinceEpoch;
      final startMs = now
          .toStartOfDayUtc()
          .subtract(Duration(days: days - 1))
          .millisecondsSinceEpoch;
      final rows = await _dao.getStatsRange(startMs, endMs);
      return Success(rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Failure(DatabaseError('Failed to get recent stats: $e'));
    }
  }
}
