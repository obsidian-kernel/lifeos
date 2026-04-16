// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pomodoroRepositoryHash() =>
    r'704fdf8099246256db01c4b3aaf8afd48e0dbf28';

/// See also [pomodoroRepository].
@ProviderFor(pomodoroRepository)
final pomodoroRepositoryProvider = Provider<PomodoroRepository>.internal(
  pomodoroRepository,
  name: r'pomodoroRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pomodoroRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PomodoroRepositoryRef = ProviderRef<PomodoroRepository>;
String _$pomodoroTimerEngineHash() =>
    r'6aaf3eee8d61ff9bda5dee2bd4640327cd386f06';

/// See also [pomodoroTimerEngine].
@ProviderFor(pomodoroTimerEngine)
final pomodoroTimerEngineProvider = Provider<PomodoroTimerEngine>.internal(
  pomodoroTimerEngine,
  name: r'pomodoroTimerEngineProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pomodoroTimerEngineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PomodoroTimerEngineRef = ProviderRef<PomodoroTimerEngine>;
String _$pomodoroTimerStateHash() =>
    r'1b63ffda10125a8a739fdba5ece58ed6ed7d28a5';

/// See also [pomodoroTimerState].
@ProviderFor(pomodoroTimerState)
final pomodoroTimerStateProvider = StreamProvider<PomodoroTimerState>.internal(
  pomodoroTimerState,
  name: r'pomodoroTimerStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pomodoroTimerStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PomodoroTimerStateRef = StreamProviderRef<PomodoroTimerState>;
String _$pomodoroTodayStatsHash() =>
    r'10b7b6cd5cfb5666026b93ce6b74a8a936e3addd';

/// See also [pomodoroTodayStats].
@ProviderFor(pomodoroTodayStats)
final pomodoroTodayStatsProvider =
    AutoDisposeStreamProvider<PomodoroStatsEntity?>.internal(
  pomodoroTodayStats,
  name: r'pomodoroTodayStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pomodoroTodayStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PomodoroTodayStatsRef
    = AutoDisposeStreamProviderRef<PomodoroStatsEntity?>;
String _$pomodoroRecentStatsHash() =>
    r'7d400a8a07fcbea0cba32186fc6e07b6e645222b';

/// See also [pomodoroRecentStats].
@ProviderFor(pomodoroRecentStats)
final pomodoroRecentStatsProvider =
    AutoDisposeFutureProvider<List<PomodoroStatsEntity>>.internal(
  pomodoroRecentStats,
  name: r'pomodoroRecentStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pomodoroRecentStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PomodoroRecentStatsRef
    = AutoDisposeFutureProviderRef<List<PomodoroStatsEntity>>;
String _$pomodoroSettingsNotifierHash() =>
    r'9c85d65c37f9744634755818c607e86e817372a9';

/// See also [PomodoroSettingsNotifier].
@ProviderFor(PomodoroSettingsNotifier)
final pomodoroSettingsNotifierProvider =
    NotifierProvider<PomodoroSettingsNotifier, PomodoroSettings>.internal(
  PomodoroSettingsNotifier.new,
  name: r'pomodoroSettingsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pomodoroSettingsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PomodoroSettingsNotifier = Notifier<PomodoroSettings>;
String _$pomodoroActionsHash() => r'f8bb5c86745d60803d453fe5398457d0c69d7280';

/// See also [PomodoroActions].
@ProviderFor(PomodoroActions)
final pomodoroActionsProvider =
    AutoDisposeNotifierProvider<PomodoroActions, void>.internal(
  PomodoroActions.new,
  name: r'pomodoroActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pomodoroActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PomodoroActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
