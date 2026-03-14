import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../../../../shared/providers/core_providers.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';

part 'habit_providers.g.dart';

@Riverpod(keepAlive: true)
HabitRepository habitRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return HabitRepositoryImpl(db.habitDao);
}

@riverpod
Stream<List<HabitEntity>> habits(Ref ref) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchActive();
}

@riverpod
class HabitEditor extends _$HabitEditor {
  @override
  void build() {}

  HabitRepository get _repo => ref.read(habitRepositoryProvider);

  Future<Result<void>> save({
    String? id,
    required String title,
    String? description,
    String? icon,
    String? color,
    required String frequencyJson,
    int targetCount = 1,
    String? unit,
    double sortOrder = 0,
    bool isArchived = false,
  }) async {
    if (title.trim().isEmpty) {
      return Failure(const ValidationError('Title cannot be empty'));
    }
    final now = nowUtc();
    final habit = HabitEntity(
      id: id ?? const Uuid().v4(),
      title: title.trim(),
      description: description?.trim(),
      icon: icon,
      color: color,
      frequencyJson: frequencyJson,
      targetCount: targetCount,
      unit: unit,
      isArchived: isArchived,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
    return _repo.saveHabit(habit);
  }

  Future<Result<void>> archive(String id) => _repo.archiveHabit(id);
  Future<Result<void>> delete(String id) => _repo.deleteHabit(id);
}

@riverpod
class HabitLogger extends _$HabitLogger {
  @override
  void build() {}

  HabitRepository get _repo => ref.read(habitRepositoryProvider);

  Future<Result<void>> logToday(String habitId, {int count = 1, String? note}) {
    return _repo.logHabit(habitId, day: nowUtc(), count: count, note: note);
  }

  Future<Result<void>> unlogToday(String habitId) {
    return _repo.unlogHabit(habitId, nowUtc());
  }

  Future<Result<(int current, int longest)>> streaks(String habitId) =>
      _repo.streaks(habitId, nowUtc());
}
