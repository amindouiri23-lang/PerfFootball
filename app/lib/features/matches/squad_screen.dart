import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/injured_badge.dart';
import '../../data/database.dart';
import '../sessions/session_repository.dart' show openInjuriesProvider;
import '../team/team_repository.dart';
import 'match_repository.dart';

typedef Sheet = ({bool present, String? reason, String role});

/// E22 — Feuille de match : tous cochés par défaut, titulaire ou remplaçant (remplaçant par défaut).
class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen> {
  Map<String, Sheet>? _sheet;

  /// Feuille déjà enregistrée, sinon tout le monde présent et remplaçant. Un joueur arrivé par
  /// synchronisation est ajouté sans toucher aux choix déjà faits.
  void _init(List<Player> players, List<MatchPlayer> existing) {
    final byPlayer = {for (final r in existing) r.playerId: r};
    final sheet = _sheet ??= {};
    for (final p in players) {
      sheet.putIfAbsent(p.id, () {
        final r = byPlayer[p.id];
        return r == null
            ? (present: true, reason: null, role: 'sub')
            : (present: r.present, reason: r.absenceReason, role: r.role ?? 'sub');
      });
    }
    sheet.removeWhere((id, _) => !players.any((p) => p.id == id));
  }

  void _set(String id, Sheet s) => setState(() => _sheet![id] = s);

  Future<void> _confirm(FootballMatch m, int starters) async {
    if (starters != 11) {
      final go = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('$starters titulaire${starters > 1 ? 's' : ''} sélectionné${starters > 1 ? 's' : ''}'),
          content: const Text('Une équipe aligne normalement 11 titulaires. Continuer ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Corriger')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Continuer')),
          ],
        ),
      );
      if (go != true) return;
    }
    await ref.read(matchRepositoryProvider).confirmSquad(m, _sheet!);
    if (mounted) context.go('/matches/${m.id}');
  }

  @override
  Widget build(BuildContext context) {
    final m = ref.watch(matchProvider(widget.matchId)).value;
    if (m == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final players = ref.watch(playersProvider(m.teamId));
    final existing = ref.watch(matchPlayersProvider(m.id));
    if (!players.hasValue || !existing.hasValue) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    _init(players.value!, existing.value!);
    final injured = {for (final i in ref.watch(openInjuriesProvider(m.teamId)).value ?? const <Injury>[]) i.playerId};
    final suspended = _maybeSuspended(m);

    final list = players.value!;
    final present = _sheet!.values.where((s) => s.present).toList();
    final starters = present.where((s) => s.role == 'starter').length;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Feuille de match')),
      body: Column(children: [
        ListTile(
          title: Text('${m.opponent} · ${m.dayLabel} · ${m.time}'),
          subtitle: Text.rich(TextSpan(children: [
            TextSpan(text: '${present.length} présents', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            TextSpan(text: ' · $starters titulaires · ${present.length - starters} remplaçants'),
          ])),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(children: [
            for (final p in list) _row(p, injured.contains(p.id), suspended.contains(p.id)),
          ]),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: present.isEmpty ? null : () => _confirm(m, starters),
                child: const Text('Confirmer la feuille de match'),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  /// Joueurs exclus lors du dernier match terminé avant celui-ci (rappel seulement).
  Set<String> _maybeSuspended(FootballMatch m) {
    final previous = (ref.watch(matchesProvider(m.teamId)).value ?? const <FootballMatch>[])
        .where((x) => x.id != m.id && x.status == 'completed' && '${x.date} ${x.kickOffTime}'.compareTo('${m.date} ${m.kickOffTime}') < 0)
        .toList()
      ..sort((a, b) => '${b.date} ${b.kickOffTime}'.compareTo('${a.date} ${a.kickOffTime}'));
    if (previous.isEmpty) return const {};
    final reds = ref.watch(teamRedCardsProvider(m.teamId)).value ?? const <MatchEvent>[];
    return {for (final e in reds.where((e) => e.matchId == previous.first.id)) e.playerId};
  }

  Widget _row(Player p, bool injured, bool suspended) {
    final s = _sheet![p.id]!;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(children: [
      CheckboxListTile(
        value: s.present,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (v) => _set(p.id, v == true
            ? (present: true, reason: null, role: s.role)
            : (present: false, reason: injured ? 'injured' : 'not_selected', role: s.role)),
        title: Text('${p.shirtNumber ?? ''}  ${p.fullName}', style: s.present ? null : TextStyle(color: muted)),
        subtitle: Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(s.present ? positions[p.position]! : (matchAbsenceReasons[s.reason] ?? 'Absent')),
          if (injured) const InjuredBadge(),
          if (suspended) const _SuspendedBadge(),
        ]),
        secondary: s.present
            ? SegmentedButton<String>(
                showSelectedIcon: false,
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: const [
                  ButtonSegment(value: 'starter', label: Text('Tit.')),
                  ButtonSegment(value: 'sub', label: Text('Remp.')),
                ],
                selected: {s.role},
                onSelectionChanged: (v) => _set(p.id, (present: true, reason: null, role: v.first)),
              )
            : null,
      ),
      if (!s.present)
        Padding(
          padding: const EdgeInsets.fromLTRB(56, 0, 16, 8),
          child: Wrap(spacing: 6, runSpacing: 6, children: [
            for (final e in matchAbsenceReasons.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: s.reason == e.key,
                onSelected: (v) => _set(p.id, (present: false, reason: v ? e.key : null, role: s.role)),
              ),
          ]),
        ),
    ]);
  }
}

class _SuspendedBadge extends StatelessWidget {
  const _SuspendedBadge();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: c.tertiaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Text('Suspendu ?', style: TextStyle(color: c.onTertiaryContainer, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
