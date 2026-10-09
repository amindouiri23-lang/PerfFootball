import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../sessions/session_repository.dart' show bodyAreas, injurySides;
import '../sessions/session_screen.dart' show showRemarkSheet;
import '../sessions/sessions_list_screen.dart' show StatusChip;
import '../team/team_repository.dart';
import 'match_repository.dart';
import 'matches_list_screen.dart';

/// E23 « Match en cours » et E26 « Détail d'un match » : un seul écran qui s'adapte à l'état.
class MatchScreen extends ConsumerWidget {
  const MatchScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(matchProvider(id)).value;
    if (m == null || m.deleted) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Match introuvable.')));
    final team = ref.watch(activeTeamProvider).value;
    final players = {for (final p in ref.watch(playersProvider(m.teamId)).value ?? const <Player>[]) p.id: p};
    final rows = ref.watch(matchPlayersProvider(m.id)).value ?? const <MatchPlayer>[];
    final events = ref.watch(matchEventsProvider(m.id)).value ?? const <MatchEvent>[];
    final injuries = ref.watch(matchInjuriesProvider(m.id)).value ?? const <Injury>[];
    final repo = ref.read(matchRepositoryProvider);
    final theme = Theme.of(context);
    final completed = m.status == 'completed';
    final goalsFor = completed ? (m.goalsFor ?? 0) : events.where((e) => e.type == 'goal').length;
    final goalsAgainst = m.goalsAgainst ?? 0;
    final present = squadOrder(rows.where((r) => r.present).toList(), players);
    String name(String? id) => players[id]?.fullName ?? '—';

    // Chronologie : événements et blessures, par minute.
    final timeline = <({int minute, Widget tile})>[
      for (final e in events)
        (
          minute: e.minute,
          tile: ListTile(
            dense: true,
            leading: SizedBox(width: 36, child: Text("${e.minute}'", style: const TextStyle(fontWeight: FontWeight.bold))),
            title: Row(children: [
              Icon(eventIcons[e.type], color: eventColors[e.type], size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(name(e.playerId))),
            ]),
            subtitle: Text([
              eventTypes[e.type]!,
              if (e.assistPlayerId != null) 'passe de ${name(e.assistPlayerId)}',
              if (e.remark != null) e.remark!,
            ].join(' · ')),
            onTap: () => showEventSheet(context, ref, m, present, players, event: e),
          ),
        ),
      for (final i in injuries)
        (
          minute: i.minute ?? 999,
          tile: ListTile(
            dense: true,
            leading: SizedBox(width: 36, child: Text(i.minute == null ? '—' : "${i.minute}'", style: const TextStyle(fontWeight: FontWeight.bold))),
            title: Row(children: [
              Icon(Icons.healing, color: theme.colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(name(i.playerId))),
            ]),
            subtitle: Text('Blessure · ${bodyAreas[i.bodyArea]}${i.side != null ? ' ${injurySides[i.side]!.toLowerCase()}' : ''}'),
          ),
        ),
    ]..sort((a, b) => a.minute.compareTo(b.minute));

