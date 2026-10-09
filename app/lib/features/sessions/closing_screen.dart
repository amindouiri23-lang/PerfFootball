import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/steppers.dart';
import '../../data/database.dart';
import '../team/team_repository.dart';
import 'session_repository.dart';

/// E17 — Clôture : durée réelle et RPE de chaque présent, enregistrés à chaque appui.
/// Les joueurs sans RPE sont listés en premier (ordre figé à l'ouverture pour que les lignes ne sautent pas).
class ClosingScreen extends ConsumerStatefulWidget {
  const ClosingScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ClosingScreen> createState() => _ClosingScreenState();
}

class _ClosingScreenState extends ConsumerState<ClosingScreen> {
  List<String>? _order;
  /// Valeurs affichées tout de suite, avant que la base locale renvoie la mise à jour :
  /// des appuis rapides sur − / + ne doivent pas se perdre.
  final Map<String, int> _durations = {};
  final Map<String, int?> _rpes = {};

  Future<void> _validate(TrainingSession s) async {
    final repo = ref.read(sessionRepositoryProvider);
    await repo.complete(s);
    if (!mounted) return;
    final wellness = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Séance terminée'),
        content: const Text('Remplir le questionnaire de bien-être maintenant ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Plus tard')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Oui')),
        ],
      ),
    );
    if (!mounted) return;
    context.go(wellness == true ? '/sessions/${s.id}/wellness' : '/sessions');
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider(widget.sessionId)).value;
    final rowsAsync = ref.watch(sessionPlayersProvider(widget.sessionId));
    if (s == null || !rowsAsync.hasValue) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final players = {for (final p in ref.watch(playersProvider(s.teamId)).value ?? const <Player>[]) p.id: p};
    final rows = {for (final r in rowsAsync.value!.where((r) => r.present)) r.id: r};
    _order ??= (rows.values.toList()
          ..sort((a, b) {
            final byRpe = (a.rpe == null ? 0 : 1).compareTo(b.rpe == null ? 0 : 1);
            return byRpe != 0 ? byRpe : (players[a.playerId]?.shirtNumber ?? 999).compareTo(players[b.playerId]?.shirtNumber ?? 999);
          }))
        .map((r) => r.id)
        .toList();
    int durationOf(SessionPlayer r) => _durations[r.id] ?? r.durationMin ?? s.plannedDurationMin;
    int? rpeOf(SessionPlayer r) => _rpes.containsKey(r.id) ? _rpes[r.id] : r.rpe;
    final withRpe = rows.values.where((r) => rpeOf(r) != null).length;
    final repo = ref.read(sessionRepositoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Clôture de la séance')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: [
        Row(children: [
          Expanded(child: Text('RPE saisis : $withRpe/${rows.length}', style: theme.textTheme.titleSmall)),
          TextButton.icon(
            onPressed: () {
              setState(_durations.clear);
              repo.applyPlannedDuration(s);
            },
            icon: const Icon(Icons.schedule),
            label: Text('${s.plannedDurationMin} min à tous'),
          ),
        ]),
        Text('RPE demandé environ 30 minutes après la séance (0 = repos, 10 = maximal). '
            'Facultatif : la séance peut être validée sans.', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        for (final id in _order!)
          if (rows[id] case final r?)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text('${players[r.playerId]?.shirtNumber ?? ''}  ${players[r.playerId]?.fullName ?? '—'}',
                          style: theme.textTheme.titleSmall),
                    ),
                    MinutesStepper(
                      value: durationOf(r),
                      onChanged: (v) {
                        setState(() => _durations[r.id] = v);
                        repo.setDuration(r.id, v);
                      },
                    ),
                  ]),
                  const SizedBox(height: 8),
                  RpeSelector(
                    value: rpeOf(r),
                    onChanged: (v) async {
                      setState(() => _rpes[r.id] = v);
                      // Première saisie : la durée affichée est enregistrée en même temps que le RPE.
                      if (r.durationMin == null) await repo.setDuration(r.id, durationOf(r));
                      await repo.setRpe(r.id, v);
                    },
                  ),
                  if (rpeOf(r) case final rpe?)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('RPE $rpe — ${rpeLabels[rpe]}', style: theme.textTheme.bodySmall),
                    ),
                ]),
              ),
            ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(onPressed: () => _validate(s), child: const Text('Valider la clôture')),
        ),
      ),
    );
  }
}
