import 'package:equatable/equatable.dart';

class PlaylistEntity extends Equatable {
  const PlaylistEntity({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final List<String> trackIds; // ordered list of track IDs
  final DateTime createdAt;    // UTC
  final DateTime updatedAt;    // UTC

  int get trackCount => trackIds.length;

  PlaylistEntity copyWith({
    String? name,
    List<String>? trackIds,
    DateTime? updatedAt,
  }) {
    return PlaylistEntity(
      id: id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, trackIds, createdAt, updatedAt];
}