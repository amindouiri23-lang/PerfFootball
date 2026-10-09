import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../team/team_repository.dart';
import 'session_repository.dart';
import 'sessions_list_screen.dart';

/// E14 « Séance en cours » et E19 « Détail d'une séance » : un seul écran qui s'adapte à l'état.
/// Planifiée → démarrer l'appel ; En cours → blessures, remarques, terminer ; Terminée → consultation
/// et corrections (durées, RPE, bien-être).
class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider(id)).value;
    if (s == null || s.deleted) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Séance introuvable.')));
    }
    final theme = Theme.of(context);
    final players = {for (final p in ref.watch(playersProvider(s.teamId)).value ?? const <Player>[]) p.id: p};
    final rows = ref.watch(sessionPlayersProvider(s.id)).value ?? const <SessionPlayer>[];
    final injuries = ref.watch(sessionInjuriesProvider(s.id)).value ?? const <Injury>[];
    final wellness = ref.watch(sessionWellnessProvider(s.id)).value ?? const <WellnessEntry>[];
    final repo = ref.read(sessionRepositoryProvider);

    int byNumber(SessionPlayer a, SessionPlayer b) =>
        (players[a.playerId]?.shirtNumber ?? 999).compareTo(players[b.playerId]?.shirtNumber ?? 999);
    final present = rows.where((r) => r.present).toList()..sort(byNumber);
    final absent = rows.where((r) => !r.present).toList()..sort(byNumber);
    final completed = s.status == 'completed';

    return Scaffold(
      appBar: AppBar(title: const Text('Séance'), actions: [
        const SyncIndicator(),
        PopupMenuButton<String>(
          onSelected: (v) async {
            switch (v) {
              case 'edit':
                context.go('/sessions/${s.id}/edit');
              case 'call':
                context.go('/sessions/${s.id}/attendance');
              case 'close':
                context.go('/sessions/${s.id}/close');
              case 'wellness':
                context.go('/sessions/${s.id}/wellness');
              case 'delete':
                if (await confirmDeleteSession(context, ref, s) && context.mounted) context.go('/sessions');
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier les informations')),
            if (s.status != 'planned') ...[
              const PopupMenuItem(value: 'call', child: Text('Modifier l\'appel')),
              if (completed) const PopupMenuItem(value: 'close', child: Text('Modifier les durées et RPE')),
              const PopupMenuItem(value: 'wellness', child: Text('Bien-être')),
            ],
            const PopupMenuItem(value: 'delete', child: Text('Supprimer la séance')),
          ],
        ),
      ]),
      body: ListView(padding: const EdgeInsets.only(bottom: 96), children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text('${sessionTypes[s.type]} · ${s.dayLabel} · ${s.time}', style: theme.textTheme.titleMedium),
                ),
                StatusChip(s.status),
              ]),
              const SizedBox(height: 4),
              Text([
                '${s.plannedDurationMin} min prévues',
                if (rows.isNotEmpty) '${present.length} présents · ${absent.length} absents',
                if (completed) 'Bien-être ${wellness.length}/${present.length}',
              ].join(' · ')),
              if (s.objective != null) Text('Objectif : ${s.objective}'),
              const Divider(height: 24),
              InkWell(
                onTap: () async {
                  final text = await showRemarkSheet(context, 'Remarque sur la séance', s.remarks);
                  if (text != null) await repo.setRemarks(s.id, text.isEmpty ? null : text);
                },
                child: Row(children: [
                  const Icon(Icons.edit_note),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s.remarks ?? 'Ajouter une remarque sur la séance',
                        style: s.remarks == null ? TextStyle(color: theme.colorScheme.onSurfaceVariant) : null),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        if (s.status == 'planned')
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('La séance n\'a pas encore commencé : faites l\'appel pour enregistrer les présents.'),
          )
        else ...[
          _SectionTitle('Présents (${present.length})'),
          for (final r in present)
            _PlayerRow(
              session: s,
              row: r,
              player: players[r.playerId],
              injury: injuries.where((i) => i.playerId == r.playerId).firstOrNull,
            ),
          if (absent.isNotEmpty)
            ExpansionTile(
              title: Text('Absents (${absent.length})'),
              children: [
                for (final r in absent)
                  ListTile(
                    dense: true,
                    title: Text(players[r.playerId]?.fullName ?? '—'),
                    trailing: Text(absenceReasons[r.absenceReason] ?? 'Sans motif'),
                  ),
              ],
            ),
        ],
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (s.status) {
            'planned' => FilledButton(
                onPressed: () => context.go('/sessions/${s.id}/attendance'), child: const Text('Démarrer l\'appel')),
            'in_progress' => FilledButton(
                onPressed: () => context.go('/sessions/${s.id}/close'), child: const Text('Terminer la séance')),
            _ => OutlinedButton.icon(
                onPressed: () => context.go('/sessions/${s.id}/wellness'),
                icon: const Icon(Icons.favorite_border),
                label: Text('Bien-être (${wellness.length}/${present.length})'),
              ),
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}

class _PlayerRow extends ConsumerWidget {
  const _PlayerRow({required this.session, required this.row, required this.player, required this.injury});

  final TrainingSession session;
  final SessionPlayer row;
  final Player? player;
  final Injury? injury;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final details = [
      if (injury != null) 'Blessure : ${bodyAreas[injury!.bodyArea]}${injury!.side != null ? ' ${injurySides[injury!.side]!.toLowerCase()}' : ''} · ${severities[injury!.severity]!.split(' ').first}',
      if (session.status == 'completed') '${row.durationMin ?? '—'} min · RPE ${row.rpe ?? '—'}',
      if (row.remark != null) 'Remarque : ${row.remark}',
    ];
    return ListTile(
      title: Text('${player?.shirtNumber ?? ''}  ${player?.fullName ?? '—'}'),
      subtitle: details.isEmpty ? null : Text(details.join('\n'), style: injury != null ? TextStyle(color: theme.colorScheme.onSurface) : null),
      isThreeLine: details.length > 1,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          tooltip: 'Déclarer une blessure',
          icon: Icon(Icons.healing, color: injury != null ? theme.colorScheme.error : null),
          onPressed: () => context.go('/sessions/${session.id}/injury/${row.playerId}'),
        ),
        IconButton(
          tooltip: 'Remarque sur le joueur',
          icon: Icon(row.remark != null ? Icons.edit_note : Icons.edit_outlined),
          onPressed: () async {
            final text = await showRemarkSheet(context, 'Remarque — ${player?.fullName ?? ''}', row.remark);
            if (text != null) await ref.read(sessionRepositoryProvider).setPlayerRemark(row.id, text.isEmpty ? null : text);
          },
        ),
      ]),
    );
  }
}

/// E16 — Remarque libre dans un panneau par-dessus l'écran. Renvoie le texte (vide pour effacer),
/// ou null si annulé. La dictée vocale est celle du clavier du téléphone.
Future<String?> showRemarkSheet(BuildContext context, String title, String? initial) {
  final controller = TextEditingController(text: initial);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(controller: controller, autofocus: true, maxLines: 4, maxLength: 1000,
            textCapitalization: TextCapitalization.sentences),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler'))),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Enregistrer'),
            ),
          ),
        ]),
      ]),
    ),
  );
}
