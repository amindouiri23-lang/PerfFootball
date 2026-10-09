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

/// Séance d'entraînement. Nom de classe distinct de `Session` (Supabase Auth).
@DataClassName('TrainingSession')
class Sessions extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get date => text()();
  TextColumn get startTime => text()();
  TextColumn get type => text()();
  IntColumn get plannedDurationMin => integer().withDefault(const Constant(90))();
  TextColumn get objective => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('planned'))();
}

/// Présence et charge d'un joueur pour une séance (id déterministe : séance + joueur).
class SessionPlayers extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get sessionId => text()();
  TextColumn get playerId => text()();
  BoolColumn get present => boolean().withDefault(const Constant(true))();
  TextColumn get absenceReason => text().nullable()();
  IntColumn get durationMin => integer().nullable()();
  IntColumn get rpe => integer().nullable()();
  TextColumn get remark => text().nullable()();
}

/// Questionnaire de bien-être après une séance (id déterministe : séance + joueur).
@DataClassName('WellnessEntry')
class Wellness extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get sessionId => text()();
  TextColumn get playerId => text()();
  RealColumn get sleepHours => real()();
  IntColumn get sleepQuality => integer()();
  IntColumn get fatigue => integer()();
  IntColumn get soreness => integer()();
  IntColumn get stress => integer()();
  IntColumn get mood => integer()();
  TextColumn get remark => text().nullable()();
}

@DataClassName('FootballMatch')
class Matches extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get date => text()();
  TextColumn get kickOffTime => text()();
  TextColumn get opponent => text()();
  TextColumn get homeAway => text()();
  TextColumn get competition => text()();
  IntColumn get durationMin => integer().withDefault(const Constant(90))();
  IntColumn get goalsFor => integer().nullable()();
  IntColumn get goalsAgainst => integer().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('planned'))();
}

/// Feuille de match d'un joueur (id déterministe : match + joueur).
class MatchPlayers extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get matchId => text()();
  TextColumn get playerId => text()();
  BoolColumn get present => boolean().withDefault(const Constant(true))();
  TextColumn get absenceReason => text().nullable()();
  TextColumn get role => text().nullable()();
  IntColumn get minutesPlayed => integer().nullable()();
  IntColumn get rpe => integer().nullable()();
  TextColumn get remark => text().nullable()();
}

/// But (avec passeur éventuel) ou carton. Les blessures de match sont dans Injuries.
class MatchEvents extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get matchId => text()();
  TextColumn get playerId => text()();
  TextColumn get type => text()();
  IntColumn get minute => integer()();
  TextColumn get assistPlayerId => text().nullable()();
  TextColumn get remark => text().nullable()();
}

class Injuries extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get playerId => text()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get matchId => text().nullable()();
  IntColumn get minute => integer().nullable()();
  TextColumn get date => text()();
  TextColumn get bodyArea => text()();
  TextColumn get side => text().nullable()();
  TextColumn get type => text()();
  TextColumn get mechanism => text()();
  TextColumn get severity => text()();
  TextColumn get description => text().nullable()();
  TextColumn get expectedReturnDate => text().nullable()();
  TextColumn get returnDate => text().nullable()();
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

@DriftDatabase(tables: [
  Teams, TeamMembers, Players, Sessions, SessionPlayers, Wellness, Matches, MatchPlayers, MatchEvents, Injuries,
  SyncState, LocalSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2 : séances, présence, bien-être, blessures.
            for (final TableInfo t in [sessions, sessionPlayers, wellness, injuries]) {
              await m.createTable(t);
            }
          }
          if (from < 3) {
            // v3 : matchs, feuilles de match, événements.
            for (final TableInfo t in [matches, matchPlayers, matchEvents]) {
              await m.createTable(t);
            }
          }
        },
      );

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
