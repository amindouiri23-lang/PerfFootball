import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/widgets/steppers.dart';
import '../../data/database.dart';
import '../team/team_repository.dart';
import 'match_repository.dart';
import 'match_screen.dart' show squadOrder;

/// E25 — Fin de match : score final, temps de jeu et RPE de chaque présent.
/// Temps de jeu par défaut : titulaire = durée du match, remplaçant = 0, exclu = minute du carton
/// rouge, titulaire blessé = minute de la blessure. Valeurs enregistrées à chaque appui.
class EndMatchScreen extends ConsumerStatefulWidget {
  const EndMatchScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<EndMatchScreen> createState() => _EndMatchScreenState();
}

class _EndMatchScreenState extends ConsumerState<EndMatchScreen> {
  int? _for;
  int? _against;
  final Map<String, int> _minutes = {};
  final Map<String, int?> _rpes = {};

  int _default(FootballMatch m, MatchPlayer r, List<MatchEvent> events, List<Injury> injuries) {
    final red = events.where((e) => e.type == 'red_card' && e.playerId == r.playerId).firstOrNull;
    if (red != null && r.role == 'starter') return red.minute.clamp(0, m.durationMin);
    final injury = injuries.where((i) => i.playerId == r.playerId && i.minute != null).firstOrNull;
    if (injury != null && r.role == 'starter') return injury.minute!.clamp(0, m.durationMin);
    return r.role == 'starter' ? m.durationMin : 0;
  }

  @override
  Widget build(BuildContext context) {
    final m = ref.watch(matchProvider(widget.matchId)).value;
    final rowsAsync = ref.watch(matchPlayersProvider(widget.matchId));
    if (m == null || !rowsAsync.hasValue) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final players = {for (final p in ref.watch(playersProvider(m.teamId)).value ?? const <Player>[]) p.id: p};
    final events = ref.watch(matchEventsProvider(m.id)).value ?? const <MatchEvent>[];
    final injuries = ref.watch(matchInjuriesProvider(m.id)).value ?? const <Injury>[];
    final present = squadOrder(rowsAsync.value!.where((r) => r.present).toList(), players);
    final repo = ref.read(matchRepositoryProvider);
    final theme = Theme.of(context);

    final goalsFor = _for ?? m.goalsFor ?? events.where((e) => e.type == 'goal').length;
    final goalsAgainst = _against ?? m.goalsAgainst ?? 0;
    int minutesOf(MatchPlayer r) => _minutes[r.id] ?? r.minutesPlayed ?? _default(m, r, events, injuries);
    int? rpeOf(MatchPlayer r) => _rpes.containsKey(r.id) ? _rpes[r.id] : r.rpe;

    Widget score(String label, int value, ValueChanged<int> onChanged) => Column(children: [
          Text(label, style: theme.textTheme.labelLarge, overflow: TextOverflow.ellipsis),
          Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(onPressed: value > 0 ? () => onChanged(value - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
            Text('$value', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle_outline)),
          ]),
        ]);

    return Scaffold(
      appBar: AppBar(title: const Text('Fin de match')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: [
        Text('Score final', style: theme.textTheme.titleSmall),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Expanded(child: score(ref.watch(activeTeamProvider).value?.name ?? 'Nous', goalsFor, (v) => setState(() => _for = v))),
              const Text('-', style: TextStyle(fontSize: 28)),
              Expanded(child: score(m.opponent, goalsAgainst, (v) => setState(() => _against = v))),
            ]),
          ),
        ),
        Text('Buts de l\'équipe pré-remplis avec les buts saisis ; à corriger pour un but contre son camp adverse.',
            style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        Text('Temps de jeu et RPE', style: theme.textTheme.titleSmall),
        Text('Touchez les minutes pour saisir la valeur exacte. RPE facultatif.', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        for (final r in present)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text('${players[r.playerId]?.shirtNumber ?? ''}  ${players[r.playerId]?.fullName ?? '—'}  ·  ${matchRoles[r.role] ?? ''}',
                        style: theme.textTheme.titleSmall),
                  ),
                  MinutesStepper(
                    value: minutesOf(r),
                    max: m.durationMin + 30,
                    onChanged: (v) {
                      setState(() => _minutes[r.id] = v);
                      repo.setMinutes(r.id, v);
                    },
                  ),
                ]),
                const SizedBox(height: 8),
                if (minutesOf(r) == 0)
                  Text('N\'a pas joué : pas de RPE.', style: theme.textTheme.bodySmall)
                else
                  RpeSelector(
                    value: rpeOf(r),
                    onChanged: (v) async {
                      setState(() => _rpes[r.id] = v);
                      if (r.minutesPlayed == null) await repo.setMinutes(r.id, minutesOf(r));
                      await repo.setRpe(r.id, v);
                    },
                  ),
              ]),
            ),
          ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () async {
              await repo.complete(m, goalsFor: goalsFor, goalsAgainst: goalsAgainst, defaultMinutes: {
                for (final r in present) r.id: minutesOf(r),
              });
              if (!context.mounted) return;
              showMessage(context, 'Match terminé : $goalsFor - $goalsAgainst');
              context.go('/matches/${m.id}');
            },
            child: const Text('Valider le match'),
          ),
        ),
      ),
    );
  }
}
