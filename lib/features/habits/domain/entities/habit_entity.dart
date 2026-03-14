import 'package:equatable/equatable.dart';

class HabitEntity extends Equatable {
  const HabitEntity({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.color,
    required this.frequencyJson,
    required this.targetCount,
    this.unit,
    required this.isArchived,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? icon;
  final String? color;
  final String frequencyJson;
  final int targetCount;
  final String? unit;
  final bool isArchived;
  final double sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        color,
        frequencyJson,
        targetCount,
        unit,
        isArchived,
        sortOrder,
        createdAt,
        updatedAt,
      ];

  HabitEntity copyWith({
    String? title,
    String? description,
    String? icon,
    String? color,
    String? frequencyJson,
    int? targetCount,
    String? unit,
    bool? isArchived,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequencyJson: frequencyJson ?? this.frequencyJson,
      targetCount: targetCount ?? this.targetCount,
      unit: unit ?? this.unit,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HabitLogEntity extends Equatable {
  const HabitLogEntity({
    required this.id,
    required this.habitId,
    required this.loggedAt,
    required this.count,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String habitId;
  final DateTime loggedAt; // day-level (UTC midnight)
  final int count;
  final String? note;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, habitId, loggedAt, count, note, createdAt];
}
