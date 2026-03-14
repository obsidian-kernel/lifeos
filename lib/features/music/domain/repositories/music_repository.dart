import '../../../../core/error/result.dart';
import '../entities/playlist_entity.dart';
import '../entities/track_entity.dart';

abstract interface class MusicRepository {
  // ── Library ───────────────────────────────────────────────────────────

  /// Scan [directoryPath] and upsert found tracks into DB.
  /// Returns count of newly added tracks.
  Future<Result<int>> scanDirectory(String directoryPath);

  /// Mark tracks whose files no longer exist as unavailable.
  Future<Result<int>> reconcileAvailability();

  // ── Tracks ────────────────────────────────────────────────────────────

  Future<Result<List<TrackEntity>>> getAllTracks();
  Future<Result<TrackEntity?>> getTrackById(String id);
  Future<Result<List<TrackEntity>>> getTracksByAlbum(String album);
  Future<Result<List<TrackEntity>>> getTracksByArtist(String artist);
  Future<Result<List<TrackEntity>>> searchTracks(String query);
  Stream<List<TrackEntity>> watchAllTracks();

  /// Increment play count and update lastPlayedAt.
  Future<Result<void>> recordPlay(String trackId);

  // ── Playlists ─────────────────────────────────────────────────────────

  Future<Result<PlaylistEntity>> createPlaylist(String name);
  Future<Result<PlaylistEntity>> renamePlaylist(String id, String name);
  Future<Result<void>> deletePlaylist(String id);
  Future<Result<void>> addTrackToPlaylist(String playlistId, String trackId);
  Future<Result<void>> removeTrackFromPlaylist(String playlistId, String trackId);
  Future<Result<void>> reorderPlaylistTrack(
      String playlistId, int oldIndex, int newIndex);
  Future<Result<List<PlaylistEntity>>> getPlaylists();
  Future<Result<PlaylistEntity?>> getPlaylistById(String id);
  Future<Result<List<TrackEntity>>> getPlaylistTracks(String playlistId);
  Stream<List<PlaylistEntity>> watchPlaylists();
}