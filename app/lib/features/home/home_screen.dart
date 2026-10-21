import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/permissions.dart';
import '../../core/photos.dart';
import '../../core/theme.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../../data/sync.dart';
import '../matches/match_repository.dart';
import '../profile/profile_repository.dart';
import '../sessions/session_repository.dart';
import '../sessions/sessions_list_screen.dart';
import '../tactics/tactic_screens.dart' show showTacticInfoSheet;
import '../team/team_repository.dart';
import 'player_space.dart';
import '../team/team_filter.dart';

/// E10 — Accueil, façon « centre du club » d'un jeu de foot : identité de l'équipe, prochain match,
/// état de l'effectif, charge de la semaine, séances du jour, infirmerie.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).value;
    final team = ref.watch(activeTeamProvider);
    final theme = Theme.of(context);
    final today = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());
    final perms = ref.watch(permsProvider);
    if (perms.isPlayer) {
      return Scaffold(
        appBar: AppBar(title: Text(profile == null ? 'Bonjour' : 'Bonjour ${profile.firstName}'), actions: const [SyncIndicator()]),
        body: PlayerSpace(playerId: perms.playerId),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(profile == null ? 'Bonjour' : 'Bonjour ${profile.firstName}'),
        actions: const [SyncIndicator()],
        bottom: teamFilterBar(ref),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (team.value != null) _clubHeader(context, team.value!),
        Text(today[0].toUpperCase() + today.substring(1), style: theme.textTheme.bodyMedium),
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
    final sessions = (ref.watch(sessionsProvider(teamId)).value ?? const <TrainingSession>[]).where((s) => s.date == today).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final theme = Theme.of(context);
    final perms = ref.watch(permsProvider);
    return [
      Card(
        child: ListTile(
          leading: const Icon(Icons.emoji_events_outlined),
          title: const Text('Résultats du club'),
          subtitle: const Text('Scores et matchs en direct de toutes les équipes'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/home/results'),
        ),
      ),
      ..._nextMatch(context, ref, teamId),
      ..._squadAndLoad(context, ref, teamId),
      const SizedBox(height: 16),
      Text("AUJOURD'HUI", style: sectionLabel(context)),
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
              if (perms.can('seances.appel'))
              switch (s.status) {
                'planned' => FilledButton(
                    onPressed: () => context.go('/sessions/${s.id}/attendance'), child: const Text("Démarrer l'appel")),
                'in_progress' => FilledButton(onPressed: () => context.go('/sessions/${s.id}'), child: const Text('Reprendre')),
                _ => OutlinedButton(onPressed: () => context.go('/sessions/${s.id}'), child: const Text('Voir')),
              },
            ]),
          ),
        ),
      ..._infirmary(context, ref, teamId),
      const SizedBox(height: 8),
      Row(children: [
        if (perms.can('seances.add'))
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go('/sessions/new'),
            icon: const Icon(Icons.add),
            label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Séance')),
            style: _compact,
          ),
        ),
        if (perms.can('seances.add') && perms.can('matchs.add')) const SizedBox(width: 12),
        if (perms.can('matchs.add'))
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go('/matches/new'),
            icon: const Icon(Icons.add),
            label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Match')),
            style: _compact,
          ),
        ),
        if ((perms.can('seances.add') || perms.can('matchs.add')) && perms.can('tactiques.add')) const SizedBox(width: 12),
        if (perms.can('tactiques.add'))
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final id = await showTacticInfoSheet(context, ref, teamId: teamId);
              if (id != null && context.mounted) context.go('/team/tactics/$id');
            },
            icon: const Icon(Icons.add),
            label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Tactique')),
            style: _compact,
          ),
        ),
      ]),
    ];
  }

  /// Trois boutons côte à côte sur un téléphone : marges réduites, libellé réduit plutôt que coupé.
  static final _compact = OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8));

  /// En-tête du club : logo de l'équipe (modifiable dans « Modifier l'équipe »), club et équipe.
  Widget _clubHeader(BuildContext context, Team team) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          PhotoAvatar(path: team.logoPath, initials: team.name.substring(0, 1).toUpperCase(), radius: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (team.clubName != null) Text(team.clubName!.toUpperCase(), style: sectionLabel(context)),
              Text(team.name.toUpperCase(), style: gameTitle(context, size: 28)),
            ]),
          ),
        ]),
      );

  /// État de l'effectif (joueurs, aptes, blessés) et charge de la semaine en cours : prévue (durée × RPE
  /// prévu) et réalisée (moyenne des présents notés), additionnées sur les séances du lundi au dimanche.
  List<Widget> _squadAndLoad(BuildContext context, WidgetRef ref, String teamId) {
    final theme = Theme.of(context);
    final players = ref.watch(playersProvider(teamId)).value ?? const <Player>[];
    final ids = {for (final p in players) p.id};
    final injured = {
      for (final i in ref.watch(openInjuriesProvider(teamId)).value ?? const <Injury>[])
        if (ids.contains(i.playerId)) i.playerId,
    };
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final week = (ref.watch(sessionsProvider(teamId)).value ?? const <TrainingSession>[])
        .where((s) => !s.day.isBefore(monday) && s.day.isBefore(monday.add(const Duration(days: 7))))
        .toList();
    final rows = ref.watch(teamSessionPlayersProvider(teamId)).value ?? const <SessionPlayer>[];
    final planned = week.fold(0, (sum, s) => sum + (s.plannedLoad ?? 0));
    final done = week.fold(0, (sum, s) => sum + (meanObservedLoad(rows.where((r) => r.sessionId == s.id)) ?? 0));
    Widget number(String value, String label, {Color? color}) => Expanded(
          child: Column(children: [
            Text(value, style: gameTitle(context, size: 30, color: color)),
            Text(label, style: theme.textTheme.bodySmall),
          ]),
        );
    return [
      Text("ÉTAT DE L'EFFECTIF", style: sectionLabel(context)),
      const SizedBox(height: 8),
      Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go('/team'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              number('${players.length}', 'joueurs'),
              number('${players.length - injured.length}', 'aptes'),
              number('${injured.length}', injured.length > 1 ? 'blessés' : 'blessé',
                  color: injured.isEmpty ? null : theme.colorScheme.primary),
            ]),
          ),
        ),
      ),
      ...[
        const SizedBox(height: 16),
        Text('CHARGE DE LA SEMAINE', style: sectionLabel(context)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Text('$done UA', style: gameTitle(context, size: 24)),
                const Spacer(),
                if (planned > 0) Text('prévu $planned UA', style: theme.textTheme.bodySmall),
              ]),
              if (planned > 0) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (done / planned).clamp(0.0, 1.0),
                    minHeight: 6,
                    color: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.go('/home/load'),
                  icon: const Icon(Icons.bar_chart, size: 18),
                  label: const Text('Voir par joueur'),
                ),
              ),
            ]),
          ),
        ),
      ],
    ];
  }

  /// Joueurs blessés (blessure sans date de retour) → infirmerie.
  List<Widget> _infirmary(BuildContext context, WidgetRef ref, String teamId) {
    final players = {for (final p in ref.watch(playersProvider(teamId)).value ?? const <Player>[]) p.id: p};
    final injured = (ref.watch(openInjuriesProvider(teamId)).value ?? const <Injury>[])
        .where((i) => players.containsKey(i.playerId))
        .map((i) => players[i.playerId]!.fullName)
        .toSet()
        .toList();
    final theme = Theme.of(context);
    return [
      const SizedBox(height: 16),
      Text('INFIRMERIE', style: sectionLabel(context)),
      const SizedBox(height: 8),
      Card(
        color: injured.isEmpty ? null : theme.colorScheme.errorContainer,
        child: ListTile(
          leading: Icon(Icons.healing, color: injured.isEmpty ? null : theme.colorScheme.onErrorContainer),
          title: Text(injured.isEmpty
              ? 'Aucun joueur blessé'
              : '${injured.length} joueur${injured.length > 1 ? 's' : ''} blessé${injured.length > 1 ? 's' : ''}'),
          subtitle: injured.isEmpty ? null : Text(injured.join(' · ')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/team/injuries'),
        ),
      ),
    ];
  }

  /// Match du jour ou prochain match non terminé, avec le compte à rebours en jours.
  List<Widget> _nextMatch(BuildContext context, WidgetRef ref, String teamId) {
    final today = isoDate(DateTime.now());
    final next = (ref.watch(matchesProvider(teamId)).value ?? const <FootballMatch>[])
        .where((m) => m.date.compareTo(today) >= 0 && (m.status == 'planned' || m.status == 'in_progress'))
        .toList()
      ..sort((a, b) => '${a.date} ${a.kickOffTime}'.compareTo('${b.date} ${b.kickOffTime}'));
    if (next.isEmpty) return const [];
    final m = next.first;
    final days = m.day.difference(DateTime.parse(today)).inDays;
    final theme = Theme.of(context);
    return [
      Text(days == 0 ? 'MATCH DU JOUR' : 'PROCHAIN MATCH', style: sectionLabel(context)),
      const SizedBox(height: 8),
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go(m.status == 'planned' && days == 0 ? '/matches/${m.id}/squad' : '/matches/${m.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Text(m.competitionLabel.toUpperCase(), style: sectionLabel(context)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: Text(m.homeAway == 'A' ? m.opponent.toUpperCase() : 'NOUS',
                    style: gameTitle(context, size: 22), textAlign: TextAlign.center)),
                Text(days == 0 ? m.time : 'J-$days', style: gameTitle(context, size: 18, color: theme.colorScheme.primary)),
                Expanded(child: Text(m.homeAway == 'A' ? 'NOUS' : m.opponent.toUpperCase(),
                    style: gameTitle(context, size: 22), textAlign: TextAlign.center)),
              ]),
              const SizedBox(height: 4),
              Text('${m.dayLabel} · ${m.time} · ${homeAwayLabels[m.homeAway]}', style: theme.textTheme.bodySmall),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }
}
