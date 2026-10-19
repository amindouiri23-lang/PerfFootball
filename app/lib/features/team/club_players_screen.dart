import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/permissions.dart';
import '../../core/router.dart';
import '../../data/database.dart';
import '../../data/sync.dart';
import '../sessions/session_repository.dart' show pairId;
import 'team_repository.dart';
import 'team_screen.dart' show NoTeamScreen;

/// Joueurs des autres équipes du même club (celles que le compte voit), par équipe.
final _clubPlayersProvider = StreamProvider.family<List<Player>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.players)..where((p) => p.teamId.equals(teamId) & p.deleted.equals(false))).watch();
});

/// Ajouter à l'équipe active des joueurs d'une autre équipe du club (surclassement, renfort…).
/// Le joueur reste dans son équipe d'origine : une fiche est créée dans cette équipe, avec son dossier
/// (et son dossier médical si le rôle le permet). Ses statistiques sont suivies équipe par équipe.
class ClubPlayersScreen extends ConsumerStatefulWidget {
  const ClubPlayersScreen({super.key});

  @override
  ConsumerState<ClubPlayersScreen> createState() => _ClubPlayersScreenState();
}

class _ClubPlayersScreenState extends ConsumerState<ClubPlayersScreen> {
  String? _from;
  final Set<String> _selected = {};
  bool _busy = false;

  Future<void> _add(Team target, List<Player> chosen) async {
    setState(() => _busy = true);
    final db = ref.read(databaseProvider);
    final copyMedical = ref.read(permsProvider).can('medical.edit');
    final now = nowIso();
    await db.transaction(() async {
      for (final p in chosen) {
        // Même joueur ajouté deux fois à la même équipe : même fiche (id déterministe).
        final id = pairId(p.id, target.id);
        await db.into(db.players).insertOnConflictUpdate(p.copyWith(
              id: id, teamId: target.id, createdAt: now, updatedAt: now, serverUpdatedAt: const Value(null),
              deleted: false, isDirty: true, shirtNumber: const Value(null),
            ));
        final profile = await (db.select(db.playerProfiles)..where((x) => x.id.equals(p.id))).getSingleOrNull();
        if (profile != null && !profile.deleted) {
          await db.into(db.playerProfiles).insertOnConflictUpdate(profile.copyWith(
                id: id, playerId: id, teamId: target.id, createdAt: now, updatedAt: now,
                serverUpdatedAt: const Value(null), isDirty: true,
              ));
        }
        final medical = copyMedical ? await (db.select(db.playerMedical)..where((x) => x.id.equals(p.id))).getSingleOrNull() : null;
        if (medical != null && !medical.deleted) {
          await db.into(db.playerMedical).insertOnConflictUpdate(medical.copyWith(
                id: id, playerId: id, teamId: target.id, createdAt: now, updatedAt: now,
                serverUpdatedAt: const Value(null), isDirty: true,
              ));
        }
      }
    });
    ref.read(syncControllerProvider.notifier).requestSync();
    if (!mounted) return;
    showMessage(context, '${chosen.length} joueur${chosen.length > 1 ? 's' : ''} ajouté${chosen.length > 1 ? 's' : ''} à ${target.name}');
    context.go('/team');
  }

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(activeTeamProvider).value;
    if (target == null) return const NoTeamScreen();
    final teams = (ref.watch(teamsProvider).value ?? const <Team>[])
        .where((t) => t.id != target.id && t.clubName != null && t.clubName!.trim().toLowerCase() == target.clubName?.trim().toLowerCase())
        .toList();
    final theme = Theme.of(context);
    final from = teams.where((t) => t.id == _from).firstOrNull ?? teams.firstOrNull;
    final mine = {for (final p in ref.watch(playersProvider(target.id)).value ?? const <Player>[]) p.id};
    final candidates = from == null ? const <Player>[] : ref.watch(_clubPlayersProvider(from.id)).value ?? const <Player>[];
    final chosen = candidates.where((p) => _selected.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Ajouter à ${target.name}')),
      body: teams.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  target.clubName == null
                      ? 'Cette équipe n\'a pas de club : indiquez-le dans « Modifier l\'équipe ».'
                      : 'Aucune autre équipe de ${target.clubName} n\'est accessible à votre compte.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(padding: const EdgeInsets.only(bottom: 96), children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text('Équipe d\'origine (${target.clubName})', style: theme.textTheme.titleSmall),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(children: [
                  for (final t in teams)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(t.name),
                        selected: t.id == from?.id,
                        onSelected: (_) => setState(() {
                          _from = t.id;
                          _selected.clear();
                        }),
                      ),
                    ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text('Le joueur reste dans son équipe d\'origine : une fiche est créée dans cette équipe, avec son dossier.'),
              ),
              for (final p in candidates)
                Builder(builder: (context) {
                  final already = mine.contains(pairId(p.id, target.id));
                  return CheckboxListTile(
                    value: already || _selected.contains(p.id),
                    title: Text(p.fullName),
                    subtitle: Text([positions[p.position], if (already) 'déjà dans ${target.name}'].whereType<String>().join(' · ')),
                    onChanged: already ? null : (v) => setState(() => v == true ? _selected.add(p.id) : _selected.remove(p.id)),
                  );
                }),
            ]),
      bottomNavigationBar: teams.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: chosen.isEmpty || _busy ? null : () => _add(target, chosen),
                  child: Text(chosen.isEmpty ? 'Cochez les joueurs à ajouter' : 'Ajouter ${chosen.length} joueur${chosen.length > 1 ? 's' : ''}'),
                ),
              ),
            ),
    );
  }
}
