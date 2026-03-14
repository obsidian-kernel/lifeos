import '../../../../core/error/result.dart';
import '../entities/habit_entity.dart';

abstract interface class HabitRepository {
  Stream<List<HabitEntity>> watchActive();
  Future<Result<void>> saveHabit(HabitEntity habit);
  Future<Result<void>> archiveHabit(String id);
  Future<Result<void>> deleteHabit(String id);

  Future<Result<List<HabitLogEntity>>> getLogs(
      String habitId, DateTime start, DateTime end);
  Future<Result<void>> logHabit(String habitId,
      {required DateTime day, int count = 1, String? note});
  Future<Result<void>> unlogHabit(String habitId, DateTime day);

  /// Returns (current streak, longest streak) in days.
  Future<Result<(int current, int longest)>> streaks(
      String habitId, DateTime todayUtc);
}
