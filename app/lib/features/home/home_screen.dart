import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/sync_indicator.dart';
import '../../data/sync.dart';
import '../profile/profile_repository.dart';
import '../sessions/session_repository.dart';
import '../sessions/sessions_list_screen.dart';
import '../team/team_repository.dart';

/// E10 — Accueil : séances du jour avec l'action adaptée à leur état. Matchs et infirmerie
/// arrivent avec leurs modules.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).value;
    final team = ref.watch(activeTeamProvider);
    final theme = Theme.of(context);
    final today = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text(profile == null ? 'Bonjour' : 'Bonjour ${profile.firstName}'),
        actions: const [SyncIndicator()],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(
          [today[0].toUpperCase() + today.substring(1), if (team.value != null) team.value!.name].join(' · '),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        if (team.hasValue && team.value == null && ref.watch(firstSyncDoneProvider))
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bienvenue !', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Commencez par créer l\'équipe que vous suivez, puis ajoutez vos joueurs.'),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => context.go('/team/new'), child: const Text('Créer mon équipe')),
              ]),
            ),
          ),
        if (team.value != null) ..._today(context, ref, team.value!.id),
      ]),
    );
  }

  List<Widget> _today(BuildContext context, WidgetRef ref, String teamId) {
    final today = isoDate(DateTime.now());
    final sessions = (ref.watch(sessionsProvider(teamId)).value ?? const []).where((s) => s.date == today).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final theme = Theme.of(context);
    return [
      Text("AUJOURD'HUI", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
      const SizedBox(height: 8),
      if (sessions.isEmpty) const Text("Aucune séance prévue aujourd'hui."),
      for (final s in sessions)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(child: Text('${s.time} · ${sessionTypes[s.type]}', style: theme.textTheme.titleMedium)),
                StatusChip(s.status),
              ]),
              Text([
                '${s.plannedDurationMin} min',
                if (s.objective != null) s.objective!,
              ].join(' · ')),
              const SizedBox(height: 8),
              switch (s.status) {
                'planned' => FilledButton(
                    onPressed: () => context.go('/sessions/${s.id}/attendance'), child: const Text("Démarrer l'appel")),
                'in_progress' => FilledButton(onPressed: () => context.go('/sessions/${s.id}'), child: const Text('Reprendre')),
                _ => OutlinedButton(onPressed: () => context.go('/sessions/${s.id}'), child: const Text('Voir')),
              },
            ]),
          ),
        ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => context.go('/sessions/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle séance'),
      ),
    ];
  }
}
