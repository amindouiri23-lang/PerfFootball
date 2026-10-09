import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import '../../data/sync.dart';

const _uuid = Uuid();

/// Espace de noms des identifiants déterministes (docs/01 §5.5) — ne jamais le changer.
const _idNamespace = '71d5779a-5c07-404c-8757-26e95c0f8b4a';

/// Même id sur tous les appareils pour un même couple : la seconde saisie met à jour la première.
String pairId(String a, String b) => _uuid.v5(_idNamespace, '$a:$b');

// Valeurs en base → libellés affichés (specs E12, E13, E15).
const sessionTypes = {
  'technical': 'Technique', 'tactical': 'Tactique', 'physical': 'Physique', 'mixed': 'Mixte',
  'recovery': 'Récupération', 'gym': 'Musculation', 'other': 'Autre',
};
const sessionTypeColors = {
  'technical': Color(0xFF1565C0), 'tactical': Color(0xFF6A1B9A), 'physical': Color(0xFFEF6C00),
  'mixed': Color(0xFF00838F), 'recovery': Color(0xFF2E7D32), 'gym': Color(0xFF5D4037), 'other': Color(0xFF616161),
};
const sessionStatuses = {'planned': 'Planifiée', 'in_progress': 'En cours', 'completed': 'Terminée'};
const absenceReasons = {
  'injured': 'Blessé', 'sick': 'Malade', 'national_team': 'Sélection', 'personal': 'Personnel', 'other': 'Autre',
};
const bodyAreas = {
  'head': 'Tête', 'neck': 'Cou', 'shoulder': 'Épaule', 'arm': 'Bras', 'back': 'Dos', 'hip_groin': 'Hanche/aine',
  'thigh_front': 'Cuisse avant', 'thigh_back': 'Cuisse arrière', 'knee': 'Genou', 'calf': 'Mollet',
  'ankle': 'Cheville', 'foot': 'Pied', 'other': 'Autre',
};
const injurySides = {'left': 'Gauche', 'right': 'Droit', 'both': 'Les deux'};
const injuryTypes = {
  'muscle': 'Musculaire', 'ligament': 'Ligamentaire', 'bone': 'Osseuse', 'contusion': 'Contusion',
  'tendon': 'Tendineuse', 'other': 'Autre',
};
const mechanisms = {'contact': 'Contact', 'non_contact': 'Sans contact', 'overuse': 'Surmenage'};
const severities = {'minor': 'Légère (≤ 3 j)', 'moderate': 'Modérée (4 à 28 j)', 'severe': 'Grave (> 28 j)'};

/// « Cuisse arrière droit » : zone du corps et côté d'une blessure.
String injuryLabel(Injury i) => '${bodyAreas[i.bodyArea]}${i.side != null ? ' ${injurySides[i.side]!.toLowerCase()}' : ''}';

/// Couleur de l'échelle RPE CR-10 : vert (facile) → rouge (maximal).
Color rpeColor(int rpe) => switch (rpe) {
      <= 2 => const Color(0xFF2E7D32),
      <= 4 => const Color(0xFF7CB342),
      <= 6 => const Color(0xFFF9A825),
      <= 8 => const Color(0xFFEF6C00),
      _ => const Color(0xFFC62828),
    };

const rpeLabels = {
  0: 'Repos', 1: 'Très très facile', 2: 'Facile', 3: 'Modéré', 4: 'Un peu difficile', 5: 'Difficile',
  6: 'Difficile +', 7: 'Très difficile', 8: 'Très difficile +', 9: 'Presque maximal', 10: 'Maximal',
};

String isoDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

extension TrainingSessionLabels on TrainingSession {
  DateTime get day => DateTime.parse(date);
  String get time => startTime.substring(0, 5);
  String get dayLabel {
    final s = DateFormat('EEE d MMM', 'fr_FR').format(day);
    return s[0].toUpperCase() + s.substring(1);
  }
}

// ---------------------------------------------------------------------------
// Lectures (flux de la base locale)
// ---------------------------------------------------------------------------

final sessionsProvider = StreamProvider.family<List<TrainingSession>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.sessions)..where((s) => s.teamId.equals(teamId) & s.deleted.equals(false))).watch();
});

final sessionProvider = StreamProvider.family<TrainingSession?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.sessions)..where((s) => s.id.equals(id))).watchSingleOrNull();
});

final sessionPlayersProvider = StreamProvider.family<List<SessionPlayer>, String>((ref, sessionId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.sessionPlayers)..where((p) => p.sessionId.equals(sessionId) & p.deleted.equals(false))).watch();
});