    return Scaffold(
      appBar: AppBar(title: const Text('Match'), actions: [
        const SyncIndicator(),
        PopupMenuButton<String>(
          onSelected: (v) async {
            switch (v) {
              case 'edit':
                context.go('/matches/${m.id}/edit');
              case 'squad':
                context.go('/matches/${m.id}/squad');
              case 'end':
                context.go('/matches/${m.id}/end');
              case 'delete':
                if (await confirmDeleteMatch(context, ref, m) && context.mounted) context.go('/matches');
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier les informations')),
            if (m.status != 'planned') const PopupMenuItem(value: 'squad', child: Text('Modifier la feuille de match')),
            if (completed) const PopupMenuItem(value: 'end', child: Text('Modifier temps de jeu et RPE')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer le match')),
          ],
        ),
      ]),
      body: ListView(padding: const EdgeInsets.only(bottom: 96), children: [
        Card(
          margin: const EdgeInsets.all(16),
          color: theme.colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                Expanded(child: Text(team?.name ?? '', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onPrimary))),
                Text('$goalsFor - $goalsAgainst',
                    style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                Expanded(child: Text(m.opponent, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onPrimary))),
              ]),
              if (m.status == 'in_progress')
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('Buts adverses', style: TextStyle(color: theme.colorScheme.onPrimary)),
                  IconButton(
                    tooltip: 'Moins un but adverse',
                    color: theme.colorScheme.onPrimary,
                    onPressed: goalsAgainst > 0 ? () => repo.setGoalsAgainst(m.id, goalsAgainst - 1) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  IconButton(
                    tooltip: 'Plus un but adverse',
                    color: theme.colorScheme.onPrimary,
                    onPressed: () => repo.setGoalsAgainst(m.id, goalsAgainst + 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ]),
              const SizedBox(height: 4),
              Text('${m.dayLabel} · ${m.time} · ${homeAwayLabels[m.homeAway]} · ${competitions[m.competition]}',
                  style: TextStyle(color: theme.colorScheme.onPrimary)),
              const SizedBox(height: 8),
              StatusChip(m.status, labels: matchStatuses),
            ]),
          ),
        ),
        if (m.status == 'planned')
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Le match n\'a pas encore commencé : choisissez les joueurs présents et les titulaires.'),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              for (final t in ['goal', 'yellow_card', 'red_card'])
                _QuickAction(
                  icon: eventIcons[t]!,
                  color: eventColors[t]!,
                  label: switch (t) { 'goal' => 'But', 'yellow_card' => 'Jaune', _ => 'Rouge' },
                  onPressed: () => showEventSheet(context, ref, m, present, players, type: t),
                ),
              _QuickAction(
                icon: Icons.healing,
                color: theme.colorScheme.error,
                label: 'Blessure',
                onPressed: () async {
                  final playerId = await pickPlayer(context, 'Joueur blessé', present, players);
                  if (playerId != null && context.mounted) context.go('/matches/${m.id}/injury/$playerId');
                },
              ),
            ]),
          ),
          _title(context, 'Chronologie'),
          if (timeline.isEmpty) const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Aucun événement.')),
          for (final t in timeline) t.tile,
          _title(context, 'Joueurs'),
          for (final r in present)
            _PlayerRow(m: m, row: r, player: players[r.playerId], events: events, injured: injuries.any((i) => i.playerId == r.playerId)),
        ],
        _title(context, 'Remarques sur le match'),
        ListTile(
          leading: const Icon(Icons.edit_note),
          title: Text(m.remarks ?? 'Ajouter une remarque',
              style: m.remarks == null ? TextStyle(color: theme.colorScheme.onSurfaceVariant) : null),
          onTap: () async {
            final text = await showRemarkSheet(context, 'Remarque sur le match', m.remarks);
            if (text != null) await repo.setRemarks(m.id, text.isEmpty ? null : text);
          },
        ),
      ]),
      bottomNavigationBar: m.status == 'completed'
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: m.status == 'planned'
                    ? FilledButton(onPressed: () => context.go('/matches/${m.id}/squad'), child: const Text('Choisir les joueurs présents'))
                    : FilledButton(onPressed: () => context.go('/matches/${m.id}/end'), child: const Text('Fin du match')),
              ),
            ),
    );
  }

  Widget _title(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}

/// Bouton d'ajout rapide : icône au-dessus du libellé, pour tenir à quatre sur un téléphone.
class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.color, required this.label, required this.onPressed});

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onPressed,
            child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color), Text(label)]),
          ),
        ),
      );
}

/// Titulaires puis remplaçants, par numéro.
List<MatchPlayer> squadOrder(List<MatchPlayer> rows, Map<String, Player> players) => rows
  ..sort((a, b) {
    final byRole = (a.role == 'starter' ? 0 : 1).compareTo(b.role == 'starter' ? 0 : 1);
    return byRole != 0 ? byRole : (players[a.playerId]?.shirtNumber ?? 999).compareTo(players[b.playerId]?.shirtNumber ?? 999);
  });

class _PlayerRow extends ConsumerWidget {
  const _PlayerRow({required this.m, required this.row, required this.player, required this.events, required this.injured});

  final FootballMatch m;
  final MatchPlayer row;
  final Player? player;
  final List<MatchEvent> events;
  final bool injured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = events.where((e) => e.type == 'goal' && e.playerId == row.playerId).length;
    final assists = events.where((e) => e.assistPlayerId == row.playerId).length;
    final yellows = events.where((e) => e.type == 'yellow_card' && e.playerId == row.playerId).length;
    final reds = events.where((e) => e.type == 'red_card' && e.playerId == row.playerId).length;
    final details = [
      matchRoles[row.role] ?? '',
      if (goals > 0) '$goals but${goals > 1 ? 's' : ''}',
      if (assists > 0) '$assists passe${assists > 1 ? 's' : ''} déc.',
      if (yellows > 0) '$yellows jaune${yellows > 1 ? 's' : ''}',
      if (reds > 0) 'rouge',
      if (injured) 'blessé',
      if (m.status == 'completed') "${row.minutesPlayed ?? '—'}' · RPE ${row.rpe ?? '—'}",
      if (row.remark != null) 'Remarque : ${row.remark}',
    ];
    return ListTile(
      title: Text('${player?.shirtNumber ?? ''}  ${player?.fullName ?? '—'}'),
      subtitle: Text(details.join(' · ')),
      trailing: IconButton(
        tooltip: 'Remarque sur le joueur',
        icon: Icon(row.remark != null ? Icons.edit_note : Icons.edit_outlined),
        onPressed: () async {
          final text = await showRemarkSheet(context, 'Remarque — ${player?.fullName ?? ''}', row.remark);
          if (text != null) await ref.read(matchRepositoryProvider).setPlayerRemark(row.id, text.isEmpty ? null : text);
        },
      ),
    );
  }
}

