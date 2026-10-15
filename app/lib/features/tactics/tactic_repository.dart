import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import '../../data/sync.dart';
import '../sessions/session_repository.dart' show pairId;
import 'tactic_board.dart';

const _uuid = Uuid();

// Valeurs en base → libellés affichés.
const tacticKinds = {
  'corner': 'Corner', 'free_kick': 'Coup franc', 'penalty': 'Penalty', 'throw_in': 'Touche',
  'kick_off': 'Engagement', 'custom': 'Situation personnalisée',
};
const tacticSides = {'attack': 'Offensif', 'defense': 'Défensif'};
const tacticPitches = {'half': 'Demi-terrain', 'full': 'Terrain entier'};

/// Rôles proposés d'un toucher sur un pion.
const tacticRoles = [
  'Tireur', '1er poteau', '2e poteau', 'Point de penalty', 'Écran', 'Second ballon', 'Couverture', 'Marquage', 'Zone',
  'Mur', 'Gardien',
];

// ---------------------------------------------------------------------------
// Lectures
// ---------------------------------------------------------------------------

final tacticsProvider = StreamProvider.family<List<Tactic>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.tactics)
        ..where((t) => t.teamId.equals(teamId) & t.deleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.name)]))
      .watch();
});

final tacticProvider = StreamProvider.family<Tactic?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.tactics)..where((t) => t.id.equals(id))).watchSingleOrNull();
});

/// Liens de toute l'équipe : nombre de séances et de matchs de chaque tactique.
final teamTacticLinksProvider = StreamProvider.family<List<TacticLink>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.tacticLinks)..where((l) => l.teamId.equals(teamId) & l.deleted.equals(false))).watch();
});

// ---------------------------------------------------------------------------
// Écritures
// ---------------------------------------------------------------------------

final tacticRepositoryProvider = Provider<TacticRepository>((ref) => TacticRepository(ref));

class TacticRepository {
  TacticRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);
  void _sync() => _ref.read(syncControllerProvider.notifier).requestSync();

  /// Crée une tactique avec un tableau de départ adapté à la situation ; renvoie son id.
  Future<String> create({required String teamId, required String name, required String kind, required String side,
      required String pitch, String? notes}) async {
    final id = _uuid.v4();
    final now = nowIso();
    await _db.into(_db.tactics).insert(TacticsCompanion.insert(
          id: id, teamId: teamId, name: name, kind: kind, side: side, pitch: Value(pitch),
          board: Value(startingBoard(kind, side, pitch).encode()), notes: Value(notes),
          createdAt: now, updatedAt: now, isDirty: const Value(true),
        ));
    _sync();
    return id;
  }

  Future<void> _update(String id, TacticsCompanion fields) async {
    await (_db.update(_db.tactics)..where((t) => t.id.equals(id)))
        .write(fields.copyWith(updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  Future<void> updateInfo(String id, {required String name, required String kind, required String side,
          required String pitch, String? notes}) =>
      _update(id, TacticsCompanion(name: Value(name), kind: Value(kind), side: Value(side), pitch: Value(pitch), notes: Value(notes)));

  Future<void> saveBoard(String id, TacticBoard board) => _update(id, TacticsCompanion(board: Value(board.encode())));

  /// Copie d'une tactique (ex. la version « corner à droite » avant d'appliquer la symétrie).
  Future<String> duplicate(Tactic t) async {
    final id = _uuid.v4();
    final now = nowIso();
    final name = '${t.name} (copie)';
    await _db.into(_db.tactics).insert(t.copyWith(
          id: id, name: name.length > 60 ? name.substring(0, 60) : name,
          createdAt: now, updatedAt: now, serverUpdatedAt: const Value(null), isDirty: true,
        ));
    _sync();
    return id;
  }

  /// Suppression : la tactique et ses liens vers les séances et les matchs.
  Future<void> delete(String id) async {
    final now = nowIso();
    const gone = Value(true);
    await _db.transaction(() async {
      await (_db.update(_db.tactics)..where((t) => t.id.equals(id)))
          .write(TacticsCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
      await (_db.update(_db.tacticLinks)..where((l) => l.tacticId.equals(id)))
          .write(TacticLinksCompanion(deleted: gone, updatedAt: Value(now), isDirty: gone));
    });
    _sync();
  }

  /// Tactiques rattachées à une séance (sessionId) ou à un match (matchId) : remplace la sélection.
  Future<void> setLinks({required String teamId, String? sessionId, String? matchId, required Set<String> tacticIds}) async {
    final target = (sessionId ?? matchId)!;
    final now = nowIso();
    await _db.transaction(() async {
      final current = await (_db.select(_db.tacticLinks)
            ..where((l) => sessionId != null ? l.sessionId.equals(sessionId) : l.matchId.equals(matchId!)))
          .get();
      for (final l in current.where((l) => !l.deleted && !tacticIds.contains(l.tacticId))) {
        await (_db.update(_db.tacticLinks)..where((x) => x.id.equals(l.id)))
            .write(TacticLinksCompanion(deleted: const Value(true), updatedAt: Value(now), isDirty: const Value(true)));
      }
      for (final tacticId in tacticIds) {
        final id = pairId(tacticId, target);
        final existing = current.where((l) => l.id == id).firstOrNull;
        if (existing != null && !existing.deleted) continue;
        await _db.into(_db.tacticLinks).insertOnConflictUpdate(TacticLinksCompanion.insert(
              id: id, teamId: teamId, tacticId: tacticId, sessionId: Value(sessionId), matchId: Value(matchId),
              createdAt: existing?.createdAt ?? now, updatedAt: now, deleted: const Value(false), isDirty: const Value(true),
            ));
      }
    });
    _sync();
  }
}

/// Tableau de départ : le ballon à l'endroit du coup de pied arrêté et le gardien du but dessiné en haut
/// (adverse si la tactique est offensive, le nôtre si elle est défensive).
TacticBoard startingBoard(String kind, String side, String pitch) {
  final full = pitch == 'full';
  // Hauteur en fraction du terrain affiché pour une distance (m) depuis le but du haut.
  double fromGoal(double m) => m / pitchLengthM(pitch);
  final (bx, by) = switch (kind) {
    'corner' => (0.02, fromGoal(0.6)),
    'free_kick' => (0.4, fromGoal(24)),
    'penalty' => (0.5, fromGoal(11)),
    'throw_in' => (0.0, fromGoal(20)),
    _ => (0.5, full ? 0.5 : 0.98),
  };
  final keeperUs = side == 'defense';
  return TacticBoard(tokens: [
    BoardToken(id: 'ball', kind: 'ball', x: bx, y: by),
    if (kind != 'kick_off' && kind != 'custom')
      BoardToken(id: 'gk', kind: keeperUs ? 'us' : 'them', x: 0.5, y: fromGoal(1.5), label: keeperUs ? 'GB' : null,
          role: keeperUs ? 'Gardien' : null),
  ]);
}
