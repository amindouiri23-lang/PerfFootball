import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import '../../data/sync.dart';
import '../sessions/session_repository.dart' show pairId;

const _uuid = Uuid();

// Valeurs en base → libellés affichés (specs E20 à E25).
const competitions = {'league': 'Championnat', 'cup': 'Coupe', 'friendly': 'Amical', 'tournament': 'Tournoi'};
const homeAwayLabels = {'H': 'Domicile', 'A': 'Extérieur', 'N': 'Neutre'};
const matchStatuses = {
  'planned': 'Planifié', 'in_progress': 'En cours', 'completed': 'Terminé',
  'forfeit': 'Forfait', 'postponed': 'Reporté', 'cancelled': 'Annulé', 'abandoned': 'Arrêté',
};
/// Score d'un match gagné ou perdu par forfait.
const forfeitGoals = 3;
const matchAbsenceReasons = {
  'not_selected': 'Non retenu', 'injured': 'Blessé', 'sick': 'Malade', 'suspended': 'Suspendu',
  'national_team': 'Sélection', 'rest': 'Repos', 'other_team': 'Autre équipe', 'other': 'Autre',
};
const phases = {'first_leg': 'Aller', 'second_leg': 'Retour'};
const matchRoles = {'starter': 'Titulaire', 'sub': 'Remplaçant'};
const eventTypes = {'goal': 'But', 'yellow_card': 'Carton jaune', 'red_card': 'Carton rouge', 'substitution': 'Changement'};
const eventIcons = {
  'goal': Icons.sports_soccer, 'yellow_card': Icons.style, 'red_card': Icons.style, 'substitution': Icons.swap_horiz,
};
const eventColors = {
  'goal': Color(0xFF1B5E20), 'yellow_card': Color(0xFFF9A825), 'red_card': Color(0xFFC62828),
  'substitution': Color(0xFF1565C0),
};

extension FootballMatchLabels on FootballMatch {
  DateTime get day => DateTime.parse(date);
  String get time => kickOffTime.substring(0, 5);
  String get dayLabel {
    final s = DateFormat('EEE d MMM', 'fr_FR').format(day);
    return s[0].toUpperCase() + s.substring(1);
  }

  /// « Championnat · J5 aller » : compétition, journée et phase.
  String get competitionLabel => [
        competitions[competition]!,
        [if (matchday != null) 'J$matchday', if (phase != null) phases[phase]!.toLowerCase()].join(' '),
      ].where((s) => s.isNotEmpty).join(' · ');

  /// 'W', 'D', 'L', ou null si le score n'est pas saisi ou si le match ne compte pas au bilan
  /// (reporté, annulé, arrêté). Un forfait compte : victoire ou défaite 3-0.
  String? get result => goalsFor == null || goalsAgainst == null || !{'completed', 'forfeit'}.contains(status)
      ? null
      : goalsFor! > goalsAgainst! ? 'W' : goalsFor! < goalsAgainst! ? 'L' : 'D';

  /// Minute affichée par le chronomètre (« 23' », « 45+2' », « MT », « 67' », « 90+3' », « Fin »).
  String get clockLabel => matchClockLabel(period, firstHalfStartedAt, secondHalfStartedAt, durationMin);

  /// Minute en cours pour pré-remplir un but, un carton ou un changement (null si le chrono ne tourne pas).
  int? get liveMinute => matchLiveMinute(period, firstHalfStartedAt, secondHalfStartedAt, durationMin);

  /// Match qui ne se jouera pas ou plus : forfait, reporté, annulé.
  bool get notPlayed => {'forfeit', 'postponed', 'cancelled'}.contains(status);
}

/// Minutes écoulées (commencées) depuis [iso] : 1 dès le coup d'envoi.
int _minutesSince(String iso, DateTime now) => now.difference(DateTime.parse(iso)).inSeconds ~/ 60 + 1;

/// Minute affichée par le chronomètre : temps additionnel noté « 45+2' » au-delà de la mi-temps.
String matchClockLabel(String? period, String? firstStart, String? secondStart, int durationMin, {DateTime? now}) {
  final half = durationMin ~/ 2;
  now ??= DateTime.now();
  switch (period) {
    case 'first_half' when firstStart != null:
      final e = _minutesSince(firstStart, now);
      return e <= half ? "$e'" : "$half+${e - half}'";
    case 'half_time':
      return 'MT';
    case 'second_half' when secondStart != null:
      final e = _minutesSince(secondStart, now);
      return e <= half ? "${half + e}'" : "$durationMin+${e - half}'";
    case 'finished':
      return 'Fin';
  }
  return '';
}

