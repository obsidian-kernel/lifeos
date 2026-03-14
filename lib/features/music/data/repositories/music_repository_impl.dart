import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/file_system_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/track_entity.dart';
import '../../domain/repositories/music_repository.dart';
import '../daos/music_dao.dart';
import '../models/music_mapper.dart';
import '../models/playlist_track_table.dart';
import '../models/playlist_table.dart';

class MusicRepositoryImpl implements MusicRepository {
  MusicRepositoryImpl({
    required MusicDao musicDao,
    required FileSystemService fileSystemService,
  })  : _musicDao = musicDao,
        _fileSystemService = fileSystemService;

  final MusicDao _musicDao;
  final FileSystemService _fileSystemService;
  static const _uuid = Uuid();

  @override
  Future<Result<int>> scanDirectory(String directoryPath) async {
    try {
      final scanResult = await _fileSystemService.scanDirectory(
        directoryPath,
        extensions: AppConstants.supportedAudioExtensions,
      );

      if (scanResult.isFailure) {
        return Failure(scanResult.errorOrNull!);
      }

      final files = scanResult.valueOrNull!.files;
      int newCount = 0;

      for (final file in files) {
        final existing = await _musicDao.getTrackByPath(file.path);
        if (existing != null) {
          // Already indexed — mark available if it was stale
          if (!existing.isAvailable) {
            await _musicDao.markAvailable(existing.id);
          }
          continue;
        }

        // New track — extract what metadata we can from filename
        final title = _extractTitle(file.name, file.extension);
        final now = nowUtc();

        final companion = TracksCompanion(
          id: Value(_uuid.v4()),
          path: Value(file.path),
          title: Value(title),
          extension: Value(file.extension),
          fileSizeBytes: Value(file.sizeBytes),
          isAvailable: const Value(true),
          playCount: const Value(0),
          indexedAt: Value(now.millisecondsSinceEpoch),
          sortOrder: const Value(0),
        );

        await _musicDao.upsertTrack(companion);
        newCount++;
      }

      return Success(newCount);
    } catch (e) {
      return Failure(DatabaseError('Scan failed: $e'));
    }
  }

  String _extractTitle(String filename, String extension) {
    // Remove extension suffix from filename
    final withoutExt = filename.endsWith('.$extension')
        ? filename.substring(0, filename.length - extension.length - 1)
        : filename;
    return withoutExt.trim().isEmpty ? filename : withoutExt.trim();
  }

  @override
  Future<Result<int>> reconcileAvailability() async {
    try {
      final all = await _musicDao.getAllTracksIncludingUnavailable();
      int changed = 0;

      for (final track in all) {
        final exists = await File(track.path).exists();
        if (!exists && track.isAvailable) {
          await _musicDao.markUnavailable(track.id);
          changed++;
        } else if (exists && !track.isAvailable) {
          await _musicDao.markAvailable(track.id);
          changed++;
        }
      }

      return Success(changed);
    } catch (e) {
      return Failure(DatabaseError('Reconcile failed: $e'));
    }
  }

