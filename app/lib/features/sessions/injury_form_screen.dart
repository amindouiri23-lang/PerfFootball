import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import '../../data/database.dart';
import '../matches/match_repository.dart';
import '../team/team_repository.dart';
import 'session_repository.dart';

/// E15 — Déclarer une blessure pendant une séance ([sessionId]), un match ([matchId]) ou hors club
/// (aucun des deux, depuis l'infirmerie : le joueur et la date sont alors demandés).
/// Pour un match, la minute est demandée.
class InjuryFormScreen extends ConsumerStatefulWidget {
  const InjuryFormScreen({super.key, this.sessionId, this.matchId, this.playerId})
      : assert(sessionId == null || matchId == null),
        assert(playerId != null || (sessionId == null && matchId == null));

  final String? sessionId;
  final String? matchId;
  final String? playerId;

  @override
  ConsumerState<InjuryFormScreen> createState() => _InjuryFormScreenState();
}

class _InjuryFormScreenState extends ConsumerState<InjuryFormScreen> {
  /// Un double appui ne doit pas créer deux fois la même fiche (voir le verrou dans _save).
  bool _saving = false;
  final _description = TextEditingController();
  final _minute = TextEditingController();
  String? _area;
  String? _side;
  String? _type;
  String? _mechanism;
  String? _severity;
  DateTime? _expectedReturn;
  bool _submitted = false;
  /// Blessure hors club : joueur et date choisis dans le formulaire.
  late String? _playerId = widget.playerId;
  DateTime _date = DateTime.now();

  bool get _outside => widget.sessionId == null && widget.matchId == null;

  int? get _minuteValue => int.tryParse(_minute.text);
  bool get _minuteValid => widget.matchId == null || _minute.text.isEmpty || (_minuteValue! >= 1 && _minuteValue! <= 130);

  Future<void> _save() async {
    if (_saving) return;
    _saving = true;
    try {
      await _saveUnguarded();
    } finally {
      // Verrou gardé un instant : l'enregistrement local prend quelques millisecondes, la seconde
      // frappe d'un double appui arrive souvent après — elle doit aussi être ignorée.
      Future<void>.delayed(const Duration(milliseconds: 600), () => _saving = false);
    }
  }

  Future<void> _saveUnguarded() async {
    setState(() => _submitted = true);
    if ([_playerId, _area, _type, _mechanism, _severity].contains(null) || !_minuteValid) return;
    final ctx = _context(listen: false)!;
    final player = ref.read(playerProvider(_playerId!)).value;
    final text = _description.text.trim();
    await ref.read(sessionRepositoryProvider).saveInjury(
          teamId: ctx.teamId, playerId: _playerId!, sessionId: widget.sessionId, matchId: widget.matchId,
          minute: widget.matchId == null ? null : _minuteValue, date: ctx.date,
          bodyArea: _area!, side: _side, type: _type!, mechanism: _mechanism!, severity: _severity!,
          description: text.isEmpty ? null : text,
          expectedReturnDate: _expectedReturn == null ? null : isoDate(_expectedReturn!),
        );
    if (!mounted) return;
    showMessage(context, 'Blessure de ${player?.fullName ?? 'ce joueur'} enregistrée');
    context.go(ctx.back);
  }

  /// Séance ou match d'origine : équipe, date, libellé et écran de retour.
  /// [listen] : vrai pendant build (ref.watch), faux dans un rappel (ref.read).
  ({String teamId, String date, DateTime day, String label, String back})? _context({bool listen = true}) {
    if (_outside) {
      final team = (listen ? ref.watch(activeTeamProvider) : ref.read(activeTeamProvider)).value;
      return team == null
          ? null
          : (teamId: team.id, date: isoDate(_date), day: _date, label: 'Hors séance et match', back: '/team/injuries');
    }
    if (widget.sessionId != null) {
      final p = sessionProvider(widget.sessionId!);
      final s = (listen ? ref.watch(p) : ref.read(p)).value;
      return s == null
          ? null
          : (teamId: s.teamId, date: s.date, day: s.day,
              label: 'Séance du ${DateFormat('d/MM', 'fr_FR').format(s.day)} · ${sessionTypes[s.type]}',
              back: '/sessions/${s.id}');
    }
    final p = matchProvider(widget.matchId!);
    final m = (listen ? ref.watch(p) : ref.read(p)).value;
    return m == null
        ? null
        : (teamId: m.teamId, date: m.date, day: m.day, label: 'Match contre ${m.opponent}', back: '/matches/${m.id}');
  }

  @override
  void dispose() {
    _description.dispose();
    _minute.dispose();
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
    final ctx = _context();
    if (ctx == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final player = _playerId == null ? null : ref.watch(playerProvider(_playerId!)).value;
    final theme = Theme.of(context);
    return FormPage(title: 'Déclarer une blessure', children: [
      if (_outside) ...[
        DropdownButtonFormField<String>(
          initialValue: _playerId,
          decoration: InputDecoration(
            labelText: 'Joueur *',
            errorText: _submitted && _playerId == null ? 'Obligatoire' : null,
          ),
          items: [
            for (final p in ref.watch(playersProvider(ctx.teamId)).value ?? const <Player>[])
              DropdownMenuItem(value: p.id, child: Text('${p.shirtNumber ?? ''} ${p.fullName}')),
          ],
          onChanged: (v) => setState(() => _playerId = v),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: _date,
                firstDate: DateTime(2020), lastDate: DateTime.now());
            if (d != null) setState(() => _date = d);
          },
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Date de la blessure *', suffixIcon: Icon(Icons.event)),
            child: Text(DateFormat('d MMMM y', 'fr_FR').format(_date)),
          ),
        ),
        const SizedBox(height: 16),
      ] else
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(child: Text(player?.initials ?? '?')),
          title: Text(player?.fullName ?? ''),
          subtitle: Text(ctx.label, style: theme.textTheme.bodyMedium),
        ),
      const SizedBox(height: 8),
      if (widget.matchId != null) ...[
        TextField(
          controller: _minute,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Minute',
            errorText: _submitted && !_minuteValid ? 'Entre 1 et 130' : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
      _chips('Zone du corps', bodyAreas, _area, (v) => _area = v),
      _chips('Côté', injurySides, _side, (v) => _side = v, required: false),
      _chips('Type', injuryTypes, _type, (v) => _type = v),
      _chips('Circonstance', mechanisms, _mechanism, (v) => _mechanism = v),
      _chips('Gravité estimée', severities, _severity, (v) => _severity = v),
      InkWell(
        onTap: () async {
          final d = await showDatePicker(context: context, initialDate: _expectedReturn ?? ctx.day.add(const Duration(days: 7)),
              firstDate: ctx.day, lastDate: ctx.day.add(const Duration(days: 365)));
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
