import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/sync_indicator.dart';
import '../../data/sync.dart';
import '../profile/profile_repository.dart';
import '../team/team_repository.dart';

/// E10 — Accueil. Pour l'instant : salutation, date et équipe active ; séances, matchs et infirmerie
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
      ]),
    );
  }
}
