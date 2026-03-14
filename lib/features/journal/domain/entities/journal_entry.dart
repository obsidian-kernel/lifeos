import 'package:equatable/equatable.dart';

class JournalEntryEntity extends Equatable {
  const JournalEntryEntity({
    required this.id,
    this.title,
    required this.body,
    this.mood,
    this.moodLabel,
    this.tags = const [],
    this.weatherJson,
    this.location,
    required this.wordCount,
    required this.isPinned,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? title;
  final String body;
  final int? mood; // 1-5
  final String? moodLabel;
  final List<String> tags;
  final String? weatherJson;
  final String? location;
  final int wordCount;
  final bool isPinned;
  final DateTime entryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntryEntity copyWith({
    String? title,
    String? body,
    int? mood,
    String? moodLabel,
    List<String>? tags,
    String? weatherJson,
    String? location,
    int? wordCount,
    bool? isPinned,
    DateTime? entryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntryEntity(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      mood: mood ?? this.mood,
      moodLabel: moodLabel ?? this.moodLabel,
      tags: tags ?? this.tags,
      weatherJson: weatherJson ?? this.weatherJson,
      location: location ?? this.location,
      wordCount: wordCount ?? this.wordCount,
      isPinned: isPinned ?? this.isPinned,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        mood,
        moodLabel,
        tags,
        weatherJson,
        location,
        wordCount,
        isPinned,
        entryDate,
        createdAt,
        updatedAt,
      ];
}
