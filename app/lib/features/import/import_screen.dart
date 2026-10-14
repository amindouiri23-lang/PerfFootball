import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/form_page.dart';
import '../../data/database.dart';
import '../sessions/session_repository.dart' show isoDate;
import '../team/player_files.dart' show consentBy;
import '../team/team_repository.dart';
import 'import_repository.dart';
import 'importers.dart';
import 'xlsx.dart';

/// E39 — Import d'un fichier Excel du club dans l'équipe active : lecture, rapprochement des noms
/// avec l'effectif (à valider), puis écriture locale et synchronisation.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

enum _Filter { check, create, all }

class _ImportScreenState extends ConsumerState<ImportScreen> {
  String? _fileName;
  ImportPlan? _plan;
  Map<String, NameMapping>? _mapping;
  String? _error;
  bool _busy = false;
  _Filter _filter = _Filter.check;
  DateTime? _testDate;
  bool _withMedical = false;
  String? _consentBy;
  bool _attested = false;

  Future<void> _pick(List<Player> players) async {
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (file == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final plan = parseWorkbook(readXlsx(await file.readAsBytes()));
      setState(() {
        _fileName = file.name;
        _plan = plan;
        _mapping = plan == null ? null : matchNames(plan, players);
        _error = plan == null ? 'Format non reconnu. Fichiers acceptés : suivi d\'entraînement, temps de jeu, '
            'tests physiques, fiches de renseignements.' : null;
        _filter = _Filter.check;
      });
    } catch (e) {
      setState(() => _error = 'Fichier illisible : $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _import(Team team) async {
    final plan = _plan!;
    if (plan.kind == ImportKind.tests && _testDate == null) {
      setState(() => _error = 'Indiquez la date des tests.');
      return;
    }
    if (_withMedical && (_consentBy == null || !_attested)) {
      setState(() => _error = 'Le consentement est obligatoire pour importer les données de santé.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final summary = await ref.read(importRepositoryProvider).apply(
            plan,
            _mapping!,
            teamId: team.id,
            testDate: _testDate == null ? null : isoDate(_testDate!),
            consent: _withMedical ? (by: _consentBy!, date: isoDate(DateTime.now())) : null,
          );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import terminé'),
          content: Text('$summary.\n\nLes données sont enregistrées sur l\'appareil et seront synchronisées.'),
          actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );
      if (mounted) context.go('/team');
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final players = ref.watch(playersProvider(team.id)).value ?? const <Player>[];
    final theme = Theme.of(context);
    final plan = _plan;
    final mapping = _mapping;

    return FormPage(title: 'Importer un fichier Excel', children: [
      Text('Équipe : ${team.name} (${team.season})', style: theme.textTheme.titleSmall),
      const SizedBox(height: 4),
      const Text('Les données sont ajoutées à l\'équipe active. Pour une autre équipe, changez d\'équipe dans « Mon équipe ».'),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: _busy ? null : () => _pick(players),
        icon: const Icon(Icons.upload_file),
        label: Text(_fileName ?? 'Choisir un fichier .xlsx'),
      ),
      if (_busy) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ),
      if (plan != null && mapping != null) ...[
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(importKindLabels[plan.kind]!),
            subtitle: Text([
              plan.description,
              if (plan.sessions.isNotEmpty)
                '${plan.sessions.length} séance(s) du ${_short(plan.sessions.first.date)} au ${_short(plan.sessions.last.date)}',
              if (plan.matches.isNotEmpty) '${plan.matches.length} match(s)',
              if (plan.tests.isNotEmpty) '${plan.tests.length} joueur(s) testé(s)',
              if (plan.profiles.isNotEmpty) '${plan.profiles.length} fiche(s)',
            ].join('\n')),
          ),
        ),
        if (plan.warnings.isNotEmpty)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline, color: theme.colorScheme.tertiary),
            title: Text('${plan.warnings.length} remarque(s) sur le fichier'),
            children: [for (final w in plan.warnings) ListTile(dense: true, title: Text(w))],
          ),
        if (plan.kind == ImportKind.tests) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _testDate ?? DateTime.now(),
                  firstDate: DateTime(2020), lastDate: DateTime.now(), helpText: 'Date des tests');
              if (d != null) setState(() => _testDate = d);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date des tests *', suffixIcon: Icon(Icons.calendar_today)),
              child: Text(_testDate == null ? 'Le fichier ne la contient pas : à indiquer'
                  : DateFormat('d MMMM y', 'fr_FR').format(_testDate!)),
            ),
          ),
        ],
        if (plan.kind == ImportKind.profiles) _medicalConsent(theme),
        const SizedBox(height: 16),
        _names(theme, mapping, players),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : () => _import(team),
          child: Text('Importer (${mapping.values.where((m) => !m.ignore).length} joueurs)'),
        ),
      ],
    ]);
  }

  static String _short(String date) => DateFormat('d MMM', 'fr_FR').format(DateTime.parse(date));

  Widget _medicalConsent(ThemeData theme) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _withMedical,
              onChanged: (v) => setState(() => _withMedical = v),
              title: const Text('Importer aussi les réponses médicales'),
              subtitle: const Text('Allergies, maladies, opérations, blessures récentes : visibles du seul responsable.'),
            ),
            if (_withMedical) ...[
              Wrap(spacing: 8, children: [
                for (final e in consentBy.entries)
                  ChoiceChip(label: Text(e.value), selected: _consentBy == e.key, onSelected: (_) => setState(() => _consentBy = e.key)),
              ]),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _attested,
                onChanged: (v) => setState(() => _attested = v ?? false),
                title: const Text('J\'atteste que chaque joueur (ou son parent s\'il est mineur) a consenti à ce suivi médical'),
              ),
            ],
          ]),
        ),
      );

  Widget _names(ThemeData theme, Map<String, NameMapping> mapping, List<Player> players) {
    final byId = {for (final p in players) p.id: p};
    // Nom proche (ressemblance entre 0,75 et 1) ; un joueur créé par l'import n'est pas « à vérifier ».
    bool toCheck(NameMapping m) => m.playerId != null && m.confidence > 0 && m.confidence < 1 && !m.ignore;
    final check = mapping.values.where(toCheck).length;
    final create = mapping.values.where((m) => m.create).length;
    final shown = mapping.entries.where((e) => switch (_filter) {
          _Filter.check => toCheck(e.value),
          _Filter.create => e.value.create,
          _Filter.all => true,
        });
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Joueurs du fichier', style: theme.textTheme.titleSmall),
      const SizedBox(height: 4),
      Text('${mapping.length - check - create} reconnu(s) · $check nom(s) proche(s) à vérifier · $create nouveau(x)'),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        ChoiceChip(label: Text('À vérifier ($check)'), selected: _filter == _Filter.check, onSelected: (_) => setState(() => _filter = _Filter.check)),
        ChoiceChip(label: Text('Nouveaux ($create)'), selected: _filter == _Filter.create, onSelected: (_) => setState(() => _filter = _Filter.create)),
        ChoiceChip(label: Text('Tous (${mapping.length})'), selected: _filter == _Filter.all, onSelected: (_) => setState(() => _filter = _Filter.all)),
      ]),
      for (final e in shown)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            e.value.ignore
                ? Icons.block
                : e.value.create
                    ? Icons.person_add_alt
                    : toCheck(e.value)
                        ? Icons.help_outline
                        : Icons.check_circle_outline,
            color: toCheck(e.value) ? theme.colorScheme.tertiary : null,
          ),
          title: Text('${e.value.imported.name}${e.value.imported.positionText != null ? ' · ${e.value.imported.positionText}' : ''}'),
          subtitle: Text(e.value.ignore
              ? 'Ignoré'
              : e.value.create
                  ? 'Nouveau joueur : ${e.value.first} ${e.value.last} · ${detailedPositions[e.value.detailed] ?? positions[e.value.group]}'
                  : '→ ${byId[e.value.playerId]?.fullName ?? '?'}'),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () => _edit(e.value, players),
        ),
      if (shown.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('Rien à vérifier ici.')),
    ]);
  }

  /// Choix pour un nom : un joueur de l'effectif (les plus proches d'abord), un nouveau joueur, ou ignorer.
  Future<void> _edit(NameMapping m, List<Player> players) async {
    final key = normalizeName(m.imported.name);
    final sorted = [...players]..sort((a, b) =>
        nameSimilarity(normalizeName(b.fullName), key).compareTo(nameSimilarity(normalizeName(a.fullName), key)));
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scroll) => ListView(controller: scroll, children: [
          ListTile(title: Text(m.imported.name, style: Theme.of(context).textTheme.titleMedium)),
          ListTile(leading: const Icon(Icons.person_add_alt), title: const Text('Créer un nouveau joueur'),
              onTap: () => Navigator.of(context).pop('#create')),
          ListTile(leading: const Icon(Icons.block), title: const Text('Ignorer ce nom'),
              onTap: () => Navigator.of(context).pop('#ignore')),
          const Divider(),
          for (final p in sorted)
            ListTile(
              leading: Icon(p.id == m.playerId ? Icons.radio_button_checked : Icons.radio_button_off),
              title: Text(p.fullName),
              subtitle: Text(p.positionLabel),
              onTap: () => Navigator.of(context).pop(p.id),
            ),
        ]),
      ),
    );
    if (choice == null) return;
    if (choice == '#create') {
      if (await _editNewPlayer(m) != true) return;
    }
    setState(() {
      m.ignore = choice == '#ignore';
      m.playerId = choice.startsWith('#') ? null : choice;
    });
  }

  /// Nom et poste du joueur à créer (la découpe nom / prénom du fichier est une supposition).
  Future<bool?> _editNewPlayer(NameMapping m) {
    final first = TextEditingController(text: m.first);
    final last = TextEditingController(text: m.last);
    var group = m.group;
    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Nouveau joueur'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: first, decoration: const InputDecoration(labelText: 'Prénom')),
            TextField(controller: last, decoration: const InputDecoration(labelText: 'Nom')),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              for (final e in positions.entries)
                ChoiceChip(label: Text(e.value), selected: group == e.key, onSelected: (_) => setDialog(() => group = e.key)),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
            FilledButton(
              onPressed: () {
                if (first.text.trim().isEmpty || last.text.trim().isEmpty) return;
                m.first = first.text.trim();
                m.last = last.text.trim();
                if (group != m.group) {
                  m.group = group;
                  if (positionGroup[m.detailed] != group) m.detailed = null;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
