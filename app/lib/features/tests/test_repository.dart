import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import '../../data/sync.dart';
import '../sessions/session_repository.dart' show naturalId;

const _uuid = Uuid();

// Valeurs en base → libellés affichés (specs E32 à E34).
const testCategories = {
  'anthropometry': 'Mesures corporelles', 'endurance': 'Endurance', 'speed': 'Vitesse', 'agility': 'Agilité',
  'power': 'Détente', 'strength': 'Force', 'other': 'Autre',
};
const testBetter = {'higher': 'Plus haut = mieux', 'lower': 'Plus bas = mieux', 'none': 'Sans classement'};

/// Les trois batteries de tests d'une saison.
const testCampaigns = {'start': 'Début de saison', 'mid': 'Mi-saison', 'end': 'Fin de saison'};

/// Saison sportive d'une date : elle commence le 1er juillet (« 2026-2027 » → 2026).
int seasonOf(DateTime d) => d.month >= 7 ? d.year : d.year - 1;

String seasonLabel(int season) => '$season-${season + 1}';

/// « 3,29 » : virgule française, zéros inutiles retirés.
String formatTestValue(double v) =>
    NumberFormat('0.##', 'fr_FR').format(v);

/// Lit « 3,29 » ou « 3.29 » ; null si vide ou invalide.
double? parseTestValue(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

extension TestTypeLabels on TestType {
  String get unitLabel => unit == null || unit!.isEmpty ? '' : ' $unit';

  /// Meilleur des essais : le plus bas pour un chrono, le plus haut sinon.
  double best(Iterable<double> values) => better == 'lower'
      ? values.reduce((a, b) => a < b ? a : b)
      : values.reduce((a, b) => a > b ? a : b);

  /// Vrai si [a] est meilleur que [b] ; null si le test n'a pas de sens de classement.
  bool? isBetter(double a, double b) => switch (better) {
        'higher' => a > b,
        'lower' => a < b,
        _ => null,
      };
}

// ---------------------------------------------------------------------------
// Lectures
// ---------------------------------------------------------------------------

/// Tests communs et tests de l'équipe, dans l'ordre du catalogue.
final testTypesProvider = StreamProvider.family<List<TestType>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.testTypes)
        ..where((t) => t.deleted.equals(false) & (t.teamId.isNull() | t.teamId.equals(teamId)))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder), (t) => OrderingTerm(expression: t.name)]))
      .watch();
});

final teamTestResultsProvider = StreamProvider.family<List<TestResult>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.testResults)..where((r) => r.teamId.equals(teamId) & r.deleted.equals(false))).watch();
});

final playerTestResultsProvider = StreamProvider.family<List<TestResult>, String>((ref, playerId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.testResults)
        ..where((r) => r.playerId.equals(playerId) & r.deleted.equals(false))
        ..orderBy([(r) => OrderingTerm(expression: r.date, mode: OrderingMode.desc)]))
      .watch();
});

/// Meilleur résultat d'un joueur pour un test et un jour.
class BestResult {
  const BestResult(this.date, this.value);
  final String date;
  final double value;
}

/// Pour un joueur : par test, le meilleur résultat de chaque jour, du plus récent au plus ancien.
Map<String, List<BestResult>> bestByTest(List<TestResult> results, Map<String, TestType> types) {
  final byKey = <String, Map<String, List<double>>>{};
  for (final r in results) {
    byKey.putIfAbsent(r.testTypeId, () => {}).putIfAbsent(r.date, () => []).add(r.value);
  }
  return {
    for (final e in byKey.entries)
      if (types[e.key] != null)
        e.key: [
          for (final d in e.value.keys.toList()..sort((a, b) => b.compareTo(a)))
            BestResult(d, types[e.key]!.best(e.value[d]!)),
        ],
  };
}

// ---------------------------------------------------------------------------
// Écritures
// ---------------------------------------------------------------------------

final testRepositoryProvider = Provider<TestRepository>((ref) => TestRepository(ref));

class TestRepository {
  TestRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);
  void _sync() => _ref.read(syncControllerProvider.notifier).requestSync();

  /// Un essai : id déterministe (joueur, test, jour, essai), une valeur vide efface le résultat.
  Future<void> saveResult({
    required String teamId,
    required String playerId,
    required String testTypeId,
    required String date,
    required int attempt,
    required double? value,
    String? campaign,
  }) async {
    final id = naturalId([playerId, testTypeId, date, '$attempt']);
    final now = nowIso();
    final existing = await (_db.select(_db.testResults)..where((r) => r.id.equals(id))).getSingleOrNull();
    if (value == null) {
      if (existing != null && !existing.deleted) {
        await (_db.update(_db.testResults)..where((r) => r.id.equals(id)))
            .write(TestResultsCompanion(deleted: const Value(true), updatedAt: Value(now), isDirty: const Value(true)));
        _sync();
      }
      return;
    }
    await _db.into(_db.testResults).insertOnConflictUpdate(TestResultsCompanion.insert(
          id: id, teamId: teamId, playerId: playerId, testTypeId: testTypeId, date: date,
          attempt: Value(attempt), value: value, campaign: Value(campaign), deleted: const Value(false),
          createdAt: existing?.createdAt ?? now, updatedAt: now, isDirty: const Value(true),
        ));
    _sync();
  }

  /// E34 — test propre à l'équipe (les tests communs viennent du serveur).
  Future<String> addTestType({
    required String teamId,
    required String name,
    String? unit,
    required String category,
    required String better,
    required int attempts,
  }) async {
    final id = _uuid.v4();
    final now = nowIso();
    await _db.into(_db.testTypes).insert(TestTypesCompanion.insert(
          id: id, teamId: Value(teamId), name: name, unit: Value(unit), category: category, better: better,
          attempts: Value(attempts), sortOrder: const Value(1000), createdAt: now, updatedAt: now,
          isDirty: const Value(true),
        ));
    _sync();
    return id;
  }
}
