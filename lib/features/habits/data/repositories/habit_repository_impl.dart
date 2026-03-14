import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../daos/habit_dao.dart';
import '../models/habit_mapper.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._dao);

  final HabitDao _dao;
  static const _uuid = Uuid();

  @override
  Stream<List<HabitEntity>> watchActive() =>
      _dao.watchActiveHabits().map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Future<Result<void>> saveHabit(HabitEntity habit) async {
    try {
      await _dao.upsertHabit(habit.toCompanion());
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to save habit: $e'));
    }
  }

  @override
  Future<Result<void>> archiveHabit(String id) async {
    try {
      await _dao.archiveHabit(id);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to archive habit: $e'));
    }
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    try {
      await _dao.deleteHabit(id);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to delete habit: $e'));
    }
  }

  @override
  Future<Result<List<HabitLogEntity>>> getLogs(
      String habitId, DateTime start, DateTime end) async {
    try {
      final rows = await _dao.getLogs(
        habitId,
        start.toStartOfDayUtc().millisecondsSinceEpoch,
        end.toStartOfDayUtc().millisecondsSinceEpoch,
      );
      return Success(rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Failure(DatabaseError('Failed to fetch logs: $e'));
    }
  }

  @override
  Future<Result<void>> logHabit(String habitId,
      {required DateTime day, int count = 1, String? note}) async {
    try {
      final dayEpoch = day.toStartOfDayUtc().millisecondsSinceEpoch;
      final existing = await _dao.getLogForDay(habitId, dayEpoch);
      final now = nowUtc();
      final createdAt = existing != null
          ? DateTime.fromMillisecondsSinceEpoch(existing.createdAt, isUtc: true)
          : now;
      final log = HabitLogEntity(
        id: existing?.id ?? _uuid.v4(),
        habitId: habitId,
        loggedAt: day.toStartOfDayUtc(),
        count: count,
        note: note ?? existing?.note,
        createdAt: createdAt,
      );
      await _dao.upsertLog(log.toCompanion());
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to log habit: $e'));
    }
  }

  @override
  Future<Result<void>> unlogHabit(String habitId, DateTime day) async {
    try {
      final existing = await _dao.getLogForDay(
          habitId, day.toStartOfDayUtc().millisecondsSinceEpoch);
      if (existing != null) {
        await _dao.deleteLog(existing.id);
      }
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to unlog habit: $e'));
    }
  }

  @override
  Future<Result<(int current, int longest)>> streaks(
      String habitId, DateTime todayUtc) async {
    try {
      final end = todayUtc.toStartOfDayUtc();
      final start = end.subtract(const Duration(days: 365)); // 1y window
      final logsResult = await getLogs(habitId, start, end);
      if (logsResult.isFailure) return Failure(logsResult.errorOrNull!);
      final days = logsResult.valueOrNull!
          .map((l) => l.loggedAt.toUtc().millisecondsSinceEpoch)
          .toSet();
      int current = 0;
      int longest = 0;
      var cursor = end;
      while (days.contains(cursor.millisecondsSinceEpoch)) {
        current++;
        cursor = cursor.subtract(const Duration(days: 1));
      }
      longest = max(longest, current);
      // compute longest
      var streak = 0;
      for (int i = 0; i < 365; i++) {
        final day = end.subtract(Duration(days: i));
        final present = days.contains(day.millisecondsSinceEpoch);
        if (present) {
          streak++;
          longest = max(longest, streak);
        } else {
          streak = 0;
        }
      }
      return Success((current, longest));
    } catch (e) {
      return Failure(DatabaseError('Failed to compute streaks: $e'));
    }
  }
}
