import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../matches/match_repository.dart';
import '../team/team_filter.dart';
import '../team/team_repository.dart';
import '../team/team_screen.dart' show NoTeamScreen;
import 'session_repository.dart';

/// Une séance ou un match d'un joueur dans la semaine : charge = RPE × minutes (null si l'un manque).
typedef LoadLine = ({DateTime day, String label, int? minutes, int? rpe});

extension on LoadLine {
  int? get load => minutes == null || rpe == null ? null : minutes! * rpe!;
}

/// Charge de la semaine par joueur : séances (RPE × durée) et matchs (RPE × minutes jouées), avec le détail.
class PlayerLoadScreen extends ConsumerStatefulWidget {
  const PlayerLoadScreen({super.key});

  @override
  ConsumerState<PlayerLoadScreen> createState() => _PlayerLoadScreenState();
}

class _PlayerLoadScreenState extends ConsumerState<PlayerLoadScreen> {
  /// 0 = semaine en cours, -1 = semaine précédente…
  int _week = 0;

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const NoTeamScreen();
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1)).add(Duration(days: 7 * _week));
    final sunday = monday.add(const Duration(days: 6));
    bool inWeek(DateTime d) => !d.isBefore(monday) && d.isBefore(monday.add(const Duration(days: 7)));

    final players = ref.watch(playersProvider(team.id)).value ?? const <Player>[];
    final sessions = {
      for (final s in ref.watch(sessionsProvider(team.id)).value ?? const <TrainingSession>[])
        if (inWeek(s.day) && s.status != 'planned') s.id: s,
    };
    final matches = {
      for (final m in ref.watch(matchesProvider(team.id)).value ?? const <FootballMatch>[])
        if (inWeek(m.day) && {'in_progress', 'completed', 'abandoned'}.contains(m.status)) m.id: m,
    };
    final lines = <String, List<LoadLine>>{};
    for (final r in ref.watch(teamSessionPlayersProvider(team.id)).value ?? const <SessionPlayer>[]) {
      final s = sessions[r.sessionId];
      if (s == null || !r.present) continue;
      (lines[r.playerId] ??= []).add((day: s.day, label: 'Séance · ${sessionTypes[s.type]}', minutes: r.durationMin, rpe: r.rpe));
    }
    for (final r in ref.watch(teamMatchPlayersProvider(team.id)).value ?? const <MatchPlayer>[]) {
      final m = matches[r.matchId];
      if (m == null || !r.present || (r.minutesPlayed ?? 0) == 0) continue;
      (lines[r.playerId] ??= []).add((day: m.day, label: 'Match · ${m.opponent}', minutes: r.minutesPlayed, rpe: r.rpe));
    }
    int total(String id) => (lines[id] ?? const <LoadLine>[]).fold(0, (sum, l) => sum + (l.load ?? 0));
    final sorted = [...players]..sort((a, b) => total(b.id).compareTo(total(a.id)));
    final max = sorted.isEmpty ? 0 : total(sorted.first.id);
    final withLoad = players.where((p) => total(p.id) > 0).toList();
    final mean = withLoad.isEmpty ? 0 : (withLoad.fold(0, (s, p) => s + total(p.id)) / withLoad.length).round();
    final fmt = DateFormat('d MMM', 'fr_FR');

    return Scaffold(
      appBar: AppBar(title: const Text('Charge par joueur'), bottom: teamFilterBar(ref)),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(children: [
            IconButton(tooltip: 'Semaine précédente', onPressed: () => setState(() => _week--), icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text(
                _week == 0 ? 'Cette semaine · ${fmt.format(monday)} – ${fmt.format(sunday)}' : 'Semaine du ${fmt.format(monday)} au ${fmt.format(sunday)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: 'Semaine suivante',
              onPressed: _week >= 0 ? null : () => setState(() => _week++),
              icon: const Icon(Icons.chevron_right),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Charge = RPE × minutes, pour chaque séance et chaque match. Moyenne de l\'équipe : $mean UA'
            '${withLoad.length < players.length ? ' (${withLoad.length} joueurs avec une charge)' : ''}.',
            style: theme.textTheme.bodySmall,
          ),
        ),
        for (final p in sorted)
          ExpansionTile(
            title: Row(children: [
              Expanded(child: Text(p.fullName)),
              Text('${total(p.id)} UA', style: theme.textTheme.titleSmall),
            ]),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: max == 0 ? 0 : total(p.id) / max,
                  minHeight: 6,
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            children: [
              if ((lines[p.id] ?? const []).isEmpty)
                const ListTile(dense: true, title: Text('Aucune séance ni aucun match cette semaine.')),
              for (final l in [...?lines[p.id]]..sort((a, b) => a.day.compareTo(b.day)))
                ListTile(
                  dense: true,
                  title: Text('${DateFormat('EEE d', 'fr_FR').format(l.day)} · ${l.label}'),
                  subtitle: Text(l.load == null
                      ? 'RPE ${l.rpe ?? '—'} × ${l.minutes ?? '—'} min · ${l.rpe == null ? 'RPE manquant' : 'durée manquante'}'
                      : 'RPE ${l.rpe} × ${l.minutes} min'),
                  trailing: Text(l.load == null ? '—' : '${l.load} UA', style: theme.textTheme.titleSmall),
                ),
            ],
          ),
      ]),
    );
  }
}
