import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import '../../data/sync.dart';
import '../sessions/session_repository.dart' show pairId;

const _uuid = Uuid();

// Questionnaires de bien-être lancés seuls (sans séance), pour une liste de joueurs choisis.

extension WellnessSurveyLabels on WellnessSurvey {
  String get label {
    final d = DateFormat('EEE d MMM', 'fr_FR').format(DateTime.parse(date));
    return [d[0].toUpperCase() + d.substring(1), ?title].join(' · ');
  }
}

final surveysProvider = StreamProvider.family<List<WellnessSurvey>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellnessSurveys)
        ..where((s) => s.teamId.equals(teamId) & s.deleted.equals(false))
        ..orderBy([(s) => OrderingTerm(expression: s.date, mode: OrderingMode.desc), (s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc)]))
      .watch();
});

final surveyProvider = StreamProvider.family<WellnessSurvey?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellnessSurveys)..where((s) => s.id.equals(id))).watchSingleOrNull();
});

/// Joueurs appelés à répondre (d'un questionnaire, ou de toute l'équipe avec [surveyId] null).
final surveyPlayersProvider = StreamProvider.family<List<WellnessSurveyPlayer>, ({String teamId, String? surveyId})>((ref, k) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellnessSurveyPlayers)
        ..where((p) => p.teamId.equals(k.teamId) & p.deleted.equals(false) & (k.surveyId == null ? const Constant(true) : p.surveyId.equals(k.surveyId!))))
      .watch();
});

/// Réponses (d'un questionnaire, ou de toute l'équipe avec [surveyId] null).
final surveyAnswersProvider = StreamProvider.family<List<WellnessEntry>, ({String teamId, String? surveyId})>((ref, k) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellness)
        ..where((w) => w.teamId.equals(k.teamId) & w.deleted.equals(false) & (k.surveyId == null ? w.surveyId.isNotNull() : w.surveyId.equals(k.surveyId!))))
      .watch();
});

final wellnessRepositoryProvider = Provider<WellnessRepository>((ref) => WellnessRepository(ref));

class WellnessRepository {
  WellnessRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);
  void _sync() => _ref.read(syncControllerProvider.notifier).requestSync();

  /// Lance un questionnaire pour [playerIds] ; renvoie son id.
  Future<String> createSurvey({required String teamId, required String date, String? title, required Set<String> playerIds}) async {
    final id = _uuid.v4();
    final now = nowIso();
    await _db.transaction(() async {
      await _db.into(_db.wellnessSurveys).insert(WellnessSurveysCompanion.insert(
            id: id, teamId: teamId, date: date, title: Value(title), createdAt: now, updatedAt: now, isDirty: const Value(true)));
      for (final p in playerIds) {
        await _db.into(_db.wellnessSurveyPlayers).insert(WellnessSurveyPlayersCompanion.insert(
              id: pairId(id, p), teamId: teamId, surveyId: id, playerId: p, createdAt: now, updatedAt: now,
              isDirty: const Value(true)));
      }
    });
    _sync();
    return id;
  }

  /// Suppression : le questionnaire et la liste des joueurs appelés (les réponses déjà données restent).
  Future<void> deleteSurvey(String id) async {
    final now = nowIso();
    const gone = Value(true);
    await _db.transaction(() async {
      await (_db.update(_db.wellnessSurveys)..where((s) => s.id.equals(id)))
          .write(WellnessSurveysCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
      await (_db.update(_db.wellnessSurveyPlayers)..where((p) => p.surveyId.equals(id)))
          .write(WellnessSurveyPlayersCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
    });
    _sync();
  }

  /// Réponse d'un joueur à un questionnaire (id déterministe : questionnaire + joueur).
  Future<void> saveAnswer(WellnessSurvey s, String playerId,
      {required double sleepHours, required int sleepQuality, required int fatigue, required int soreness,
      required int stress, required int mood, String? remark}) async {
    final now = nowIso();
    await _db.into(_db.wellness).insertOnConflictUpdate(WellnessCompanion.insert(
          id: pairId(s.id, playerId), teamId: s.teamId, surveyId: Value(s.id), playerId: playerId,
          sleepHours: sleepHours, sleepQuality: sleepQuality, fatigue: fatigue, soreness: soreness,
          stress: stress, mood: mood, remark: Value(remark),
          createdAt: now, updatedAt: now, isDirty: const Value(true),
        ));
    _sync();
  }
}

/// Réponses à un questionnaire.
final surveyAnswersOfProvider = StreamProvider.family<List<WellnessEntry>, String>((ref, surveyId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellness)..where((w) => w.surveyId.equals(surveyId) & w.deleted.equals(false))).watch();
});

/// Joueurs appelés à répondre à un questionnaire.
final surveyPlayersOfProvider = StreamProvider.family<List<WellnessSurveyPlayer>, String>((ref, surveyId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellnessSurveyPlayers)..where((p) => p.surveyId.equals(surveyId) & p.deleted.equals(false))).watch();
});
