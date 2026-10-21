import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perffoot/data/database.dart';
import 'package:sqlite3/sqlite3.dart';

// Un téléphone en version 0.1.0 a une base locale v3 : la mise à jour doit ajouter les colonnes et
// tables v4 sans perdre les données, et faire relire joueurs, séances et matchs.
void main() {
  test('migration v3 → v4', () async {
    final file = File('${Directory.systemTemp.createTempSync('perffoot').path}/v3.sqlite');

    // Base v4 complète, puis ramenée à l'état v3 (colonnes et tables v4 retirées).
    final v4 = AppDatabase(NativeDatabase(file));
    await v4.customSelect('SELECT 1').get();
    await v4.close();
    final raw = sqlite3.open(file.path);
    for (final c in ['players.detailed_position', 'players.secondary_position', 'sessions.planned_rpe',
      'matches.phase', 'matches.matchday']) {
      final p = c.split('.');
      raw.execute('ALTER TABLE ${p[0]} DROP COLUMN ${p[1]}');
    }
    for (final t in ['test_types', 'test_results', 'player_profiles', 'player_medical']) {
      raw.execute('DROP TABLE $t');
    }
    raw.execute("INSERT INTO players (id, team_id, first_name, last_name, position, created_at, updated_at) "
        "VALUES ('p1', 't1', 'Lucas', 'Moreau', 'MID', 'x', 'x')");
    raw.execute("INSERT INTO sync_state (table_name, cursor) VALUES ('players', '2026-10-01T00:00:00Z'), "
        "('injuries', '2026-10-01T00:00:00Z')");
    raw.execute('PRAGMA user_version = 3');
    raw.close();

    final db = AppDatabase(NativeDatabase(file));
    final player = await (db.select(db.players)..where((p) => p.id.equals('p1'))).getSingle();
    expect(player.firstName, 'Lucas');
    expect(player.detailedPosition, isNull);
    expect(await db.select(db.testTypes).get(), isEmpty);
    expect(await db.select(db.playerMedical).get(), isEmpty);
    final cursors = {for (final s in await db.select(db.syncState).get()) s.tableName_};
    expect(cursors, {'injuries'}, reason: 'joueurs relus en entier pour recevoir les nouvelles colonnes');
    await db.close();
  });

  test('migration v4 → v5 (champs du formulaire dans le dossier)', () async {
    final file = File('${Directory.systemTemp.createTempSync('perffoot').path}/v4.sqlite');
    final v5 = AppDatabase(NativeDatabase(file));
    await v5.customSelect('SELECT 1').get();
    await v5.close();
    final raw = sqlite3.open(file.path);
    for (final c in ['other_position', 'school_address', 'coach_name', 'manager_name']) {
      raw.execute('ALTER TABLE player_profiles DROP COLUMN $c');
    }
    raw.execute("INSERT INTO player_profiles (id, team_id, player_id, nationality, created_at, updated_at) "
        "VALUES ('p1', 't1', 'p1', 'Française', 'x', 'x')");
    raw.execute("INSERT INTO sync_state (table_name, cursor) VALUES ('player_profiles', '2026-10-01T00:00:00Z')");
    raw.execute('PRAGMA user_version = 4');
    raw.close();

    final db = AppDatabase(NativeDatabase(file));
    final p = await db.select(db.playerProfiles).getSingle();
    expect(p.nationality, 'Française');
    expect(p.coachName, isNull);
    expect(await db.select(db.syncState).get(), isEmpty, reason: 'dossiers relus pour recevoir les nouveaux champs');
    await db.close();
  });

  test('migration v5 → v6 (issues de match et tactiques)', () async {
    final file = File('${Directory.systemTemp.createTempSync('perffoot').path}/v5.sqlite');
    final v6 = AppDatabase(NativeDatabase(file));
    await v6.customSelect('SELECT 1').get();
    await v6.close();
    final raw = sqlite3.open(file.path);
    raw.execute('ALTER TABLE matches DROP COLUMN forfeit_by');
    raw.execute('DROP TABLE tactics');
    raw.execute('DROP TABLE tactic_links');
    raw.execute("INSERT INTO matches (id, team_id, date, kick_off_time, opponent, home_away, competition, created_at, updated_at) "
        "VALUES ('m1', 't1', '2026-10-18', '15:00:00', 'EST', 'H', 'league', 'x', 'x')");
    raw.execute('PRAGMA user_version = 5');
    raw.close();

    final db = AppDatabase(NativeDatabase(file));
    final m = await db.select(db.matches).getSingle();
    expect(m.opponent, 'EST');
    expect(m.forfeitBy, isNull);
    expect(await db.select(db.tactics).get(), isEmpty);
    expect(await db.select(db.tacticLinks).get(), isEmpty);
    await db.close();
  });

  test('migration v6 → v7 (préparation et questionnaires de bien-être)', () async {
    final file = File('${Directory.systemTemp.createTempSync('perffoot').path}/v6.sqlite');
    final v7 = AppDatabase(NativeDatabase(file));
    await v7.customSelect('SELECT 1').get();
    await v7.close();
    final raw = sqlite3.open(file.path);
    raw.execute('ALTER TABLE matches DROP COLUMN formation');
    raw.execute('ALTER TABLE match_players DROP COLUMN slot');
    for (final t in ['session_exercises', 'session_comments', 'wellness_surveys', 'wellness_survey_players']) {
      raw.execute('DROP TABLE $t');
    }
    // Table du bien-être d'avant : séance obligatoire, pas de questionnaire.
    raw.execute('DROP TABLE wellness');
    raw.execute('CREATE TABLE wellness (id TEXT NOT NULL PRIMARY KEY, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, '
        'server_updated_at TEXT, deleted INTEGER NOT NULL DEFAULT 0, is_dirty INTEGER NOT NULL DEFAULT 0, team_id TEXT NOT NULL, '
        'session_id TEXT NOT NULL, player_id TEXT NOT NULL, sleep_hours REAL NOT NULL, sleep_quality INTEGER NOT NULL, '
        'fatigue INTEGER NOT NULL, soreness INTEGER NOT NULL, stress INTEGER NOT NULL, mood INTEGER NOT NULL, remark TEXT)');
    raw.execute("INSERT INTO wellness (id, created_at, updated_at, team_id, session_id, player_id, sleep_hours, sleep_quality, "
        "fatigue, soreness, stress, mood) VALUES ('w1', 'x', 'x', 't1', 's1', 'p1', 8, 4, 4, 4, 4, 4)");
    raw.execute('PRAGMA user_version = 6');
    raw.close();

    final db = AppDatabase(NativeDatabase(file));
    final w = await db.select(db.wellness).getSingle();
    expect(w.sessionId, 's1');
    expect(w.surveyId, isNull);
    expect(await db.select(db.wellnessSurveys).get(), isEmpty);
    expect(await db.select(db.sessionExercises).get(), isEmpty);
    await db.close();
  });

  test('migration v9 → v10 (temps additionnel : noms de colonnes du serveur)', () async {
    final file = File('${Directory.systemTemp.createTempSync('perffoot').path}/v9.sqlite');
    final v10 = AppDatabase(NativeDatabase(file));
    await v10.customSelect('SELECT 1').get();
    await v10.close();
    final raw = sqlite3.open(file.path);
    raw.execute('ALTER TABLE matches RENAME COLUMN added_time_1 TO added_time1');
    raw.execute('ALTER TABLE matches RENAME COLUMN added_time_2 TO added_time2');
    raw.execute("INSERT INTO matches (id, team_id, date, kick_off_time, opponent, home_away, competition, created_at, updated_at, "
        "added_time1) VALUES ('m1', 't1', '2026-10-21', '15:00:00', 'EST', 'H', 'league', 'x', 'x', 3)");
    raw.execute('PRAGMA user_version = 9');
    raw.close();

    final db = AppDatabase(NativeDatabase(file));
    final m = await db.select(db.matches).getSingle();
    expect(m.addedTime1, 3);
    final names = {for (final c in await db.customSelect('PRAGMA table_info(matches)').get()) c.read<String>('name')};
    expect(names, containsAll(['added_time_1', 'added_time_2']));
    expect(names, isNot(contains('added_time1')));
    await db.close();
  });

  test('migration v10 → v11 (batterie de tests de la saison)', () async {
    final file = File('${Directory.systemTemp.createTempSync('perffoot').path}/v10.sqlite');
    final v11 = AppDatabase(NativeDatabase(file));
    await v11.customSelect('SELECT 1').get();
    await v11.close();
    final raw = sqlite3.open(file.path);
    raw.execute('ALTER TABLE test_results DROP COLUMN campaign');
    raw.execute("INSERT INTO test_results (id, team_id, player_id, test_type_id, date, attempt, value, created_at, updated_at) "
        "VALUES ('r1', 't1', 'p1', 'tt1', '2026-09-01', 1, 3.4, 'x', 'x')");
    raw.execute('PRAGMA user_version = 10');
    raw.close();

    final db = AppDatabase(NativeDatabase(file));
    final r = await db.select(db.testResults).getSingle();
    expect(r.value, 3.4);
    expect(r.campaign, isNull);
    await db.close();
  });
}
