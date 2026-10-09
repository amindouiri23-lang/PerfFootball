import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/auth_repository.dart';
import 'database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Description d'une table synchronisée. L'ordre de la liste est l'ordre des dépendances.
class _SyncTable {
  const _SyncTable(this.name, {this.push = true, this.booleans = const {}});
  final String name;
  /// false : table en lecture seule pour l'application (écrite par le serveur).
  final bool push;
  /// Colonnes booléennes autres que deleted (SQLite stocke 0/1, Supabase true/false).
  final Set<String> booleans;
}

const _tables = [
  _SyncTable('teams'),
  _SyncTable('team_members', push: false),
  _SyncTable('players'),
  _SyncTable('sessions'),
  _SyncTable('session_players', booleans: {'present'}),
  _SyncTable('wellness'),
  _SyncTable('matches'),
  _SyncTable('match_players', booleans: {'present'}),
  _SyncTable('match_events'),
  _SyncTable('injuries'), // après sessions et matches, qu'elle référence
];

/// Synchronisation hors ligne d'abord (docs/01 §6) :
/// envoi des lignes modifiées (is_dirty), puis réception des lignes changées sur le serveur.
class SyncEngine {
  SyncEngine(this._db, this._client);

  final AppDatabase _db;
  final SupabaseClient _client;

  /// Marge de relecture : une transaction validée tard peut porter un server_updated_at antérieur
  /// au curseur. Relire 5 minutes en arrière est sans risque (les écritures sont idempotentes).
  static const _overlap = Duration(minutes: 5);
  static const _page = 1000;

  Future<void> run() async {
    await _push();
    await _pull();
  }

  TableInfo _info(String name) => _db.allTables.firstWhere((t) => t.actualTableName == name);

  Future<void> _push() async {
    for (final t in _tables.where((t) => t.push)) {
      final rows = await _db.customSelect('SELECT * FROM ${t.name} WHERE is_dirty = 1').get();
      if (rows.isEmpty) continue;
      final payload = [for (final r in rows) _toRemote(t, r.data)];
      await _client.from(t.name).upsert(payload);
      // Ne marquer « propre » que si la ligne n'a pas été modifiée pendant l'envoi.
      await _db.transaction(() async {
        for (final r in rows) {
          await _db.customUpdate(
            'UPDATE ${t.name} SET is_dirty = 0 WHERE id = ? AND updated_at = ?',
            variables: [Variable(r.data['id']), Variable(r.data['updated_at'])],
            updates: {_info(t.name)},
          );
        }
      });
    }
  }

  Future<void> _pull() async {
    for (final t in _tables) {
      final state = await (_db.select(_db.syncState)..where((s) => s.tableName_.equals(t.name))).getSingleOrNull();
      final since = state == null
          ? null
          : DateTime.parse(state.cursor).subtract(_overlap).toUtc().toIso8601String();
      var cursor = state?.cursor;
      for (var offset = 0;; offset += _page) {
        var query = _client.from(t.name).select();
        if (since != null) query = query.gte('server_updated_at', since);
        final rows = await query.order('server_updated_at').range(offset, offset + _page - 1);
        if (rows.isNotEmpty) {
          await _db.transaction(() async {
            for (final row in rows) {
              await _upsertLocal(t, row);
            }
          });
          final last = rows.last['server_updated_at'] as String;
          if (cursor == null || DateTime.parse(last).isAfter(DateTime.parse(cursor))) cursor = last;
        }
        if (rows.length < _page) break;
      }
      if (cursor != null) {
        await _db.into(_db.syncState).insertOnConflictUpdate(SyncStateCompanion.insert(tableName_: t.name, cursor: cursor));
      }
    }
  }

  Map<String, Object?> _toRemote(_SyncTable t, Map<String, Object?> local) {
    final row = Map<String, Object?>.of(local)
      ..remove('is_dirty')
      ..remove('server_updated_at'); // posé par le serveur
    for (final c in {'deleted', ...t.booleans}) {
      row[c] = row[c] == 1; // SQLite stocke 0/1, Supabase true/false
    }
    return row;
  }

