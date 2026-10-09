import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/photos.dart';
import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import 'team_repository.dart';

/// E06 — Créer / modifier mon équipe. [editActive] : modifie l'équipe active au lieu d'en créer une.
class TeamFormScreen extends ConsumerStatefulWidget {
  const TeamFormScreen({super.key, this.editActive = false});

  final bool editActive;

  @override
  ConsumerState<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends ConsumerState<TeamFormScreen> {
  /// Un double appui ne doit pas créer deux fois la même fiche (voir le verrou dans _save).
  bool _saving = false;
  final _form = GlobalKey<FormState>();
  late final _team = widget.editActive ? ref.read(activeTeamProvider).value : null;
  late final _name = TextEditingController(text: _team?.name);
  late final _club = TextEditingController(text: _team?.clubName);
  late String _category = _team?.category ?? 'seniors';
  late String _season = _team?.season ?? currentSeason();

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
    if (!_form.currentState!.validate()) return;
    final repo = ref.read(teamRepositoryProvider);
    final club = _club.text.trim().isEmpty ? null : _club.text.trim();
    if (_team == null) {
      await repo.createTeam(name: _name.text.trim(), clubName: club, category: _category, season: _season);
    } else {
      await repo.updateTeam(_team.id, name: _name.text.trim(), clubName: club, category: _category, season: _season);
    }
    if (!mounted) return;
    showMessage(context, _team == null ? 'Équipe créée' : 'Équipe modifiée');
    context.go('/team');
  }

  @override
  void dispose() {
    _name.dispose();
    _club.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seasons = {...seasonChoices(), _season}.toList()..sort();
    return Form(
      key: _form,
      child: FormPage(title: _team == null ? 'Créer mon équipe' : 'Modifier l\'équipe', children: [
        if (_team == null) ...[
          const Text('Créez l\'équipe que vous suivez : vous pourrez ensuite ajouter vos joueurs.'),
          const SizedBox(height: 24),
        ] else ...[
          // Logo : l'équipe doit exister (son id sert de dossier dans le stockage).
          Center(
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () async {
                final path = await pickAndUploadPhoto(context, ref, 'teams/${_team.id}/logo.jpg');
                if (path != null) await ref.read(teamRepositoryProvider).setTeamLogo(_team.id, path);
              },
              child: Column(children: [
                PhotoAvatar(
                  path: ref.watch(teamsProvider).value?.where((t) => t.id == _team.id).firstOrNull?.logoPath,
                  initials: _team.name.substring(0, 1).toUpperCase(),
                  radius: 36,
                ),
                const SizedBox(height: 4),
                const Text('Changer le logo'),
              ]),
            ),
          ),
          const SizedBox(height: 24),
        ],
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nom de l\'équipe *', hintText: 'Ex. Seniors A'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(controller: _club, decoration: const InputDecoration(labelText: 'Club')),
        const SizedBox(height: 16),
        Text('Catégorie *', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in categories.entries)
            ChoiceChip(label: Text(e.value), selected: _category == e.key, onSelected: (_) => setState(() => _category = e.key)),
        ]),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _season,
          decoration: const InputDecoration(labelText: 'Saison *'),
          items: [for (final s in seasons) DropdownMenuItem(value: s, child: Text(s))],
          onChanged: (v) => setState(() => _season = v!),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: _save, child: Text(_team == null ? 'Créer l\'équipe' : 'Enregistrer')),
      ]),
    );
  }
}
