import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../../core/utils/constants.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../../domain/entities/pomodoro_entity.dart';
import '../../domain/repositories/pomodoro_repository.dart';

/// Pomodoro settings value object.
/// Immutable. Created once and passed to the engine.
class PomodoroSettings {
  const PomodoroSettings({
    this.workSeconds = AppConstants.defaultWorkDuration * 60,
    this.shortBreakSeconds = AppConstants.defaultShortBreak * 60,
    this.longBreakSeconds = AppConstants.defaultLongBreak * 60,
    this.sessionsBeforeLongBreak =
        AppConstants.defaultSessionsBeforeLongBreak,
    this.autoStartBreaks = false,
    this.autoStartWork = false,
  });

  final int workSeconds;
  final int shortBreakSeconds;
  final int longBreakSeconds;
  final int sessionsBeforeLongBreak;
  final bool autoStartBreaks;
  final bool autoStartWork;

  int secondsForType(PomodoroSessionType type) => switch (type) {
        PomodoroSessionType.work => workSeconds,
        PomodoroSessionType.shortBreak => shortBreakSeconds,
        PomodoroSessionType.longBreak => longBreakSeconds,
      };

  PomodoroSettings copyWith({
    int? workSeconds,
    int? shortBreakSeconds,
    int? longBreakSeconds,
    int? sessionsBeforeLongBreak,
    bool? autoStartBreaks,
    bool? autoStartWork,
  }) {
    return PomodoroSettings(
      workSeconds: workSeconds ?? this.workSeconds,
      shortBreakSeconds: shortBreakSeconds ?? this.shortBreakSeconds,
      longBreakSeconds: longBreakSeconds ?? this.longBreakSeconds,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartWork: autoStartWork ?? this.autoStartWork,
    );
  }
}

/// Core timer engine. Pure Dart. No Flutter dependencies.
///
/// Design decisions:
/// - Uses dart:async Timer.periodic at 1-second resolution.
///   Sub-second accuracy is not required for a focus timer.
/// - State is emitted as a broadcast stream. Multiple listeners allowed.
/// - Session completion is persisted to the repository on each finish.
///   The engine does not care about DB success — it fires and continues.
/// - Settings are mutable only when the timer is idle.
///   Changing settings mid-session is disallowed to prevent state corruption.
/// - The engine owns the session sequence logic:
///   work → short break → work → ... → long break (after N work sessions).
class PomodoroTimerEngine {
  PomodoroTimerEngine({
    required PomodoroRepository repository,
    PomodoroSettings settings = const PomodoroSettings(),
  })  : _repository = repository,
        _settings = settings {
    _state = PomodoroTimerState.idle(workSeconds: settings.workSeconds);
  }

  final PomodoroRepository _repository;
  PomodoroSettings _settings;

  late PomodoroTimerState _state;
  Timer? _ticker;
  final _stateController = StreamController<PomodoroTimerState>.broadcast();

  static const _uuid = Uuid();

  Stream<PomodoroTimerState> get stateStream => _stateController.stream;
  PomodoroTimerState get currentState => _state;
  PomodoroSettings get settings => _settings;

  // ── Public API ────────────────────────────────────────────────────────────

  void start() {
    if (_state.isRunning) return;
    if (_state.isFinished) {
      _advanceToNextSession();
      return;
    }
    _emit(_state.copyWith(status: PomodoroTimerStatus.running));
    _startTicker();
  }

  void pause() {
    if (!_state.isRunning) return;
    _ticker?.cancel();
    _ticker = null;
    _emit(_state.copyWith(status: PomodoroTimerStatus.paused));
  }

  void resume() {
    if (!_state.isPaused) return;
    _emit(_state.copyWith(status: PomodoroTimerStatus.running));
    _startTicker();
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _state = PomodoroTimerState.idle(workSeconds: _settings.workSeconds);
    _emit(_state);
  }

  void skip() {
    _ticker?.cancel();
    _ticker = null;
    _advanceToNextSession();
  }

  /// Update settings — only allowed when timer is idle or finished.
  bool updateSettings(PomodoroSettings newSettings) {
    if (_state.isRunning || _state.isPaused) return false;
    _settings = newSettings;
    // Rebuild idle state with new work duration
    _state = PomodoroTimerState.idle(workSeconds: newSettings.workSeconds);
    _emit(_state);
    return true;
  }

  void linkTask(String? taskId) {
    _emit(_state.copyWith(
      linkedTaskId: taskId,
      clearLinkedTaskId: taskId == null,
    ));
  }

  void dispose() {
    _ticker?.cancel();
    _stateController.close();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!_state.isRunning) return;

    final remaining = _state.remainingSeconds - 1;

    if (remaining <= 0) {
      _ticker?.cancel();
      _ticker = null;
      _onSessionComplete();
    } else {
      _emit(_state.copyWith(remainingSeconds: remaining));
    }
  }

  void _onSessionComplete() {
    // Persist completed session (fire and forget — no await on purpose)
    final session = PomodoroSessionEntity(
      id: _uuid.v4(),
      sessionType: _state.sessionType,
      durationSeconds: _state.totalSeconds,
      completedAt: nowUtc(),
      taskId: _state.linkedTaskId,
    );
    _repository.recordSession(session);

    // Update completed work count
    final newWorkCount = _state.sessionType == PomodoroSessionType.work
        ? _state.completedWorkSessions + 1
        : _state.completedWorkSessions;

    _emit(_state.copyWith(
      status: PomodoroTimerStatus.finished,
      remainingSeconds: 0,
      completedWorkSessions: newWorkCount,
    ));

    // Auto-start next session if configured
    if (_state.sessionType == PomodoroSessionType.work &&
        _settings.autoStartBreaks) {
      Future.delayed(const Duration(milliseconds: 300), _advanceToNextSession);
    } else if (_state.sessionType != PomodoroSessionType.work &&
        _settings.autoStartWork) {
      Future.delayed(const Duration(milliseconds: 300), _advanceToNextSession);
    }
  }

  void _advanceToNextSession() {
    final nextType = _nextSessionType();
    final nextSeconds = _settings.secondsForType(nextType);

    _emit(PomodoroTimerState(
      status: PomodoroTimerStatus.idle,
      sessionType: nextType,
      totalSeconds: nextSeconds,
      remainingSeconds: nextSeconds,
      completedWorkSessions: _state.completedWorkSessions,
      linkedTaskId: _state.linkedTaskId,
    ));
  }

  PomodoroSessionType _nextSessionType() {
    if (_state.sessionType != PomodoroSessionType.work) {
      return PomodoroSessionType.work;
    }
    // After N completed work sessions → long break
    if (_state.completedWorkSessions > 0 &&
        _state.completedWorkSessions % _settings.sessionsBeforeLongBreak == 0) {
      return PomodoroSessionType.longBreak;
    }
    return PomodoroSessionType.shortBreak;
  }

  void _emit(PomodoroTimerState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }
}
