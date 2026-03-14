import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../../domain/entities/habit_entity.dart';

extension HabitRowToEntity on Habit {
  HabitEntity toEntity() => HabitEntity(
        id: id,
        title: title,
        description: description,
        icon: icon,
        color: color,
        frequencyJson: frequency,
        targetCount: targetCount,
        unit: unit,
        isArchived: isArchived,
        sortOrder: sortOrder,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt, isUtc: true),
      );
}

extension HabitEntityToCompanion on HabitEntity {
  HabitsCompanion toCompanion() => HabitsCompanion(
        id: Value(id),
        title: Value(title),
        description: Value(description),
        icon: Value(icon),
        color: Value(color),
        frequency: Value(frequencyJson),
        targetCount: Value(targetCount),
        unit: Value(unit),
        isArchived: Value(isArchived),
        sortOrder: Value(sortOrder),
        createdAt: Value(createdAt.toUtc().millisecondsSinceEpoch),
        updatedAt: Value(updatedAt.toUtc().millisecondsSinceEpoch),
      );
}

extension HabitLogRowToEntity on HabitLog {
  HabitLogEntity toEntity() => HabitLogEntity(
        id: id,
        habitId: habitId,
        loggedAt: DateTime.fromMillisecondsSinceEpoch(loggedAt, isUtc: true),
        count: count,
        note: note,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
      );
}

extension HabitLogEntityToCompanion on HabitLogEntity {
  HabitLogsCompanion toCompanion() => HabitLogsCompanion(
        id: Value(id),
        habitId: Value(habitId),
        loggedAt: Value(loggedAt.toStartOfDayUtc().millisecondsSinceEpoch),
        count: Value(count),
        note: Value(note),
        createdAt: Value(createdAt.toUtc().millisecondsSinceEpoch),
      );
}
