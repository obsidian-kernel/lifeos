import 'package:equatable/equatable.dart';

/// Immutable domain entity representing a single audio track.
///
/// Design decisions:
/// - `path` is the source of truth. Everything else is metadata.
/// - `isAvailable` is a runtime check — file may have been deleted
///   since last scan. Never assumed to be true without verification.
/// - Duration stored as milliseconds int to match DB storage.
///   Converted to Duration only at presentation layer.
/// - No embedded artwork bytes in entity — only a flag.
///   Artwork is loaded lazily on demand from the file.
class TrackEntity extends Equatable {
  const TrackEntity({
    required this.id,
    required this.path,
    required this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.genre,
    this.year,
    required this.durationMs,
    required this.fileSizeBytes,
    required this.extension,
    required this.isAvailable,
    required this.playCount,
    this.lastPlayedAt,
    required this.indexedAt,
    this.sortOrder = 0,
  });

  final String id;
  final String path;
  final String title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final String? genre;
  final int? year;
  final int durationMs;
  final int fileSizeBytes;
  final String extension; // mp3, flac, etc.
  final bool isAvailable; // false = file missing from disk
  final int playCount;
  final DateTime? lastPlayedAt; // UTC
  final DateTime indexedAt;     // UTC
  final int sortOrder;

  Duration get duration => Duration(milliseconds: durationMs);

  String get displayArtist => artist ?? 'Unknown Artist';
  String get displayAlbum => album ?? 'Unknown Album';

  TrackEntity copyWith({
    String? title,
    String? artist,
    String? album,
    String? albumArtist,
    String? genre,
    int? year,
    int? durationMs,
    int? fileSizeBytes,
    bool? isAvailable,
    int? playCount,
    DateTime? lastPlayedAt,
    int? sortOrder,
    bool clearLastPlayedAt = false,
  }) {
    return TrackEntity(
      id: id,
      path: path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      durationMs: durationMs ?? this.durationMs,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      extension: extension,
      isAvailable: isAvailable ?? this.isAvailable,
      playCount: playCount ?? this.playCount,
      lastPlayedAt:
          clearLastPlayedAt ? null : lastPlayedAt ?? this.lastPlayedAt,
      indexedAt: indexedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        id, path, title, artist, album, albumArtist,
        genre, year, durationMs, fileSizeBytes, extension,
        isAvailable, playCount, lastPlayedAt, indexedAt, sortOrder,
      ];
}