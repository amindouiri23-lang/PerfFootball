import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../data/database.dart';
import '../sessions/session_repository.dart' show openInjuriesProvider;
import '../tactics/tactic_board.dart' show PitchPainter, TokenView, pitchWidthM, pitchLengthM;
import '../team/team_repository.dart';
import 'match_repository.dart';

/// Places des 11 titulaires pour chaque dispositif : libellé du poste et position sur un terrain entier
/// vu de dessus (x de gauche à droite, y de l'attaque en haut au but en bas), 0 = gardien.
const formations = <String, List<(String, double, double)>>{
  '4-4-2': [('GB', .5, .92), ('DD', .85, .72), ('DC', .62, .76), ('DC', .38, .76), ('DG', .15, .72),
    ('MD', .85, .48), ('MC', .62, .5), ('MC', .38, .5), ('MG', .15, .48), ('BU', .62, .22), ('BU', .38, .22)],
  '4-3-3': [('GB', .5, .92), ('DD', .85, .72), ('DC', .62, .76), ('DC', .38, .76), ('DG', .15, .72),
    ('MC', .72, .5), ('MDC', .5, .56), ('MC', .28, .5), ('AD', .82, .25), ('BU', .5, .18), ('AG', .18, .25)],
  '4-2-3-1': [('GB', .5, .92), ('DD', .85, .72), ('DC', .62, .76), ('DC', .38, .76), ('DG', .15, .72),
    ('MDC', .62, .58), ('MDC', .38, .58), ('MOD', .82, .38), ('MOC', .5, .36), ('MOG', .18, .38), ('BU', .5, .17)],
  '4-1-4-1': [('GB', .5, .92), ('DD', .85, .72), ('DC', .62, .76), ('DC', .38, .76), ('DG', .15, .72),
    ('MDC', .5, .6), ('MD', .85, .42), ('MC', .62, .44), ('MC', .38, .44), ('MG', .15, .42), ('BU', .5, .18)],
  '3-5-2': [('GB', .5, .92), ('DC', .75, .75), ('DC', .5, .78), ('DC', .25, .75), ('PD', .9, .5),
    ('MC', .68, .52), ('MDC', .5, .58), ('MC', .32, .52), ('PG', .1, .5), ('BU', .62, .22), ('BU', .38, .22)],
  '3-4-3': [('GB', .5, .92), ('DC', .75, .75), ('DC', .5, .78), ('DC', .25, .75), ('MD', .85, .5),
    ('MC', .62, .53), ('MC', .38, .53), ('MG', .15, .5), ('AD', .8, .25), ('BU', .5, .18), ('AG', .2, .25)],
  '5-3-2': [('GB', .5, .92), ('DD', .9, .66), ('DC', .7, .76), ('DC', .5, .78), ('DC', .3, .76), ('DG', .1, .66),
    ('MC', .72, .5), ('MC', .5, .53), ('MC', .28, .5), ('BU', .62, .22), ('BU', .38, .22)],
  '5-4-1': [('GB', .5, .92), ('DD', .9, .66), ('DC', .7, .76), ('DC', .5, .78), ('DC', .3, .76), ('DG', .1, .66),
    ('MD', .85, .46), ('MC', .62, .5), ('MC', .38, .5), ('MG', .15, .46), ('BU', .5, .2)],
};

/// Préparation du match : dispositif, titulaires placés sur le terrain, remplaçants. Le match reste
/// « Planifié » ; le jour du match, la feuille reprend cette composition.
class LineupScreen extends ConsumerStatefulWidget {
  const LineupScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<LineupScreen> createState() => _LineupScreenState();
}

class _LineupScreenState extends ConsumerState<LineupScreen> {
  String? _formation;
  Map<int, String>? _starters;
  Set<String>? _subs;
  bool _saving = false;

  void _init(FootballMatch m, List<MatchPlayer> rows) {
    _formation ??= m.formation ?? '4-3-3';
    _starters ??= {for (final r in rows) if (r.present && r.role == 'starter' && r.slot != null) r.slot!: r.playerId};
    _subs ??= {for (final r in rows) if (r.present && r.role == 'sub') r.playerId};
  }

