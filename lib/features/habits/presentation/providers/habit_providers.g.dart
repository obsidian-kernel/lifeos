// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitRepositoryHash() => r'94efdb26a3de941f92c29e1110a52f696e068fe3';

/// See also [habitRepository].
@ProviderFor(habitRepository)
final habitRepositoryProvider = Provider<HabitRepository>.internal(
  habitRepository,
  name: r'habitRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HabitRepositoryRef = ProviderRef<HabitRepository>;
String _$habitsHash() => r'b578e47ceebef058c35af878f326d12e4a00e46a';

/// See also [habits].
@ProviderFor(habits)
final habitsProvider = AutoDisposeStreamProvider<List<HabitEntity>>.internal(
  habits,
  name: r'habitsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$habitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HabitsRef = AutoDisposeStreamProviderRef<List<HabitEntity>>;
String _$habitEditorHash() => r'b5a05364843f2b2b6f9bc008eea5201be965d69c';

/// See also [HabitEditor].
@ProviderFor(HabitEditor)
final habitEditorProvider =
    AutoDisposeNotifierProvider<HabitEditor, void>.internal(
  HabitEditor.new,
  name: r'habitEditorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$habitEditorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HabitEditor = AutoDisposeNotifier<void>;
String _$habitLoggerHash() => r'8653424dcfa1f0db1201897cf30daed9225deb68';

/// See also [HabitLogger].
@ProviderFor(HabitLogger)
final habitLoggerProvider =
    AutoDisposeNotifierProvider<HabitLogger, void>.internal(
  HabitLogger.new,
  name: r'habitLoggerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$habitLoggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HabitLogger = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
