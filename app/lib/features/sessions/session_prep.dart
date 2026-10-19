import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/permissions.dart';
import '../../core/router.dart';
import '../../data/database.dart';
import '../../data/sync.dart';
import '../auth/auth_repository.dart';
import '../profile/profile_repository.dart';
import '../tactics/tactic_repository.dart';
import '../tactics/tactic_screens.dart' show TacticThumbnail, showTacticInfoSheet;

const _uuid = Uuid();

// Préparation d'une séance (programme d'exercices) et commentaires du staff.

final sessionExercisesProvider = StreamProvider.family<List<SessionExercise>, String>((ref, sessionId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.sessionExercises)
        ..where((e) => e.sessionId.equals(sessionId) & e.deleted.equals(false))
        ..orderBy([(e) => OrderingTerm(expression: e.sortOrder), (e) => OrderingTerm(expression: e.createdAt)]))
      .watch();
});

final sessionCommentsProvider = StreamProvider.family<List<SessionComment>, String>((ref, sessionId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.sessionComments)
        ..where((c) => c.sessionId.equals(sessionId) & c.deleted.equals(false))
        ..orderBy([(c) => OrderingTerm(expression: c.createdAt)]))
      .watch();
});

final sessionPrepRepositoryProvider = Provider<SessionPrepRepository>((ref) => SessionPrepRepository(ref));

class SessionPrepRepository {
  SessionPrepRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);
  void _sync() => _ref.read(syncControllerProvider.notifier).requestSync();

  /// Crée (id null, en fin de programme) ou modifie un exercice.
  Future<void> saveExercise({String? id, required TrainingSession s, required String name, String? description,
      int? durationMin, String? tacticId, required int sortOrder}) async {
    final now = nowIso();
    final fields = SessionExercisesCompanion(
      name: Value(name), description: Value(description), durationMin: Value(durationMin), tacticId: Value(tacticId),
      sortOrder: Value(sortOrder), updatedAt: Value(now), isDirty: const Value(true),
    );
    if (id == null) {
      await _db.into(_db.sessionExercises).insert(fields.copyWith(
            id: Value(_uuid.v4()), teamId: Value(s.teamId), sessionId: Value(s.id), createdAt: Value(now)));
    } else {
      await (_db.update(_db.sessionExercises)..where((e) => e.id.equals(id))).write(fields);
    }
    _sync();
  }

  Future<void> deleteExercise(String id) async {
    await (_db.update(_db.sessionExercises)..where((e) => e.id.equals(id)))
        .write(SessionExercisesCompanion(deleted: const Value(true), updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }

  /// Échange deux exercices dans le programme.
  Future<void> swap(SessionExercise a, SessionExercise b, int indexA, int indexB) async {
    final now = nowIso();
    await _db.transaction(() async {
      await (_db.update(_db.sessionExercises)..where((e) => e.id.equals(a.id)))
          .write(SessionExercisesCompanion(sortOrder: Value(indexB), updatedAt: Value(now), isDirty: const Value(true)));
      await (_db.update(_db.sessionExercises)..where((e) => e.id.equals(b.id)))
          .write(SessionExercisesCompanion(sortOrder: Value(indexA), updatedAt: Value(now), isDirty: const Value(true)));
    });
    _sync();
  }

  Future<void> addComment(TrainingSession s, {required String authorName, required String text}) async {
    final now = nowIso();
    await _db.into(_db.sessionComments).insert(SessionCommentsCompanion.insert(
          id: _uuid.v4(), teamId: s.teamId, sessionId: s.id,
          authorId: _ref.read(supabaseProvider).auth.currentUser!.id, authorName: authorName, text_: text,
          createdAt: now, updatedAt: now, isDirty: const Value(true),
        ));
    _sync();
  }

  Future<void> deleteComment(String id) async {
    await (_db.update(_db.sessionComments)..where((c) => c.id.equals(id)))
        .write(SessionCommentsCompanion(deleted: const Value(true), updatedAt: Value(nowIso()), isDirty: const Value(true)));
    _sync();
  }
}

/// « Programme de la séance » : exercices dans l'ordre, durée totale, tactique de chaque exercice.
class SessionProgram extends ConsumerWidget {
  const SessionProgram({super.key, required this.session});

  final TrainingSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(sessionExercisesProvider(session.id)).value ?? const <SessionExercise>[];
    final tactics = {for (final t in ref.watch(tacticsProvider(session.teamId)).value ?? const <Tactic>[]) t.id: t};
    final editable = ref.watch(permsProvider).can('seances.edit');
    final repo = ref.read(sessionPrepRepositoryProvider);
    final theme = Theme.of(context);
    final total = exercises.fold<int>(0, (s, e) => s + (e.durationMin ?? 0));

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
        child: Row(children: [
          Expanded(
            child: Text(total > 0 ? 'Programme de la séance · $total min' : 'Programme de la séance',
                style: theme.textTheme.titleSmall),
          ),
          if (editable)
            TextButton.icon(
              onPressed: () => showExerciseSheet(context, ref, session, sortOrder: exercises.length),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Exercice'),
            ),
        ]),
      ),
      if (exercises.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Aucun exercice. Préparez la séance : nom, consignes, durée et tactique de chaque exercice.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        ),
      for (final (i, e) in exercises.indexed)
        Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: editable ? () => showExerciseSheet(context, ref, session, exercise: e, sortOrder: i) : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(radius: 14, child: Text('${i + 1}', style: const TextStyle(fontSize: 13))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text([e.name, if (e.durationMin != null) '${e.durationMin} min'].join(' · '), style: theme.textTheme.titleSmall),
                    if (e.description != null) Text(e.description!, style: theme.textTheme.bodySmall),
                    if (tactics[e.tacticId] != null)
                      InkWell(
                        onTap: () => context.go('/sessions/${session.id}/tactic/${e.tacticId}'),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(children: [
                            SizedBox(width: 32, child: TacticThumbnail(tactics[e.tacticId]!)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(tactics[e.tacticId]!.name, style: TextStyle(color: theme.colorScheme.primary))),
                          ]),
                        ),
                      ),
                  ]),
                ),
                if (editable)
                  Column(children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Monter',
                      icon: const Icon(Icons.arrow_upward, size: 18),
                      onPressed: i == 0 ? null : () => repo.swap(e, exercises[i - 1], i, i - 1),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Descendre',
                      icon: const Icon(Icons.arrow_downward, size: 18),
                      onPressed: i == exercises.length - 1 ? null : () => repo.swap(e, exercises[i + 1], i, i + 1),
                    ),
                  ]),
              ]),
            ),
          ),
        ),
    ]);
  }
}