/// Choix d'un joueur présent dans une grille (blessure de match).
Future<String?> pickPlayer(BuildContext context, String title, List<MatchPlayer> present, Map<String, Player> players) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in present)
              ActionChip(
                label: Text('${players[r.playerId]?.shirtNumber ?? ''} ${players[r.playerId]?.lastName ?? ''}'),
                onPressed: () => Navigator.of(context).pop(r.playerId),
              ),
          ]),
        ]),
      ),
    ),
  );
}

/// E24 — Ajouter ou modifier un but / carton, dans un panneau par-dessus le match.
Future<void> showEventSheet(BuildContext context, WidgetRef ref, FootballMatch m, List<MatchPlayer> present,
    Map<String, Player> players, {String? type, MatchEvent? event}) async {
  final repo = ref.read(matchRepositoryProvider);
  var kind = event?.type ?? type ?? 'goal';
  final minute = TextEditingController(text: event?.minute.toString() ?? '');
  final remark = TextEditingController(text: event?.remark ?? '');
  String? scorer = event?.playerId;
  String? assist = event?.assistPlayerId;
  var submitted = false;
  var saving = false; // un double appui ne doit pas créer deux événements
  String label(String id) => '${players[id]?.shirtNumber ?? ''} ${players[id]?.lastName ?? ''}';

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(builder: (context, setState) {
      final theme = Theme.of(context);
      final min = int.tryParse(minute.text);
      final minuteOk = min != null && min >= 1 && min <= 130;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(event == null ? 'Ajouter un événement' : 'Modifier l\'événement', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              for (final e in eventTypes.entries)
                ChoiceChip(label: Text(e.value), selected: kind == e.key, onSelected: (_) => setState(() => kind = e.key)),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: minute,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: event == null,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: 'Minute *', errorText: submitted && !minuteOk ? 'Entre 1 et 130' : null),
            ),
            const SizedBox(height: 12),
            Text(kind == 'goal' ? 'Buteur *' : 'Joueur *', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final r in present)
                ChoiceChip(
                  label: Text(label(r.playerId)),
                  selected: scorer == r.playerId,
                  onSelected: (_) => setState(() {
                    scorer = r.playerId;
                    if (assist == scorer) assist = null;
                  }),
                ),
            ]),
            if (submitted && scorer == null)
              Text('Obligatoire', style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
            if (kind == 'goal') ...[
              const SizedBox(height: 12),
              Text('Passeur décisif', style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: [
                ChoiceChip(label: const Text('Aucun'), selected: assist == null, onSelected: (_) => setState(() => assist = null)),
                for (final r in present.where((r) => r.playerId != scorer))
                  ChoiceChip(
                    label: Text(label(r.playerId)),
                    selected: assist == r.playerId,
                    onSelected: (_) => setState(() => assist = r.playerId),
                  ),
              ]),
            ],
            const SizedBox(height: 12),
            TextField(controller: remark, maxLength: 200, decoration: const InputDecoration(labelText: 'Remarque', hintText: 'Ex. Penalty, coup franc')),
            Row(children: [
              if (event != null)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                    onPressed: () async {
                      await repo.deleteEvent(event.id);
                      if (context.mounted) Navigator.of(context).pop(false);
                    },
                    child: const Text('Supprimer'),
                  ),
                ),
              if (event != null) const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    setState(() => submitted = true);
                    if (!minuteOk || scorer == null || saving) return;
                    saving = true;
                    final text = remark.text.trim();
                    await repo.saveEvent(
                      id: event?.id, m: m, type: kind, minute: min, playerId: scorer!,
                      assistPlayerId: assist, remark: text.isEmpty ? null : text,
                    );
                    if (context.mounted) Navigator.of(context).pop(true);
                  },
                  child: const Text('Enregistrer'),
                ),
              ),
            ]),
          ]),
        ),
      );
    }),
  );

  // Deuxième carton jaune : proposer le carton rouge à la même minute.
  if (saved == true && kind == 'yellow_card' && scorer != null && context.mounted) {
    final events = await repo.eventsOf(m.id); // lecture directe : inclut le carton qui vient d'être enregistré
    final yellows = events.where((e) => e.type == 'yellow_card' && e.playerId == scorer).length;
    final hasRed = events.any((e) => e.type == 'red_card' && e.playerId == scorer);
    if (yellows >= 2 && !hasRed && context.mounted) {
      final red = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Deuxième carton jaune'),
          content: Text('Ajouter le carton rouge pour ${players[scorer]?.fullName ?? 'ce joueur'} ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Non')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ajouter le rouge')),
          ],
        ),
      );
      if (red == true) {
        await repo.saveEvent(m: m, type: 'red_card', minute: int.parse(minute.text), playerId: scorer!);
        if (context.mounted) showMessage(context, 'Carton rouge ajouté');
      }
    }
  }
}
