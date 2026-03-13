import 'package:drift/drift.dart';

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}