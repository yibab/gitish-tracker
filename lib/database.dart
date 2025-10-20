import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Defines the table for storing habits.
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

// Defines the table for storing daily completions of habits.
class Completions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  DateTimeColumn get date => dateTime()();
}

// A simple key-value table for app settings, like the habit goal.
class Settings extends Table {
  // Using a fixed ID of 0 for the single settings row.
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get habitGoal => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Habits, Completions, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // Incremented from 2

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(completions);
          await migrator.createTable(settings);
        }
        if (from < 3) {
          await migrator.addColumn(habits, habits.isDeleted);
        }
      },
    );
  }

  // Habit Methods
  Future<int> addHabit(String name) => into(habits).insert(HabitsCompanion(name: Value(name)));

  // This now only watches for habits that are not soft-deleted.
  Stream<List<Habit>> watchAllHabits() =>
      (select(habits)..where((tbl) => tbl.isDeleted.equals(false))).watch();

  Stream<List<Habit>> watchArchivedHabits() =>
      (select(habits)..where((tbl) => tbl.isDeleted.equals(true))).watch();

  Future<void> archiveHabit(int id) =>
      (update(habits)..where((tbl) => tbl.id.equals(id))).write(const HabitsCompanion(isDeleted: Value(true)));

  Future<void> restoreHabit(int id) =>
      (update(habits)..where((tbl) => tbl.id.equals(id))).write(const HabitsCompanion(isDeleted: Value(false)));

  // Settings Methods
  Stream<int> watchHabitGoal() {
    return (select(settings)..where((tbl) => tbl.id.equals(0)))
        .watchSingleOrNull()
        .map((s) => s?.habitGoal ?? 1);
  }

  Future<void> updateHabitGoal(int goal) {
    return into(settings).insert(
      SettingsCompanion(id: const Value(0), habitGoal: Value(goal)),
      mode: InsertMode.replace,
    );
  }

  // Completion Methods
  Stream<List<Completion>> watchCompletionsForDay(DateTime date) {
    return (select(completions)..where((tbl) => tbl.date.equals(date))).watch();
  }

  Stream<int> watchCompletionCountForDay(DateTime date) {
    return watchCompletionsForDay(date).map((completions) => completions.length);
  }

  Future<void> addCompletion(int habitId, DateTime date) {
    return into(completions).insert(CompletionsCompanion(
      habitId: Value(habitId),
      date: Value(date),
    ));
  }

  Future<void> removeCompletion(int habitId, DateTime date) {
    return (delete(completions)
          ..where((tbl) => tbl.habitId.equals(habitId) & tbl.date.equals(date)))
        .go();
  }

  // Debug Method
  Future<void> debugDumpAllData() async {
    print('--- DATABASE DUMP ---');
    final allHabits = await select(habits).get();
    print('Habits: $allHabits');
    final allCompletions = await select(completions).get();
    print('Completions: $allCompletions');
    final allSettings = await select(settings).get();
    print('Settings: $allSettings');
    print('--- END DUMP ---');
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