/// Présence de toutes les séances d'une équipe (compteurs « 21/24 » de la liste).
final teamSessionPlayersProvider = StreamProvider.family<List<SessionPlayer>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.sessionPlayers)..where((p) => p.teamId.equals(teamId) & p.deleted.equals(false))).watch();
});

final sessionWellnessProvider = StreamProvider.family<List<WellnessEntry>, String>((ref, sessionId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellness)..where((w) => w.sessionId.equals(sessionId) & w.deleted.equals(false))).watch();
});

final sessionInjuriesProvider = StreamProvider.family<List<Injury>, String>((ref, sessionId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.injuries)..where((i) => i.sessionId.equals(sessionId) & i.deleted.equals(false))).watch();
});

/// Toutes les blessures d'une équipe (infirmerie E27 : en cours et historique).
final teamInjuriesProvider = StreamProvider.family<List<Injury>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.injuries)
        ..where((i) => i.teamId.equals(teamId) & i.deleted.equals(false))
        ..orderBy([(i) => OrderingTerm(expression: i.date, mode: OrderingMode.desc)]))
      .watch();
});

/// Blessures en cours (sans date de retour) d'une équipe : pastille « Blessé ».
final openInjuriesProvider = StreamProvider.family<List<Injury>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.injuries)
        ..where((i) => i.teamId.equals(teamId) & i.deleted.equals(false) & i.returnDate.isNull()))
      .watch();
});

// ---------------------------------------------------------------------------
// Écritures (base locale, puis synchronisation)
// ---------------------------------------------------------------------------

final sessionRepositoryProvider = Provider<SessionRepository>((ref) => SessionRepository(ref));

