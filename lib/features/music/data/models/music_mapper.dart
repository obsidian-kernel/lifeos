import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/track_entity.dart';

extension TrackRowToEntity on Track {
  TrackEntity toEntity() {
    return TrackEntity(
      id: id,
      path: path,
      title: title,
      artist: artist,
      album: album,
      albumArtist: albumArtist,
      genre: genre,
      year: year,
      durationMs: durationMs,
      lastPositionMs: lastPositionMs,
      fileSizeBytes: fileSizeBytes,
      extension: extension,
      isAvailable: isAvailable,
      playCount: playCount,
      lastPlayedAt: lastPlayedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(lastPlayedAt!, isUtc: true)
          : null,
      indexedAt: DateTime.fromMillisecondsSinceEpoch(indexedAt, isUtc: true),
      sortOrder: sortOrder,
      artworkPath: artworkPath,
    );
  }
}

extension TrackEntityToCompanion on TrackEntity {
  TracksCompanion toCompanion() {
    return TracksCompanion(
      id: Value(id),
      path: Value(path),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      albumArtist: Value(albumArtist),
      genre: Value(genre),
      year: Value(year),
      durationMs: Value(durationMs),
      lastPositionMs: Value(lastPositionMs),
      fileSizeBytes: Value(fileSizeBytes),
      extension: Value(extension),
      isAvailable: Value(isAvailable),
      playCount: Value(playCount),
      lastPlayedAt: Value(lastPlayedAt?.millisecondsSinceEpoch),
      indexedAt: Value(indexedAt.millisecondsSinceEpoch),
      sortOrder: Value(sortOrder),
      artworkPath: Value(artworkPath),
    );
  }
}

extension PlaylistRowToEntity on Playlist {
  PlaylistEntity toEntity({List<String> trackIds = const []}) {
    return PlaylistEntity(
      id: id,
      name: name,
      trackIds: trackIds,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt, isUtc: true),
    );
  }
}
