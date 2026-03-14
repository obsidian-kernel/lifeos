// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$journalRepositoryHash() => r'61c6a9952b77e8a20710bcb3d926811b5dd6c8e4';

/// See also [journalRepository].
@ProviderFor(journalRepository)
final journalRepositoryProvider = Provider<JournalRepository>.internal(
  journalRepository,
  name: r'journalRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$journalRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JournalRepositoryRef = ProviderRef<JournalRepository>;
String _$journalEntriesHash() => r'21e96fbeaa79e35515e8f8d4635565d40f07fa3e';

/// See also [journalEntries].
@ProviderFor(journalEntries)
final journalEntriesProvider =
    AutoDisposeStreamProvider<List<JournalEntryEntity>>.internal(
  journalEntries,
  name: r'journalEntriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$journalEntriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JournalEntriesRef
    = AutoDisposeStreamProviderRef<List<JournalEntryEntity>>;
String _$journalSearchQueryHash() =>
    r'182a5e6652f0e417fe7337d013d061e879fe1ba4';

/// See also [JournalSearchQuery].
@ProviderFor(JournalSearchQuery)
final journalSearchQueryProvider =
    AutoDisposeNotifierProvider<JournalSearchQuery, String>.internal(
  JournalSearchQuery.new,
  name: r'journalSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$journalSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JournalSearchQuery = AutoDisposeNotifier<String>;
String _$journalEditorHash() => r'5f819a4204c2e7ef63bae978d38a4dd08aa934d6';

/// See also [JournalEditor].
@ProviderFor(JournalEditor)
final journalEditorProvider =
    AutoDisposeNotifierProvider<JournalEditor, void>.internal(
  JournalEditor.new,
  name: r'journalEditorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$journalEditorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JournalEditor = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