/// Ajout (exercise null) ou modification d'un exercice : nom, durée, consignes, tactique.
Future<void> showExerciseSheet(BuildContext context, WidgetRef ref, TrainingSession s,
    {SessionExercise? exercise, required int sortOrder}) {
  final name = TextEditingController(text: exercise?.name ?? '');
  final description = TextEditingController(text: exercise?.description ?? '');
  final duration = TextEditingController(text: exercise?.durationMin?.toString() ?? '');
  String? tacticId = exercise?.tacticId;
  var submitted = false;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Consumer(builder: (context, ref, _) {
      final tactics = ref.watch(tacticsProvider(s.teamId)).value ?? const <Tactic>[];
      return StatefulBuilder(builder: (context, setState) {
        final theme = Theme.of(context);
        final repo = ref.read(sessionPrepRepositoryProvider);
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(exercise == null ? 'Nouvel exercice' : 'Modifier l\'exercice', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: name,
                autofocus: exercise == null,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  hintText: 'Rondo 5 contre 2',
                  errorText: submitted && name.text.trim().isEmpty ? 'Obligatoire' : null,
                ),
              ),
              TextField(
                controller: duration,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Durée (minutes)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                maxLength: 2000,
                maxLines: 5,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Description et consignes', alignLabelWithHint: true),
              ),
              DropdownButtonFormField<String?>(
                initialValue: tactics.any((t) => t.id == tacticId) ? tacticId : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tactique de l\'exercice'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Aucune')),
                  for (final t in tactics) DropdownMenuItem(value: t.id, child: Text(t.name, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => tacticId = v),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Créer une tactique pour cet exercice'),
                  onPressed: () async {
                    final id = await showTacticInfoSheet(context, ref, teamId: s.teamId);
                    if (id != null) setState(() => tacticId = id);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                if (exercise != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                      onPressed: () async {
                        await repo.deleteExercise(exercise.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: const Text('Supprimer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      setState(() => submitted = true);
                      if (name.text.trim().isEmpty) return;
                      final d = int.tryParse(duration.text);
                      final text = description.text.trim();
                      await repo.saveExercise(
                        id: exercise?.id, s: s, name: name.text.trim(), description: text.isEmpty ? null : text,
                        durationMin: d == null || d < 1 ? null : d.clamp(1, 240), tacticId: tacticId, sortOrder: sortOrder,
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Enregistrer'),
                  ),
                ),
              ]),
            ]),
          ),
        );
      });
    }),
  );
}

/// Commentaires du staff sur la séance (directeur technique, entraîneurs…), du plus ancien au plus récent.
class SessionCommentsSection extends ConsumerStatefulWidget {
  const SessionCommentsSection({super.key, required this.session});

  final TrainingSession session;

  @override
  ConsumerState<SessionCommentsSection> createState() => _SessionCommentsSectionState();
}

class _SessionCommentsSectionState extends ConsumerState<SessionCommentsSection> {
  final _text = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final user = ref.read(supabaseProvider).auth.currentUser;
    final profile = ref.read(myProfileProvider).value;
    final role = roleLabels[ref.read(permsProvider).role];
    final author = [profile?.fullName ?? user?.email ?? 'Staff', ?role].join(' · ');
    await ref.read(sessionPrepRepositoryProvider).addComment(widget.session, authorName: author, text: text);
    _text.clear();
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(sessionCommentsProvider(widget.session.id)).value ?? const <SessionComment>[];
    final me = ref.watch(supabaseProvider).auth.currentUser?.id;
    final canComment = ref.watch(permsProvider).can('seances.commenter');
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text('Commentaires (${comments.length})', style: theme.textTheme.titleSmall),
      ),
      if (comments.isEmpty && !canComment)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Aucun commentaire.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        ),
      for (final c in comments)
        ListTile(
          leading: const Icon(Icons.chat_bubble_outline),
          title: Text(c.text_),
          subtitle: Text('${c.authorName} · ${DateFormat("d MMM 'à' HH:mm", 'fr_FR').format(DateTime.parse(c.createdAt).toLocal())}'),
          trailing: c.authorId == me
              ? IconButton(
                  tooltip: 'Supprimer mon commentaire',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref.read(sessionPrepRepositoryProvider).deleteComment(c.id);
                    if (context.mounted) showMessage(context, 'Commentaire supprimé');
                  },
                )
              : null,
        ),
      if (canComment)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _text,
                maxLength: 1000,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Ajouter un commentaire', counterText: ''),
              ),
            ),
            IconButton(tooltip: 'Envoyer', icon: const Icon(Icons.send), onPressed: _sending ? null : _send),
          ]),
        ),
    ]);
  }
}
