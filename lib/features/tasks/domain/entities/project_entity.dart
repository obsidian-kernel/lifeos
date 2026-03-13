import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  const ProjectEntity({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    this.archivedAt,
  });

  final String id;
  final String name;
  final int color;         // ARGB int
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  ProjectEntity copyWith({
    String? name,
    int? color,
    int? sortOrder,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
  }) {
    return ProjectEntity(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      archivedAt: clearArchivedAt ? null : archivedAt ?? this.archivedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, color, sortOrder, createdAt, archivedAt];
}