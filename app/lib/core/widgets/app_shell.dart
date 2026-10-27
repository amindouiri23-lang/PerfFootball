import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/sync.dart';
import '../permissions.dart';
import '../settings.dart';
import 'sync_indicator.dart' show isLocalStoreDamaged, repairLocalStore;
import '../../features/auth/auth_repository.dart';

const _destinations = [
  (icon: Icons.home_outlined, selected: Icons.home, label: 'Accueil'),
  (icon: Icons.directions_run_outlined, selected: Icons.directions_run, label: 'Séances'),
  (icon: Icons.sports_soccer_outlined, selected: Icons.sports_soccer, label: 'Matchs'),
  (icon: Icons.groups_outlined, selected: Icons.groups, label: 'Équipe'),
  (icon: Icons.person_outline, selected: Icons.person, label: 'Profil'),
];

/// Navigation principale : barre en bas sur téléphone (< 600 dp), colonne à gauche au-delà (specs §3.2).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  StatefulNavigationShell get shell => widget.shell;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  /// Entrée dans l'application connectée : la base locale n'appartient qu'à un utilisateur,
  /// puis première synchronisation.
  Future<void> _startSession() async {
    final db = ref.read(databaseProvider);
    final userId = ref.read(supabaseProvider).auth.currentUser!.id;
    try {
      if (await db.setting('owner_user_id') != userId) {
        await db.wipe(keepSettings: deviceSettingKeys);
        await db.setSetting('owner_user_id', userId);
      }
    } catch (_) {
      // Base locale illisible (abîmée) : la synchronisation ci-dessous échoue à son tour et l'affiche, avec le
      // bandeau « Réparer ».
    }
    await ref.read(syncControllerProvider.notifier).sync();
  }

  void _go(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    // Une écriture refusée par le serveur (droits du rôle) a été annulée : le dire.
    ref.listen(syncControllerProvider, (prev, next) {
      if (next.notice != null && next.notice != prev?.notice) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.notice!)));
      }
      // Copie locale abîmée : bandeau sur tous les écrans, avec la réparation à portée de main.
      final damaged = isLocalStoreDamaged(next.error);
      if (damaged && !isLocalStoreDamaged(prev?.error)) {
        ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
          leading: const Icon(Icons.warning_amber_rounded),
          content: const Text('Les données enregistrées sur cet appareil sont abîmées. Réparez-les : elles seront '
              'rechargées depuis le serveur (rien n\'est perdu, tout a été envoyé).'),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                repairLocalStore(context, ref, ref.read(pendingCountProvider).value ?? 0, damaged: true);
              },
              child: const Text('Réparer'),
            ),
          ],
        ));
      } else if (!damaged && isLocalStoreDamaged(prev?.error)) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
    // Onglets visibles selon le rôle : Accueil et Profil toujours.
    final perms = ref.watch(permsProvider);
    final visible = [
      0,
      if (perms.can('seances.view')) 1,
      if (perms.can('matchs.view')) 2,
      if (perms.can('effectif.view')) 3,
      4,
    ];
    final selected = visible.indexOf(shell.currentIndex).clamp(0, visible.length - 1);
    void go(int i) => _go(visible[i]);
    final compact = MediaQuery.sizeOf(context).width < 600;
    if (compact) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: go,
          destinations: [
            for (final d in [for (final i in visible) _destinations[i]])
              NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selected), label: d.label),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(children: [
        NavigationRail(
          selectedIndex: selected,
          onDestinationSelected: go,
          labelType: NavigationRailLabelType.all,
          destinations: [
            for (final d in [for (final i in visible) _destinations[i]])
              NavigationRailDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selected), label: Text(d.label)),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: shell),
      ]),
    );
  }
}
