import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../sessions/session_repository.dart' show isoDate;
import '../team/team_repository.dart';
import 'test_repository.dart';

String _dayLabel(String date) {
  final s = DateFormat('EEEE d MMMM y', 'fr_FR').format(DateTime.parse(date));
  return s[0].toUpperCase() + s.substring(1);
}

/// E32 — Tests physiques : les journées de tests de l'équipe, de la plus récente à la plus ancienne.
class TestDaysScreen extends ConsumerWidget {
  const TestDaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final results = ref.watch(teamTestResultsProvider(team.id)).value ?? const <TestResult>[];
    final types = {for (final t in ref.watch(testTypesProvider(team.id)).value ?? const <TestType>[]) t.id: t};
    final byDay = <String, List<TestResult>>{};
    for (final r in results) {
      byDay.putIfAbsent(r.date, () => []).add(r);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Tests physiques'), actions: const [SyncIndicator()]),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle journée de tests'),
        onPressed: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            helpText: 'Date des tests',
          );
          if (d != null && context.mounted) context.go('/team/tests/${isoDate(d)}');
        },
      ),
      body: days.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Aucun test pour l\'instant.\nCréez une journée de tests ou importez le fichier Excel des tests.',
                    textAlign: TextAlign.center),
              ),
            )
          : ListView(padding: const EdgeInsets.only(bottom: 88), children: [
              for (final d in days)
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(_dayLabel(d)),
                  subtitle: Text(() {
                    final rows = byDay[d]!;
                    final players = rows.map((r) => r.playerId).toSet().length;
                    final names = rows.map((r) => types[r.testTypeId]?.name).whereType<String>().toSet();
                    return '$players joueur${players > 1 ? 's' : ''} · ${names.length} test${names.length > 1 ? 's' : ''}'
                        ' — ${names.take(4).join(', ')}${names.length > 4 ? '…' : ''}';
                  }()),
                  onTap: () => context.go('/team/tests/$d'),
                ),
            ]),
    );
  }
}

/// E33 — Journée de tests : un test à la fois, une ligne par joueur, un champ par essai. Le meilleur
/// essai est calculé ; « Classement » trie les joueurs du meilleur au moins bon.
class TestDayScreen extends ConsumerStatefulWidget {
  const TestDayScreen({super.key, required this.date});

  final String date;

  @override
  ConsumerState<TestDayScreen> createState() => _TestDayScreenState();
}

