import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/theme.dart';
import '../../core/widgets/steppers.dart';
import '../../data/database.dart';
import '../../data/sync.dart';
import '../sessions/session_repository.dart';
import '../team/team_repository.dart';

/// Questionnaires de bien-être du joueur (le serveur ne lui envoie que les siens).
final _myWellnessProvider = StreamProvider.family<List<WellnessEntry>, String>((ref, playerId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellness)..where((w) => w.playerId.equals(playerId) & w.deleted.equals(false))).watch();
});

/// Accueil d'un compte joueur : son dossier, son RPE et son questionnaire de bien-être après chaque séance.
class PlayerSpace extends ConsumerWidget {
  const PlayerSpace({super.key, required this.playerId});

  final String? playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = playerId;
    if (id == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Votre compte n\'est relié à aucun joueur. Demandez à l\'administrateur.', textAlign: TextAlign.center),
        ),
      );
    }
    final player = ref.watch(playerProvider(id)).value;
    if (player == null) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Chargement de votre fiche…')));
    }
    final theme = Theme.of(context);
    final sessions = {for (final s in ref.watch(sessionsProvider(player.teamId)).value ?? const <TrainingSession>[]) s.id: s};
    // Mes lignes de séance : séances commencées ou terminées où j'étais présent, la plus récente d'abord.
    final rows = (ref.watch(teamSessionPlayersProvider(player.teamId)).value ?? const <SessionPlayer>[])
        .where((r) => r.playerId == id && r.present && sessions[r.sessionId] != null && sessions[r.sessionId]!.status != 'planned')
        .toList()
      ..sort((a, b) => '${sessions[b.sessionId]!.date}${sessions[b.sessionId]!.startTime}'
          .compareTo('${sessions[a.sessionId]!.date}${sessions[a.sessionId]!.startTime}'));
    final answered = {for (final w in ref.watch(_myWellnessProvider(id)).value ?? const <WellnessEntry>[]) w.sessionId};

    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(player.fullName.toUpperCase(), style: gameTitle(context, size: 28)),
      Text('Votre espace joueur', style: theme.textTheme.bodyMedium),
      const SizedBox(height: 16),
      Card(
        child: ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: const Text('Mon dossier'),
          subtitle: const Text('Coordonnées, école, parents, club précédent'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/home/dossier/$id'),
        ),
      ),
      const SizedBox(height: 16),
      Text('MES SÉANCES', style: sectionLabel(context)),
      const SizedBox(height: 8),
      if (rows.isEmpty) const Text('Aucune séance pour l\'instant. Elles apparaissent ici après l\'appel du staff.'),
      for (final r in rows.take(15))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('${sessions[r.sessionId]!.dayLabel} · ${sessionTypes[sessions[r.sessionId]!.type]}', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(r.rpe == null ? Icons.speed : Icons.check),
                    label: Text(r.rpe == null ? 'Donner mon RPE' : 'RPE ${r.rpe}'),
                    onPressed: () => _askRpe(context, ref, r),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: answered.contains(r.sessionId)
                      ? OutlinedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Bien-être'),
                          onPressed: () => context.go('/home/wellness/${r.sessionId}/$id'),
                        )
                      : FilledButton.icon(
                          icon: const Icon(Icons.favorite_border),
                          label: const Text('Bien-être'),
                          onPressed: () => context.go('/home/wellness/${r.sessionId}/$id'),
                        ),
                ),
              ]),
            ]),
          ),
        ),
    ]);
  }

  Future<void> _askRpe(BuildContext context, WidgetRef ref, SessionPlayer row) async {
    int? value = row.rpe;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Effort ressenti pendant la séance (RPE)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              const Text('1 = très facile · 10 = effort maximal'),
              const SizedBox(height: 12),
              RpeSelector(value: value, onChanged: (v) => setState(() => value = v)),
              const SizedBox(height: 16),
              FilledButton(onPressed: value == null ? null : () => Navigator.of(context).pop(true), child: const Text('Enregistrer')),
            ]),
          ),
        ),
      ),
    );
    if (ok != true) return;
    await ref.read(sessionRepositoryProvider).setRpe(row.id, value);
    if (context.mounted) showMessage(context, 'RPE enregistré, merci !');
  }
}
