import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/playlist_table.dart';
import '../models/playlist_track_table.dart';
import '../models/track_table.dart';

part 'music_dao.g.dart';

@DriftAccessor(tables: [Tracks, Playlists, PlaylistTracks])
class MusicDao extends DatabaseAccessor<AppDatabase> with _$MusicDaoMixin {
  MusicDao(super.db);

  // ── Tracks ─────────────────────────────────────────────────────────────

  Stream<List<Track>> watchAllTracks() =>
      (select(tracks)
            ..where((t) => t.isAvailable.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.artist),
                        (t) => OrderingTerm.asc(t.album),
                        (t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<List<Track>> getAllTracks() =>
      (select(tracks)
            ..where((t) => t.isAvailable.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.artist),
                        (t) => OrderingTerm.asc(t.album),
                        (t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<Track?> getTrackById(String id) =>
      (select(tracks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Track?> getTrackByPath(String path) =>
      (select(tracks)..where((t) => t.path.equals(path))).getSingleOrNull();

  Future<List<Track>> getTracksByAlbum(String album) =>
      (select(tracks)
            ..where((t) =>
                t.album.equals(album) & t.isAvailable.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<List<Track>> getTracksByArtist(String artist) =>
      (select(tracks)
            ..where((t) =>
                t.artist.equals(artist) & t.isAvailable.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.album),
                        (t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<List<Track>> getAllTracksIncludingUnavailable() =>
      select(tracks).get();

  Future<void> upsertTrack(TracksCompanion companion) =>
      into(tracks).insertOnConflictUpdate(companion);

  Future<void> markUnavailable(String id) =>
      (update(tracks)..where((t) => t.id.equals(id))).write(
        const TracksCompanion(isAvailable: Value(false)),
      );

  Future<void> markAvailable(String id) =>
      (update(tracks)..where((t) => t.id.equals(id))).write(
        const TracksCompanion(isAvailable: Value(true)),
      );

  Future<void> incrementPlayCount(String id, int nowMs) =>
      customUpdate(
        'UPDATE tracks SET play_count = play_count + 1, last_played_at = ? WHERE id = ?',
        variables: [Variable<int>(nowMs), Variable<String>(id)],
        updates: {tracks},
      );

  /// FTS search — raw SQL justified for FTS5 virtual table.
  Future<List<String>> searchTrackIds(String query) async {
    final sanitized = query.trim().replaceAll("'", "''");
    final rows = await customSelect(
      "SELECT t.id AS id "
      "FROM tracks_fts f "
      "JOIN tracks t ON t.rowid = f.rowid "
      "WHERE tracks_fts MATCH '$sanitized*' "
      "ORDER BY rank LIMIT 100",
      readsFrom: {tracks},
    ).get();
    return rows.map((r) => r.read<String>('id')).toList();
  }

  Future<List<Track>> getTracksByIds(List<String> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(tracks)..where((t) => t.id.isIn(ids))).get();
  }

  // ── Playlists ──────────────────────────────────────────────────────────

  Stream<List<Playlist>> watchPlaylists() =>
      (select(playlists)
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .watch();

  Future<List<Playlist>> getAllPlaylists() =>
      (select(playlists)
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .get();

  Future<Playlist?> getPlaylistById(String id) =>
      (select(playlists)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<void> insertPlaylist(PlaylistsCompanion companion) =>
      into(playlists).insert(companion);

  Future<void> updatePlaylist(PlaylistsCompanion companion) =>
      update(playlists).replace(companion);

  Future<void> deletePlaylist(String id) =>
      (delete(playlists)..where((p) => p.id.equals(id))).go();

  // ── Playlist Tracks ────────────────────────────────────────────────────

  Future<List<PlaylistTrack>> getPlaylistTracks(String playlistId) =>
      (select(playlistTracks)
            ..where((pt) => pt.playlistId.equals(playlistId))
            ..orderBy([(pt) => OrderingTerm.asc(pt.sortOrder)]))
          .get();

  Future<void> addTrackToPlaylist(PlaylistTracksCompanion companion) =>
      into(playlistTracks).insertOnConflictUpdate(companion);

  Future<void> removeTrackFromPlaylist(
          String playlistId, String trackId) =>
      (delete(playlistTracks)
            ..where((pt) =>
                pt.playlistId.equals(playlistId) &
                pt.trackId.equals(trackId)))
          .go();

  Future<void> clearPlaylistTracks(String playlistId) =>
      (delete(playlistTracks)
            ..where((pt) => pt.playlistId.equals(playlistId)))
          .go();

  Future<int> getMaxSortOrderInPlaylist(String playlistId) async {
    final rows = await (select(playlistTracks)
          ..where((pt) => pt.playlistId.equals(playlistId))
          ..orderBy([(pt) => OrderingTerm.desc(pt.sortOrder)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return -1;
    return rows.first.sortOrder;
  }
}