import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/core_providers.dart';
import '../../../../core/error/result.dart';
import '../../data/repositories/music_repository_impl.dart';
import '../../data/services/audio_player_service.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/track_entity.dart';
import '../../domain/repositories/music_repository.dart';

part 'music_providers.g.dart';

// ── AudioPlayerService singleton ──────────────────────────────────────────

@Riverpod(keepAlive: true)
AudioPlayerService audioPlayerService(Ref ref) {
  final repo = ref.watch(musicRepositoryProvider);
  final service = AudioPlayerService(repo);
  ref.onDispose(service.dispose);
  return service;
}

// ── Playback State Stream ─────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Stream<PlaybackState> playbackState(Ref ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream;
}

// ── Repository ────────────────────────────────────────────────────────────

@riverpod
MusicRepository musicRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final fs = ref.watch(fileSystemServiceProvider);
  return MusicRepositoryImpl(
    musicDao: db.musicDao,
    fileSystemService: fs,
  );
}

// ── Track List Stream ─────────────────────────────────────────────────────

@riverpod
Stream<List<TrackEntity>> trackListStream(Ref ref) {
  final repo = ref.watch(musicRepositoryProvider);
  return repo.watchAllTracks();
}

// ── Playlist List Stream ──────────────────────────────────────────────────

@riverpod
Stream<List<PlaylistEntity>> playlistListStream(Ref ref) {
  final repo = ref.watch(musicRepositoryProvider);
  return repo.watchPlaylists();
}

// ── Search Query ──────────────────────────────────────────────────────────

@riverpod
class MusicSearchQuery extends _$MusicSearchQuery {
  @override
  String build() => '';
  void setQuery(String q) => state = q;
  void clear() => state = '';
}

// ── Search Results ────────────────────────────────────────────────────────

@riverpod
Future<List<TrackEntity>> musicSearchResults(Ref ref) async {
  final query = ref.watch(musicSearchQueryProvider);
  if (query.isEmpty) return [];
  final repo = ref.watch(musicRepositoryProvider);
  final result = await repo.searchTracks(query);
  return result.fold(onSuccess: (t) => t, onFailure: (_) => []);
}

// ── View Mode ─────────────────────────────────────────────────────────────

enum MusicViewMode { library, albums, artists, playlists }

@riverpod
class MusicViewModeNotifier extends _$MusicViewModeNotifier {
  @override
  MusicViewMode build() => MusicViewMode.library;
  void setMode(MusicViewMode mode) => state = mode;
}

// ── Scan State ────────────────────────────────────────────────────────────

@riverpod
class MusicScanState extends _$MusicScanState {
  @override
  AsyncValue<int?> build() => const AsyncValue.data(null);

  Future<void> scan(String directoryPath) async {
    state = const AsyncValue.loading();
    final repo = ref.read(musicRepositoryProvider);
    final result = await repo.scanDirectory(directoryPath);
    state = result.fold(
      onSuccess: (count) => AsyncValue.data(count),
      onFailure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }
}

// ── Player Actions ────────────────────────────────────────────────────────

@riverpod
class PlayerActions extends _$PlayerActions {
  @override
  void build() {}

  AudioPlayerService get _service =>
      ref.read(audioPlayerServiceProvider);

  MusicRepository get _repo => ref.read(musicRepositoryProvider);

  Future<void> playTrack(TrackEntity track) async {
    await _service.playTrack(track);
    await _repo.recordPlay(track.id);
  }

  Future<void> playQueue(List<TrackEntity> queue,
      {int startIndex = 0}) async {
    await _service.playQueue(queue, startIndex: startIndex);
    if (queue.isNotEmpty) {
      await _repo.recordPlay(queue[startIndex].id);
    }
  }

  Future<void> togglePlayPause() => _service.togglePlayPause();
  Future<void> skipNext() => _service.skipNext();
  Future<void> skipPrevious() => _service.skipPrevious();
  Future<void> seekTo(Duration position) => _service.seekTo(position);
  void toggleShuffle() => _service.toggleShuffle();
  void cycleRepeatMode() => _service.cycleRepeatMode();
  void addToQueue(TrackEntity track) => _service.addToQueue(track);
  void playNext(TrackEntity track) => _service.addNext(track);
  void removeFromQueue(int index) => _service.removeFromQueue(index);
  void moveInQueue(int oldIndex, int newIndex) =>
      _service.moveInQueue(oldIndex, newIndex);
  Future<void> playFromQueue(int index) => _service.playFromQueue(index);

  Future<void> addToPlaylist(String playlistId, String trackId) =>
      _repo.addTrackToPlaylist(playlistId, trackId);
}

// ── Playlist actions ──────────────────────────────────────────────────────

@riverpod
class PlaylistActions extends _$PlaylistActions {
  @override
  void build() {}

  MusicRepository get _repo => ref.read(musicRepositoryProvider);

  Future<Result<void>> create(String name) async =>
      (await _repo.createPlaylist(name))
          .fold(onSuccess: (_) => const Success(null), onFailure: Failure.new);

  Future<Result<void>> rename(String id, String name) async =>
      (await _repo.renamePlaylist(id, name))
          .fold(onSuccess: (_) => const Success(null), onFailure: Failure.new);

  Future<Result<void>> delete(String id) => _repo.deletePlaylist(id);
  Future<Result<List<TrackEntity>>> tracks(String playlistId) =>
      _repo.getPlaylistTracks(playlistId);
}
