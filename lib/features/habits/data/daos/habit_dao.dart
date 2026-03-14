import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/habit_table.dart';

part 'habit_dao.g.dart';

@DriftAccessor(tables: [Habits, HabitLogs])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  Stream<List<Habit>> watchActiveHabits() => (select(habits)
        ..where((h) => h.isArchived.equals(false))
        ..orderBy([(h) => OrderingTerm.asc(h.sortOrder), (h) => OrderingTerm.asc(h.title)]))
      .watch();

  Future<List<Habit>> getAllHabits() => select(habits).get();

  Future<void> upsertHabit(HabitsCompanion companion) =>
      into(habits).insertOnConflictUpdate(companion);

  Future<void> archiveHabit(String id) =>
      (update(habits)..where((h) => h.id.equals(id))).write(
        const HabitsCompanion(isArchived: Value(true)),
      );

  Future<void> deleteHabit(String id) =>
      (delete(habits)..where((h) => h.id.equals(id))).go();

  Future<List<HabitLog>> getLogs(String habitId, int startDay, int endDay) =>
      (select(habitLogs)
            ..where((l) =>
                l.habitId.equals(habitId) &
                l.loggedAt.isBiggerOrEqualValue(startDay) &
                l.loggedAt.isSmallerOrEqualValue(endDay))
            ..orderBy([(l) => OrderingTerm.desc(l.loggedAt)]))
          .get();

  Future<HabitLog?> getLogForDay(String habitId, int dayEpochMs) =>
      (select(habitLogs)
            ..where((l) =>
                l.habitId.equals(habitId) & l.loggedAt.equals(dayEpochMs))
            ..limit(1))
          .getSingleOrNull();

  Future<void> upsertLog(HabitLogsCompanion companion) =>
      into(habitLogs).insertOnConflictUpdate(companion);

  Future<void> deleteLog(String id) =>
      (delete(habitLogs)..where((l) => l.id.equals(id))).go();
}
