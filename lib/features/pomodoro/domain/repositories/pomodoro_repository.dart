import '../../../../core/error/result.dart';
import '../entities/pomodoro_entity.dart';

abstract interface class PomodoroRepository {
  /// Persist a completed session and update daily stats atomically.
  Future<Result<void>> recordSession(PomodoroSessionEntity session);

  /// Returns today's stats, or null if no sessions yet today.
  Future<Result<PomodoroStatsEntity?>> getTodayStats();

  /// Reactive stream of today's stats — updates whenever a session completes.
  Stream<PomodoroStatsEntity?> watchTodayStats();

  /// Returns stats for the last [days] days for the history view.
  Future<Result<List<PomodoroStatsEntity>>> getRecentStats({int days = 7});
}
