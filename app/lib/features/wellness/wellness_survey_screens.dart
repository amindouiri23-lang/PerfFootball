import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/permissions.dart';
import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../sessions/session_repository.dart' show isoDate;
import '../sessions/wellness_screens.dart' show wellnessTotal;
import '../team/team_filter.dart';
import '../team/team_repository.dart';
import '../team/team_screen.dart' show NoTeamScreen;
import 'wellness_repository.dart';

/// Questionnaires de bien-être lancés seuls : liste, avec le nombre de réponses.
class SurveysScreen extends ConsumerWidget {
  const SurveysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const NoTeamScreen();
    final surveys = ref.watch(surveysProvider(team.id)).value ?? const <WellnessSurvey>[];
    final called = ref.watch(surveyPlayersProvider((teamId: team.id, surveyId: null))).value ?? const <WellnessSurveyPlayer>[];
    final answers = ref.watch(surveyAnswersProvider((teamId: team.id, surveyId: null))).value ?? const <WellnessEntry>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Questionnaires de bien-être'), actions: const [SyncIndicator()], bottom: teamFilterBar(ref)),
      floatingActionButton: !ref.watch(permsProvider).can('bienetre.edit')
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.go('/sessions/wellness/new'),
              icon: const Icon(Icons.add),
              label: const Text('Nouveau questionnaire'),
            ),
      body: surveys.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Aucun questionnaire. Lancez-en un : choisissez les joueurs, ils répondent depuis leur compte.',
                    textAlign: TextAlign.center),
              ),
            )
          : ListView(padding: const EdgeInsets.only(bottom: 88), children: [
              for (final s in surveys)
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: Text(s.label),
                  subtitle: Text('${answers.where((a) => a.surveyId == s.id).length}/'
                      '${called.where((c) => c.surveyId == s.id).length} réponses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/sessions/wellness/${s.id}'),
                ),
            ]),
    );
  }
}

/// Nouveau questionnaire : date, titre facultatif, joueurs appelés à répondre.
class NewSurveyScreen extends ConsumerStatefulWidget {
  const NewSurveyScreen({super.key});

  @override
  ConsumerState<NewSurveyScreen> createState() => _NewSurveyScreenState();
}

class _NewSurveyScreenState extends ConsumerState<NewSurveyScreen> {
  DateTime _date = DateTime.now();
  final _title = TextEditingController();
  Set<String>? _selected;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const NoTeamScreen();
    final players = ref.watch(playersProvider(team.id)).value ?? const <Player>[];
    // Par défaut, toute l'équipe est appelée à répondre.
    final selected = _selected ??= {for (final p in players) p.id};
    final theme = Theme.of(context);
    return FormPage(title: 'Nouveau questionnaire', children: [
      Text(team.name, style: theme.textTheme.titleSmall),
      const SizedBox(height: 12),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_today),
        title: Text(DateFormat('EEEE d MMMM y', 'fr_FR').format(_date)),
        subtitle: const Text('Date du questionnaire'),
        onTap: () async {
          final d = await showDatePicker(context: context, initialDate: _date,
              firstDate: DateTime.now().subtract(const Duration(days: 60)), lastDate: DateTime.now().add(const Duration(days: 60)));
          if (d != null) setState(() => _date = d);
        },
      ),
      TextField(
        controller: _title,
        maxLength: 80,
        decoration: const InputDecoration(labelText: 'Titre (facultatif)', hintText: 'Lendemain de match'),
      ),
      Row(children: [
        Expanded(child: Text('Joueurs appelés à répondre (${selected.length}/${players.length})', style: theme.textTheme.titleSmall)),
        TextButton(
          onPressed: () => setState(() => _selected = selected.length == players.length ? {} : {for (final p in players) p.id}),
          child: Text(selected.length == players.length ? 'Aucun' : 'Tous'),
        ),
      ]),
      for (final p in players)
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: selected.contains(p.id),
          title: Text(p.fullName),
          subtitle: Text(positions[p.position] ?? p.position),
          onChanged: (v) => setState(() => v == true ? selected.add(p.id) : selected.remove(p.id)),
        ),
      const SizedBox(height: 16),
      BusyButton(
        label: 'Lancer le questionnaire',
        busy: _busy,
        onPressed: () async {
          if (selected.isEmpty) {
            showMessage(context, 'Choisissez au moins un joueur.');
            return;
          }
          setState(() => _busy = true);
          final title = _title.text.trim();
          final id = await ref.read(wellnessRepositoryProvider).createSurvey(
                teamId: team.id, date: isoDate(_date), title: title.isEmpty ? null : title, playerIds: selected);
          if (!context.mounted) return;
          showMessage(context, 'Questionnaire lancé : les joueurs le voient dans leur espace.');
          context.go('/sessions/wellness/$id');
        },
      ),
    ]);
  }
}

/// Suivi d'un questionnaire : qui a répondu (score sur 25), qui doit encore répondre.
class SurveyScreen extends ConsumerWidget {
  const SurveyScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(surveyProvider(id)).value;
    if (s == null || s.deleted) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Questionnaire introuvable.')));
    final players = {for (final p in ref.watch(playersProvider(s.teamId)).value ?? const <Player>[]) p.id: p};
    final called = ref.watch(surveyPlayersOfProvider(id)).value ?? const <WellnessSurveyPlayer>[];
    final answers = {for (final w in ref.watch(surveyAnswersOfProvider(id)).value ?? const <WellnessEntry>[]) w.playerId: w};
    final perms = ref.watch(permsProvider);
    final theme = Theme.of(context);
    final todo = called.where((c) => !answers.containsKey(c.playerId)).toList();
    final done = called.where((c) => answers.containsKey(c.playerId)).toList();

    Widget tile(WellnessSurveyPlayer c) {
      final p = players[c.playerId];
      final w = answers[c.playerId];
      return ListTile(
        leading: CircleAvatar(child: Text(p?.initials ?? '?')),
        title: Text(p?.fullName ?? '—'),
        subtitle: w == null ? const Text('En attente de sa réponse') : null,
        trailing: w == null
            ? (perms.can('bienetre.edit') ? const Icon(Icons.edit_outlined) : null)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text('${wellnessTotal(w)}/25'),
              ]),
        // Le staff peut remplir à la place du joueur (joueur sans téléphone, par exemple).
        onTap: perms.can('bienetre.edit') ? () => context.go('/sessions/wellness/$id/${c.playerId}') : null,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.label), actions: [
        if (perms.can('bienetre.edit'))
          PopupMenuButton<String>(
            onSelected: (_) async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer le questionnaire ?'),
                  content: const Text('Les joueurs ne le verront plus. Les réponses déjà données sont conservées.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
                    FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
                  ],
                ),
              );
              if (ok != true) return;
              await ref.read(wellnessRepositoryProvider).deleteSurvey(id);
              if (context.mounted) context.go('/sessions/wellness');
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Supprimer le questionnaire'))],
          ),
      ]),
      body: ListView(children: [
        ListTile(title: Text('${done.length}/${called.length} réponses'),
            subtitle: const Text('Chaque joueur répond depuis son compte (Accueil → Questionnaires de bien-être).')),
        if (todo.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Text('En attente (${todo.length})', style: theme.textTheme.titleSmall)),
          for (final c in todo) tile(c),
        ],
        if (done.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Text('Répondu (${done.length})', style: theme.textTheme.titleSmall)),
          for (final c in done) tile(c),
        ],
      ]),
    );
  }
}
