import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../team/team_repository.dart' show categories;
import 'admin_repository.dart';

/// E30 / E29 — Choix des équipes d'un compte, regroupées par club. Cocher un club coche toutes ses
/// équipes (celles qui existent aujourd'hui). Les équipes dont le compte est propriétaire restent cochées.
class TeamPicker extends ConsumerWidget {
  const TeamPicker({super.key, required this.selected, required this.onChanged, this.ownedIds = const {}});

  final Set<String> selected;
  final Set<String> ownedIds;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(adminTeamsProvider);
    return teams.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Column(children: [
        Text(e is AppException ? e.message : networkErrorMessage),
        TextButton(onPressed: () => ref.invalidate(adminTeamsProvider), child: const Text('Réessayer')),
      ]),
      data: (list) {
        if (list.isEmpty) return const Text('Aucune équipe pour l\'instant.');
        final clubs = <String, List<AdminTeam>>{};
        for (final t in list) {
          clubs.putIfAbsent(t.clubName ?? 'Sans club', () => []).add(t);
        }
        final names = clubs.keys.toList()..sort((a, b) => a == 'Sans club' ? 1 : b == 'Sans club' ? -1 : a.compareTo(b));
        bool on(AdminTeam t) => ownedIds.contains(t.id) || selected.contains(t.id);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final club in names) ...[
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              tristate: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(club, style: Theme.of(context).textTheme.titleSmall),
              subtitle: Text('Tout le club (${clubs[club]!.length} équipe${clubs[club]!.length > 1 ? 's' : ''})'),
              value: clubs[club]!.every(on) ? true : clubs[club]!.any(on) ? null : false,
              onChanged: (_) {
                final ids = clubs[club]!.where((t) => !ownedIds.contains(t.id)).map((t) => t.id);
                final all = clubs[club]!.every(on);
                onChanged(all ? ({...selected}..removeAll(ids)) : {...selected, ...ids});
              },
            ),
            for (final t in clubs[club]!)
              CheckboxListTile(
                contentPadding: const EdgeInsets.only(left: 32),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Text(t.name),
                subtitle: Text([
                  categories[t.category] ?? t.category,
                  t.season,
                  if (ownedIds.contains(t.id)) 'propriétaire',
                ].join(' · ')),
                value: on(t),
                onChanged: ownedIds.contains(t.id)
                    ? null
                    : (v) => onChanged(v == true ? {...selected, t.id} : ({...selected}..remove(t.id))),
              ),
          ],
        ]);
      },
    );
  }
}

/// E29 — « Équipes » d'un compte existant : modifie ses accès (rôle staff).
Future<void> showAccountTeams(BuildContext context, WidgetRef ref, StaffAccount account) async {
  final teams = await ref.read(adminTeamsProvider.future).catchError((Object _) => const <AdminTeam>[]);
  if (!context.mounted) return;
  final owned = {for (final t in teams) if (t.createdBy == account.id) t.id};
  var selected = {...account.teamIds}..removeAll(owned);
  var busy = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (context, scroll) => Column(children: [
          ListTile(
            title: Text('Équipes de ${account.displayName}'),
            subtitle: const Text('Il voit toutes les données de ces équipes, sauf le dossier médical.'),
          ),
          Expanded(
            child: ListView(controller: scroll, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
              TeamPicker(selected: selected, ownedIds: owned, onChanged: (s) => setSheet(() => selected = s)),
            ]),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        setSheet(() => busy = true);
                        try {
                          await ref.read(adminRepositoryProvider).setTeams(account.id, selected.toList());
                          ref.invalidate(staffAccountsProvider);
                          if (context.mounted) Navigator.of(context).pop();
                        } on AppException catch (e) {
                          setSheet(() => busy = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        }
                      },
                child: Text(busy ? 'Enregistrement…' : 'Enregistrer'),
              ),
            ),
          ),
        ]),
      ),
    ),
  );
}
