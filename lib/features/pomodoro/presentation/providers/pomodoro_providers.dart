import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../../shared/providers/core_providers.dart';
import '../../data/repositories/pomodoro_repository_impl.dart';
import '../../data/services/pomodoro_timer_engine.dart';
import '../../domain/entities/pomodoro_entity.dart';
import '../../domain/repositories/pomodoro_repository.dart';

part 'pomodoro_providers.g.dart';

// ── Repository ────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
PomodoroRepository pomodoroRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return PomodoroRepositoryImpl(db.pomodoroDao);
}

// ── Settings Notifier ─────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class PomodoroSettingsNotifier extends _$PomodoroSettingsNotifier {
  @override
  PomodoroSettings build() => const PomodoroSettings();

  void update(PomodoroSettings newSettings) => state = newSettings;

  void setWorkMinutes(int minutes) =>
      state = state.copyWith(workSeconds: minutes * 60);
  void setShortBreakMinutes(int minutes) =>
      state = state.copyWith(shortBreakSeconds: minutes * 60);
  void setLongBreakMinutes(int minutes) =>
      state = state.copyWith(longBreakSeconds: minutes * 60);
  void setSessionsBeforeLongBreak(int n) =>
      state = state.copyWith(sessionsBeforeLongBreak: n);
  void setAutoStartBreaks(bool v) => state = state.copyWith(autoStartBreaks: v);
  void setAutoStartWork(bool v) => state = state.copyWith(autoStartWork: v);
}

// ── Timer Engine Singleton ─────────────────────────────────────────────────

@Riverpod(keepAlive: true)
PomodoroTimerEngine pomodoroTimerEngine(Ref ref) {
  final repo = ref.watch(pomodoroRepositoryProvider);
  final settings = ref.watch(pomodoroSettingsNotifierProvider);
  final engine = PomodoroTimerEngine(repository: repo, settings: settings);
  ref.onDispose(engine.dispose);
  return engine;
}

// ── Timer State Stream ────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Stream<PomodoroTimerState> pomodoroTimerState(Ref ref) {
  final engine = ref.watch(pomodoroTimerEngineProvider);
  return engine.stateStream;
}

// ── Today Stats Stream ────────────────────────────────────────────────────

@riverpod
Stream<PomodoroStatsEntity?> pomodoroTodayStats(Ref ref) {
  final repo = ref.watch(pomodoroRepositoryProvider);
  return repo.watchTodayStats();
}

// ── Recent Stats ──────────────────────────────────────────────────────────

@riverpod
Future<List<PomodoroStatsEntity>> pomodoroRecentStats(Ref ref) async {
  final repo = ref.watch(pomodoroRepositoryProvider);
  final result = await repo.getRecentStats(days: 7);
  return result.fold(onSuccess: (s) => s, onFailure: (_) => []);
}

// ── Timer Actions ─────────────────────────────────────────────────────────

@riverpod
class PomodoroActions extends _$PomodoroActions {
  @override
  void build() {}

  PomodoroTimerEngine get _engine => ref.read(pomodoroTimerEngineProvider);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  void start() {
    _engine.start();
    _scheduleSoundNotification();
  }

  void pause() => _engine.pause();
  void resume() => _engine.resume();
  void reset() {
    _engine.reset();
    _notifications.cancelAll();
  }

  void skip() => _engine.skip();
  void linkTask(String? taskId) => _engine.linkTask(taskId);

  bool applySettings(PomodoroSettings settings) {
    final applied = _engine.updateSettings(settings);
    if (applied) {
      ref.read(pomodoroSettingsNotifierProvider.notifier).update(settings);
    }
    return applied;
  }

  /// Schedule a local notification to fire when the current session ends.
  /// Cancels any previously scheduled pomodoro notification first.
  void _scheduleSoundNotification() {
    final state = _engine.currentState;
    if (!state.isRunning) return;

    final endsAt = DateTime.now()
        .add(Duration(seconds: state.remainingSeconds));

    final isWork = state.sessionType == PomodoroSessionType.work;
    final title = isWork ? 'Focus session complete!' : 'Break time over!';
    final body = isWork
        ? 'Great work. Time for a break.'
        : 'Ready to focus again?';

    _notifications.cancel(AppConstants.pomodoroNotificationId);
    _notifications.scheduleOnce(
      id: AppConstants.pomodoroNotificationId,
      channelId: AppConstants.pomodoroNotificationChannelId,
      title: title,
      body: body,
      scheduledAt: endsAt.toUtc(),
    );
  }
}
