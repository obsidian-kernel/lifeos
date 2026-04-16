import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/pomodoro_entity.dart';

extension PomodoroSessionRowToEntity on PomodoroSession {
  PomodoroSessionEntity toEntity() => PomodoroSessionEntity(
        id: id,
        sessionType: PomodoroSessionType.values[sessionType],
        durationSeconds: durationSeconds,
        completedAt:
            DateTime.fromMillisecondsSinceEpoch(completedAt, isUtc: true),
        taskId: taskId,
      );
}

extension PomodoroSessionEntityToCompanion on PomodoroSessionEntity {
  PomodoroSessionsCompanion toCompanion() => PomodoroSessionsCompanion(
        id: Value(id),
        sessionType: Value(sessionType.index),
        durationSeconds: Value(durationSeconds),
        completedAt: Value(completedAt.millisecondsSinceEpoch),
        taskId: Value(taskId),
      );
}

extension PomodoroStatRowToEntity on PomodoroStat {
  PomodoroStatsEntity toEntity() => PomodoroStatsEntity(
        dayEpochMs: dayEpochMs,
        workSessionsCompleted: workSessionsCompleted,
        totalFocusSeconds: totalFocusSeconds,
        totalBreakSeconds: totalBreakSeconds,
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(updatedAt, isUtc: true),
      );
}
