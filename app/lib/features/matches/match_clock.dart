import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import 'match_repository.dart';

/// Chronomètre du match en cours : temps de jeu (mm:ss), minute affichée (« 45+2' », « MT ») et bouton
/// de la prochaine étape (coup d'envoi, mi-temps, reprise, fin du temps de jeu). Le temps additionnel est
/// demandé à la mi-temps et à la fin ; il apparaît ensuite dans les résultats du club.
class MatchClock extends ConsumerStatefulWidget {
  const MatchClock({super.key, required this.match, required this.canControl});

  final FootballMatch match;
  /// Faux : le chrono s'affiche sans les boutons (rôle sans « Matchs — Feuille de match, buts… »).
  final bool canControl;

  @override
  ConsumerState<MatchClock> createState() => _MatchClockState();
}

class _MatchClockState extends ConsumerState<MatchClock> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  /// Temps de jeu écoulé depuis le coup d'envoi du match (la 2e mi-temps reprend à la moitié de la durée).
  Duration? _elapsed(FootballMatch m) {
    final now = DateTime.now();
    final half = Duration(minutes: m.durationMin ~/ 2);
    return switch (m.period) {
      'first_half' when m.firstHalfStartedAt != null => now.difference(DateTime.parse(m.firstHalfStartedAt!)),
      'half_time' => half,
      'second_half' when m.secondHalfStartedAt != null => half + now.difference(DateTime.parse(m.secondHalfStartedAt!)),
      _ => null,
    };
  }

  Future<int?> _askAddedTime(String title) => showDialog<int>(
        context: context,
        builder: (context) {
          var minutes = 0;
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(title),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Minutes de temps additionnel accordées par l\'arbitre.'),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton.outlined(
                    onPressed: minutes > 0 ? () => setState(() => minutes--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('+$minutes min', style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  IconButton.outlined(
                    onPressed: minutes < 30 ? () => setState(() => minutes++) : null,
                    icon: const Icon(Icons.add),
                  ),
                ]),
              ]),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
                FilledButton(onPressed: () => Navigator.of(context).pop(minutes), child: const Text('Valider')),
              ],
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final repo = ref.read(matchRepositoryProvider);
    final theme = Theme.of(context);
    final elapsed = _elapsed(m);
    final half = m.durationMin ~/ 2;
    String two(int n) => n.toString().padLeft(2, '0');
    final time = elapsed == null ? '00:00' : '${two(elapsed.inMinutes)}:${two(elapsed.inSeconds % 60)}';
    final label = switch (m.period) {
      null => 'Chrono non lancé',
      'first_half' => '1re mi-temps · ${m.clockLabel}',
      'half_time' => 'Mi-temps${(m.addedTime1 ?? 0) > 0 ? ' · temps additionnel +${m.addedTime1}' : ''}',
      'second_half' => '2e mi-temps · ${m.clockLabel}',
      _ => 'Temps de jeu terminé · +${m.addedTime1 ?? 0} / +${m.addedTime2 ?? 0}',
    };

    Widget? action;
    if (widget.canControl) {
      action = switch (m.period) {
        null => FilledButton.icon(
            onPressed: () => repo.kickOff(m),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Coup d\'envoi'),
          ),
        'first_half' => OutlinedButton.icon(
            onPressed: () async {
              final added = await _askAddedTime('Mi-temps — temps additionnel de la 1re mi-temps');
              if (added != null) await repo.halfTime(m, added);
            },
            icon: const Icon(Icons.pause),
            label: const Text('Mi-temps'),
          ),
        'half_time' => FilledButton.icon(
            onPressed: () => repo.secondHalf(m),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Reprise · 2e mi-temps'),
          ),
        'second_half' => OutlinedButton.icon(
            onPressed: () async {
              final added = await _askAddedTime('Fin du temps de jeu — temps additionnel de la 2e mi-temps');
              if (added != null) await repo.fullTime(m, added);
            },
            icon: const Icon(Icons.sports),
            label: const Text('Fin du temps de jeu'),
          ),
        _ => null,
      };
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        // Bouton sous le temps : les boutons du thème occupent toute la largeur.
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(Icons.timer_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(time, style: theme.textTheme.headlineMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
            const SizedBox(width: 12),
            Expanded(
              child: Text(m.period == null ? '$label · 2 × $half min' : label, style: theme.textTheme.bodyMedium),
            ),
          ]),
          if (action != null) ...[const SizedBox(height: 10), action],
        ]),
      ),
    );
  }
}
