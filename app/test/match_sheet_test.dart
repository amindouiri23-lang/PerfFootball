import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:perffoot/data/database.dart';
import 'package:perffoot/data/sync.dart';
import 'package:perffoot/features/exports/document_exports.dart';
import 'package:perffoot/features/matches/match_repository.dart';
import 'package:perffoot/features/tactics/tactic_repository.dart';
import 'package:perffoot/features/team/team_repository.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  testWidgets('feuille de match PDF : section Changements et colonne Changement', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final team = Team(id: 't', createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, name: 'Senior B',
        category: 'senior', season: '2026-2027', createdBy: 'u');
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      teamsProvider.overrideWith((ref) => Stream.value([team])),
    ]);
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    await tester.runAsync(() async {
      Future<void> player(String id, String first, String last, int n) => db.into(db.players).insert(PlayersCompanion.insert(
          id: id, teamId: 't', firstName: first, lastName: last, position: 'MID', createdAt: 'x', updatedAt: 'x',
          shirtNumber: Value(n)));
      await player('a', 'Ayoub', 'Tizaoui', 4);
      await player('b', 'Hamza', 'Nasri', 12);
      await player('c', 'Salim', 'Mejri', 15);
      await db.into(db.matches).insert(MatchesCompanion.insert(
          id: 'm', teamId: 't', date: '2026-10-20', kickOffTime: '15:00:00', opponent: 'Ess', homeAway: 'H',
          competition: 'league', createdAt: 'x', updatedAt: 'x', status: const Value('completed'),
          goalsFor: const Value(1), goalsAgainst: const Value(0), formation: const Value('4-4-2')));
      Future<void> row(String p, String role, int? slot, int minutes) => db.into(db.matchPlayers).insert(
          MatchPlayersCompanion.insert(id: 'r$p', teamId: 't', matchId: 'm', playerId: p, createdAt: 'x', updatedAt: 'x',
              role: Value(role), slot: Value(slot), minutesPlayed: Value(minutes)));
      await row('a', 'starter', 0, 63);
      await row('c', 'starter', 1, 90);
      await row('b', 'sub', null, 27);
      await db.into(db.matchEvents).insert(MatchEventsCompanion.insert(
          id: 'e', teamId: 't', matchId: 'm', type: 'substitution', minute: 63, createdAt: 'x', updatedAt: 'x',
          playerId: const Value('b'), assistPlayerId: const Value('a')));

      final m = await db.select(db.matches).getSingle();
      // Comme l'écran du match : les données lues par l'export sont écoutées (Riverpod 3 met en pause un
      // fournisseur que personne n'écoute).
      for (final p in [playersProvider('t'), matchPlayersProvider('m'), matchEventsProvider('m'), matchInjuriesProvider('m'),
        teamTacticLinksProvider('t'), tacticsProvider('t'), teamsProvider]) {
        container.listen(p, (_, _) {});
      }
      final bytes = await container.read(documentExportsProvider).matchSheet(m);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      const out = String.fromEnvironment('PDF_OUT');
      if (out.isNotEmpty) File(out).writeAsBytesSync(bytes);
    });
  });
}
