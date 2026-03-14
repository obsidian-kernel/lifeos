// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioPlayerServiceHash() =>
    r'8618dd4365bd811f0008585ea92bbd5abb25dd51';

/// See also [audioPlayerService].
@ProviderFor(audioPlayerService)
final audioPlayerServiceProvider = Provider<AudioPlayerService>.internal(
  audioPlayerService,
  name: r'audioPlayerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioPlayerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioPlayerServiceRef = ProviderRef<AudioPlayerService>;
String _$playbackStateHash() => r'c75ca7323b85166001913d59b100d02737062609';

/// See also [playbackState].
@ProviderFor(playbackState)
final playbackStateProvider = StreamProvider<PlaybackState>.internal(
  playbackState,
  name: r'playbackStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playbackStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlaybackStateRef = StreamProviderRef<PlaybackState>;
String _$musicRepositoryHash() => r'710bdb5654ef2b9aa5e945b6a9e50614e0d95cc7';

/// See also [musicRepository].
@ProviderFor(musicRepository)
final musicRepositoryProvider = AutoDisposeProvider<MusicRepository>.internal(
  musicRepository,
  name: r'musicRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$musicRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MusicRepositoryRef = AutoDisposeProviderRef<MusicRepository>;
String _$trackListStreamHash() => r'3a7c4e9da0d1a74f1a99fd310632464e55399b22';

/// See also [trackListStream].
@ProviderFor(trackListStream)
final trackListStreamProvider =
    AutoDisposeStreamProvider<List<TrackEntity>>.internal(
  trackListStream,
  name: r'trackListStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trackListStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrackListStreamRef = AutoDisposeStreamProviderRef<List<TrackEntity>>;
String _$playlistListStreamHash() =>
    r'9e1847fc4d2da34aff7be966be5a4c5f4ac93cbf';

/// See also [playlistListStream].
@ProviderFor(playlistListStream)
final playlistListStreamProvider =
    AutoDisposeStreamProvider<List<PlaylistEntity>>.internal(
  playlistListStream,
  name: r'playlistListStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playlistListStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlaylistListStreamRef
    = AutoDisposeStreamProviderRef<List<PlaylistEntity>>;
String _$musicSearchResultsHash() =>
    r'79ffe63ad5ff52ce5cff02cde7562117c30ae730';

/// See also [musicSearchResults].
@ProviderFor(musicSearchResults)
final musicSearchResultsProvider =
    AutoDisposeFutureProvider<List<TrackEntity>>.internal(
  musicSearchResults,
  name: r'musicSearchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$musicSearchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MusicSearchResultsRef = AutoDisposeFutureProviderRef<List<TrackEntity>>;
String _$musicSearchQueryHash() => r'f25235bd34506118e5868701b3da43941513ccbd';

/// See also [MusicSearchQuery].
@ProviderFor(MusicSearchQuery)
final musicSearchQueryProvider =
    AutoDisposeNotifierProvider<MusicSearchQuery, String>.internal(
  MusicSearchQuery.new,
  name: r'musicSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$musicSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MusicSearchQuery = AutoDisposeNotifier<String>;
String _$musicViewModeNotifierHash() =>
    r'11fb307e0ba4f659f6be92c4bc0d3a06f08974f1';

/// See also [MusicViewModeNotifier].
@ProviderFor(MusicViewModeNotifier)
final musicViewModeNotifierProvider =
    AutoDisposeNotifierProvider<MusicViewModeNotifier, MusicViewMode>.internal(
  MusicViewModeNotifier.new,
  name: r'musicViewModeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$musicViewModeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MusicViewModeNotifier = AutoDisposeNotifier<MusicViewMode>;
String _$musicScanStateHash() => r'f28a1281081721c288a1f29e06f7da4b14ca9b6c';

/// See also [MusicScanState].
@ProviderFor(MusicScanState)
final musicScanStateProvider =
    AutoDisposeNotifierProvider<MusicScanState, AsyncValue<int?>>.internal(
  MusicScanState.new,
  name: r'musicScanStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$musicScanStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MusicScanState = AutoDisposeNotifier<AsyncValue<int?>>;
String _$playerActionsHash() => r'7f240a19884b663c045d6b939017c339e9b71b18';

/// See also [PlayerActions].
@ProviderFor(PlayerActions)
final playerActionsProvider =
    AutoDisposeNotifierProvider<PlayerActions, void>.internal(
  PlayerActions.new,
  name: r'playerActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playerActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PlayerActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
