import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/permissions.dart';
import '../../core/router.dart';
import '../../core/photos.dart';
import '../../core/widgets/player_card.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../../data/sync.dart';
import '../matches/match_repository.dart';
import '../sessions/session_repository.dart';
import '../tactics/tactic_repository.dart';
import 'team_repository.dart';
import 'team_filter.dart';

/// E07 — Mon équipe (effectif).
class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  String _query = '';
  String? _position;

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(activeTeamProvider);
    return team.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (t) => t != null
          ? _roster(context, t)
          : ref.watch(firstSyncDoneProvider)
              ? const NoTeamScreen()
              : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  Widget _roster(BuildContext context, Team team) {
    final players = ref.watch(playersProvider(team.id)).value ?? const <Player>[];
    final tacticCount = (ref.watch(tacticsProvider(team.id)).value ?? const <Tactic>[]).length;
    final injured = {for (final i in ref.watch(openInjuriesProvider(team.id)).value ?? const <Injury>[]) i.playerId};
    // Statistiques réelles de la saison pour les cartes : minutes jouées, buts, passes décisives.
    final minutes = <String, int>{};
    for (final r in ref.watch(teamMatchPlayersProvider(team.id)).value ?? const <MatchPlayer>[]) {
      if (r.present && r.minutesPlayed != null) minutes[r.playerId] = (minutes[r.playerId] ?? 0) + r.minutesPlayed!;
    }
    final goals = <String, int>{}, assists = <String, int>{};
    for (final e in (ref.watch(teamMatchEventsProvider(team.id)).value ?? const <MatchEvent>[]).where((e) => e.type == 'goal')) {
      goals[e.playerId] = (goals[e.playerId] ?? 0) + 1;
      if (e.assistPlayerId != null) assists[e.assistPlayerId!] = (assists[e.assistPlayerId!] ?? 0) + 1;
    }
    final q = _query.toLowerCase();
    final shown = players
        .where((p) => _position == null || p.position == _position)
        .where((p) => p.fullName.toLowerCase().contains(q))
        .toList();
    return Scaffold(
      appBar: AppBar(
        bottom: teamFilterBar(ref),
        title: Row(children: [
          PhotoAvatar(path: team.logoPath, initials: team.name.substring(0, 1).toUpperCase(), radius: 16),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(team.name),
          Text('${categories[team.category]} · ${team.season}', style: Theme.of(context).textTheme.bodySmall),
        ])),
        ]),
        actions: [
          const SyncIndicator(),
          PopupMenuButton<String>(
            onSelected: (v) => switch (v) {
              'edit' => context.go('/team/edit'),
              'switch' => _switchTeam(context),
              'injuries' => context.go('/team/injuries'),
              'tests' => context.go('/team/tests'),
              'import' => context.go('/team/import'),
              _ => context.go('/team/new'),
            },
            itemBuilder: (_) {
              final perms = ref.read(permsProvider);
              return [
                if (perms.can('equipes.edit')) const PopupMenuItem(value: 'edit', child: Text('Modifier l\'équipe')),
                const PopupMenuItem(value: 'switch', child: Text('Changer d\'équipe')),
                if (perms.can('equipes.add')) const PopupMenuItem(value: 'new', child: Text('Créer une autre équipe')),
                if (perms.can('blessures.view')) const PopupMenuItem(value: 'injuries', child: Text('Infirmerie')),
                if (perms.can('tests.view')) const PopupMenuItem(value: 'tests', child: Text('Tests physiques')),
                if (perms.can('import.use')) const PopupMenuItem(value: 'import', child: Text('Importer un fichier Excel')),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: !ref.watch(permsProvider).can('effectif.add') ? null : FloatingActionButton.extended(
        onPressed: () => context.go('/team/players/new'),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Ajouter un joueur'),
      ),
      body: players.isEmpty
          ? const _EmptyRoster()
          : ListView(padding: const EdgeInsets.only(bottom: 88), children: [
              if (ref.watch(permsProvider).can('tactiques.view'))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/team/tactics'),
                  icon: const Icon(Icons.sports_soccer),
                  label: Text('Tactiques${tacticCount > 0 ? ' ($tacticCount)' : ''}'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher un joueur'),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(children: [
                  for (final e in <String?, String>{null: 'Tous', ...positionPlural}.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e.value),
                        selected: _position == e.key,
                        onSelected: (_) => setState(() => _position = e.key),
                      ),
                    ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text('${shown.length} joueur${shown.length > 1 ? 's' : ''}'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 190, mainAxisExtent: 176, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: shown.length,
                  itemBuilder: (context, i) {
                    final p = shown[i];
                    return PlayerCard(
                      player: p,
                      injured: injured.contains(p.id),
                      stats: [
                        if ((minutes[p.id] ?? 0) > 0) "${minutes[p.id]}′",
                        if ((goals[p.id] ?? 0) > 0) '${goals[p.id]} B',
                        if ((assists[p.id] ?? 0) > 0) '${assists[p.id]} PD',
                      ],
                      onTap: () => context.go('/team/players/${p.id}'),
                      onLongPress: () => _playerActions(context, p),
                    );
                  },
                ),
              ),
            ]),
    );
  }

  /// Appui long sur une carte : modifier ou supprimer le joueur.
  Future<void> _playerActions(BuildContext context, Player p) async {
    final v = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: Text(p.fullName)),
          ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Modifier'),
              onTap: () => Navigator.of(context).pop('edit')),
          ListTile(leading: const Icon(Icons.delete_outline), title: const Text('Supprimer'),
              onTap: () => Navigator.of(context).pop('delete')),
        ]),
      ),
    );
    if (!context.mounted || v == null) return;
    if (v == 'edit') {
      context.go('/team/players/${p.id}/edit');
    } else {
      await confirmDeletePlayer(context, ref, p);
    }
  }

  Future<void> _switchTeam(BuildContext context) async {
    final teams = ref.read(teamsProvider).value ?? const <Team>[];
    final active = ref.read(activeTeamProvider).value;
    final id = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          const ListTile(title: Text('Changer d\'équipe')),
          for (final t in teams)
            ListTile(
              leading: Icon(t.id == active?.id ? Icons.radio_button_checked : Icons.radio_button_off),
              title: Text(t.name),
              subtitle: Text('${categories[t.category]} · ${t.season}'),
              onTap: () => Navigator.of(context).pop(t.id),
            ),
        ]),
      ),
    );
    if (id != null) await ref.read(teamRepositoryProvider).setActiveTeam(id);
  }
}

/// Confirmation de suppression (E08) ; renvoie true si le joueur a été supprimé.
Future<bool> confirmDeletePlayer(BuildContext context, WidgetRef ref, Player p) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Supprimer ${p.fullName} ?'),
      content: const Text('Il n\'apparaîtra plus dans l\'effectif. Ses données passées sont conservées pour les statistiques.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
      ],
    ),
  );
  if (ok != true) return false;
  await ref.read(teamRepositoryProvider).deletePlayer(p.id);
  if (context.mounted) showMessage(context, '${p.fullName} supprimé de l\'effectif');
  return true;
}

class _EmptyRoster extends StatelessWidget {
  const _EmptyRoster();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.groups_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          const Text('Aucun joueur pour l\'instant. Ajoutez votre premier joueur.', textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

/// Pas encore d'équipe : invitation à la créer (première connexion, E06).
class NoTeamScreen extends StatelessWidget {
  const NoTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon équipe'), actions: const [SyncIndicator()]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shield_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Bienvenue ! Commencez par créer l\'équipe que vous suivez.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => context.go('/team/new'), child: const Text('Créer mon équipe')),
          ]),
        ),
      ),
    );
  }
}
