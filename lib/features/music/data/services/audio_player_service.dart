import 'dart:async';

import 'package:media_kit/media_kit.dart';

import '../../domain/entities/track_entity.dart';
import '../../domain/repositories/music_repository.dart';

enum TrackRepeatMode { none, one, all }

/// Immutable playback state snapshot consumed by Riverpod providers.
class PlaybackState {
  const PlaybackState({
    this.currentTrack,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.shuffleEnabled = false,
    this.repeatMode = TrackRepeatMode.none,
  });

  final TrackEntity? currentTrack;
  final List<TrackEntity> queue;
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration bufferedPosition;
  final bool shuffleEnabled;
  final TrackRepeatMode repeatMode;

  bool get hasTrack => currentTrack != null;
  bool get isQueueEmpty => queue.isEmpty;

  PlaybackState copyWith({
    TrackEntity? currentTrack,
    List<TrackEntity>? queue,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    Duration? bufferedPosition,
    bool? shuffleEnabled,
    TrackRepeatMode? repeatMode,
    bool clearCurrentTrack = false,
  }) {
    return PlaybackState(
      currentTrack:
          clearCurrentTrack ? null : currentTrack ?? this.currentTrack,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}

/// Audio playback service backed by media_kit.
///
/// Design:
/// - Single Player instance — never recreated between tracks.
/// - State emitted as `Stream<PlaybackState>` — UI never touches Player directly.
/// - Position polled via media_kit's built-in stream — no manual Timer needed.
class AudioPlayerService {
  AudioPlayerService(this._repo) {
    _init();
  }

  final MusicRepository _repo;
  late final Player _player;
  final _stateController = StreamController<PlaybackState>.broadcast();
  final List<StreamSubscription<dynamic>> _subs = [];

  PlaybackState _state = const PlaybackState();
  int _lastPersistedPositionMs = 0;

  Stream<PlaybackState> get stateStream => _stateController.stream;
  PlaybackState get currentState => _state;

  void _init() {
    _player = Player();

    // Playing state
    _subs.add(_player.stream.playing.listen((playing) {
      _emit(_state.copyWith(isPlaying: playing));
    }));

    // Duration updates
    _subs.add(_player.stream.duration.listen((duration) {
      if (_state.queue.isEmpty || duration == Duration.zero) return;
      final ms = duration.inMilliseconds;
      final current = _state.currentTrack;
      if (current == null || current.durationMs == ms) return;

      final updatedTrack = current.copyWith(durationMs: ms);
      final updatedQueue = List<TrackEntity>.from(_state.queue);
      if (_state.currentIndex >= 0 && _state.currentIndex < updatedQueue.length) {
        updatedQueue[_state.currentIndex] = updatedTrack;
      }

      _emit(_state.copyWith(
        currentTrack: updatedTrack,
        queue: updatedQueue,
      ));

      // Persist duration to DB (fire-and-forget)
      unawaited(_repo.setTrackDuration(updatedTrack.id, ms));
    }));

    // Position
    _subs.add(_player.stream.position.listen((pos) {
      _emit(_state.copyWith(position: pos));
      _maybePersistPosition(pos);
    }));

    // Buffered position
    _subs.add(_player.stream.buffer.listen((buf) {
      _emit(_state.copyWith(bufferedPosition: buf));
    }));

    // Track completed
    _subs.add(_player.stream.completed.listen((completed) {
      if (completed) _handleTrackCompleted();
    }));
  }

  void _emit(PlaybackState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  void _handleTrackCompleted() {
    switch (_state.repeatMode) {
      case TrackRepeatMode.one:
        _player.seek(Duration.zero);
        _player.play();
      case TrackRepeatMode.all:
        if (_state.queue.isNotEmpty) {
          final next = (_state.currentIndex + 1) % _state.queue.length;
          playFromQueue(next);
        }
      case TrackRepeatMode.none:
        if (_state.currentIndex < _state.queue.length - 1) {
          playFromQueue(_state.currentIndex + 1);
        } else {
          _emit(_state.copyWith(
            isPlaying: false,
            position: Duration.zero,
          ));
        }
    }
    final current = _state.currentTrack;
    if (current != null) {
      unawaited(_repo.setLastPosition(current.id, 0));
    }
  }

  // ── Public API ───────────────────────────────────────────────────────────

  Future<void> playTrack(TrackEntity track) async {
    await playQueue([track], startIndex: 0);
  }

  Future<void> playQueue(
    List<TrackEntity> queue, {
    int startIndex = 0,
  }) async {
    if (queue.isEmpty) return;
    final clamped = startIndex.clamp(0, queue.length - 1);
    final track = queue[clamped];

    _emit(_state.copyWith(
      queue: queue,
      currentIndex: clamped,
      currentTrack: track,
      position: Duration.zero,
    ));
    _lastPersistedPositionMs = 0;

    try {
      await _player.open(Media(track.path));
      await _maybeResumePosition(track);
      await _player.play();
    } catch (_) {
      await _handleOpenFailure(track);
    }
  }

  Future<void> playFromQueue(int index) async {
    if (index < 0 || index >= _state.queue.length) return;
    final track = _state.queue[index];
    _emit(_state.copyWith(
      currentIndex: index,
      currentTrack: track,
      position: Duration.zero,
    ));
    _lastPersistedPositionMs = 0;
    try {
      await _player.open(Media(track.path));
      await _maybeResumePosition(track);
      await _player.play();
    } catch (_) {
      await _handleOpenFailure(track);
    }
  }

  Future<void> play() async => _player.play();
  Future<void> pause() async => _player.pause();

  Future<void> togglePlayPause() async {
    _state.isPlaying ? await _player.pause() : await _player.play();
  }

  Future<void> seekTo(Duration position) async => _player.seek(position);

  Future<void> skipNext() async {
    if (_state.queue.isEmpty) return;
    final next = _state.shuffleEnabled
        ? _randomIndex()
        : (_state.currentIndex + 1).clamp(0, _state.queue.length - 1);
    await playFromQueue(next);
  }

  Future<void> skipPrevious() async {
    if (_state.queue.isEmpty) return;
    if (_state.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final prev =
        (_state.currentIndex - 1).clamp(0, _state.queue.length - 1);
    await playFromQueue(prev);
  }

  void toggleShuffle() {
    _emit(_state.copyWith(shuffleEnabled: !_state.shuffleEnabled));
  }

  void cycleRepeatMode() {
    final next = TrackRepeatMode.values[
        (_state.repeatMode.index + 1) % TrackRepeatMode.values.length];
    _emit(_state.copyWith(repeatMode: next));
  }

  void addToQueue(TrackEntity track) {
    _emit(_state.copyWith(queue: [..._state.queue, track]));
  }

  void addNext(TrackEntity track) {
    final updated = [..._state.queue];
    final insertAt = _state.queue.isEmpty
        ? 0
        : (_state.currentIndex + 1).clamp(0, updated.length);
    updated.insert(insertAt, track);
    _emit(_state.copyWith(queue: updated));
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _state.queue.length) return;
    final updated = [..._state.queue]..removeAt(index);
    final newIndex = index <= _state.currentIndex
        ? (_state.currentIndex - 1)
            .clamp(0, updated.isEmpty ? 0 : updated.length - 1)
        : _state.currentIndex;
    _emit(_state.copyWith(queue: updated, currentIndex: newIndex));
  }

  void moveInQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _state.queue.length) return;
    if (newIndex < 0 || newIndex >= _state.queue.length) return;
    final updated = [..._state.queue];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    var currentIndex = _state.currentIndex;
    if (oldIndex == currentIndex) {
      currentIndex = newIndex;
    } else {
      if (oldIndex < currentIndex) currentIndex--;
      if (newIndex <= currentIndex) currentIndex++;
    }

    _emit(_state.copyWith(queue: updated, currentIndex: currentIndex));
  }

  int _randomIndex() {
    if (_state.queue.length <= 1) return 0;
    int next;
    do {
      next = DateTime.now().millisecondsSinceEpoch % _state.queue.length;
    } while (next == _state.currentIndex);
    return next;
  }

  Future<void> _maybeResumePosition(TrackEntity track) async {
    if (track.lastPositionMs <= 5000) return;
    try {
      await _player.seek(Duration(milliseconds: track.lastPositionMs));
    } catch (_) {
      // ignore seek failures
    }
  }

  void _maybePersistPosition(Duration pos) {
    final current = _state.currentTrack;
    if (current == null) return;
    final ms = pos.inMilliseconds;
    if ((ms - _lastPersistedPositionMs).abs() < 2000) return;
    _lastPersistedPositionMs = ms;
    unawaited(_repo.setLastPosition(current.id, ms));
  }

  Future<void> _handleOpenFailure(TrackEntity track) async {
    _emit(_state.copyWith(isPlaying: false));
    unawaited(_repo.markTrackUnavailable(track.id));
    if (_state.queue.length > 1) {
      await skipNext();
    }
  }

  Future<void> dispose() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    await _player.dispose();
    await _stateController.close();
  }
}