class SessionRepository {
  SessionRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);
  void _sync() => _ref.read(syncControllerProvider.notifier).requestSync();

  /// Crée (id null) ou modifie les informations d'une séance ; renvoie son id.
  Future<String> saveSession({
    String? id,
    required String teamId,
    required String date,
    required String startTime,
    required String type,
    required int plannedDurationMin,
    String? objective,
  }) async {
    final now = nowIso();
    final fields = SessionsCompanion(
      teamId: Value(teamId), date: Value(date), startTime: Value(startTime), type: Value(type),
      plannedDurationMin: Value(plannedDurationMin), objective: Value(objective),
      updatedAt: Value(now), isDirty: const Value(true),
    );
    if (id == null) {
      id = _uuid.v4();
      await _db.into(_db.sessions).insert(fields.copyWith(id: Value(id), createdAt: Value(now)));
    } else {
      await (_db.update(_db.sessions)..where((s) => s.id.equals(id!))).write(fields);
    }
    _sync();
    return id;
  }

  Future<void> _updateSession(String id, SessionsCompanion fields) async {
    await (_db.update(_db.sessions)..where((s) => s.id.equals(id)))
        .write(fields.copyWith(updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  Future<void> setRemarks(String id, String? text) => _updateSession(id, SessionsCompanion(remarks: Value(text)));

  /// Validation de la clôture : la séance passe « Terminée » et les présents sans durée saisie reçoivent
  /// la durée prévue (sinon leur charge serait inconnue dans Power BI).
  Future<void> complete(TrainingSession s) async {
    final now = nowIso();
    await _db.transaction(() async {
      await (_db.update(_db.sessionPlayers)
            ..where((p) => p.sessionId.equals(s.id) & p.present.equals(true) & p.durationMin.isNull()))
          .write(SessionPlayersCompanion(
              durationMin: Value(s.plannedDurationMin), updatedAt: Value(now), isDirty: const Value(true)));
      await (_db.update(_db.sessions)..where((x) => x.id.equals(s.id)))
          .write(SessionsCompanion(status: const Value('completed'), updatedAt: Value(now), isDirty: const Value(true)));
    });
    _sync();
  }

  /// Suppression : séance, présence et bien-être. Les blessures restent (elles concernent le joueur)
  /// mais ne sont plus rattachées à la séance.
  Future<void> deleteSession(String id) async {
    final now = nowIso();
    const gone = Value(true);
    await _db.transaction(() async {
      await (_db.update(_db.sessions)..where((s) => s.id.equals(id)))
          .write(SessionsCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
      await (_db.update(_db.sessionPlayers)..where((p) => p.sessionId.equals(id)))
          .write(SessionPlayersCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
      await (_db.update(_db.wellness)..where((w) => w.sessionId.equals(id)))
          .write(WellnessCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
      await (_db.update(_db.injuries)..where((i) => i.sessionId.equals(id)))
          .write(InjuriesCompanion(sessionId: const Value(null), updatedAt: Value(now), isDirty: gone));
    });
    _sync();
  }

  /// E13 — enregistre l'appel. Les joueurs absents perdent durée et RPE ; la séance passe « En cours ».
  Future<void> confirmAttendance(TrainingSession s, Map<String, ({bool present, String? reason})> calls) async {
    final now = nowIso();
    await _db.transaction(() async {
      for (final e in calls.entries) {
        final id = pairId(s.id, e.key);
        final present = e.value.present;
        final existing = await (_db.select(_db.sessionPlayers)..where((p) => p.id.equals(id))).getSingleOrNull();
        final fields = SessionPlayersCompanion(
          present: Value(present),
          absenceReason: Value(present ? null : e.value.reason),
          durationMin: present ? Value(existing?.durationMin) : const Value(null),
          rpe: present ? Value(existing?.rpe) : const Value(null),
          deleted: const Value(false),
          updatedAt: Value(now),
          isDirty: const Value(true),
        );
        if (existing == null) {
          await _db.into(_db.sessionPlayers).insert(fields.copyWith(
                id: Value(id), teamId: Value(s.teamId), sessionId: Value(s.id), playerId: Value(e.key),
                createdAt: Value(now),
              ));
        } else {
          await (_db.update(_db.sessionPlayers)..where((p) => p.id.equals(id))).write(fields);
        }
      }
      if (s.status == 'planned') {
        await (_db.update(_db.sessions)..where((x) => x.id.equals(s.id)))
            .write(SessionsCompanion(status: const Value('in_progress'), updatedAt: Value(now), isDirty: const Value(true)));
      }
    });
    _sync();
  }

  Future<void> _updatePlayerRow(String rowId, SessionPlayersCompanion fields) async {
    await (_db.update(_db.sessionPlayers)..where((p) => p.id.equals(rowId)))
        .write(fields.copyWith(updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  Future<void> setPlayerRemark(String rowId, String? text) =>
      _updatePlayerRow(rowId, SessionPlayersCompanion(remark: Value(text)));

  Future<void> setDuration(String rowId, int minutes) =>
      _updatePlayerRow(rowId, SessionPlayersCompanion(durationMin: Value(minutes)));

  Future<void> setRpe(String rowId, int? rpe) => _updatePlayerRow(rowId, SessionPlayersCompanion(rpe: Value(rpe)));

  /// « Appliquer la durée prévue à tous » (E17) : tous les présents reçoivent la durée prévue.
  Future<void> applyPlannedDuration(TrainingSession s) async {
    await (_db.update(_db.sessionPlayers)..where((p) => p.sessionId.equals(s.id) & p.present.equals(true))).write(
        SessionPlayersCompanion(durationMin: Value(s.plannedDurationMin), updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  /// E18 — un questionnaire par joueur et par séance.
  Future<void> saveWellness(TrainingSession s, String playerId,
      {required double sleepHours, required int sleepQuality, required int fatigue, required int soreness,
      required int stress, required int mood, String? remark}) async {
    final now = nowIso();
    final id = pairId(s.id, playerId);
    await _db.into(_db.wellness).insertOnConflictUpdate(WellnessCompanion.insert(
          id: id, teamId: s.teamId, sessionId: s.id, playerId: playerId,
          sleepHours: sleepHours, sleepQuality: sleepQuality, fatigue: fatigue, soreness: soreness,
          stress: stress, mood: mood, remark: Value(remark),
          createdAt: now, updatedAt: now, isDirty: const Value(true),
        ));
    _sync();
  }

  /// E27 — retour du joueur : la blessure passe dans l'historique.
  Future<void> setReturnDate(String injuryId, String date) async {
    await (_db.update(_db.injuries)..where((i) => i.id.equals(injuryId)))
        .write(InjuriesCompanion(returnDate: Value(date), updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  /// E15 — déclaration d'une blessure (séance, match ou hors club).
  Future<void> saveInjury({
    required String teamId,
    required String playerId,
    String? sessionId,
    String? matchId,
    int? minute,
    required String date,
    required String bodyArea,
    String? side,
    required String type,
    required String mechanism,
    required String severity,
    String? description,
    String? expectedReturnDate,
  }) async {
    final now = nowIso();
    await _db.into(_db.injuries).insert(InjuriesCompanion.insert(
          id: _uuid.v4(), teamId: teamId, playerId: playerId, sessionId: Value(sessionId), matchId: Value(matchId),
          minute: Value(minute), date: date, bodyArea: bodyArea, side: Value(side), type: type,
          mechanism: mechanism, severity: severity, description: Value(description),
          expectedReturnDate: Value(expectedReturnDate),
          createdAt: now, updatedAt: now, isDirty: const Value(true),
        ));
    _sync();
  }
}