  Future<void> _pickForSlot(int slot, String label, List<Player> players, Set<String> injured) async {
    final taken = {..._starters!.values};
    final current = _starters![slot];
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: ListView(children: [
            ListTile(title: Text('Titulaire au poste $label', style: Theme.of(context).textTheme.titleMedium)),
            if (current != null)
              ListTile(leading: const Icon(Icons.remove_circle_outline), title: const Text('Vider la place'),
                  onTap: () => Navigator.of(context).pop('')),
            for (final p in players.where((p) => !taken.contains(p.id) || p.id == current))
              ListTile(
                selected: p.id == current,
                leading: CircleAvatar(child: Text(p.shirtNumber?.toString() ?? p.initials)),
                title: Text(p.fullName),
                subtitle: Text([positions[p.position], if (injured.contains(p.id)) 'blessé'].whereType<String>().join(' · ')),
                onTap: () => Navigator.of(context).pop(p.id),
              ),
          ]),
        ),
      ),
    );
    if (choice == null) return;
    setState(() {
      if (choice.isEmpty) {
        _starters!.remove(slot);
      } else {
        _starters![slot] = choice;
        _subs!.remove(choice);
      }
    });
  }

  Future<void> _pickSubs(List<Player> players) async {
    final starters = {..._starters!.values};
    final selected = {..._subs!};
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.75,
            child: Column(children: [
              ListTile(title: Text('Remplaçants (${selected.length})', style: Theme.of(context).textTheme.titleMedium)),
              Expanded(
                child: ListView(children: [
                  for (final p in players.where((p) => !starters.contains(p.id)))
                    CheckboxListTile(
                      value: selected.contains(p.id),
                      title: Text(p.fullName),
                      subtitle: Text(positions[p.position] ?? ''),
                      onChanged: (v) => setSheet(() => v == true ? selected.add(p.id) : selected.remove(p.id)),
                    ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Valider')),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
    if (ok == true) setState(() => _subs = selected);
  }

  @override
  Widget build(BuildContext context) {
    final m = ref.watch(matchProvider(widget.matchId)).value;
    final playersAsync = ref.watch(playersProvider(m?.teamId ?? ''));
    final rowsAsync = ref.watch(matchPlayersProvider(widget.matchId));
    if (m == null || !playersAsync.hasValue || !rowsAsync.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _init(m, rowsAsync.value!);
    final players = playersAsync.value!;
    final byId = {for (final p in players) p.id: p};
    final injured = {for (final i in ref.watch(openInjuriesProvider(m.teamId)).value ?? const <Injury>[]) i.playerId};
    final slots = formations[_formation]!;
    // Changement de dispositif : les places au-delà du nouveau nombre n'existent pas (11 partout).
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Composition · ${m.opponent}')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: [
        Text('Dispositif', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final f in formations.keys)
            ChoiceChip(label: Text(f), selected: _formation == f, onSelected: (_) => setState(() => _formation = f)),
        ]),
        const SizedBox(height: 12),
        Text('Touchez un poste pour y placer un joueur (${_starters!.length}/11 titulaires).', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AspectRatio(
              aspectRatio: pitchWidthM / pitchLengthM('full'),
              child: LayoutBuilder(builder: (context, c) {
                final size = c.biggest;
                final ts = (size.width * 0.1).clamp(24.0, 40.0);
                return Stack(clipBehavior: Clip.none, children: [
                  Positioned.fill(child: CustomPaint(painter: PitchPainter(pitch: 'full', arrows: const []))),
                  for (final (i, (label, x, y)) in slots.indexed)
                    Positioned(
                      left: x * size.width - ts * 2,
                      top: y * size.height - ts / 2,
                      width: ts * 4,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _pickForSlot(i, label, players, injured),
                          child: _starters![i] == null
                              ? Opacity(opacity: 0.75, child: TokenView(kind: 'them', text: '+', caption: label, size: ts))
                              : TokenView(
                                  kind: 'us',
                                  text: byId[_starters![i]]?.shirtNumber?.toString() ?? byId[_starters![i]]?.initials ?? '?',
                                  caption: byId[_starters![i]]?.lastName ?? label,
                                  size: ts,
                                ),
                        ),
                      ),
                    ),
                ]);
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text('Remplaçants (${_subs!.length})', style: theme.textTheme.titleSmall)),
          TextButton.icon(
            onPressed: () => _pickSubs(players),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Choisir'),
          ),
        ]),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final id in _subs!)
            InputChip(label: Text(byId[id]?.fullName ?? '—'), onDeleted: () => setState(() => _subs!.remove(id))),
        ]),
        const SizedBox(height: 8),
        Text('${players.length - _starters!.length - _subs!.length} joueur(s) non convoqué(s).', style: theme.textTheme.bodySmall),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    await ref.read(matchRepositoryProvider).saveLineup(m,
                        formation: _formation!, starters: _starters!, subs: _subs!, playerIds: [for (final p in players) p.id]);
                    if (!context.mounted) return;
                    showMessage(context, 'Composition enregistrée');
                    context.go('/matches/${m.id}');
                  },
            child: const Text('Enregistrer la composition'),
          ),
        ),
      ),
    );
  }
}

/// Composition préparée, en petit, sur la fiche du match.
class LineupPreview extends ConsumerWidget {
  const LineupPreview({super.key, required this.match});

  final FootballMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = formations[match.formation];
    if (slots == null) return const SizedBox.shrink();
    final rows = ref.watch(matchPlayersProvider(match.id)).value ?? const <MatchPlayer>[];
    final byId = {for (final p in ref.watch(playersProvider(match.teamId)).value ?? const <Player>[]) p.id: p};
    final bySlot = {for (final r in rows) if (r.present && r.role == 'starter' && r.slot != null) r.slot!: r.playerId};
    final subs = [for (final r in rows) if (r.present && r.role == 'sub') byId[r.playerId]?.lastName].whereType<String>().toList();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Composition · ${match.formation}', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: AspectRatio(
              aspectRatio: pitchWidthM / pitchLengthM('full'),
              child: LayoutBuilder(builder: (context, c) {
                final size = c.biggest;
                final ts = (size.width * 0.1).clamp(18.0, 30.0);
                return Stack(clipBehavior: Clip.none, children: [
                  Positioned.fill(child: CustomPaint(painter: PitchPainter(pitch: 'full', arrows: const []))),
                  for (final (i, (label, x, y)) in slots.indexed)
                    Positioned(
                      left: x * size.width - ts * 2,
                      top: y * size.height - ts / 2,
                      width: ts * 4,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: TokenView(
                          kind: bySlot[i] == null ? 'them' : 'us',
                          text: bySlot[i] == null ? '' : byId[bySlot[i]]?.shirtNumber?.toString() ?? byId[bySlot[i]]?.initials ?? '?',
                          caption: byId[bySlot[i]]?.lastName ?? label,
                          size: ts,
                        ),
                      ),
                    ),
                ]);
              }),
            ),
          ),
        ),
        if (subs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Remplaçants : ${subs.join(', ')}', style: theme.textTheme.bodySmall),
          ),
      ]),
    );
  }
}
