import 'package:equatable/equatable.dart';

enum PomodoroSessionType { work, shortBreak, longBreak }

enum PomodoroTimerStatus { idle, running, paused, finished }

/// Immutable domain entity for a completed session record.
class PomodoroSessionEntity extends Equatable {
  const PomodoroSessionEntity({
    required this.id,
    required this.sessionType,
    required this.durationSeconds,
    required this.completedAt,
    this.taskId,
  });

  final String id;
  final PomodoroSessionType sessionType;
  final int durationSeconds;
  final DateTime completedAt; // UTC
  final String? taskId;

  bool get isWorkSession => sessionType == PomodoroSessionType.work;

  @override
  List<Object?> get props =>
      [id, sessionType, durationSeconds, completedAt, taskId];
}

/// Immutable daily stats aggregate.
class PomodoroStatsEntity extends Equatable {
  const PomodoroStatsEntity({
    required this.dayEpochMs,
    required this.workSessionsCompleted,
    required this.totalFocusSeconds,
    required this.totalBreakSeconds,
    required this.updatedAt,
  });

  final int dayEpochMs;
  final int workSessionsCompleted;
  final int totalFocusSeconds;
  final int totalBreakSeconds;
  final DateTime updatedAt;

  String get formattedFocusTime {
    final minutes = totalFocusSeconds ~/ 60;
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  List<Object?> get props => [
        dayEpochMs,
        workSessionsCompleted,
        totalFocusSeconds,
        totalBreakSeconds,
        updatedAt,
      ];
}

/// Immutable snapshot of the running timer state.
/// Emitted by the timer engine on every tick.
class PomodoroTimerState extends Equatable {
  const PomodoroTimerState({
    required this.status,
    required this.sessionType,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.completedWorkSessions,
    this.linkedTaskId,
  });

  final PomodoroTimerStatus status;
  final PomodoroSessionType sessionType;
  final int totalSeconds;
  final int remainingSeconds;
  final int completedWorkSessions; // within current run, resets on reset
  final String? linkedTaskId;

  double get progress =>
      totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0.0;

  bool get isIdle => status == PomodoroTimerStatus.idle;
  bool get isRunning => status == PomodoroTimerStatus.running;
  bool get isPaused => status == PomodoroTimerStatus.paused;
  bool get isFinished => status == PomodoroTimerStatus.finished;

  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get sessionLabel => switch (sessionType) {
        PomodoroSessionType.work => 'Focus',
        PomodoroSessionType.shortBreak => 'Short Break',
        PomodoroSessionType.longBreak => 'Long Break',
      };

  PomodoroTimerState copyWith({
    PomodoroTimerStatus? status,
    PomodoroSessionType? sessionType,
    int? totalSeconds,
    int? remainingSeconds,
    int? completedWorkSessions,
    String? linkedTaskId,
    bool clearLinkedTaskId = false,
  }) {
    return PomodoroTimerState(
      status: status ?? this.status,
      sessionType: sessionType ?? this.sessionType,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completedWorkSessions:
          completedWorkSessions ?? this.completedWorkSessions,
      linkedTaskId:
          clearLinkedTaskId ? null : linkedTaskId ?? this.linkedTaskId,
    );
  }

  /// Default idle state at app start.
  static PomodoroTimerState idle({
    int workSeconds = 25 * 60,
  }) =>
      PomodoroTimerState(
        status: PomodoroTimerStatus.idle,
        sessionType: PomodoroSessionType.work,
        totalSeconds: workSeconds,
        remainingSeconds: workSeconds,
        completedWorkSessions: 0,
      );

  @override
  List<Object?> get props => [
        status,
        sessionType,
        totalSeconds,
        remainingSeconds,
        completedWorkSessions,
        linkedTaskId,
      ];
}
