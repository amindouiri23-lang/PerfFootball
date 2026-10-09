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
const matchStatuses = {'planned': 'Planifié', 'in_progress': 'En cours', 'completed': 'Terminé'};
const matchAbsenceReasons = {
  'not_selected': 'Non retenu', 'injured': 'Blessé', 'sick': 'Malade', 'suspended': 'Suspendu',
  'national_team': 'Sélection', 'other': 'Autre',
};
const matchRoles = {'starter': 'Titulaire', 'sub': 'Remplaçant'};
const eventTypes = {'goal': 'But', 'yellow_card': 'Carton jaune', 'red_card': 'Carton rouge'};
const eventIcons = {'goal': Icons.sports_soccer, 'yellow_card': Icons.style, 'red_card': Icons.style};
const eventColors = {'goal': Color(0xFF1B5E20), 'yellow_card': Color(0xFFF9A825), 'red_card': Color(0xFFC62828)};

extension FootballMatchLabels on FootballMatch {
  DateTime get day => DateTime.parse(date);
  String get time => kickOffTime.substring(0, 5);
  String get dayLabel {
    final s = DateFormat('EEE d MMM', 'fr_FR').format(day);
    return s[0].toUpperCase() + s.substring(1);
  }

  /// 'W', 'D', 'L' ou null si le score n'est pas saisi.
  String? get result => goalsFor == null || goalsAgainst == null
      ? null
      : goalsFor! > goalsAgainst! ? 'W' : goalsFor! < goalsAgainst! ? 'L' : 'D';
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
  }) async {
    final now = nowIso();
    final fields = MatchesCompanion(
      teamId: Value(teamId), date: Value(date), kickOffTime: Value(kickOffTime), opponent: Value(opponent),
      homeAway: Value(homeAway), competition: Value(competition), durationMin: Value(durationMin),
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

  /// Suppression : match, feuille et événements. Les blessures restent, détachées du match.
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

  /// E25 — fin du match : score final, temps de jeu par défaut pour les présents non saisis, état « Terminé ».
  Future<void> complete(FootballMatch m, {required int goalsFor, required int goalsAgainst,
      required Map<String, int> defaultMinutes}) async {
    final now = nowIso();
    await _db.transaction(() async {
      for (final e in defaultMinutes.entries) {
        await (_db.update(_db.matchPlayers)..where((p) => p.id.equals(e.key) & p.minutesPlayed.isNull()))
            .write(MatchPlayersCompanion(minutesPlayed: Value(e.value), updatedAt: Value(now), isDirty: const Value(true)));
      }
      await (_db.update(_db.matches)..where((x) => x.id.equals(m.id))).write(MatchesCompanion(
            goalsFor: Value(goalsFor), goalsAgainst: Value(goalsAgainst), status: const Value('completed'),
            updatedAt: Value(now), isDirty: const Value(true),
          ));
    });
    _sync();
  }
}
