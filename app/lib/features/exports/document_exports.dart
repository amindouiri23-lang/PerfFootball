import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/pdf_kit.dart';
import '../../data/database.dart';
import '../matches/lineup_screen.dart' show formations;
import '../matches/match_repository.dart';
import '../sessions/session_prep.dart' show sessionExercisesProvider;
import '../sessions/session_repository.dart';
import '../tactics/tactic_board.dart';
import '../tactics/tactic_export.dart';
import '../tactics/tactic_render.dart';
import '../tactics/tactic_repository.dart';
import '../team/team_repository.dart';

// Documents PDF : programme d'une séance d'entraînement et feuille de match. Les données sont lues dans la base
// locale au moment de l'export ; les schémas (tactiques, composition) sont dessinés en image.

String _longDate(String iso) {
  final s = DateFormat('EEEE d MMMM y', 'fr_FR').format(DateTime.parse(iso));
  return s[0].toUpperCase() + s.substring(1);
}

String _teamName(Ref ref, String teamId) =>
    (ref.read(teamsProvider).value ?? const <Team>[]).where((t) => t.id == teamId).firstOrNull?.name ?? '';

Future<Map<String, Player>> _players(Ref ref, String teamId) async =>
    {for (final p in await ref.read(playersProvider(teamId).future)) p.id: p};

/// Tactiques rattachées à une séance ou un match, avec leur schéma.
Future<List<(Tactic, List<Uint8List>)>> _linkedTactics(Ref ref, String teamId, Map<String, Player> players,
    {String? sessionId, String? matchId, Set<String> exclude = const {}}) async {
  final links = await ref.read(teamTacticLinksProvider(teamId).future);
  final tactics = {for (final t in await ref.read(tacticsProvider(teamId).future)) t.id: t};
  final ids = {
    for (final l in links)
      if ((sessionId != null && l.sessionId == sessionId) || (matchId != null && l.matchId == matchId)) l.tacticId,
  }.difference(exclude);
  return [
    for (final id in ids)
      if (tactics[id] case final Tactic t) (t, await renderTacticSteps(t, players, width: 900)),
  ];
}

// ---------------------------------------------------------------------------
// Programme de séance
// ---------------------------------------------------------------------------

final documentExportsProvider = Provider<DocumentExports>((ref) => DocumentExports(ref));

class DocumentExports {
  DocumentExports(this._ref);

  final Ref _ref;

