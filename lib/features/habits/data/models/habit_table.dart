import 'package:drift/drift.dart';

class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()(); // emoji or icon key
  TextColumn get color => text().nullable()(); // hex string
  TextColumn get frequency => text()(); // JSON: {type: daily|weekly, days:[...]}
  IntColumn get targetCount => integer().withDefault(const Constant(1))();
  TextColumn get unit => text().nullable()(); // e.g., "glasses"
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitLogs extends Table {
  TextColumn get id => text()();
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  IntColumn get loggedAt => integer()(); // UTC day epoch ms (midnight)
  IntColumn get count => integer().withDefault(const Constant(1))();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
