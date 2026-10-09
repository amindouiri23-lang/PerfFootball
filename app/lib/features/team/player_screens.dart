import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import '../../data/database.dart';
import 'team_repository.dart';
import 'team_screen.dart';

/// E08 — Fiche joueur. Les onglets d'historique (séances, matchs, blessures, bien-être)
/// arrivent avec leurs modules.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider(id));
    return player.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (p) {
        if (p == null || p.deleted) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Joueur introuvable.')),
          );
        }
        final theme = Theme.of(context);
        final details = [
          positions[p.position],
          if (p.age != null) '${p.age} ans',
          if (p.dominantFoot != null) 'Pied ${feet[p.dominantFoot]!.toLowerCase()}',
          if (p.heightCm != null) '${p.heightCm} cm',
        ].join(' · ');
        return Scaffold(
          appBar: AppBar(
            title: const Text('Fiche joueur'),
            actions: [
              IconButton(
                tooltip: 'Modifier',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.go('/team/players/$id/edit'),
              ),
              PopupMenuButton<String>(
                onSelected: (_) async {
                  if (await confirmDeletePlayer(context, ref, p) && context.mounted) context.go('/team');
                },
                itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Supprimer le joueur'))],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 36, child: Text(p.initials, style: theme.textTheme.headlineSmall)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p.shirtNumber != null ? '#${p.shirtNumber} ' : ''}${p.fullName}',
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(details),
                        if (p.birthDate != null)
                          Text(
                            'Né le ${DateFormat('d MMMM y', 'fr_FR').format(DateTime.parse(p.birthDate!))}',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'L\'historique du joueur (séances, matchs, blessures, bien-être) '
                    'apparaîtra ici avec les modules Séances et Matchs.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// E09 — Ajouter / modifier un joueur.
class PlayerFormScreen extends ConsumerStatefulWidget {
  const PlayerFormScreen({super.key, this.id});

  /// null : création.
  final String? id;

  @override
  ConsumerState<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends ConsumerState<PlayerFormScreen> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _number = TextEditingController();
  final _height = TextEditingController();
  String? _position;
  String? _foot;
  DateTime? _birth;
  bool _dirty = false;
  /// Après un premier essai d'enregistrement, les erreurs se mettent à jour pendant la saisie.
  bool _submitted = false;
  bool _loaded = false;

  void _load(Player? p) {
    if (_loaded) return;
    _loaded = true;
    if (p == null) return;
    _first.text = p.firstName;
    _last.text = p.lastName;
    _number.text = p.shirtNumber?.toString() ?? '';
    _height.text = p.heightCm?.toString() ?? '';
    _position = p.position;
    _foot = p.dominantFoot;
    _birth = p.birthDate == null ? null : DateTime.parse(p.birthDate!);
  }

  void _changed() => _dirty = true;

  void _reset() {
    _first.clear();
    _last.clear();
    _number.clear();
    _height.clear();
    setState(() {
      _position = null;
      _foot = null;
      _birth = null;
      _dirty = false;
      _submitted = false;
    });
  }

  Future<void> _save({required bool another}) async {
    setState(() => _submitted = true);
    if (!_form.currentState!.validate()) return;
    final team = ref.read(activeTeamProvider).value!;
    await ref
        .read(teamRepositoryProvider)
        .savePlayer(
          id: widget.id,
          teamId: team.id,
          firstName: _first.text.trim(),
          lastName: _last.text.trim(),
          shirtNumber: int.tryParse(_number.text),
          position: _position!,
          birthDate: _birth == null ? null : DateFormat('yyyy-MM-dd').format(_birth!),
          dominantFoot: _foot,
          heightCm: int.tryParse(_height.text),
        );
    if (!mounted) return;
    showMessage(context, '${_first.text.trim()} ${_last.text.trim()} enregistré');
    if (another) {
      _reset();
    } else {
      _dirty = false;
      context.go(widget.id == null ? '/team' : '/team/players/${widget.id}');
    }
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(now.year - 20),
      firstDate: DateTime(now.year - 60),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (d == null) return;
    setState(() {
      _birth = d;
      _dirty = true;
    });
  }

  Future<bool> _confirmLeave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonner les modifications ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Continuer la saisie')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Abandonner')),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _number.dispose();
    _height.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null;

  String? _range(String? v, int min, int max) {
    if (v == null || v.isEmpty) return null;
    final n = int.tryParse(v);
    return (n == null || n < min || n > max) ? 'Entre $min et $max' : null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id != null) {
      final player = ref.watch(playerProvider(widget.id!));
      if (player.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      _load(player.value);
    }
    final team = ref.watch(activeTeamProvider).value;
    final players = team == null ? const <Player>[] : ref.watch(playersProvider(team.id)).value ?? const [];
    final number = int.tryParse(_number.text);
    final sameNumber = players.where((p) => p.shirtNumber == number && p.id != widget.id).firstOrNull;
    final create = widget.id == null;
    final digits = [FilteringTextInputFormatter.digitsOnly];

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && await _confirmLeave() && context.mounted) {
          _dirty = false;
          context.pop();
        }
      },
      child: Form(
        key: _form,
        autovalidateMode: _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
        onChanged: _changed,
        child: FormPage(
          title: create ? 'Ajouter un joueur' : 'Modifier le joueur',
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _first,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Prénom *'),
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _last,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _number,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    decoration: const InputDecoration(labelText: 'N° de maillot'),
                    validator: (v) => _range(v, 1, 99),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _height,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    decoration: const InputDecoration(labelText: 'Taille (cm)'),
                    validator: (v) => _range(v, 140, 220),
                  ),
                ),
              ],
            ),
            if (sameNumber != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Le numéro $number est déjà porté par ${sameNumber.fullName}.',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
            const SizedBox(height: 16),
            FormField<String>(
              initialValue: _position,
              validator: (_) => _position == null ? 'Obligatoire' : null,
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Poste *', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in positions.entries)
                        ChoiceChip(
                          label: Text(e.value),
                          selected: _position == e.key,
                          onSelected: (_) => setState(() {
                            _position = e.key;
                            _dirty = true;
                          }),
                        ),
                    ],
                  ),
                  if (field.hasError)
                    Text(field.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Pied fort', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final e in feet.entries)
                  ChoiceChip(
                    label: Text(e.value),
                    selected: _foot == e.key,
                    onSelected: (s) => setState(() {
                      _foot = s ? e.key : null;
                      _dirty = true;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickBirth,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de naissance',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _birth == null
                      ? ''
                      : '${DateFormat('dd/MM/yyyy').format(_birth!)} (${DateTime.now().difference(_birth!).inDays ~/ 365} ans)',
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => _save(another: false), child: const Text('Enregistrer')),
            if (create) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _save(another: true),
                child: const Text('Enregistrer et ajouter un autre'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
