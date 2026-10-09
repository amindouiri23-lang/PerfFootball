import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/widgets/injured_badge.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../../data/sync.dart';
import '../sessions/session_repository.dart';
import 'team_repository.dart';

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
    final players = ref.watch(playersProvider(team.id)).value ?? const [];
    final injured = {for (final i in ref.watch(openInjuriesProvider(team.id)).value ?? const <Injury>[]) i.playerId};
    final q = _query.toLowerCase();
    final shown = players
        .where((p) => _position == null || p.position == _position)
        .where((p) => p.fullName.toLowerCase().contains(q))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(team.name),
          Text('${categories[team.category]} · ${team.season}', style: Theme.of(context).textTheme.bodySmall),
        ]),
        actions: [
          const SyncIndicator(),
          PopupMenuButton<String>(
            onSelected: (v) => switch (v) {
              'edit' => context.go('/team/edit'),
              'switch' => _switchTeam(context),
              _ => context.go('/team/new'),
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Modifier l\'équipe')),
              PopupMenuItem(value: 'switch', child: Text('Changer d\'équipe')),
              PopupMenuItem(value: 'new', child: Text('Créer une autre équipe')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/team/players/new'),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Ajouter un joueur'),
      ),
      body: players.isEmpty
          ? const _EmptyRoster()
          : ListView(padding: const EdgeInsets.only(bottom: 88), children: [
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
              for (final p in shown) _PlayerTile(p, injured: injured.contains(p.id)),
            ]),
    );
  }

  Future<void> _switchTeam(BuildContext context) async {
    final teams = ref.read(teamsProvider).value ?? const [];
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

class _PlayerTile extends ConsumerWidget {
  const _PlayerTile(this.p, {required this.injured});

  final Player p;
  final bool injured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(child: Text(p.initials)),
      title: Text('${p.shirtNumber != null ? '${p.shirtNumber}  ' : ''}${p.fullName}'),
      subtitle: Text(positions[p.position]!),
      onTap: () => context.go('/team/players/${p.id}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (injured) const InjuredBadge(),
        PopupMenuButton<String>(
          tooltip: 'Actions',
          onSelected: (v) => v == 'edit'
              ? context.go('/team/players/${p.id}/edit')
              : confirmDeletePlayer(context, ref, p),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Modifier')),
            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ]),
    );
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
