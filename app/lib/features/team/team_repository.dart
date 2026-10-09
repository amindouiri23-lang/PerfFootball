import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import '../../data/sync.dart';
import '../auth/auth_repository.dart';

const _uuid = Uuid();

// Valeurs en base → libellés affichés (specs E06 et E09).
const categories = {'seniors': 'Seniors', 'u21': 'U21', 'u19': 'U19', 'u17': 'U17', 'u15': 'U15', 'other': 'Autre'};
const positions = {'GK': 'Gardien', 'DEF': 'Défenseur', 'MID': 'Milieu', 'FWD': 'Attaquant'};
const positionShort = {'GK': 'GB', 'DEF': 'DEF', 'MID': 'MIL', 'FWD': 'ATT'};
const positionPlural = {'GK': 'Gardiens', 'DEF': 'Défenseurs', 'MID': 'Milieux', 'FWD': 'Attaquants'};
const feet = {'R': 'Droit', 'L': 'Gauche', 'B': 'Les deux'};

/// Saison en cours (bascule au 1er juillet), précédente et suivante, ex. « 2026-2027 ».
List<String> seasonChoices([DateTime? now]) {
  final d = now ?? DateTime.now();
  final start = d.month >= 7 ? d.year : d.year - 1;
  return [for (final y in [start - 1, start, start + 1]) '$y-${y + 1}'];
}

String currentSeason() => seasonChoices()[1];

final teamsProvider = StreamProvider<List<Team>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.teams)
        ..where((t) => t.deleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.name)]))
      .watch();
});

const _activeTeamKey = 'active_team_id';

/// Équipe active : celle choisie sur l'appareil, sinon la première.
final activeTeamProvider = Provider<AsyncValue<Team?>>((ref) {
  final teams = ref.watch(teamsProvider);
  final chosen = ref.watch(_activeTeamIdProvider).value;
  return teams.whenData((list) => list.where((t) => t.id == chosen).firstOrNull ?? list.firstOrNull);
});

final _activeTeamIdProvider = StreamProvider<String?>((ref) => ref.watch(databaseProvider).watchSetting(_activeTeamKey));

/// Joueurs non supprimés d'une équipe, triés par poste puis par numéro.
final playersProvider = StreamProvider.family<List<Player>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  const order = ['GK', 'DEF', 'MID', 'FWD'];
  return (db.select(db.players)..where((p) => p.teamId.equals(teamId) & p.deleted.equals(false)))
      .watch()
      .map((list) => list
        ..sort((a, b) {
          final byPos = order.indexOf(a.position).compareTo(order.indexOf(b.position));
          if (byPos != 0) return byPos;
          return (a.shirtNumber ?? 999).compareTo(b.shirtNumber ?? 999);
        }));
});

final playerProvider = StreamProvider.family<Player?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.players)..where((p) => p.id.equals(id))).watchSingleOrNull();
});

final teamRepositoryProvider = Provider<TeamRepository>((ref) => TeamRepository(ref));

/// Écritures locales (is_dirty = true) puis demande de synchronisation : l'écran n'attend jamais le réseau.
class TeamRepository {
  TeamRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);
  void _sync() => _ref.read(syncControllerProvider.notifier).requestSync();

  Future<String> createTeam({required String name, String? clubName, required String category, required String season}) async {
    final id = _uuid.v4();
    final now = nowIso();
    await _db.into(_db.teams).insert(TeamsCompanion.insert(
      id: id, createdAt: now, updatedAt: now, isDirty: const Value(true),
      name: name, clubName: Value(clubName), category: category, season: season,
      createdBy: _ref.read(supabaseProvider).auth.currentUser!.id,
    ));
    await setActiveTeam(id);
    _sync();
    return id;
  }

  Future<void> updateTeam(String id, {required String name, String? clubName, required String category, required String season}) async {
    await (_db.update(_db.teams)..where((t) => t.id.equals(id))).write(TeamsCompanion(
      name: Value(name), clubName: Value(clubName), category: Value(category), season: Value(season),
      updatedAt: Value(nowIso()), isDirty: const Value(true),
    ));
    _sync();
  }

  Future<void> setActiveTeam(String id) => _db.setSetting(_activeTeamKey, id);

  Future<void> setTeamLogo(String id, String path) async {
    await (_db.update(_db.teams)..where((t) => t.id.equals(id)))
        .write(TeamsCompanion(logoPath: Value(path), updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  Future<void> setPlayerPhoto(String id, String path) async {
    await (_db.update(_db.players)..where((p) => p.id.equals(id)))
        .write(PlayersCompanion(photoPath: Value(path), updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  /// Crée (id null) ou modifie un joueur ; renvoie son id.
  Future<String> savePlayer({
    String? id,
    required String teamId,
    required String firstName,
    required String lastName,
    int? shirtNumber,
    required String position,
    String? birthDate,
    String? dominantFoot,
    int? heightCm,
  }) async {
    final now = nowIso();
    final fields = PlayersCompanion(
      teamId: Value(teamId), firstName: Value(firstName), lastName: Value(lastName),
      shirtNumber: Value(shirtNumber), position: Value(position), birthDate: Value(birthDate),
      dominantFoot: Value(dominantFoot), heightCm: Value(heightCm),
      updatedAt: Value(now), isDirty: const Value(true),
    );
    if (id == null) {
      id = _uuid.v4();
      await _db.into(_db.players).insert(fields.copyWith(id: Value(id), createdAt: Value(now)));
    } else {
      await (_db.update(_db.players)..where((p) => p.id.equals(id!))).write(fields);
    }
    _sync();
    return id;
  }

  /// Suppression logique : le joueur sort de l'effectif, son historique reste pour Power BI.
  Future<void> deletePlayer(String id) async {
    await (_db.update(_db.players)..where((p) => p.id.equals(id)))
        .write(PlayersCompanion(deleted: const Value(true), updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }
}

extension PlayerLabels on Player {
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.substring(0, 1)}${lastName.substring(0, 1)}'.toUpperCase();

  int? get age {
    if (birthDate == null) return null;
    final b = DateTime.parse(birthDate!);
    final now = DateTime.now();
    return now.year - b.year - ((now.month < b.month || (now.month == b.month && now.day < b.day)) ? 1 : 0);
  }
}
