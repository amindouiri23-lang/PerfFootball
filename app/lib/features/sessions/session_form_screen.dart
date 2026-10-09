import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import '../../core/widgets/steppers.dart';
import '../../data/database.dart';
import '../team/team_repository.dart';
import 'session_repository.dart';

/// E12 — Nouvelle séance (étape 1 sur 3) ou modification de ses informations ([id] non null).
class SessionFormScreen extends ConsumerStatefulWidget {
  const SessionFormScreen({super.key, this.id});

  final String? id;

  @override
  ConsumerState<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends ConsumerState<SessionFormScreen> {
  final _objective = TextEditingController();
  late DateTime _date = DateTime.now();
  late TimeOfDay _time = _nextQuarter();
  String? _type;
  int _duration = 90;
  bool _loaded = false;
  bool _typeMissing = false;

  static TimeOfDay _nextQuarter() {
    final now = DateTime.now().add(const Duration(minutes: 15));
    return TimeOfDay(hour: now.hour, minute: now.minute - now.minute % 15);
  }

  void _load(TrainingSession? s) {
    if (_loaded || s == null) return;
    _loaded = true;
    _date = s.day;
    _time = TimeOfDay(hour: int.parse(s.startTime.substring(0, 2)), minute: int.parse(s.startTime.substring(3, 5)));
    _type = s.type;
    _duration = s.plannedDurationMin;
    _objective.text = s.objective ?? '';
  }

  String get _timeValue => '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}:00';

  Future<void> _save({required bool startCall}) async {
    if (_type == null) {
      setState(() => _typeMissing = true);
      return;
    }
    final team = ref.read(activeTeamProvider).value!;
    final date = isoDate(_date);
    final clash = (ref.read(sessionsProvider(team.id)).value ?? const <TrainingSession>[])
        .any((s) => s.id != widget.id && s.date == date && s.startTime == _timeValue);
    if (clash) {
      final go = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Séance en double ?'),
          content: Text('Une séance existe déjà le ${DateFormat('d MMMM', 'fr_FR').format(_date)} à ${_timeValue.substring(0, 5)}. Continuer ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Continuer')),
          ],
        ),
      );
      if (go != true) return;
    }
    final objective = _objective.text.trim();
    final id = await ref.read(sessionRepositoryProvider).saveSession(
          id: widget.id, teamId: team.id, date: date, startTime: _timeValue, type: _type!,
          plannedDurationMin: _duration, objective: objective.isEmpty ? null : objective,
        );
    if (!mounted) return;
    if (widget.id != null) {
      showMessage(context, 'Séance modifiée');
      context.go('/sessions/$id');
    } else if (startCall) {
      context.go('/sessions/$id/attendance');
    } else {
      showMessage(context, 'Séance enregistrée');
      context.go('/sessions');
    }
  }

  @override
  void dispose() {
    _objective.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id != null) {
      final s = ref.watch(sessionProvider(widget.id!));
      if (s.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      _load(s.value);
    }
    final theme = Theme.of(context);
    final create = widget.id == null;
    return FormPage(title: create ? 'Nouvelle séance' : 'Modifier la séance', children: [
      if (create) Text('Étape 1 sur 3 — informations', style: theme.textTheme.labelLarge),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(
          child: _PickerField(
            label: 'Date *',
            icon: Icons.calendar_today,
            value: DateFormat('EEE d MMM y', 'fr_FR').format(_date),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _date,
                  firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => _date = d);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PickerField(
            label: 'Heure *',
            icon: Icons.schedule,
            value: _time.format(context),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _time);
              if (t != null) setState(() => _time = t);
            },
          ),
        ),
      ]),
      const SizedBox(height: 16),
      Text('Type de séance *', style: theme.textTheme.labelLarge),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final e in sessionTypes.entries)
          ChoiceChip(
            label: Text(e.value),
            selected: _type == e.key,
            onSelected: (_) => setState(() {
              _type = e.key;
              _typeMissing = false;
            }),
          ),
      ]),
      if (_typeMissing)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Obligatoire', style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
        ),
      const SizedBox(height: 16),
      Text('Durée prévue *', style: theme.textTheme.labelLarge),
      const SizedBox(height: 8),
      MinutesStepper(value: _duration, min: 10, max: 240, onChanged: (v) => setState(() => _duration = v)),
      const SizedBox(height: 16),
      TextField(
        controller: _objective,
        decoration: const InputDecoration(labelText: 'Objectif', hintText: 'Ex. Travail de pressing haut'),
      ),
      const SizedBox(height: 24),
      if (create) ...[
        FilledButton(onPressed: () => _save(startCall: true), child: const Text('Démarrer l\'appel')),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () => _save(startCall: false), child: const Text('Enregistrer pour plus tard')),
      ] else
        FilledButton(onPressed: () => _save(startCall: false), child: const Text('Enregistrer')),
    ]);
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({required this.label, required this.icon, required this.value, required this.onTap});

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(labelText: label, suffixIcon: Icon(icon)),
          child: Text(value),
        ),
      );
}
