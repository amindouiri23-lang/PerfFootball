import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import '../../data/sync.dart';
import '../sessions/session_repository.dart' show naturalId, pairId;
import '../team/player_files.dart' show fitLength, profileMaxLength;
import '../team/team_repository.dart';
import 'importers.dart';

const _uuid = Uuid();

/// Ce que devient un nom du fichier : un joueur existant, un nouveau joueur, ou rien.
class NameMapping {
  NameMapping(this.imported, {this.playerId, this.confidence = 0, required this.first, required this.last,
      required this.group, this.detailed, this.secondary});

  final ImportedName imported;
  String? playerId;
  /// 1 : même nom ; entre 0,75 et 1 : nom proche, à vérifier ; 0 : aucun joueur correspondant.
  final double confidence;
  bool ignore = false;
  // Pour une création :
  String first;
  String last;
  String group;
  String? detailed;
  String? secondary;

  bool get create => playerId == null && !ignore;
}

/// Rapproche chaque nom du fichier des joueurs de l'équipe (même nom, sinon nom proche).
Map<String, NameMapping> matchNames(ImportPlan plan, List<Player> players) {
  final keys = {for (final p in players) p.id: normalizeName(p.fullName)};
  return {
    for (final e in plan.names.entries)
      e.key: () {
        final exact = keys.entries.where((k) => k.value == e.key).firstOrNull;
        var best = (id: exact?.key, score: exact == null ? 0.0 : 1.0);
        if (exact == null) {
          for (final k in keys.entries) {
            final s = nameSimilarity(k.value, e.key);
            if (s > best.score) best = (id: k.key, score: s);
          }
          if (best.score < 0.75) best = (id: null, score: 0);
        }
        final split = splitName(e.value.name,
            lastFirst: plan.kind == ImportKind.training || plan.kind == ImportKind.playingTime);
        final pos = parsePosition(e.value.positionText);
        return NameMapping(e.value, playerId: best.id, confidence: best.score, first: split.first, last: split.last,
            group: pos.group, detailed: pos.detailed, secondary: pos.secondary);
      }(),
  };
}

class ImportSummary {
  int playersCreated = 0;
  int sessions = 0;
  int attendance = 0;
  int matches = 0;
  int sheets = 0;
  int results = 0;
  int profiles = 0;
  int medical = 0;

  @override
  String toString() => [
        if (playersCreated > 0) '$playersCreated joueur(s) créé(s)',
        if (sessions > 0) '$sessions séance(s), $attendance présence(s)',
        if (matches > 0) '$matches match(s), $sheets ligne(s) de feuille de match',
        if (results > 0) '$results résultat(s) de tests',
        if (profiles > 0) '$profiles dossier(s)',
        if (medical > 0) '$medical dossier(s) médical(aux)',
      ].join(' · ');
}

final importRepositoryProvider = Provider<ImportRepository>((ref) => ImportRepository(ref));