  /// Écrit une ligne reçue, sauf si une modification locale non envoyée existe (elle partira au prochain envoi).
  Future<void> _upsertLocal(_SyncTable t, Map<String, dynamic> remote) async {
    final row = <String, Object?>{
      for (final e in remote.entries) e.key: e.value is bool ? ((e.value as bool) ? 1 : 0) : e.value,
      'is_dirty': 0,
    };
    final cols = row.keys.toList();
    final updates = cols.where((c) => c != 'id').map((c) => '$c = excluded.$c').join(', ');
    await _db.customInsert(
      'INSERT INTO ${t.name} (${cols.join(', ')}) VALUES (${List.filled(cols.length, '?').join(', ')}) '
      'ON CONFLICT(id) DO UPDATE SET $updates WHERE ${t.name}.is_dirty = 0',
      variables: [for (final c in cols) Variable(row[c])],
      updates: {_info(t.name)},
    );
  }
}

class SyncStatus {
  const SyncStatus({this.syncing = false, this.lastSuccess, this.error});
  final bool syncing;
  final DateTime? lastSuccess;
  /// Dernière erreur ; null si la dernière synchronisation a réussi.
  final String? error;
}

final syncControllerProvider = NotifierProvider<SyncController, SyncStatus>(SyncController.new);

class SyncController extends Notifier<SyncStatus> {
  Timer? _debounce;
  bool _again = false;

  @override
  SyncStatus build() {
    final sub = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) sync();
    });
    ref.onDispose(() {
      sub.cancel();
      _debounce?.cancel();
    });
    return const SyncStatus();
  }

  /// À appeler après chaque enregistrement local : regroupe les envois rapprochés.
  void requestSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), sync);
  }

  Future<void> sync() async {
    if (ref.read(supabaseProvider).auth.currentUser == null) return;
    if (state.syncing) {
      _again = true;
      return;
    }
    state = SyncStatus(syncing: true, lastSuccess: state.lastSuccess, error: state.error);
    try {
      await SyncEngine(ref.read(databaseProvider), ref.read(supabaseProvider)).run();
      state = SyncStatus(lastSuccess: DateTime.now());
    } on PostgrestException catch (e) {
      state = SyncStatus(lastSuccess: state.lastSuccess, error: 'Erreur du serveur : ${e.message}');
    } catch (e) {
      final text = e.toString();
      final offline = e is AuthRetryableFetchException ||
          ['SocketException', 'ClientException', 'Failed to fetch', 'XMLHttpRequest'].any(text.contains);
      state = SyncStatus(lastSuccess: state.lastSuccess, error: offline ? 'Hors ligne' : 'Erreur : $text');
    }
    if (_again) {
      _again = false;
      await sync();
    }
  }
}

/// Vrai après la première tentative de synchronisation : avant, une liste vide peut seulement
/// signifier « pas encore téléchargée » (évite de proposer de créer une équipe qui existe déjà).
final firstSyncDoneProvider = Provider<bool>((ref) {
  final s = ref.watch(syncControllerProvider);
  return s.lastSuccess != null || s.error != null;
});

/// Nombre de lignes modifiées sur l'appareil et pas encore envoyées.
final pendingCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final pushed = _tables.where((t) => t.push).map((t) => t.name).toList();
  final sql = 'SELECT ${pushed.map((n) => '(SELECT COUNT(*) FROM $n WHERE is_dirty = 1)').join(' + ')} AS c';
  return db
      .customSelect(sql, readsFrom: {for (final n in pushed) db.allTables.firstWhere((t) => t.actualTableName == n)})
      .watchSingle()
      .map((r) => r.read<int>('c'));
});

/// Horodatage ISO UTC des colonnes created_at / updated_at.
String nowIso() => DateTime.now().toUtc().toIso8601String();
