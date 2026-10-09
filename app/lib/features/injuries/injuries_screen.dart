import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/photos.dart';
import '../../core/router.dart';
import '../../data/database.dart';
import '../sessions/session_repository.dart';
import '../team/team_repository.dart';
import '../team/team_screen.dart';

/// E27 — Infirmerie : blessures en cours (avec retour du joueur), puis historique.
class InjuriesScreen extends ConsumerWidget {
  const InjuriesScreen({super.key});

  Future<void> _return(BuildContext context, WidgetRef ref, Injury i, Player? p) async {
    final start = DateTime.parse(i.date);
    final today = DateTime.now();
    final d = await showDatePicker(
      context: context,
      helpText: 'Date de retour de ${p?.fullName ?? 'ce joueur'}',
      initialDate: today.isBefore(start) ? start : today,
      firstDate: start,
      lastDate: today.isBefore(start) ? start : today,
    );
    if (d == null) return;
    await ref.read(sessionRepositoryProvider).setReturnDate(i.id, isoDate(d));
    if (context.mounted) showMessage(context, '${p?.fullName ?? 'Joueur'} de retour');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const NoTeamScreen();
    final players = {for (final p in ref.watch(playersProvider(team.id)).value ?? const <Player>[]) p.id: p};
    final all = ref.watch(teamInjuriesProvider(team.id)).value ?? const <Injury>[];
    // Joueurs supprimés exclus : ils ne sont plus suivis.
    final injuries = all.where((i) => players.containsKey(i.playerId)).toList();
    final open = injuries.where((i) => i.returnDate == null).toList();
    final closed = injuries.where((i) => i.returnDate != null).toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Infirmerie')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/team/injuries/new'),
        icon: const Icon(Icons.healing),
        label: const Text('Blessure'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 88), children: [
        Text('Blessures en cours (${open.length})', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (open.isEmpty) const Text('Aucun joueur blessé.'),
        for (final i in open) _OpenCard(injury: i, player: players[i.playerId], onReturn: () => _return(context, ref, i, players[i.playerId])),
        if (closed.isNotEmpty)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Historique (${closed.length})'),
            children: [
              for (final i in closed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${players[i.playerId]?.fullName ?? '—'} · ${injuryLabel(i)}'),
                  subtitle: Text('${_d(i.date)} → ${_d(i.returnDate!)} · '
                      '${DateTime.parse(i.returnDate!).difference(DateTime.parse(i.date)).inDays} j'),
                  onTap: () => context.go('/team/players/${i.playerId}'),
                ),
            ],
          ),
      ]),
    );
  }

  static String _d(String date) => DateFormat('d MMM', 'fr_FR').format(DateTime.parse(date));
}

class _OpenCard extends StatelessWidget {
  const _OpenCard({required this.injury, required this.player, required this.onReturn});

  final Injury injury;
  final Player? player;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    final days = DateTime.now().difference(DateTime.parse(injury.date)).inDays;
    final (bg, fg) = switch (injury.severity) {
      'severe' => (c.errorContainer, c.onErrorContainer),
      'moderate' => (c.tertiaryContainer, c.onTertiaryContainer),
      _ => (c.surfaceContainerHighest, c.onSurfaceVariant),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            PhotoAvatar(path: player?.photoPath, initials: player?.initials ?? '?'),
            const SizedBox(width: 12),
            Expanded(child: Text('${player?.shirtNumber ?? ''} ${player?.fullName ?? '—'}', style: theme.textTheme.titleMedium)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Text(severities[injury.severity]!.split(' ').first,
                  style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Text('${injuryLabel(injury)} · ${injuryTypes[injury.type]} · ${mechanisms[injury.mechanism]}'),
          Text([
            'Depuis le ${DateFormat('d MMM', 'fr_FR').format(DateTime.parse(injury.date))} ($days j)',
            if (injury.minute != null) "${injury.minute}'",
            if (injury.expectedReturnDate != null)
              'retour prévu le ${DateFormat('d MMM', 'fr_FR').format(DateTime.parse(injury.expectedReturnDate!))}',
          ].join(' · '), style: theme.textTheme.bodySmall),
          if (injury.description != null) Text(injury.description!, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(onPressed: onReturn, icon: const Icon(Icons.check), label: const Text('Retour du joueur')),
          ),
        ]),
      ),
    );
  }
}
