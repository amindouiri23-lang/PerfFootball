import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../sessions/session_repository.dart' show isoDate;
import '../sessions/sessions_list_screen.dart' show StatusChip;
import '../team/team_repository.dart';
import '../team/team_screen.dart';
import 'match_repository.dart';

/// E20 — Liste des matchs : résumé de la saison, « À venir » puis « Passés ».
class MatchesListScreen extends ConsumerStatefulWidget {
  const MatchesListScreen({super.key});

  @override
  ConsumerState<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends ConsumerState<MatchesListScreen> {
  String? _competition;

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const NoTeamScreen();
    final all = ref.watch(matchesProvider(team.id)).value ?? const <FootballMatch>[];
    final matches = all.where((m) => _competition == null || m.competition == _competition).toList();
    final today = isoDate(DateTime.now());
    String key(FootballMatch m) => '${m.date} ${m.kickOffTime}';
    final upcoming = matches.where((m) => m.date.compareTo(today) >= 0 && m.status == 'planned').toList()
      ..sort((a, b) => key(a).compareTo(key(b)));
    final past = matches.where((m) => !upcoming.contains(m)).toList()..sort((a, b) => key(b).compareTo(key(a)));
    final results = all.map((m) => m.result).whereType<String>().toList();
    final theme = Theme.of(context);

    Widget stat(String label, int n, [Color? color]) => Expanded(
          child: Column(children: [
            Text('$n', style: theme.textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodySmall),
          ]),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Matchs'), actions: const [SyncIndicator()]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/matches/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau match'),
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
        Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              stat('Joués', results.length),
              stat('Victoires', results.where((r) => r == 'W').length, const Color(0xFF2E7D32)),
              stat('Nuls', results.where((r) => r == 'D').length),
              stat('Défaites', results.where((r) => r == 'L').length, theme.colorScheme.error),
            ]),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: [
            for (final e in <String?, String>{null: 'Toutes', ...competitions}.entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(e.value), selected: _competition == e.key,
                    onSelected: (_) => setState(() => _competition = e.key)),
              ),
          ]),
        ),
        if (matches.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text('Aucun match pour l\'instant. Créez votre premier match.', textAlign: TextAlign.center),
          ),
        if (upcoming.isNotEmpty) ...[
          _header(context, 'À venir'),
          for (final m in upcoming) _MatchTile(m),
        ],
        if (past.isNotEmpty) ...[
          _header(context, 'Passés'),
          for (final m in past) _MatchTile(m),
        ],
      ]),
    );
  }

  Widget _header(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

class _MatchTile extends ConsumerWidget {
  const _MatchTile(this.m);

  final FootballMatch m;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text('${m.dayLabel} · ${m.time}'),
      subtitle: Text('${m.opponent} · ${homeAwayLabels[m.homeAway]} · ${competitions[m.competition]}'),
      onTap: () => context.go('/matches/${m.id}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (m.result != null) ScoreChip(m) else StatusChip(m.status, labels: matchStatuses),
        PopupMenuButton<String>(
          tooltip: 'Actions',
          onSelected: (v) => v == 'edit' ? context.go('/matches/${m.id}/edit') : confirmDeleteMatch(context, ref, m),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Modifier')),
            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ]),
    );
  }
}

/// Score coloré : vert victoire, gris nul, rouge défaite.
class ScoreChip extends StatelessWidget {
  const ScoreChip(this.m, {super.key});

  final FootballMatch m;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final (bg, fg) = switch (m.result) {
      'W' => (const Color(0xFFC8E6C9), const Color(0xFF1B5E20)),
      'L' => (c.errorContainer, c.onErrorContainer),
      _ => (c.surfaceContainerHighest, c.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text('${m.goalsFor} - ${m.goalsAgainst}', style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
    );
  }
}

Future<bool> confirmDeleteMatch(BuildContext context, WidgetRef ref, FootballMatch m) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Supprimer le match contre ${m.opponent} ?'),
      content: const Text('La feuille de match et les événements seront supprimés. Les blessures déclarées sont conservées.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
      ],
    ),
  );
  if (ok != true) return false;
  await ref.read(matchRepositoryProvider).deleteMatch(m.id);
  if (context.mounted) showMessage(context, 'Match supprimé');
  return true;
}
