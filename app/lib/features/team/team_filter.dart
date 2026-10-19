import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import 'team_repository.dart';

/// Ordre des catégories dans la barre : des seniors aux plus jeunes.
const _categoryOrder = ['seniors', 'u21', 'u19', 'u17', 'u15', 'other'];

/// Barre des équipes sous le titre d'un écran : une pastille par équipe, l'équipe active cochée.
/// Toucher une équipe la rend active pour tous les écrans. Rien n'est affiché avec une seule équipe.
PreferredSizeWidget? teamFilterBar(WidgetRef ref) {
  final teams = [...ref.watch(teamsProvider).value ?? const <Team>[]];
  if (teams.length < 2) return null;
  teams.sort((a, b) {
    final c = _categoryOrder.indexOf(a.category).compareTo(_categoryOrder.indexOf(b.category));
    return c != 0 ? c : a.name.compareTo(b.name);
  });
  final active = ref.watch(activeTeamProvider).value?.id;
  return PreferredSize(
    preferredSize: const Size.fromHeight(52),
    child: SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        children: [
          for (final t in teams)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(t.name),
                selected: t.id == active,
                onSelected: (_) => ref.read(teamRepositoryProvider).setActiveTeam(t.id),
              ),
            ),
        ],
      ),
    ),
  );
}
