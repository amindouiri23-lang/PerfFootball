import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import '../../core/widgets/steppers.dart';
import '../../data/database.dart';
import '../sessions/session_repository.dart' show isoDate;
import '../team/team_repository.dart';
import 'match_repository.dart';

/// E21 — Nouveau match ou modification de ses informations ([id] non null).
class MatchFormScreen extends ConsumerStatefulWidget {
  const MatchFormScreen({super.key, this.id});

  final String? id;

  @override
  ConsumerState<MatchFormScreen> createState() => _MatchFormScreenState();
}

class _MatchFormScreenState extends ConsumerState<MatchFormScreen> {
  final _opponent = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 15, minute: 0);
  String? _homeAway;
  String? _competition;
  int _duration = 90;
  bool _loaded = false;
  bool _submitted = false;

  void _load(FootballMatch? m) {
    if (_loaded || m == null) return;
    _loaded = true;
    _date = m.day;
    _time = TimeOfDay(hour: int.parse(m.kickOffTime.substring(0, 2)), minute: int.parse(m.kickOffTime.substring(3, 5)));
    _opponent.text = m.opponent;
    _homeAway = m.homeAway;
    _competition = m.competition;
    _duration = m.durationMin;
  }

  Future<void> _save({required bool squad}) async {
    setState(() => _submitted = true);
    if (_opponent.text.trim().isEmpty || _homeAway == null || _competition == null) return;
    final team = ref.read(activeTeamProvider).value!;
    final time = '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}:00';
    final id = await ref.read(matchRepositoryProvider).saveMatch(
          id: widget.id, teamId: team.id, date: isoDate(_date), kickOffTime: time, opponent: _opponent.text.trim(),
          homeAway: _homeAway!, competition: _competition!, durationMin: _duration,
        );
    if (!mounted) return;
    if (widget.id != null) {
      showMessage(context, 'Match modifié');
      context.go('/matches/$id');
    } else if (squad) {
      context.go('/matches/$id/squad');
    } else {
      showMessage(context, 'Match enregistré');
      context.go('/matches');
    }
  }

  @override
  void dispose() {
    _opponent.dispose();
    super.dispose();
  }

  Widget _chips(String label, Map<String, String> values, String? selected, ValueChanged<String> onSelected) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label *', style: theme.textTheme.labelLarge),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final e in values.entries)
          ChoiceChip(label: Text(e.value), selected: selected == e.key, onSelected: (_) => setState(() => onSelected(e.key))),
      ]),
      if (_submitted && selected == null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Obligatoire', style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
        ),
      const SizedBox(height: 16),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id != null) {
      final m = ref.watch(matchProvider(widget.id!));
      if (m.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      _load(m.value);
    }
    final team = ref.watch(activeTeamProvider).value;
    // Suggestions : adversaires déjà saisis.
    final opponents = team == null
        ? const <String>[]
        : {for (final m in ref.watch(matchesProvider(team.id)).value ?? const <FootballMatch>[]) m.opponent}.toList();
    final create = widget.id == null;

    return FormPage(title: create ? 'Nouveau match' : 'Modifier le match', children: [
      Row(children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _date,
                  firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => _date = d);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date *', suffixIcon: Icon(Icons.calendar_today)),
              child: Text(DateFormat('EEE d MMM y', 'fr_FR').format(_date)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _time);
              if (t != null) setState(() => _time = t);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Coup d\'envoi *', suffixIcon: Icon(Icons.schedule)),
              child: Text(_time.format(context)),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      Autocomplete<String>(
        initialValue: TextEditingValue(text: _opponent.text),
        optionsBuilder: (v) => v.text.isEmpty
            ? const Iterable<String>.empty()
            : opponents.where((o) => o.toLowerCase().contains(v.text.toLowerCase())),
        onSelected: (v) => _opponent.text = v,
        fieldViewBuilder: (context, controller, focus, onSubmit) => TextField(
          controller: controller,
          focusNode: focus,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => _opponent.text = v,
          decoration: InputDecoration(
            labelText: 'Adversaire *',
            errorText: _submitted && _opponent.text.trim().isEmpty ? 'Obligatoire' : null,
          ),
        ),
      ),
      const SizedBox(height: 16),
      _chips('Lieu', homeAwayLabels, _homeAway, (v) => _homeAway = v),
      _chips('Compétition', competitions, _competition, (v) => _competition = v),
      Text('Durée du match *', style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: MinutesStepper(value: _duration, min: 20, max: 130, onChanged: (v) => setState(() => _duration = v)),
      ),
      const SizedBox(height: 24),
      if (create) ...[
        FilledButton(onPressed: () => _save(squad: true), child: const Text('Choisir les joueurs présents')),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () => _save(squad: false), child: const Text('Enregistrer pour plus tard')),
      ] else
        FilledButton(onPressed: () => _save(squad: false), child: const Text('Enregistrer')),
    ]);
  }
}
