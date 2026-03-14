import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/track_entity.dart';

/// Playback state — immutable snapshot consumed by Riverpod providers.
class PlaybackState {
  const PlaybackState({
    this.currentTrack,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.none,
  });

  final TrackEntity? currentTrack;
  final List<TrackEntity> queue;
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration bufferedPosition;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;

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
    RepeatMode? repeatMode,
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

enum RepeatMode { none, one, all }

/// Wraps just_audio's AudioPlayer with a clean observable interface.
///
/// Design decisions:
/// - AudioPlayer is a singleton within this service — not recreated per track.
///   Recreating AudioPlayer causes audio session drops on Android.
/// - State is exposed as a Stream<PlaybackState>, not direct AudioPlayer access.
///   This isolates just_audio's API from the rest of the app.
/// - Queue management is handled here, not in the UI layer.
/// - Position polling via Timer at 250ms interval — sufficient for seekbar UX
///   without excessive rebuild pressure.
/// - No audio_service background integration yet (Phase 5b).
///   Foreground playback only. Background audio is a future enhancement.
class AudioPlayerService {
  AudioPlayerService() {
    _init();
  }

  late final AudioPlayer _player;
  final _stateController = StreamController<PlaybackState>.broadcast();

  PlaybackState _state = const PlaybackState();
  Timer? _positionTimer;

  Stream<PlaybackState> get stateStream => _stateController.stream;
  PlaybackState get currentState => _state;

  void _init() {
    _player = AudioPlayer();

    // Mirror just_audio's playing state
    _player.playingStream.listen((playing) {
      _emit(_state.copyWith(isPlaying: playing));
      if (playing) {
        _startPositionTimer();
      } else {
        _stopPositionTimer();
      }
    });

    // Handle track completion
    _player.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        _handleTrackCompleted();
      }
    });
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) {
        _emit(_state.copyWith(
          position: _player.position,
          bufferedPosition: _player.bufferedPosition,
        ));
      },
    );
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  void _emit(PlaybackState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void _handleTrackCompleted() {
    switch (_state.repeatMode) {
      case RepeatMode.one:
        _player.seek(Duration.zero);
        _player.play();
        break;
      case RepeatMode.all:
        if (_state.queue.isNotEmpty) {
          final next = (_state.currentIndex + 1) % _state.queue.length;
          playFromQueue(next);
        }
        break;
      case RepeatMode.none:
        if (_state.currentIndex < _state.queue.length - 1) {
          playFromQueue(_state.currentIndex + 1);
        } else {
          _emit(_state.copyWith(
            isPlaying: false,
            position: Duration.zero,
          ));
        }
        break;
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────

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
    ));

    try {
      await _player.setFilePath(track.path);
      await _player.play();
    } catch (_) {
      // File not found or codec error — skip silently
      // TODO: emit error state for UI to show snackbar
    }
  }

  Future<void> playFromQueue(int index) async {
    if (index < 0 || index >= _state.queue.length) return;
    final track = _state.queue[index];
    _emit(_state.copyWith(
      currentIndex: index,
      currentTrack: track,
    ));
    try {
      await _player.setFilePath(track.path);
      await _player.play();
    } catch (_) {
      // Skip unplayable track
    }
  }

  Future<void> play() async => _player.play();
  Future<void> pause() async => _player.pause();

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seekTo(Duration position) async =>
      _player.seek(position);

  Future<void> skipNext() async {
    if (_state.queue.isEmpty) return;
    final next = _state.shuffleEnabled
        ? _randomIndex()
        : (_state.currentIndex + 1).clamp(0, _state.queue.length - 1);
    await playFromQueue(next);
  }

  Future<void> skipPrevious() async {
    if (_state.queue.isEmpty) return;
    // If >3 seconds in, restart current. Otherwise go to previous.
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final prev = (_state.currentIndex - 1).clamp(0, _state.queue.length - 1);
    await playFromQueue(prev);
  }

  void toggleShuffle() {
    _emit(_state.copyWith(shuffleEnabled: !_state.shuffleEnabled));
  }

  void cycleRepeatMode() {
    final next = RepeatMode.values[
        (_state.repeatMode.index + 1) % RepeatMode.values.length];
    _emit(_state.copyWith(repeatMode: next));
  }

  void addToQueue(TrackEntity track) {
    final updated = [..._state.queue, track];
    _emit(_state.copyWith(queue: updated));
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _state.queue.length) return;
    final updated = [..._state.queue]..removeAt(index);
    final newIndex = index <= _state.currentIndex
        ? (_state.currentIndex - 1).clamp(0, updated.length - 1)
        : _state.currentIndex;
    _emit(_state.copyWith(queue: updated, currentIndex: newIndex));
  }

  int _randomIndex() {
    if (_state.queue.length <= 1) return 0;
    int next;
    do {
      next = DateTime.now().millisecondsSinceEpoch % _state.queue.length;
    } while (next == _state.currentIndex && _state.queue.length > 1);
    return next;
  }

  Future<void> dispose() async {
    _stopPositionTimer();
    await _player.dispose();
    await _stateController.close();
  }
}