class ImportRepository {
  ImportRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);

  /// Écrit le plan validé, en une transaction. Les ids des séances et des matchs importés sont
  /// déterministes : réimporter le même fichier met à jour au lieu de dupliquer.
  Future<ImportSummary> apply(
    ImportPlan plan,
    Map<String, NameMapping> mapping, {
    required String teamId,
    String? testDate,
    ({String by, String date})? consent,
  }) async {
    final sum = ImportSummary();
    final now = nowIso();
    await _db.transaction(() async {
      // 1. Joueurs à créer.
      for (final m in mapping.values.where((m) => m.create)) {
        final id = _uuid.v4();
        await _db.into(_db.players).insert(PlayersCompanion.insert(
              id: id, teamId: teamId, firstName: fitLength(m.first, 50)!, lastName: fitLength(m.last, 50)!, position: m.group,
              detailedPosition: Value(m.detailed), secondaryPosition: Value(m.secondary),
              createdAt: now, updatedAt: now, isDirty: const Value(true),
            ));
        m.playerId = id;
        sum.playersCreated++;
      }
      String? player(String name) {
        final m = mapping[normalizeName(name)];
        return m == null || m.ignore ? null : m.playerId;
      }

      // 2. Séances et présence.
      for (final s in plan.sessions) {
        final sessionId = naturalId(['import-session', teamId, s.date, '${s.index}']);
        final anyPresent = s.rows.values.any((r) => r.present);
        final fields = SessionsCompanion(
          teamId: Value(teamId), date: Value(s.date), startTime: Value(s.index == 1 ? '18:00:00' : '10:00:00'),
          type: const Value('mixed'), plannedDurationMin: Value(s.plannedDurationMin ?? 90), plannedRpe: Value(s.plannedRpe),
          remarks: const Value('Importée depuis Excel (heure et type à préciser)'),
          status: Value(anyPresent ? 'completed' : 'planned'), deleted: const Value(false),
          updatedAt: Value(now), isDirty: const Value(true),
        );
        await _db.into(_db.sessions).insert(fields.copyWith(id: Value(sessionId), createdAt: Value(now)),
            onConflict: DoUpdate((_) => fields));
        sum.sessions++;
        for (final e in s.rows.entries) {
          final playerId = player(e.key);
          if (playerId == null) continue;
          final r = e.value;
          final row = SessionPlayersCompanion(
            teamId: Value(teamId), sessionId: Value(sessionId), playerId: Value(playerId), present: Value(r.present),
            absenceReason: Value(r.present ? null : r.reason), durationMin: Value(r.present ? r.durationMin : null),
            rpe: Value(r.present ? r.rpe : null), deleted: const Value(false), updatedAt: Value(now), isDirty: const Value(true),
          );
          await _db.into(_db.sessionPlayers).insert(row.copyWith(id: Value(pairId(sessionId, playerId)), createdAt: Value(now)),
              onConflict: DoUpdate((_) => row));
          sum.attendance++;
        }
      }

      // 3. Matchs et temps de jeu. 0 minute = n'a pas joué (« Non retenu »).
      for (final m in plan.matches) {
        final matchId = naturalId(['import-match', teamId, m.date, m.opponent.toUpperCase()]);
        final fields = MatchesCompanion(
          teamId: Value(teamId), date: Value(m.date), kickOffTime: const Value('15:00:00'), opponent: Value(fitLength(m.opponent, 80)!),
          homeAway: Value(m.homeAway), competition: Value(m.competition), durationMin: Value(m.durationMin),
          goalsFor: Value(m.goalsFor), goalsAgainst: Value(m.goalsAgainst), phase: Value(m.phase), matchday: Value(m.matchday),
          remarks: const Value('Importé depuis Excel (heure et lieu à vérifier)'), status: const Value('completed'),
          deleted: const Value(false), updatedAt: Value(now), isDirty: const Value(true),
        );
        await _db.into(_db.matches).insert(fields.copyWith(id: Value(matchId), createdAt: Value(now)),
            onConflict: DoUpdate((_) => fields));
        sum.matches++;
        for (final e in m.minutes.entries) {
          final playerId = player(e.key);
          if (playerId == null) continue;
          final played = e.value > 0;
          final row = MatchPlayersCompanion(
            teamId: Value(teamId), matchId: Value(matchId), playerId: Value(playerId), present: Value(played),
            absenceReason: Value(played ? null : 'not_selected'), minutesPlayed: Value(played ? e.value : null),
            deleted: const Value(false), updatedAt: Value(now), isDirty: const Value(true),
          );
          await _db.into(_db.matchPlayers).insert(row.copyWith(id: Value(pairId(matchId, playerId)), createdAt: Value(now)),
              onConflict: DoUpdate((_) => row));
          sum.sheets++;
        }
      }

      // 4. Résultats de tests (catalogue commun, retrouvé par code).
      if (plan.tests.isNotEmpty) {
        final types = {
          for (final t in await (_db.select(_db.testTypes)..where((t) => t.code.isNotNull() & t.teamId.isNull())).get()) t.code!: t.id,
        };
        if (types.isEmpty) throw StateError('Catalogue des tests absent : synchronisez une première fois puis recommencez.');
        for (final e in plan.tests.entries) {
          final playerId = player(e.key);
          if (playerId == null) continue;
          for (final v in e.value.entries) {
            final typeId = types[v.key.$1];
            if (typeId == null) continue;
            final id = naturalId([playerId, typeId, testDate!, '${v.key.$2}']);
            final row = TestResultsCompanion(
              teamId: Value(teamId), playerId: Value(playerId), testTypeId: Value(typeId), date: Value(testDate),
              attempt: Value(v.key.$2), value: Value(v.value), deleted: const Value(false),
              updatedAt: Value(now), isDirty: const Value(true),
            );
            await _db.into(_db.testResults).insert(row.copyWith(id: Value(id), createdAt: Value(now)),
                onConflict: DoUpdate((_) => row));
            sum.results++;
          }
        }
      }

      // 5. Dossiers : un champ vide dans le fichier ne remplace pas une valeur déjà saisie.
      for (final p in plan.profiles) {
        final playerId = player(p.name);
        if (playerId == null) continue;
        final existing = await (_db.select(_db.playerProfiles)..where((x) => x.id.equals(playerId))).getSingleOrNull();
        final current = existing?.toJson() ?? const <String, dynamic>{};
        Value<String?> v(String key) => Value(fitLength(p.profile[key], profileMaxLength[key]!) ?? current[key] as String?);
        final years = int.tryParse(p.profile['yearsTraining'] ?? '');
        final row = PlayerProfilesCompanion(
          teamId: Value(teamId), playerId: Value(playerId), nationality: v('nationality'), birthPlace: v('birthPlace'),
          phone: v('phone'), email: v('email'), address: v('address'), school: v('school'), schoolYear: v('schoolYear'),
          fatherName: v('fatherName'), fatherNationality: v('fatherNationality'), fatherOccupation: v('fatherOccupation'),
          fatherMaritalStatus: v('fatherMaritalStatus'), motherName: v('motherName'),
          motherNationality: v('motherNationality'), motherMaritalStatus: v('motherMaritalStatus'),
          previousClub: v('previousClub'), previousClubCity: v('previousClubCity'),
          yearsTraining: Value(years != null && years <= 40 ? years : existing?.yearsTraining),
          preferredRole: v('preferredRole'), remarks: v('remarks'),
          deleted: const Value(false), updatedAt: Value(now), isDirty: const Value(true),
        );
        await _db.into(_db.playerProfiles).insert(row.copyWith(id: Value(playerId), createdAt: Value(now)),
            onConflict: DoUpdate((_) => row));
        sum.profiles++;
        if (p.birthDate != null) {
          await (_db.update(_db.players)..where((x) => x.id.equals(playerId) & x.birthDate.isNull()))
              .write(PlayersCompanion(birthDate: Value(p.birthDate), updatedAt: Value(now), isDirty: const Value(true)));
        }
        if (consent != null && p.medical.values.any((x) => x != null)) {
          final med = PlayerMedicalCompanion(
            teamId: Value(teamId), playerId: Value(playerId), consentDate: Value(consent.date), consentBy: Value(consent.by),
            allergies: Value(fitLength(p.medical['allergies'], 500)), conditions: Value(fitLength(p.medical['conditions'], 500)),
            lowBpAnxiety: Value(fitLength(p.medical['lowBpAnxiety'], 500)), surgeries: Value(fitLength(p.medical['surgeries'], 500)),
            recentInjuries: Value(fitLength(p.medical['recentInjuries'], 1000)),
            deleted: const Value(false), updatedAt: Value(now), isDirty: const Value(true),
          );
          await _db.into(_db.playerMedical).insert(med.copyWith(id: Value(playerId), createdAt: Value(now)),
              onConflict: DoUpdate((_) => med));
          sum.medical++;
        }
      }
    });
    _ref.read(syncControllerProvider.notifier).requestSync();
    return sum;
  }
}
