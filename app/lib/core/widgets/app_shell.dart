import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _destinations = [
  (icon: Icons.home_outlined, selected: Icons.home, label: 'Accueil'),
  (icon: Icons.directions_run_outlined, selected: Icons.directions_run, label: 'Séances'),
  (icon: Icons.sports_soccer_outlined, selected: Icons.sports_soccer, label: 'Matchs'),
  (icon: Icons.groups_outlined, selected: Icons.groups, label: 'Équipe'),
  (icon: Icons.person_outline, selected: Icons.person, label: 'Profil'),
];

/// Navigation principale : barre en bas sur téléphone (< 600 dp), colonne à gauche au-delà (specs §3.2).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

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