/// Minute du match pour un événement (temps additionnel compris, plafonnée à 130).
int? matchLiveMinute(String? period, String? firstStart, String? secondStart, int durationMin, {DateTime? now}) {
  final half = durationMin ~/ 2;
  now ??= DateTime.now();
  return switch (period) {
    'first_half' when firstStart != null => _minutesSince(firstStart, now).clamp(1, 130),
    'half_time' => half,
    'second_half' when secondStart != null => (half + _minutesSince(secondStart, now)).clamp(1, 130),
    _ => null,
  };
}

// ---------------------------------------------------------------------------
// Lectures
// ---------------------------------------------------------------------------

final matchesProvider = StreamProvider.family<List<FootballMatch>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.matches)..where((m) => m.teamId.equals(teamId) & m.deleted.equals(false))).watch();
});

final matchProvider = StreamProvider.family<FootballMatch?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.matches)..where((m) => m.id.equals(id))).watchSingleOrNull();
});

final matchPlayersProvider = StreamProvider.family<List<MatchPlayer>, String>((ref, matchId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.matchPlayers)..where((p) => p.matchId.equals(matchId) & p.deleted.equals(false))).watch();
});

final matchEventsProvider = StreamProvider.family<List<MatchEvent>, String>((ref, matchId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.matchEvents)
        ..where((e) => e.matchId.equals(matchId) & e.deleted.equals(false))
        ..orderBy([(e) => OrderingTerm(expression: e.minute)]))
      .watch();
});

final matchInjuriesProvider = StreamProvider.family<List<Injury>, String>((ref, matchId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.injuries)..where((i) => i.matchId.equals(matchId) & i.deleted.equals(false))).watch();
});

/// Feuilles de match et événements de toute l'équipe (statistiques des cartes joueurs de l'effectif).
final teamMatchPlayersProvider = StreamProvider.family<List<MatchPlayer>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.matchPlayers)..where((p) => p.teamId.equals(teamId) & p.deleted.equals(false))).watch();
});

final teamMatchEventsProvider = StreamProvider.family<List<MatchEvent>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.matchEvents)..where((e) => e.teamId.equals(teamId) & e.deleted.equals(false))).watch();
});

/// Cartons rouges de toute l'équipe (rappel « Suspendu ? » sur la feuille du match suivant).
final teamRedCardsProvider = StreamProvider.family<List<MatchEvent>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.matchEvents)
        ..where((e) => e.teamId.equals(teamId) & e.deleted.equals(false) & e.type.equals('red_card')))
      .watch();
});

// ---------------------------------------------------------------------------
// Écritures
// ---------------------------------------------------------------------------

final matchRepositoryProvider = Provider<MatchRepository>((ref) => MatchRepository(ref));

