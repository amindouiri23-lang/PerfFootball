import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/injured_badge.dart';
import '../../data/database.dart';
import '../team/team_repository.dart';
import 'session_repository.dart';

typedef Call = ({bool present, String? reason});

/// E13 — Appel (étape 2 sur 3) : tous les joueurs cochés par défaut, on décoche les absents.
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  /// null tant que l'appel n'est pas initialisé (joueurs + appel déjà enregistré).
  Map<String, Call>? _calls;

  /// Premier affichage : appel déjà enregistré, sinon tout le monde présent. Un joueur arrivé
  /// par synchronisation pendant l'appel est ajouté présent, sans toucher aux choix déjà faits.
  void _init(List<Player> players, List<SessionPlayer> existing) {
    final byPlayer = {for (final r in existing) r.playerId: r};
    final calls = _calls ??= {};
    for (final p in players) {
      calls.putIfAbsent(
        p.id,
        () => byPlayer[p.id] == null
            ? (present: true, reason: null)
            : (present: byPlayer[p.id]!.present, reason: byPlayer[p.id]!.absenceReason),
      );
    }
    calls.removeWhere((id, _) => !players.any((p) => p.id == id));
  }

  void _toggle(Player p, bool injured) {
    final c = _calls![p.id]!;
    setState(() => _calls![p.id] = c.present
        ? (present: false, reason: injured ? 'injured' : null) // « Blessé » proposé en premier
        : (present: true, reason: null));
  }

  void _setAll(bool present) => setState(() {
        for (final id in _calls!.keys) {
          _calls![id] = (present: present, reason: null);
        }
      });

  Future<void> _confirm(TrainingSession s) async {
    await ref.read(sessionRepositoryProvider).confirmAttendance(s, _calls!);
    if (mounted) context.go('/sessions/${s.id}');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider(widget.sessionId)).value;
    if (session == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final players = ref.watch(playersProvider(session.teamId));
    final existing = ref.watch(sessionPlayersProvider(session.id));
    final injured = {for (final i in ref.watch(openInjuriesProvider(session.teamId)).value ?? const <Injury>[]) i.playerId};
    if (!players.hasValue || !existing.hasValue) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    _init(players.value!, existing.value!);

    final list = players.value!;
    final present = _calls!.values.where((c) => c.present).length;
    final absent = _calls!.length - present;
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Appel')),
      body: Column(children: [
        ListTile(
          title: Text('${session.dayLabel} · ${session.time} · ${sessionTypes[session.type]}'),
          subtitle: Text.rich(TextSpan(children: [
            TextSpan(text: '$present présent${present > 1 ? 's' : ''}',
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            TextSpan(text: ' · $absent absent${absent > 1 ? 's' : ''}'),
          ])),
          trailing: TextButton(
            onPressed: () => _setAll(absent > 0),
            child: Text(absent > 0 ? 'Tout cocher' : 'Tout décocher'),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Aucun joueur dans l\'effectif.'))
              : wide
                  ? GridView.extent(
                      maxCrossAxisExtent: 260,
                      childAspectRatio: 2.6,
                      padding: const EdgeInsets.all(12),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [for (final p in list) _card(p, injured.contains(p.id))],
                    )
                  : ListView(children: [for (final p in list) _row(p, injured.contains(p.id))]),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: present == 0 ? null : () => _confirm(session),
                child: Text('Confirmer les présents ($present)'),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _row(Player p, bool injured) {
    final c = _calls![p.id]!;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(children: [
      CheckboxListTile(
        value: c.present,
        onChanged: (_) => _toggle(p, injured),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text('${p.shirtNumber ?? ''}  ${p.fullName}', style: c.present ? null : TextStyle(color: muted)),
        subtitle: c.present ? null : Text(absenceReasons[c.reason] ?? 'Absent'),
        secondary: injured ? const InjuredBadge() : Text(positionShort[p.position]!),
      ),
      if (!c.present) _reasons(p, c),
    ]);
  }

  Widget _reasons(Player p, Call c) => Padding(
        padding: const EdgeInsets.fromLTRB(56, 0, 16, 8),
        child: Wrap(spacing: 6, runSpacing: 6, children: [
          for (final e in absenceReasons.entries)
            ChoiceChip(
              label: Text(e.value),
              selected: c.reason == e.key,
              onSelected: (s) => setState(() => _calls![p.id] = (present: false, reason: s ? e.key : null)),
            ),
        ]),
      );

  Widget _card(Player p, bool injured) {
    final c = _calls![p.id]!;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _toggle(p, injured),
      onLongPress: c.present ? null : () => _pickReason(p, c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: c.present ? scheme.primaryContainer : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.present ? scheme.primary : scheme.outlineVariant),
        ),
        child: Row(children: [
          Icon(c.present ? Icons.check_box : Icons.check_box_outline_blank,
              color: c.present ? scheme.primary : scheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p.shirtNumber ?? ''} ${p.fullName}', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(c.present ? positions[p.position]! : (absenceReasons[c.reason] ?? 'Absent — motif ?'),
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
          if (injured) const InjuredBadge(),
          if (!c.present)
            IconButton(tooltip: 'Motif d\'absence', icon: const Icon(Icons.edit_note), onPressed: () => _pickReason(p, c)),
        ]),
      ),
    );
  }

  Future<void> _pickReason(Player p, Call c) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: Text('Motif d\'absence — ${p.fullName}')),
          for (final e in absenceReasons.entries)
            ListTile(
              leading: Icon(c.reason == e.key ? Icons.radio_button_checked : Icons.radio_button_off),
              title: Text(e.value),
              onTap: () => Navigator.of(context).pop(e.key),
            ),
        ]),
      ),
    );
    if (reason != null) setState(() => _calls![p.id] = (present: false, reason: reason));
  }
}