  /// Programme de la séance : informations, exercices (avec leur tactique), tactiques travaillées, présence.
  Future<Uint8List> sessionProgram(TrainingSession s) async {
    final ref = _ref;
    final players = await _players(ref, s.teamId);
    final exercises = await ref.read(sessionExercisesProvider(s.id).future);
    final tactics = {for (final t in await ref.read(tacticsProvider(s.teamId).future)) t.id: t};
    final exerciseTactics = <String, List<Uint8List>>{
      for (final e in exercises)
        if (tactics[e.tacticId] case final Tactic t) t.id: await renderTacticSteps(t, players, width: 900),
    };
    final linked = await _linkedTactics(ref, s.teamId, players, sessionId: s.id, exclude: exerciseTactics.keys.toSet());
    final rows = s.status == 'planned' ? const <SessionPlayer>[] : await ref.read(sessionPlayersProvider(s.id).future);
    final total = exercises.fold(0, (sum, e) => sum + (e.durationMin ?? 0));
    String name(String id) => players[id]?.fullName ?? '—';
    final present = rows.where((r) => r.present).toList()..sort((a, b) => name(a.playerId).compareTo(name(b.playerId)));
    final absent = rows.where((r) => !r.present).toList()..sort((a, b) => name(a.playerId).compareTo(name(b.playerId)));

    return buildPdfDocument(
      title: 'Programme de séance',
      subtitle: [_teamName(ref, s.teamId), _longDate(s.date), s.time, sessionTypes[s.type] ?? s.type].join(' · '),
      body: () => [
        pdfFacts([
          ('Date', '${_longDate(s.date)} à ${s.time}'),
          ('Type', sessionTypes[s.type] ?? s.type),
          ('Durée prévue', '${s.plannedDurationMin} min'),
          if (s.plannedRpe != null) ('RPE prévu', '${s.plannedRpe} · charge prévue ${s.plannedDurationMin * s.plannedRpe!} UA'),
          ('Statut', sessionStatuses[s.status] ?? s.status),
          if ((s.objective ?? '').isNotEmpty) ('Objectif', s.objective),
          if ((s.remarks ?? '').isNotEmpty) ('Remarques', s.remarks),
        ]),
        pdfSection('Programme${exercises.isEmpty ? '' : ' · ${exercises.length} exercice${exercises.length > 1 ? 's' : ''}'
            '${total > 0 ? ' · $total min' : ''}'}'),
        if (exercises.isEmpty) pdfText('Aucun exercice saisi.', color: pdfGrey, italic: true),
        for (final (i, e) in exercises.indexed) ...[
          pdfText('${i + 1}. ${e.name}${e.durationMin == null ? '' : ' · ${e.durationMin} min'}', size: 11, bold: true),
          if ((e.description ?? '').isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(top: 2), child: pdfText(e.description!)),
          if (tactics[e.tacticId] case final Tactic t) ...[
            pw.SizedBox(height: 6),
            ...tacticPdfBlock(t, exerciseTactics[t.id] ?? const [], players, width: 300),
          ] else
            pw.SizedBox(height: 10),
        ],
        if (linked.isNotEmpty) ...[
          pdfSection('Tactiques travaillées'),
          for (final (t, pngs) in linked) ...tacticPdfBlock(t, pngs, players, width: 300),
        ],
        if (rows.isNotEmpty) ...[
          pdfSection('Présence · ${present.length} présent${present.length > 1 ? 's' : ''}, ${absent.length} absent${absent.length > 1 ? 's' : ''}'),
          pdfTable(const ['Joueur', 'Présence', 'Durée (min)', 'RPE', 'Charge (UA)'], [
            for (final r in present)
              [name(r.playerId), 'Présent', r.durationMin, r.rpe,
                r.durationMin == null || r.rpe == null ? null : r.durationMin! * r.rpe!],
            for (final r in absent) [name(r.playerId), 'Absent · ${absenceReasons[r.absenceReason] ?? 'sans motif'}', null, null, null],
          ]),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Feuille de match
  // ---------------------------------------------------------------------------

  /// Feuille de match : informations et score, composition, remplaçants, absents, déroulé, temps de jeu,
  /// blessures et tactiques prévues.
  Future<Uint8List> matchSheet(FootballMatch m) async {
    final ref = _ref;
    final players = await _players(ref, m.teamId);
    final rows = await ref.read(matchPlayersProvider(m.id).future);
    final events = [...await ref.read(matchEventsProvider(m.id).future)]..sort((a, b) => a.minute.compareTo(b.minute));
    final injuries = await ref.read(matchInjuriesProvider(m.id).future);
    final linked = await _linkedTactics(ref, m.teamId, players, matchId: m.id);
    String name(String? id) => players[id]?.fullName ?? '—';
    String number(String id) => players[id]?.shirtNumber?.toString() ?? '';

    // Composition sur le terrain, si un dispositif et des titulaires placés existent.
    final slots = formations[m.formation];
    final bySlot = {for (final r in rows) if (r.present && r.role == 'starter' && r.slot != null) r.slot!: r.playerId};
    Uint8List? lineup;
    if (slots != null && bySlot.isNotEmpty) {
      lineup = await renderBoardPng(
        board: TacticBoard(tokens: [
          for (final (i, (_, x, y)) in slots.indexed) BoardToken(id: '$i', kind: bySlot[i] == null ? 'them' : 'us', x: x, y: y),
        ]),
        pitch: 'full',
        text: (t) => switch (players[bySlot[int.parse(t.id)]]) { final Player p => p.shirtNumber?.toString() ?? p.initials, _ => '' },
        caption: (t) => players[bySlot[int.parse(t.id)]]?.lastName ?? slots[int.parse(t.id)].$1,
        width: 700,
        tokenSize: 0.1,
      );
    }
    final starters = rows.where((r) => r.present && r.role == 'starter').toList()
      ..sort((a, b) => (a.slot ?? 99).compareTo(b.slot ?? 99));
    final subs = rows.where((r) => r.present && r.role == 'sub').toList()..sort((a, b) => name(a.playerId).compareTo(name(b.playerId)));
    final others = rows.where((r) => r.present && r.role != 'starter' && r.role != 'sub').toList();
    final absent = rows.where((r) => !r.present).toList()..sort((a, b) => name(a.playerId).compareTo(name(b.playerId)));
    // Match en cours : le score se lit sur les buts saisis, comme sur l'écran du match.
    final score = m.status == 'in_progress'
        ? '${events.where((e) => e.type == 'goal').length} - ${m.goalsAgainst ?? 0}'
        : m.goalsFor == null || m.goalsAgainst == null ? null : '${m.goalsFor} - ${m.goalsAgainst}';
    final team = _teamName(ref, m.teamId);
    final venue = m.homeAway == 'A' ? '${m.opponent} - $team' : '$team - ${m.opponent}';

    String eventLine(MatchEvent e) => switch (e.type) {
          'goal' => 'But de ${name(e.playerId)}${e.assistPlayerId == null ? '' : ' (passe de ${name(e.assistPlayerId)})'}',
          'substitution' => 'Entrée de ${name(e.playerId)}${e.assistPlayerId == null ? '' : ', sortie de ${name(e.assistPlayerId)}'}',
          'opponent_goal' => 'But de ${m.opponent}${e.remark == null ? '' : ' (${e.remark})'}',
          _ => '${eventTypes[e.type] ?? e.type} : ${name(e.playerId)}',
        };

    return buildPdfDocument(
      title: 'Feuille de match',
      subtitle: [venue, _longDate(m.date), m.time].join(' · '),
      body: () => [
        pw.Center(
          child: pw.Column(children: [
            pdfText(m.homeAway == 'A' ? '${m.opponent}   ${score ?? '-'}   $team' : '$team   ${score ?? '-'}   ${m.opponent}',
                size: 18, bold: true),
            pdfText([matchStatuses[m.status] ?? m.status, if (m.result != null) matchResultLabel[m.result]].join(' · '),
                size: 9, color: pdfGrey),
          ]),
        ),
        pw.SizedBox(height: 10),
        pdfFacts([
          ('Date', '${_longDate(m.date)} à ${m.time}'),
          ('Lieu', homeAwayLabels[m.homeAway] ?? m.homeAway),
          ('Compétition', m.competitionLabel),
          ('Durée', '${m.durationMin} min'
              '${(m.addedTime1 ?? 0) + (m.addedTime2 ?? 0) > 0 ? ' · temps additionnel +${m.addedTime1 ?? 0} / +${m.addedTime2 ?? 0}' : ''}'),
          if (m.formation != null) ('Dispositif', m.formation),
          if ((m.remarks ?? '').isNotEmpty) ('Remarques', m.remarks),
        ]),
        if (lineup != null) ...[pdfSection('Composition · ${m.formation}'), pdfImage(lineup, width: 250)],
        pdfSection('Titulaires'),
        if (starters.isEmpty && others.isEmpty)
          pdfText('Aucun titulaire saisi.', color: pdfGrey, italic: true)
        else
          pdfTable(const ['N°', 'Joueur', 'Poste'], [
            for (final r in [...starters, ...others])
              [number(r.playerId), name(r.playerId), slots != null && r.slot != null && r.slot! < slots.length ? slots[r.slot!].$1 : ''],
          ]),
        if (subs.isNotEmpty) ...[
          pdfSection('Remplaçants'),
          pdfTable(const ['N°', 'Joueur'], [for (final r in subs) [number(r.playerId), name(r.playerId)]]),
        ],
        if (absent.isNotEmpty) ...[
          pdfSection('Absents'),
          pdfTable(const ['Joueur', 'Motif'], [for (final r in absent) [name(r.playerId), matchAbsenceReasons[r.absenceReason] ?? 'sans motif']]),
        ],
        pdfSection('Déroulé du match'),
        if (events.isEmpty && injuries.isEmpty)
          pdfText('Aucun événement saisi.', color: pdfGrey, italic: true)
        else
          pdfTable(const ['Minute', 'Événement'], [
            for (final e in [
              for (final e in events) (e.minute, eventLine(e)),
              for (final i in injuries) (i.minute ?? 0, 'Blessure de ${name(i.playerId)} · ${injuryLabel(i)}'),
            ]..sort((a, b) => a.$1.compareTo(b.$1)))
              ["${e.$1}'", e.$2],
          ]),
        if (rows.any((r) => r.present && (r.minutesPlayed != null || r.rpe != null))) ...[
          pdfSection('Temps de jeu et charge'),
          pdfTable(const ['Joueur', 'Rôle', 'Minutes', 'RPE', 'Charge (UA)'], [
            for (final r in [...starters, ...others, ...subs])
              [name(r.playerId), matchRoles[r.role] ?? '', r.minutesPlayed, r.rpe,
                r.minutesPlayed == null || r.rpe == null ? null : r.minutesPlayed! * r.rpe!],
          ]),
        ],
        if (linked.isNotEmpty) ...[
          pdfSection('Tactiques prévues'),
          for (final (t, pngs) in linked) ...tacticPdfBlock(t, pngs, players, width: 300),
        ],
      ],
    );
  }
}

const matchResultLabel = {'W': 'Victoire', 'D': 'Match nul', 'L': 'Défaite'};
