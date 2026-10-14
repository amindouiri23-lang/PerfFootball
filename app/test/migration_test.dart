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
}