class MatchRepository {
  MatchRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);
  void _sync() => _ref.read(syncControllerProvider.notifier).requestSync();

  Future<String> saveMatch({
    String? id,
    required String teamId,
    required String date,
    required String kickOffTime,
    required String opponent,
    required String homeAway,
    required String competition,
    required int durationMin,
    String? phase,
    int? matchday,
  }) async {
    final now = nowIso();
    final fields = MatchesCompanion(
      teamId: Value(teamId), date: Value(date), kickOffTime: Value(kickOffTime), opponent: Value(opponent),
      homeAway: Value(homeAway), competition: Value(competition), durationMin: Value(durationMin),
      phase: Value(phase), matchday: Value(matchday),
      updatedAt: Value(now), isDirty: const Value(true),
    );
    if (id == null) {
      id = _uuid.v4();
      await _db.into(_db.matches).insert(fields.copyWith(id: Value(id), createdAt: Value(now)));
    } else {
      await (_db.update(_db.matches)..where((m) => m.id.equals(id!))).write(fields);
    }
    _sync();
    return id;
  }

  Future<void> _updateMatch(String id, MatchesCompanion fields) async {
    await (_db.update(_db.matches)..where((m) => m.id.equals(id)))
        .write(fields.copyWith(updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  Future<void> setRemarks(String id, String? text) => _updateMatch(id, MatchesCompanion(remarks: Value(text)));

  Future<void> setGoalsAgainst(String id, int goals) => _updateMatch(id, MatchesCompanion(goalsAgainst: Value(goals)));

  /// Suppression : match, feuille, événements et liens vers les tactiques. Les blessures restent, détachées du match.
  Future<void> deleteMatch(String id) async {
    final now = nowIso();
    const gone = Value(true);
    await _db.transaction(() async {
      await (_db.update(_db.matches)..where((m) => m.id.equals(id)))
          .write(MatchesCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
      await (_db.update(_db.matchPlayers)..where((p) => p.matchId.equals(id)))
          .write(MatchPlayersCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
      await (_db.update(_db.matchEvents)..where((e) => e.matchId.equals(id)))
          .write(MatchEventsCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
      await (_db.update(_db.injuries)..where((i) => i.matchId.equals(id))).write(
          InjuriesCompanion(matchId: const Value(null), minute: const Value(null), updatedAt: Value(now), isDirty: gone));
      await (_db.update(_db.tacticLinks)..where((l) => l.matchId.equals(id)))
          .write(TacticLinksCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
    });
    _sync();
  }

  /// E22 — feuille de match : présents (titulaire / remplaçant) et absents (motif). Le match passe « En cours ».
  Future<void> confirmSquad(FootballMatch m, Map<String, ({bool present, String? reason, String role})> sheet) async {
    final now = nowIso();
    await _db.transaction(() async {
      for (final e in sheet.entries) {
        final id = pairId(m.id, e.key);
        final c = e.value;
        final existing = await (_db.select(_db.matchPlayers)..where((p) => p.id.equals(id))).getSingleOrNull();
        final fields = MatchPlayersCompanion(
          present: Value(c.present),
          absenceReason: Value(c.present ? null : c.reason),
          role: Value(c.present ? c.role : null),
          // Une place dans le dispositif n'a de sens que pour un titulaire.
          slot: Value(c.present && c.role == 'starter' ? existing?.slot : null),
          minutesPlayed: c.present ? Value(existing?.minutesPlayed) : const Value(null),
          rpe: c.present ? Value(existing?.rpe) : const Value(null),
          deleted: const Value(false),
          updatedAt: Value(now),
          isDirty: const Value(true),
        );
        if (existing == null) {
          await _db.into(_db.matchPlayers).insert(fields.copyWith(
                id: Value(id), teamId: Value(m.teamId), matchId: Value(m.id), playerId: Value(e.key),
                createdAt: Value(now),
              ));
        } else {
          await (_db.update(_db.matchPlayers)..where((p) => p.id.equals(id))).write(fields);
        }
      }
      if (m.status == 'planned') {
        await (_db.update(_db.matches)..where((x) => x.id.equals(m.id)))
            .write(MatchesCompanion(status: const Value('in_progress'), updatedAt: Value(now), isDirty: const Value(true)));
      }
    });
    _sync();
  }

  /// Préparation du match : dispositif, titulaires à leur place, remplaçants ; les autres joueurs sont
  /// « non retenus ». Le match reste planifié ; minutes et RPE déjà saisis sont conservés.
  Future<void> saveLineup(FootballMatch m, {required String formation, required Map<int, String> starters,
      required Set<String> subs, required List<String> playerIds}) async {
    final now = nowIso();
    final slotOf = {for (final e in starters.entries) e.value: e.key};
    await _db.transaction(() async {
      await (_db.update(_db.matches)..where((x) => x.id.equals(m.id)))
          .write(MatchesCompanion(formation: Value(formation), updatedAt: Value(now), isDirty: const Value(true)));
      for (final p in playerIds) {
        final id = pairId(m.id, p);
        final starter = slotOf.containsKey(p);
        final called = starter || subs.contains(p);
        final existing = await (_db.select(_db.matchPlayers)..where((r) => r.id.equals(id))).getSingleOrNull();
        final fields = MatchPlayersCompanion(
          present: Value(called),
          absenceReason: Value(called ? null : existing?.absenceReason ?? 'not_selected'),
          role: Value(called ? (starter ? 'starter' : 'sub') : null),
          slot: Value(slotOf[p]),
          deleted: const Value(false),
          updatedAt: Value(now),
          isDirty: const Value(true),
        );
        if (existing == null) {
          await _db.into(_db.matchPlayers).insert(fields.copyWith(
                id: Value(id), teamId: Value(m.teamId), matchId: Value(m.id), playerId: Value(p), createdAt: Value(now)));
        } else {
          await (_db.update(_db.matchPlayers)..where((r) => r.id.equals(id))).write(fields);
        }
      }
    });
    _sync();
  }

  /// Changement : [inId] entre à la place de [outId] (événement « substitution », id null pour en créer un).
  Future<void> saveSubstitution({String? id, required FootballMatch m, required int minute, required String inId,
      required String outId}) async {
    final now = nowIso();
    final fields = MatchEventsCompanion(
      type: const Value('substitution'), minute: Value(minute), playerId: Value(inId), assistPlayerId: Value(outId),
      updatedAt: Value(now), isDirty: const Value(true),
    );
    if (id == null) {
      await _db.into(_db.matchEvents).insert(fields.copyWith(
            id: Value(_uuid.v4()), teamId: Value(m.teamId), matchId: Value(m.id), createdAt: Value(now)));
    } else {
      await (_db.update(_db.matchEvents)..where((e) => e.id.equals(id))).write(fields);
    }
    _sync();
  }

  /// Chronomètre : coup d'envoi de la 1re mi-temps.
  Future<void> kickOff(FootballMatch m) => _updateMatch(m.id,
      MatchesCompanion(period: const Value('first_half'), firstHalfStartedAt: Value(nowIso())));

  /// Mi-temps, avec le temps additionnel joué en 1re mi-temps.
  Future<void> halfTime(FootballMatch m, int addedTime) => _updateMatch(m.id,
      MatchesCompanion(period: const Value('half_time'), addedTime1: Value(addedTime)));

  /// Reprise : coup d'envoi de la 2e mi-temps.
  Future<void> secondHalf(FootballMatch m) => _updateMatch(m.id,
      MatchesCompanion(period: const Value('second_half'), secondHalfStartedAt: Value(nowIso())));

  /// Fin du temps de jeu, avec le temps additionnel de la 2e mi-temps.
  Future<void> fullTime(FootballMatch m, int addedTime) => _updateMatch(m.id,
      MatchesCompanion(period: const Value('finished'), addedTime2: Value(addedTime)));

  /// Envoie le match aux joueurs : chacun donne son RPE depuis son compte (le staff peut aussi le saisir).
  Future<void> requestRpe(FootballMatch m) => _updateMatch(m.id, const MatchesCompanion(rpeRequested: Value(true)));

  /// E24 — crée (id null) ou modifie un événement.
  Future<void> saveEvent({
    String? id,
    required FootballMatch m,
    required String type,
    required int minute,
    required String playerId,
    String? assistPlayerId,
    String? remark,
  }) async {
    final now = nowIso();
    final fields = MatchEventsCompanion(
      type: Value(type), minute: Value(minute), playerId: Value(playerId),
      assistPlayerId: Value(type == 'goal' ? assistPlayerId : null), remark: Value(remark),
      updatedAt: Value(now), isDirty: const Value(true),
    );
    if (id == null) {
      await _db.into(_db.matchEvents).insert(fields.copyWith(
            id: Value(_uuid.v4()), teamId: Value(m.teamId), matchId: Value(m.id), createdAt: Value(now)));
    } else {
      await (_db.update(_db.matchEvents)..where((e) => e.id.equals(id))).write(fields);
    }
    _sync();
  }

  Future<List<MatchEvent>> eventsOf(String matchId) =>
      (_db.select(_db.matchEvents)..where((e) => e.matchId.equals(matchId) & e.deleted.equals(false))).get();

  Future<void> deleteEvent(String id) async {
    await (_db.update(_db.matchEvents)..where((e) => e.id.equals(id)))
        .write(MatchEventsCompanion(deleted: const Value(true), updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  Future<void> _updatePlayerRow(String rowId, MatchPlayersCompanion fields) async {
    await (_db.update(_db.matchPlayers)..where((p) => p.id.equals(rowId)))
        .write(fields.copyWith(updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  Future<void> setPlayerRemark(String rowId, String? text) =>
      _updatePlayerRow(rowId, MatchPlayersCompanion(remark: Value(text)));

  Future<void> setMinutes(String rowId, int minutes) =>
      _updatePlayerRow(rowId, MatchPlayersCompanion(minutesPlayed: Value(minutes)));

  Future<void> setRpe(String rowId, int? rpe) => _updatePlayerRow(rowId, MatchPlayersCompanion(rpe: Value(rpe)));

  /// E25 — fin du match : score final, temps de jeu par défaut pour les présents non saisis, état « Terminé »
  /// (ou « Arrêté » pour un match interrompu : score et minutes jusqu'à l'arrêt).
  Future<void> complete(FootballMatch m, {required int goalsFor, required int goalsAgainst,
      required Map<String, int> defaultMinutes, String status = 'completed'}) async {
    final now = nowIso();
    await _db.transaction(() async {
      for (final e in defaultMinutes.entries) {
        await (_db.update(_db.matchPlayers)..where((p) => p.id.equals(e.key) & p.minutesPlayed.isNull()))
            .write(MatchPlayersCompanion(minutesPlayed: Value(e.value), updatedAt: Value(now), isDirty: const Value(true)));
      }
      await (_db.update(_db.matches)..where((x) => x.id.equals(m.id))).write(MatchesCompanion(
            goalsFor: Value(goalsFor), goalsAgainst: Value(goalsAgainst), status: Value(status),
            updatedAt: Value(now), isDirty: const Value(true),
          ));
    });
    _sync();
  }

  /// Forfait : score 3-0 (ou 0-3), personne n'a joué. Les minutes, RPE et buts déjà saisis sont retirés ;
  /// les cartons restent (ils comptent pour les suspensions).
  Future<void> declareForfeit(FootballMatch m, {required String by}) async {
    final now = nowIso();
    const dirty = Value(true);
    await _db.transaction(() async {
      await (_db.update(_db.matchPlayers)..where((p) => p.matchId.equals(m.id)))
          .write(MatchPlayersCompanion(minutesPlayed: const Value(null), rpe: const Value(null), updatedAt: Value(now), isDirty: dirty));
      await (_db.update(_db.matchEvents)..where((e) => e.matchId.equals(m.id) & e.type.equals('goal')))
          .write(MatchEventsCompanion(deleted: dirty, updatedAt: Value(now), isDirty: dirty));
      await (_db.update(_db.matches)..where((x) => x.id.equals(m.id))).write(MatchesCompanion(
            status: const Value('forfeit'), forfeitBy: Value(by),
            goalsFor: Value(by == 'opponent' ? forfeitGoals : 0), goalsAgainst: Value(by == 'us' ? forfeitGoals : 0),
            updatedAt: Value(now), isDirty: dirty,
          ));
    });
    _sync();
  }

  /// Report : sans nouvelle date, le match reste « Reporté » ; avec une date, il redevient « Planifié »
  /// à cette date, et la date d'origine est notée dans les remarques.
  Future<void> postpone(FootballMatch m, {String? newDate, String? newTime}) {
    if (newDate == null) return _updateMatch(m.id, const MatchesCompanion(status: Value('postponed')));
    final note = 'Reporté (initialement le ${DateFormat('d MMMM y', 'fr_FR').format(m.day)})';
    return _updateMatch(m.id, MatchesCompanion(
      status: const Value('planned'), date: Value(newDate), kickOffTime: Value(newTime ?? m.kickOffTime),
      remarks: Value(m.remarks == null ? note : '${m.remarks}\n$note'),
    ));
  }

  Future<void> cancel(FootballMatch m) => _updateMatch(m.id, const MatchesCompanion(status: Value('cancelled')));

  /// Annule un forfait, un report ou une annulation saisis par erreur : le match redevient « Planifié ».
  Future<void> restore(FootballMatch m) => _updateMatch(m.id, MatchesCompanion(
        status: const Value('planned'), forfeitBy: const Value(null),
        goalsFor: m.status == 'forfeit' ? const Value(null) : Value(m.goalsFor),
        goalsAgainst: m.status == 'forfeit' ? const Value(null) : Value(m.goalsAgainst),
      ));
}