class _TestDayScreenState extends ConsumerState<TestDayScreen> {
  String? _typeId;
  bool _ranking = false;

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final types = ref.watch(testTypesProvider(team.id)).value ?? const <TestType>[];
    final players = ref.watch(playersProvider(team.id)).value ?? const <Player>[];
    final dayResults = (ref.watch(teamTestResultsProvider(team.id)).value ?? const <TestResult>[])
        .where((r) => r.date == widget.date)
        .toList();
    if (types.isEmpty) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));

    // Par défaut : le premier test déjà saisi ce jour-là, sinon le premier du catalogue.
    final usedIds = dayResults.map((r) => r.testTypeId).toSet();
    final type = types.where((t) => t.id == _typeId).firstOrNull ??
        types.where((t) => usedIds.contains(t.id)).firstOrNull ??
        types.first;
    final values = <String, Map<int, double>>{};
    for (final r in dayResults.where((r) => r.testTypeId == type.id)) {
      values.putIfAbsent(r.playerId, () => {})[r.attempt] = r.value;
    }
    double? bestOf(String playerId) {
      final v = values[playerId];
      return v == null || v.isEmpty ? null : type.best(v.values);
    }

    final shown = [...players];
    if (_ranking && type.better != 'none') {
      shown.sort((a, b) {
        final x = bestOf(a.id), y = bestOf(b.id);
        if (x == null || y == null) return x == null ? (y == null ? 0 : 1) : -1;
        return type.better == 'lower' ? x.compareTo(y) : y.compareTo(x);
      });
    }
    final done = players.where((p) => bestOf(p.id) != null).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('d MMM y', 'fr_FR').format(DateTime.parse(widget.date))),
        actions: [
          const SyncIndicator(),
          IconButton(
            tooltip: 'Ajouter un test au catalogue',
            icon: const Icon(Icons.playlist_add),
            onPressed: () async {
              final id = await showAddTestTypeDialog(context, ref, team.id);
              if (id != null) setState(() => _typeId = id);
            },
          ),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final t in types)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: usedIds.contains(t.id) ? const Icon(Icons.check, size: 16) : null,
                    label: Text(t.name),
                    selected: t.id == type.id,
                    onSelected: (_) => setState(() => _typeId = t.id),
                  ),
                ),
            ],
          ),
        ),
        ListTile(
          dense: true,
          title: Text('${type.name}${type.unit != null ? ' (${type.unit})' : ''} · ${testCategories[type.category]}'),
          subtitle: Text('${type.attempts} essai${type.attempts > 1 ? 's' : ''} · ${testBetter[type.better]} · '
              '$done/${players.length} joueurs'),
          trailing: type.better == 'none'
              ? null
              : FilterChip(
                  label: const Text('Classement'),
                  selected: _ranking,
                  onSelected: (v) => setState(() => _ranking = v),
                ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: shown.length,
            itemBuilder: (context, i) {
              final p = shown[i];
              final best = bestOf(p.id);
              return _ResultRow(
                // Clé par joueur et par test : changer de test repart de champs à jour.
                key: ValueKey('${type.id}:${p.id}'),
                player: p,
                rank: _ranking && best != null ? i + 1 : null,
                type: type,
                values: values[p.id] ?? const {},
                best: best,
                onChanged: (attempt, v) => ref.read(testRepositoryProvider).saveResult(
                      teamId: team.id, playerId: p.id, testTypeId: type.id, date: widget.date, attempt: attempt, value: v),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    super.key,
    required this.player,
    required this.rank,
    required this.type,
    required this.values,
    required this.best,
    required this.onChanged,
  });

  final Player player;
  final int? rank;
  final TestType type;
  final Map<int, double> values;
  final double? best;
  final void Function(int attempt, double? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        SizedBox(
          width: 28,
          child: Text(rank != null ? '$rank' : '${player.shirtNumber ?? ''}',
              style: rank != null ? theme.textTheme.titleSmall : theme.textTheme.bodySmall),
        ),
        Expanded(child: Text(player.fullName, overflow: TextOverflow.ellipsis)),
        for (var a = 1; a <= type.attempts; a++)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: SizedBox(
              width: 72,
              child: _ValueField(
                label: type.attempts > 1 ? 'E$a' : (type.unit ?? 'Valeur'),
                value: values[a],
                onChanged: (v) => onChanged(a, v),
              ),
            ),
          ),
        if (type.attempts > 1)
          SizedBox(
            width: 64,
            child: Text(best == null ? '—' : formatTestValue(best!),
                textAlign: TextAlign.end, style: theme.textTheme.titleSmall),
          ),
      ]),
    );
  }
}

/// Champ numérique enregistré à chaque frappe valide ; n'est jamais réécrit pendant la saisie.
class _ValueField extends StatefulWidget {
  const _ValueField({required this.label, required this.value, required this.onChanged});

  final String label;
  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  State<_ValueField> createState() => _ValueFieldState();
}

class _ValueFieldState extends State<_ValueField> {
  late final _controller = TextEditingController(text: widget.value == null ? '' : formatTestValue(widget.value!));
  final _focus = FocusNode();
  bool _invalid = false;

