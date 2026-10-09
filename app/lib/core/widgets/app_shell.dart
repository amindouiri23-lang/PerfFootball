import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/sync.dart';
import '../settings.dart';
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
    if (await db.setting('owner_user_id') != userId) {
      await db.wipe(keepSettings: deviceSettingKeys);
      await db.setSetting('owner_user_id', userId);
    }
    await ref.read(syncControllerProvider.notifier).sync();
  }

  void _go(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    if (compact) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (final d in _destinations)
              NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selected), label: d.label),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(children: [
        NavigationRail(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _go,
          labelType: NavigationRailLabelType.all,
          destinations: [
            for (final d in _destinations)
              NavigationRailDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selected), label: Text(d.label)),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: shell),
      ]),
    );
  }
}