  @override
  Future<Result<List<TrackEntity>>> getAllTracks() async {
    try {
      final rows = await _musicDao.getAllTracks();
      return Success(rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Failure(DatabaseError('Failed to get tracks: $e'));
    }
  }

  @override
  Future<Result<TrackEntity?>> getTrackById(String id) async {
    try {
      final row = await _musicDao.getTrackById(id);
      return Success(row?.toEntity());
    } catch (e) {
      return Failure(DatabaseError('Failed to get track: $e'));
    }
  }

  @override
  Future<Result<List<TrackEntity>>> getTracksByAlbum(String album) async {
    try {
      final rows = await _musicDao.getTracksByAlbum(album);
      return Success(rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Failure(DatabaseError('Failed to get album tracks: $e'));
    }
  }

  @override
  Future<Result<List<TrackEntity>>> getTracksByArtist(String artist) async {
    try {
      final rows = await _musicDao.getTracksByArtist(artist);
      return Success(rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Failure(DatabaseError('Failed to get artist tracks: $e'));
    }
  }

  @override
  Future<Result<List<TrackEntity>>> searchTracks(String query) async {
    try {
      if (query.trim().isEmpty) return Success([]);
      final ids = await _musicDao.searchTrackIds(query);
      if (ids.isEmpty) return Success([]);
      final rows = await _musicDao.getTracksByIds(ids);
      return Success(rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Failure(DatabaseError('Search failed: $e'));
    }
  }

  @override
  Stream<List<TrackEntity>> watchAllTracks() {
    return _musicDao
        .watchAllTracks()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  @override
  Future<Result<void>> recordPlay(String trackId) async {
    try {
      await _musicDao.incrementPlayCount(
          trackId, nowUtc().millisecondsSinceEpoch);
      return Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to record play: $e'));
    }
  }

  // ── Playlists ──────────────────────────────────────────────────────────

  @override
  Future<Result<PlaylistEntity>> createPlaylist(String name) async {
    try {
      final trimmed = name.trim();
      if (trimmed.isEmpty) {
        return Failure(const ValidationError('Playlist name cannot be empty'));
      }
      final now = nowUtc();
      final companion = PlaylistsCompanion(
        id: Value(_uuid.v4()),
        name: Value(trimmed),
        createdAt: Value(now.millisecondsSinceEpoch),
        updatedAt: Value(now.millisecondsSinceEpoch),
      );
      await _musicDao.insertPlaylist(companion);
      final row = await _musicDao.getPlaylistById(companion.id.value);
      return Success(row!.toEntity());
    } catch (e) {
      return Failure(DatabaseError('Failed to create playlist: $e'));
    }
  }

  @override
  Future<Result<PlaylistEntity>> renamePlaylist(
      String id, String name) async {
    try {
      final trimmed = name.trim();
      if (trimmed.isEmpty) {
        return Failure(const ValidationError('Playlist name cannot be empty'));
      }
      final row = await _musicDao.getPlaylistById(id);
      if (row == null) {
        return Failure(NotFoundError('Playlist not found: $id'));
      }
      final updated = PlaylistsCompanion(
        id: Value(id),
        name: Value(trimmed),
        createdAt: Value(row.createdAt),
        updatedAt: Value(nowUtc().millisecondsSinceEpoch),
      );
      await _musicDao.updatePlaylist(updated);
      return Success(updated.toEntity());
    } catch (e) {
      return Failure(DatabaseError('Failed to rename playlist: $e'));
    }
  }

  @override
  Future<Result<void>> deletePlaylist(String id) async {
    try {
      await _musicDao.attachedDatabase.transaction(() async {
        await _musicDao.clearPlaylistTracks(id);
        await _musicDao.deletePlaylist(id);
      });
      return Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to delete playlist: $e'));
    }
  }

  @override
  Future<Result<void>> addTrackToPlaylist(
      String playlistId, String trackId) async {
    try {
      final maxOrder =
          await _musicDao.getMaxSortOrderInPlaylist(playlistId);
      final companion = PlaylistTracksCompanion(
        playlistId: Value(playlistId),
        trackId: Value(trackId),
        sortOrder: Value(maxOrder + 1),
      );
      await _musicDao.addTrackToPlaylist(companion);
      return Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to add track to playlist: $e'));
    }
  }

  @override
  Future<Result<void>> removeTrackFromPlaylist(
      String playlistId, String trackId) async {
    try {
      await _musicDao.removeTrackFromPlaylist(playlistId, trackId);
      return Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to remove track: $e'));
    }
  }

  @override
  Future<Result<void>> reorderPlaylistTrack(
      String playlistId, int oldIndex, int newIndex) async {
    try {
      final rows = await _musicDao.getPlaylistTracks(playlistId);
      if (oldIndex < 0 ||
          oldIndex >= rows.length ||
          newIndex < 0 ||
          newIndex >= rows.length) {
        return Success(null);
      }

      final reordered = [...rows];
      final item = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, item);

      await _musicDao.attachedDatabase.transaction(() async {
        for (int i = 0; i < reordered.length; i++) {
          final companion = PlaylistTracksCompanion(
            playlistId: Value(playlistId),
            trackId: Value(reordered[i].trackId),
            sortOrder: Value(i),
          );
          await _musicDao.addTrackToPlaylist(companion);
        }
      });
      return Success(null);
    } catch (e) {
      return Failure(DatabaseError('Failed to reorder playlist: $e'));
    }
  }

  @override
  Future<Result<List<PlaylistEntity>>> getPlaylists() async {
    try {
      final rows = await _musicDao.getAllPlaylists();
      final playlists = await Future.wait(rows.map((row) async {
        final tracks = await _musicDao.getPlaylistTracks(row.id);
        return row.toEntity(trackIds: tracks.map((t) => t.trackId).toList());
      }));
      return Success(playlists);
    } catch (e) {
      return Failure(DatabaseError('Failed to get playlists: $e'));
    }
  }

  @override
  Future<Result<PlaylistEntity?>> getPlaylistById(String id) async {
    try {
      final row = await _musicDao.getPlaylistById(id);
      if (row == null) return Success(null);
      final tracks = await _musicDao.getPlaylistTracks(id);
      return Success(
          row.toEntity(trackIds: tracks.map((t) => t.trackId).toList()));
    } catch (e) {
      return Failure(DatabaseError('Failed to get playlist: $e'));
    }
  }

  @override
  Future<Result<List<TrackEntity>>> getPlaylistTracks(
      String playlistId) async {
    try {
      final ptRows = await _musicDao.getPlaylistTracks(playlistId);
      if (ptRows.isEmpty) return Success([]);
      final ids = ptRows.map((r) => r.trackId).toList();
      final trackRows = await _musicDao.getTracksByIds(ids);
      final byId = {for (final t in trackRows) t.id: t};
      final ordered = ids
          .map((id) => byId[id]?.toEntity())
          .whereType<TrackEntity>()
          .toList();
      return Success(ordered);
    } catch (e) {
      return Failure(DatabaseError('Failed to get playlist tracks: $e'));
    }
  }

  @override
  Stream<List<PlaylistEntity>> watchPlaylists() {
    return _musicDao.watchPlaylists().asyncMap((rows) async {
      return Future.wait(rows.map((row) async {
        final tracks = await _musicDao.getPlaylistTracks(row.id);
        return row.toEntity(trackIds: tracks.map((t) => t.trackId).toList());
      }));
    });
  }
}

// Helper extension for companion→entity conversion in rename
extension _PlaylistsCompanionToEntity on PlaylistsCompanion {
  PlaylistEntity toEntity() {
    return PlaylistEntity(
      id: id.value,
      name: name.value,
      trackIds: const [],
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(createdAt.value, isUtc: true),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(updatedAt.value, isUtc: true),
    );
  }
}