  @override
  void didUpdateWidget(_ValueField old) {
    super.didUpdateWidget(old);
    // Valeur reçue d'un autre appareil : seulement si le champ n'est pas en cours de saisie.
    if (!_focus.hasFocus && widget.value != parseTestValue(_controller.text)) {
      _controller.text = widget.value == null ? '' : formatTestValue(widget.value!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        focusNode: _focus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        textInputAction: TextInputAction.next,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          labelText: widget.label,
          errorText: _invalid ? '?' : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        ),
        onChanged: (t) {
          final v = parseTestValue(t);
          setState(() => _invalid = t.trim().isNotEmpty && v == null);
          if (!_invalid) widget.onChanged(v);
        },
      );
}

/// E34 — Ajoute un test propre à l'équipe ; renvoie son id, ou null si annulé.
Future<String?> showAddTestTypeDialog(BuildContext context, WidgetRef ref, String teamId) {
  final name = TextEditingController();
  final unit = TextEditingController();
  var category = 'other';
  var better = 'higher';
  var attempts = 1;
  return showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Nouveau test'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(controller: name, autofocus: true, textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nom du test *')),
            TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unité', hintText: 's, cm, m, kg…')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Famille'),
              items: [for (final e in testCategories.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
              onChanged: (v) => setState(() => category = v!),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              for (final e in testBetter.entries)
                ChoiceChip(label: Text(e.value), selected: better == e.key, onSelected: (_) => setState(() => better = e.key)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Essais'),
              const SizedBox(width: 12),
              SegmentedButton<int>(
                segments: [for (var a = 1; a <= 3; a++) ButtonSegment(value: a, label: Text('$a'))],
                selected: {attempts},
                onSelectionChanged: (s) => setState(() => attempts = s.first),
              ),
            ]),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              final id = await ref.read(testRepositoryProvider).addTestType(
                    teamId: teamId, name: name.text.trim(), unit: unit.text.trim().isEmpty ? null : unit.text.trim(),
                    category: category, better: better, attempts: attempts,
                  );
              if (context.mounted) {
                Navigator.of(context).pop(id);
                showMessage(context, 'Test « ${name.text.trim()} » ajouté');
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    ),
  );
}

/// Onglet « Tests » de la fiche joueur : dernier meilleur résultat par test et évolution.
class PlayerTestsTab extends ConsumerWidget {
  const PlayerTestsTab({super.key, required this.player});

  final Player player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = {for (final t in ref.watch(testTypesProvider(player.teamId)).value ?? const <TestType>[]) t.id: t};
    final results = ref.watch(playerTestResultsProvider(player.id)).value ?? const <TestResult>[];
    final best = bestByTest(results, types);
    final ordered = types.values.where((t) => best.containsKey(t.id)).toList();
    if (ordered.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Aucun test.')));
    }
    final theme = Theme.of(context);
    return ListView(padding: EdgeInsets.zero, children: [
      for (final t in ordered)
        Builder(builder: (context) {
          final h = best[t.id]!;
          final last = h.first;
          final prev = h.length > 1 ? h[1] : null;
          final up = prev == null ? null : t.isBetter(last.value, prev.value);
          final same = prev != null && prev.value == last.value;
          return ExpansionTile(
            title: Text(t.name),
            subtitle: Text(DateFormat('d MMM y', 'fr_FR').format(DateTime.parse(last.date))),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('${formatTestValue(last.value)}${t.unitLabel}', style: theme.textTheme.titleMedium),
              if (prev != null && !same && up != null)
                Icon(up ? Icons.trending_up : Icons.trending_down,
                    color: up ? const Color(0xFF2E7D32) : theme.colorScheme.error),
            ]),
            children: [
              for (final b in h)
                ListTile(
                  dense: true,
                  title: Text(DateFormat('d MMMM y', 'fr_FR').format(DateTime.parse(b.date))),
                  trailing: Text('${formatTestValue(b.value)}${t.unitLabel}'),
                  onTap: () => context.go('/team/tests/${b.date}'),
                ),
            ],
          );
        }),
    ]);
  }
}
