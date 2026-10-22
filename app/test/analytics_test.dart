import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:perffoot/data/database.dart';
import 'package:perffoot/features/analytics/analytics_data.dart';
import 'package:perffoot/features/analytics/analytics_export.dart';
import 'package:perffoot/features/analytics/analytics_report.dart';
import 'package:perffoot/features/import/xlsx.dart';
import 'package:perffoot/features/matches/match_repository.dart';

Player _player(String id, String last, String position) => Player(
      id: id, createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't', firstName: 'Joueur',
      lastName: last, position: position,
    );

TrainingSession _session(String id, String date) => TrainingSession(
      id: id, createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't', date: date,
      startTime: '18:00:00', type: 'physical', plannedDurationMin: 90, status: 'completed',
    );

SessionPlayer _sp(String session, String player, {bool present = true, int? rpe, int? min}) => SessionPlayer(
      id: '$session$player', createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't',
      sessionId: session, playerId: player, present: present, rpe: rpe, durationMin: min,
    );

FootballMatch _match(String id, String date, int gf, int ga) => FootballMatch(
      id: id, createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't', date: date,
      kickOffTime: '15:00:00', opponent: 'EST', homeAway: 'H', competition: 'league', durationMin: 90,
      goalsFor: gf, goalsAgainst: ga, status: 'completed', rpeRequested: false,
    );

MatchPlayer _mp(String match, String player, int minutes, int rpe) => MatchPlayer(
      id: '$match$player', createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't',
      matchId: match, playerId: player, present: true, minutesPlayed: minutes, rpe: rpe,
    );

MatchEvent _goal(String match, String player, {String? assist}) => MatchEvent(
      id: '$match$player${assist ?? ''}', createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't',
      matchId: match, playerId: player, type: 'goal', minute: 10, assistPlayerId: assist,
    );

Injury _injury(String player, String date, {String? back}) => Injury(
      id: 'i$player', createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't', playerId: player,
      date: date, bodyArea: 'thigh_back', type: 'muscle', mechanism: 'non_contact', severity: 'moderate', returnDate: back,
    );

WellnessEntry _w(String player, int each) => WellnessEntry(
      id: 'w$player', createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't', playerId: player,
      sleepHours: 8, sleepQuality: each, fatigue: each, soreness: each, stress: each, mood: each,
    );

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  // Deux joueurs ; semaine du 12 au 18 octobre 2026 et les 4 semaines d'avant pour l'ACWR.
  final input = AnalyticsInput(
    players: [_player('a', 'Ayari', 'MID'), _player('b', 'Ben Salem', 'DEF')],
    sessions: [
      for (var i = 0; i < 5; i++) _session('s$i', '2026-${i == 0 ? '09-21' : i == 1 ? '09-28' : i == 2 ? '10-05' : i == 3 ? '10-12' : '10-13'}'),
    ],
    sessionPlayers: [
      for (var i = 0; i < 4; i++) _sp('s$i', 'a', rpe: 5, min: 60), // 300 UA par semaine
      _sp('s4', 'a', rpe: 8, min: 90), // + 720 UA la dernière semaine
      _sp('s3', 'b', present: false),
      _sp('s4', 'b', rpe: 6, min: 50),
    ],
    matches: [_match('m1', '2026-10-17', 2, 1)],
    matchPlayers: [_mp('m1', 'a', 90, 7), _mp('m1', 'b', 30, 5)],
    events: [_goal('m1', 'a', assist: 'b')],
    wellness: [(entry: _w('a', 4), day: DateTime(2026, 10, 13)), (entry: _w('b', 3), day: DateTime(2026, 10, 13))],
    injuries: [_injury('b', '2026-10-15')],
  );
  final filter = AnalyticsFilter(from: DateTime(2026, 10, 12), to: DateTime(2026, 10, 18));
  final a = Analytics.compute(input, filter, today: DateTime(2026, 10, 18));

  test('charge = RPE × minutes, séances et matchs', () {
    final ra = a.rows.firstWhere((r) => r.player.id == 'a');
    expect(ra.sessionLoad, 300 + 720);
    expect(ra.matchLoad, 630);
    expect(a.totalLoad, 300 + 720 + 630 + 300 + 150);
    expect(a.weeks, hasLength(1));
    expect(a.weeks.single.sessions, 300 + 720 + 300);
    expect(a.weeks.single.matches, 630 + 150);
  });

  test('ACWR = charge 7 jours ÷ (charge 28 jours ÷ 4)', () {
    final ra = a.rows.firstWhere((r) => r.player.id == 'a');
    // 7 jours : 300 + 720 + 630 = 1650 ; 28 jours : 3 × 300 + 1650 = 2550 → 1650 / 637,5.
    expect(ra.acwr, closeTo(1650 / (2550 / 4), 1e-9));
    // Une seule semaine de charge : pas d'ACWR.
    expect(a.rows.firstWhere((r) => r.player.id == 'b').acwr, isNull);
  });

  test('présence, buts, passes, bien-être, blessures', () {
    final rb = a.rows.firstWhere((r) => r.player.id == 'b');
    expect(rb.sessionsPlanned, 2);
    expect(rb.sessionsPresent, 1);
    expect(rb.assists, 1);
    expect(a.rows.firstWhere((r) => r.player.id == 'a').goals, 1);
    expect(a.wellnessAvg, (20 + 15) / 2);
    expect(a.openInjuries, 1);
    expect(a.daysOut, 3);
    expect(a.matches.single.result, 'W');
  });

  test('filtre par poste', () {
    final def = Analytics.compute(input, AnalyticsFilter(from: filter.from, to: filter.to, position: 'DEF'),
        today: DateTime(2026, 10, 18));
    expect(def.rows.map((r) => r.player.id), ['b']);
    expect(def.totalLoad, 300 + 150);
  });

  test('export Excel : un onglet par page, relisible', () {
    final report = buildReport(a, dashboardPages.toSet());
    final bytes = buildXlsx(const ReportHeader(team: 'Cadet A', period: '12 oct. – 18 oct. 2026'), report);
    final sheets = readXlsx(bytes);
    expect(sheets.map((s) => s.name), ['Vue d\'ensemble', 'Charge et ACWR', 'Bien-être', 'Matchs', 'Blessures']);
    final overview = sheets.first;
    expect(overview.text(1, 1), 'PerfFoot - Vue d\'ensemble');
    final (row, _) = overview.find((t) => t == 'Joueur Ayari')!;
    expect(overview.number(row, 8), 1650);
  });

  test('export PDF', () async {
    final report = buildReport(a, dashboardPages.toSet());
    final bytes = await buildPdf(const ReportHeader(team: 'Cadet A', period: '12 oct. – 18 oct. 2026'), report);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(2000));
    final out = const String.fromEnvironment('PDF_OUT');
    if (out.isNotEmpty) File(out).writeAsBytesSync(bytes);
  });
}
