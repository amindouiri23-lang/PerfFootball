import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import '../team/team_repository.dart';
import 'session_repository.dart';

/// E15 — Déclarer une blessure pendant une séance. Le joueur et le contexte sont pré-remplis.
class InjuryFormScreen extends ConsumerStatefulWidget {
  const InjuryFormScreen({super.key, required this.sessionId, required this.playerId});

  final String sessionId;
  final String playerId;

  @override
  ConsumerState<InjuryFormScreen> createState() => _InjuryFormScreenState();
}

class _InjuryFormScreenState extends ConsumerState<InjuryFormScreen> {
  final _description = TextEditingController();
  String? _area;
  String? _side;
  String? _type;
  String? _mechanism;
  String? _severity;
  DateTime? _expectedReturn;
  bool _submitted = false;

  Future<void> _save() async {
    setState(() => _submitted = true);
    if ([_area, _type, _mechanism, _severity].contains(null)) return;
    final s = ref.read(sessionProvider(widget.sessionId)).value!;
    final player = ref.read(playerProvider(widget.playerId)).value;
    final text = _description.text.trim();
    await ref.read(sessionRepositoryProvider).saveInjury(
          teamId: s.teamId, playerId: widget.playerId, sessionId: s.id, date: s.date,
          bodyArea: _area!, side: _side, type: _type!, mechanism: _mechanism!, severity: _severity!,
          description: text.isEmpty ? null : text,
          expectedReturnDate: _expectedReturn == null ? null : isoDate(_expectedReturn!),
        );
    if (!mounted) return;
    showMessage(context, 'Blessure de ${player?.fullName ?? 'ce joueur'} enregistrée');
    context.go('/sessions/${s.id}');
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Widget _chips(String label, Map<String, String> values, String? selected, ValueChanged<String?> onSelected,
      {bool required = true}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label${required ? ' *' : ''}', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final e in values.entries)
            ChoiceChip(
              label: Text(e.value),
              selected: selected == e.key,
              onSelected: (s) => setState(() => onSelected(s ? e.key : null)),
            ),
        ]),
        if (required && _submitted && selected == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Obligatoire', style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider(widget.sessionId)).value;
    final player = ref.watch(playerProvider(widget.playerId)).value;
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return FormPage(title: 'Déclarer une blessure', children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Text(player?.initials ?? '?')),
        title: Text(player?.fullName ?? ''),
        subtitle: Text('Séance du ${DateFormat('d/MM', 'fr_FR').format(s.day)} · ${sessionTypes[s.type]}'),
      ),
      const SizedBox(height: 8),
      _chips('Zone du corps', bodyAreas, _area, (v) => _area = v),
      _chips('Côté', injurySides, _side, (v) => _side = v, required: false),
      _chips('Type', injuryTypes, _type, (v) => _type = v),
      _chips('Circonstance', mechanisms, _mechanism, (v) => _mechanism = v),
      _chips('Gravité estimée', severities, _severity, (v) => _severity = v),
      InkWell(
        onTap: () async {
          final d = await showDatePicker(context: context, initialDate: _expectedReturn ?? s.day.add(const Duration(days: 7)),
              firstDate: s.day, lastDate: s.day.add(const Duration(days: 365)));
          if (d != null) setState(() => _expectedReturn = d);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Date de retour prévue', suffixIcon: Icon(Icons.event)),
          child: Text(_expectedReturn == null ? '' : DateFormat('d MMMM y', 'fr_FR').format(_expectedReturn!)),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _description,
        maxLines: 3,
        maxLength: 1000,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Description', hintText: 'Ex. Douleur en fin de sprint'),
      ),
      const SizedBox(height: 8),
      FilledButton(onPressed: _save, child: const Text('Enregistrer')),
    ]);
  }
}
