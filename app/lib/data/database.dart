import 'package:drift/drift.dart';

import 'connection_native.dart' if (dart.library.js_interop) 'connection_web.dart';

part 'database.g.dart';

// Base locale : copie des tables Supabase (mêmes noms de tables et de colonnes) + is_dirty.
// Dates et horodatages en texte ISO, transmis tels quels à Supabase (docs/01 §4 et §6).

/// Colonnes techniques communes à toutes les tables synchronisées.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get serverUpdatedAt => text().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Teams extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get clubName => text().nullable()();
  TextColumn get category => text()();
  TextColumn get season => text()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get createdBy => text()();
}

/// Lecture seule : écrite par le serveur à la création d'une équipe.
class TeamMembers extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text()();
}

class Players extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  IntColumn get shirtNumber => integer().nullable()();
  TextColumn get position => text()();
  TextColumn get birthDate => text().nullable()();
  TextColumn get dominantFoot => text().nullable()();
  IntColumn get heightCm => integer().nullable()();
  TextColumn get photoPath => text().nullable()();
}

/// Curseur de synchronisation par table : plus grand server_updated_at reçu.
class SyncState extends Table {
  TextColumn get tableName_ => text().named('table_name')();
  TextColumn get cursor => text()();

  @override
  Set<Column> get primaryKey => {tableName_};
}

/// Réglages de l'appareil (équipe active…).
class LocalSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Teams, TeamMembers, Players, SyncState, LocalSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;

  /// Vide toutes les données (déconnexion : l'appareil peut servir à un autre membre du staff).
  Future<void> wipe() => transaction(() async {
        for (final table in allTables) {
          await delete(table).go();
        }
      });

  Future<String?> setting(String key) async =>
      (await (select(localSettings)..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Stream<String?> watchSetting(String key) =>
      (select(localSettings)..where((s) => s.key.equals(key))).watchSingleOrNull().map((s) => s?.value);

  Future<void> setSetting(String key, String value) =>
      into(localSettings).insertOnConflictUpdate(LocalSettingsCompanion.insert(key: key, value: value));
}
