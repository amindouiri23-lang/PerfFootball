import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import '../../data/sync.dart';

const _uuid = Uuid();

// Séance de visionnage : une présentation de diapositives (texte, tactique, vidéo par lien), projetée en
// salle vidéo ou partagée en PDF.

const slideKinds = {'text': 'Texte', 'tactic': 'Tactique', 'video': 'Vidéo'};

extension ViewingSessionLabels on ViewingSession {
  String get dateLabel {
    if (date == null) return 'Sans date';
    final s = DateFormat('EEEE d MMMM y', 'fr_FR').format(DateTime.parse(date!));
    return s[0].toUpperCase() + s.substring(1);
  }
}

// ---------------------------------------------------------------------------
// Lectures
// ---------------------------------------------------------------------------

final viewingSessionsProvider = StreamProvider.family<List<ViewingSession>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.viewingSessions)
        ..where((v) => v.teamId.equals(teamId) & v.deleted.equals(false))
        ..orderBy([(v) => OrderingTerm(expression: v.date, mode: OrderingMode.desc), (v) => OrderingTerm(expression: v.createdAt, mode: OrderingMode.desc)]))
      .watch();
});

final viewingSessionProvider = StreamProvider.family<ViewingSession?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.viewingSessions)..where((v) => v.id.equals(id))).watchSingleOrNull();
});

final viewingSlidesProvider = StreamProvider.family<List<ViewingSlide>, String>((ref, sessionId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.viewingSlides)
        ..where((s) => s.sessionId.equals(sessionId) & s.deleted.equals(false))
        ..orderBy([(s) => OrderingTerm(expression: s.sortOrder), (s) => OrderingTerm(expression: s.createdAt)]))
      .watch();
});

/// Nombre de diapositives par séance de visionnage d'une équipe (liste).
final teamViewingSlidesProvider = StreamProvider.family<List<ViewingSlide>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.viewingSlides)..where((s) => s.teamId.equals(teamId) & s.deleted.equals(false))).watch();
});

// ---------------------------------------------------------------------------
// Écritures
// ---------------------------------------------------------------------------

final viewingRepositoryProvider = Provider<ViewingRepository>((ref) => ViewingRepository(ref));

class ViewingRepository {
  ViewingRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);
  void _sync() => _ref.read(syncControllerProvider.notifier).requestSync();

  Future<String> createSession({required String teamId, required String title, String? date, String? notes}) async {
    final id = _uuid.v4();
    final now = nowIso();
    await _db.into(_db.viewingSessions).insert(ViewingSessionsCompanion.insert(
          id: id, teamId: teamId, title: title, date: Value(date), notes: Value(notes),
          createdAt: now, updatedAt: now, isDirty: const Value(true),
        ));
    _sync();
    return id;
  }

  Future<void> updateSession(String id, {required String title, String? date, String? notes}) async {
    await (_db.update(_db.viewingSessions)..where((v) => v.id.equals(id))).write(ViewingSessionsCompanion(
          title: Value(title), date: Value(date), notes: Value(notes), updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  /// Suppression douce de la séance et de ses diapositives.
  Future<void> deleteSession(String id) async {
    final now = nowIso();
    await _db.transaction(() async {
      await (_db.update(_db.viewingSlides)..where((s) => s.sessionId.equals(id)))
          .write(ViewingSlidesCompanion(deleted: const Value(true), updatedAt: Value(now), isDirty: const Value(true)));
      await (_db.update(_db.viewingSessions)..where((v) => v.id.equals(id)))
          .write(ViewingSessionsCompanion(deleted: const Value(true), updatedAt: Value(now), isDirty: const Value(true)));
    });
    _sync();
  }

  /// Nouvelle diapositive, en fin de présentation.
  Future<void> addSlide(ViewingSession v, {required String kind, String? title, String? body, String? tacticId, String? videoUrl}) async {
    final last = await (_db.selectOnly(_db.viewingSlides)
          ..addColumns([_db.viewingSlides.sortOrder.max()])
          ..where(_db.viewingSlides.sessionId.equals(v.id) & _db.viewingSlides.deleted.equals(false)))
        .map((r) => r.read(_db.viewingSlides.sortOrder.max()))
        .getSingleOrNull();
    final now = nowIso();
    await _db.into(_db.viewingSlides).insert(ViewingSlidesCompanion.insert(
          id: _uuid.v4(), teamId: v.teamId, sessionId: v.id, sortOrder: Value((last ?? -1) + 1), kind: kind,
          title: Value(title), body: Value(body), tacticId: Value(tacticId), videoUrl: Value(videoUrl),
          createdAt: now, updatedAt: now, isDirty: const Value(true),
        ));
    _sync();
  }

  Future<void> updateSlide(String id, {String? title, String? body, String? tacticId, String? videoUrl}) async {
    await (_db.update(_db.viewingSlides)..where((s) => s.id.equals(id))).write(ViewingSlidesCompanion(
          title: Value(title), body: Value(body), tacticId: Value(tacticId), videoUrl: Value(videoUrl),
          updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  Future<void> deleteSlide(String id) async {
    await (_db.update(_db.viewingSlides)..where((s) => s.id.equals(id)))
        .write(ViewingSlidesCompanion(deleted: const Value(true), updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  /// Nouvel ordre des diapositives : seules celles qui changent de place sont réécrites.
  Future<void> reorder(List<ViewingSlide> ordered) async {
    final now = nowIso();
    await _db.transaction(() async {
      for (final (i, s) in ordered.indexed) {
        if (s.sortOrder != i) {
          await (_db.update(_db.viewingSlides)..where((x) => x.id.equals(s.id)))
              .write(ViewingSlidesCompanion(sortOrder: Value(i), updatedAt: Value(now), isDirty: const Value(true)));
        }
      }
    });
    _sync();
  }
}

/// Vidéo intégrable : YouTube, Vimeo ou fichier vidéo direct. null si le lien ne s'intègre pas (on l'ouvre).
({String src, bool iframe})? embedOf(String url) {
  final u = Uri.tryParse(url.trim());
  if (u == null || !u.hasScheme) return null;
  final host = u.host.replaceFirst('www.', '').replaceFirst('m.', '');
  String? yt;
  if (host == 'youtu.be') yt = u.pathSegments.firstOrNull;
  if (host == 'youtube.com' || host == 'youtube-nocookie.com') {
    yt = u.queryParameters['v'] ??
        (u.pathSegments.length >= 2 && {'embed', 'shorts', 'live'}.contains(u.pathSegments[0]) ? u.pathSegments[1] : null);
  }
  if (yt != null && yt.isNotEmpty) {
    final start = u.queryParameters['t']?.replaceAll('s', '');
    return (src: 'https://www.youtube-nocookie.com/embed/$yt${start != null ? '?start=$start' : ''}', iframe: true);
  }
  if (host == 'vimeo.com' && u.pathSegments.isNotEmpty && int.tryParse(u.pathSegments.last) != null) {
    return (src: 'https://player.vimeo.com/video/${u.pathSegments.last}', iframe: true);
  }
  if (RegExp(r'\.(mp4|webm|ogg|mov)$', caseSensitive: false).hasMatch(u.path)) return (src: url.trim(), iframe: false);
  return null;
}
