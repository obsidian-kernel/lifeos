import 'package:drift/drift.dart';

/// Stores completed pomodoro sessions for stats and history.
/// A session is only written on completion — interrupted sessions are discarded.
class PomodoroSessions extends Table {
  TextColumn get id => text()();
  IntColumn get sessionType => integer()(); // 0=work, 1=shortBreak, 2=longBreak
  IntColumn get durationSeconds => integer()();
  IntColumn get completedAt => integer()(); // UTC epoch ms
  TextColumn get taskId => text().nullable()(); // optional linked task

  @override
  Set<Column> get primaryKey => {id};
}

/// Stores per-day aggregate stats for fast dashboard queries.
/// Updated atomically when a session completes.
class PomodoroStats extends Table {
  IntColumn get dayEpochMs => integer()(); // UTC midnight ms — primary key
  IntColumn get workSessionsCompleted => integer().withDefault(const Constant(0))();
  IntColumn get totalFocusSeconds => integer().withDefault(const Constant(0))();
  IntColumn get totalBreakSeconds => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {dayEpochMs};
}
