import 'package:drift/drift.dart';

/// Ordered junction between Playlists and Tracks.
/// sortOrder determines playback sequence within a playlist.
class PlaylistTracks extends Table {
  TextColumn get playlistId => text()();
  TextColumn get trackId => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, trackId};
}