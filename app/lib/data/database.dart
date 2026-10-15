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
  TextColumn get detailedPosition => text().nullable()();
  TextColumn get secondaryPosition => text().nullable()();
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
  /// RPE visé : charge prévue = durée prévue × RPE prévu.
  IntColumn get plannedRpe => integer().nullable()();
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
  /// Phase de championnat (first_leg / second_leg) et numéro de journée.
  TextColumn get phase => text().nullable()();
  IntColumn get matchday => integer().nullable()();
  /// Forfait (status 'forfeit') : us = défaite 0-3, opponent = victoire 3-0.
  TextColumn get forfeitBy => text().nullable()();
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

/// Catalogue des tests : team_id null = test commun (lecture seule), sinon test ajouté par l'équipe.
class TestTypes extends Table with SyncColumns {
  TextColumn get teamId => text().nullable()();
  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  TextColumn get unit => text().nullable()();
  TextColumn get category => text()();
  /// higher / lower / none : sens du meilleur résultat.
  TextColumn get better => text()();
  IntColumn get attempts => integer().withDefault(const Constant(1))();
  IntColumn get sortOrder => integer().withDefault(const Constant(100))();
}

/// Un résultat par joueur, test, jour et essai (id déterministe).
class TestResults extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get playerId => text()();
  TextColumn get testTypeId => text()();
  TextColumn get date => text()();
  IntColumn get attempt => integer().withDefault(const Constant(1))();
  RealColumn get value => real()();
  TextColumn get remark => text().nullable()();
}

/// Dossier administratif du joueur (id = player_id).
class PlayerProfiles extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get playerId => text()();
  TextColumn get nationality => text().nullable()();
  TextColumn get birthPlace => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get school => text().nullable()();
  TextColumn get schoolYear => text().nullable()();
  TextColumn get fatherName => text().nullable()();
  TextColumn get fatherNationality => text().nullable()();
  TextColumn get fatherOccupation => text().nullable()();
  TextColumn get fatherMaritalStatus => text().nullable()();
  TextColumn get motherName => text().nullable()();
  TextColumn get motherNationality => text().nullable()();
  TextColumn get motherMaritalStatus => text().nullable()();
  TextColumn get previousClub => text().nullable()();
  TextColumn get previousClubCity => text().nullable()();
  IntColumn get yearsTraining => integer().nullable()();
  TextColumn get preferredRole => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get otherPosition => text().nullable()();
  TextColumn get schoolAddress => text().nullable()();
  TextColumn get coachName => text().nullable()();
  TextColumn get managerName => text().nullable()();
}

/// Dossier médical (id = player_id) : données de santé, visibles du seul propriétaire de l'équipe.
@DataClassName('MedicalRecord')
class PlayerMedical extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get playerId => text()();
  TextColumn get consentDate => text()();
  /// player / guardian
  TextColumn get consentBy => text()();
  TextColumn get allergies => text().nullable()();
  TextColumn get conditions => text().nullable()();
  TextColumn get lowBpAnxiety => text().nullable()();
  TextColumn get surgeries => text().nullable()();
  TextColumn get recentInjuries => text().nullable()();
  TextColumn get remarks => text().nullable()();
}

/// Tactique (coup de pied arrêté ou situation personnalisée) : `board` est le JSON des pions et flèches.
class Tactics extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get side => text()();
  TextColumn get pitch => text().withDefault(const Constant('half'))();
  TextColumn get board => text().withDefault(const Constant('{}'))();
  TextColumn get notes => text().nullable()();
}

/// Tactique travaillée en séance ou prévue pour un match (id déterministe : tactique + séance ou match).
class TacticLinks extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get tacticId => text()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get matchId => text().nullable()();
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
  TestTypes, TestResults, PlayerProfiles, PlayerMedical, Tactics, TacticLinks,
  SyncState, LocalSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2 : séances, présence, bien-être, blessures.
            for (final TableInfo<Table, dynamic> t in [sessions, sessionPlayers, wellness, injuries]) {
              await m.createTable(t);
            }
          }
          if (from < 3) {
            // v3 : matchs, feuilles de match, événements.
            for (final TableInfo<Table, dynamic> t in [matches, matchPlayers, matchEvents]) {
              await m.createTable(t);
            }
          }
          if (from < 4) {
            // v4 : charge prévue, postes détaillés, phase et journée, tests, dossiers du joueur.
            await m.addColumn(players, players.detailedPosition);
            await m.addColumn(players, players.secondaryPosition);
            await m.addColumn(sessions, sessions.plannedRpe);
            await m.addColumn(matches, matches.phase);
            await m.addColumn(matches, matches.matchday);
            for (final TableInfo<Table, dynamic> t in [testTypes, testResults, playerProfiles, playerMedical]) {
              await m.createTable(t);
            }
            // Les lignes existantes doivent être relues pour recevoir les nouvelles colonnes.
            for (final name in ['players', 'sessions', 'matches']) {
              await (delete(syncState)..where((s) => s.tableName_.equals(name))).go();
            }
          }
          // v5 : champs du formulaire du club dans le dossier. Venant de v3, la table vient d'être créée
          // complète : les colonnes ne s'ajoutent qu'à une base déjà en v4.
          if (from == 4) {
            for (final c in [playerProfiles.otherPosition, playerProfiles.schoolAddress, playerProfiles.coachName,
              playerProfiles.managerName]) {
              await m.addColumn(playerProfiles, c);
            }
            await (delete(syncState)..where((s) => s.tableName_.equals('player_profiles'))).go();
          }
          if (from < 6) {
            // v6 : issues de match (forfait…) et tactiques. Une base venant de v2 a reçu la table des matchs
            // complète à l'étape v3 : la colonne n'est ajoutée que si elle manque.
            final cols = await customSelect('PRAGMA table_info(matches)').get();
            if (!cols.any((c) => c.read<String>('name') == 'forfeit_by')) {
              await m.addColumn(matches, matches.forfeitBy);
            }
            for (final TableInfo<Table, dynamic> t in [tactics, tacticLinks]) {
              await m.createTable(t);
            }
          }
        },
      );

  /// Vide toutes les données (déconnexion : l'appareil peut servir à un autre membre du staff).
  /// Les réglages de l'appareil (thème, durées par défaut) sont conservés.
  Future<void> wipe({Set<String> keepSettings = const {}}) => transaction(() async {
        for (final table in allTables.where((t) => t != localSettings)) {
          await delete(table).go();
        }
        await (delete(localSettings)..where((s) => s.key.isNotIn(keepSettings))).go();
      });

  Future<String?> setting(String key) async =>
      (await (select(localSettings)..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Stream<String?> watchSetting(String key) =>
      (select(localSettings)..where((s) => s.key.equals(key))).watchSingleOrNull().map((s) => s?.value);

  Future<void> setSetting(String key, String value) =>
      into(localSettings).insertOnConflictUpdate(LocalSettingsCompanion.insert(key: key, value: value));
}
