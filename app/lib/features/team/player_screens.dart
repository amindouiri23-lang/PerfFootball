import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import '../../data/database.dart';
import 'team_repository.dart';
import '../../core/photos.dart';
import '../../core/widgets/injured_badge.dart';
import '../matches/match_repository.dart';
import '../matches/matches_list_screen.dart' show ScoreChip;
import '../sessions/session_repository.dart';
import '../sessions/wellness_screens.dart' show wellnessTotal;
import 'player_history.dart';
import 'team_screen.dart';

/// E08 — Fiche joueur : identité (photo modifiable), statistiques de la saison et historique.
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
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Joueur introuvable.')));
        }
        final theme = Theme.of(context);
        final sessions = ref.watch(playerSessionsProvider(id)).value ?? const <SessionLine>[];
        final matches = ref.watch(playerMatchesProvider(id)).value ?? const <MatchLine>[];
        final events = ref.watch(playerEventsProvider(id)).value ?? const <MatchEvent>[];
        final injuries = ref.watch(playerInjuriesProvider(id)).value ?? const <Injury>[];
        final wellness = ref.watch(playerWellnessProvider(id)).value ?? const <WellnessLine>[];
        final stats = PlayerStats(sessions, matches, events, id);
        final openInjury = injuries.where((i) => i.returnDate == null).firstOrNull;
        final details = [
          positions[p.position],
          if (p.age != null) '${p.age} ans',
          if (p.dominantFoot != null) 'Pied ${feet[p.dominantFoot]!.toLowerCase()}',
          if (p.heightCm != null) '${p.heightCm} cm',
        ].join(' · ');

        Widget stat(String value, String label) => Expanded(
              child: Column(children: [
                Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
              ]),
            );

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(title: const Text('Fiche joueur'), actions: [
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
            ]),
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () async {
                            final path = await pickAndUploadPhoto(context, ref, 'teams/${p.teamId}/players/${p.id}.jpg');
                            if (path != null) await ref.read(teamRepositoryProvider).setPlayerPhoto(p.id, path);
                          },
                          child: Stack(children: [
                            PhotoAvatar(path: p.photoPath, initials: p.initials, radius: 36),
                            const Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(radius: 11, child: Icon(Icons.photo_camera, size: 13)),
                            ),
                          ]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${p.shirtNumber != null ? '#${p.shirtNumber} ' : ''}${p.fullName}',
                                style: theme.textTheme.titleLarge),
                            Text(details),
                            if (openInjury != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                                  const InjuredBadge(),
                                  Text(injuryLabel(openInjury), style: theme.textTheme.bodySmall),
                                ]),
                              ),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(children: [
                            stat(stats.attendance == null ? '—' : '${stats.attendance} %',
                                'Présence\n${stats.sessionsPresent}/${stats.sessionsHeld}'),
                            stat('${stats.matchesPlayed}', 'Matchs\njoués'),
                            stat('${stats.minutes}', 'Minutes'),
                            stat('${stats.goals} / ${stats.assists}', 'Buts /\npasses'),
                            stat('${stats.yellows} / ${stats.reds}', 'Cartons\nJ / R'),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: TabBar(tabs: [
                    Tab(text: 'Séances'),
                    Tab(text: 'Matchs'),
                    Tab(text: 'Blessures'),
                    Tab(text: 'Bien-être'),
                  ]),
                ),
              ],
              body: TabBarView(children: [
                _list(sessions.isEmpty ? 'Aucune séance.' : null, [
                  for (final l in sessions)
                    ListTile(
                      title: Text('${l.session.dayLabel} · ${sessionTypes[l.session.type]}'),
                      subtitle: Text(l.row.present
                          ? [
                              'Présent',
                              if (l.row.durationMin != null) '${l.row.durationMin} min',
                              if (l.row.rpe != null) 'RPE ${l.row.rpe}',
                              if (l.row.remark != null) 'Remarque : ${l.row.remark}',
                            ].join(' · ')
                          : 'Absent — ${absenceReasons[l.row.absenceReason] ?? 'sans motif'}'),
                      onTap: () => context.go('/sessions/${l.session.id}'),
                    ),
                ]),
                _list(matches.isEmpty ? 'Aucun match.' : null, [
                  for (final l in matches)
                    ListTile(
                      title: Text('${l.match.dayLabel} · ${l.match.opponent}'),
                      subtitle: Text(l.row.present
                          ? [
                              matchRoles[l.row.role] ?? '',
                              if (l.row.minutesPlayed != null) "${l.row.minutesPlayed}'",
                              ..._matchEvents(events, l.match.id, id),
                              if (l.row.rpe != null) 'RPE ${l.row.rpe}',
                            ].join(' · ')
                          : 'Absent — ${matchAbsenceReasons[l.row.absenceReason] ?? 'sans motif'}'),
                      trailing: l.match.result == null ? null : ScoreChip(l.match),
                      onTap: () => context.go('/matches/${l.match.id}'),
                    ),
                ]),
                _list(injuries.isEmpty ? 'Aucune blessure.' : null, [
                  for (final i in injuries)
                    ListTile(
                      title: Text('${injuryLabel(i)} · ${injuryTypes[i.type]}'),
                      subtitle: Text([
                        DateFormat('d MMM y', 'fr_FR').format(DateTime.parse(i.date)),
                        severities[i.severity]!.split(' ').first,
                        i.returnDate == null
                            ? 'en cours'
                            : 'retour le ${DateFormat('d MMM', 'fr_FR').format(DateTime.parse(i.returnDate!))}',
                      ].join(' · ')),
                      trailing: i.returnDate == null ? const InjuredBadge() : null,
                    ),
                ]),
                _list(wellness.isEmpty ? 'Aucun questionnaire.' : null, [
                  for (final w in wellness)
                    ListTile(
                      title: Text('${w.session.dayLabel} · ${sessionTypes[w.session.type]}'),
                      subtitle: Text('Sommeil ${w.entry.sleepHours.toStringAsFixed(1).replaceAll('.', ',')} h'
                          '${w.entry.remark != null ? ' · ${w.entry.remark}' : ''}'),
                      trailing: Text('${wellnessTotal(w.entry)}/25', style: theme.textTheme.titleMedium),
                    ),
                ]),
              ]),
            ),
          ),
        );
      },
    );
  }

  static List<String> _matchEvents(List<MatchEvent> events, String matchId, String playerId) {
    final mine = events.where((e) => e.matchId == matchId);
    final goals = mine.where((e) => e.type == 'goal' && e.playerId == playerId).length;
    final assists = mine.where((e) => e.type == 'goal' && e.assistPlayerId == playerId).length;
    final yellows = mine.where((e) => e.type == 'yellow_card' && e.playerId == playerId).length;
    final red = mine.any((e) => e.type == 'red_card' && e.playerId == playerId);
    return [
      if (goals > 0) '$goals but${goals > 1 ? 's' : ''}',
      if (assists > 0) '$assists passe${assists > 1 ? 's' : ''} déc.',
      if (yellows > 0) '$yellows jaune${yellows > 1 ? 's' : ''}',
      if (red) 'rouge',
    ];
  }

  Widget _list(String? empty, List<Widget> children) => empty != null
      ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(empty)))
      : ListView(padding: EdgeInsets.zero, children: children);
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
  /// Un double appui ne doit pas créer deux fois la même fiche (voir le verrou dans _save).
  bool _saving = false;
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
    if (_saving) return;
    _saving = true;
    try {
      await _saveUnguarded(another: another);
    } finally {
      // Verrou gardé un instant : l'enregistrement local prend quelques millisecondes, la seconde
      // frappe d'un double appui arrive souvent après — elle doit aussi être ignorée.
      Future<void>.delayed(const Duration(milliseconds: 600), () => _saving = false);
    }
  }

  Future<void> _saveUnguarded({required bool another}) async {
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
    final players = team == null ? const <Player>[] : ref.watch(playersProvider(team.id)).value ?? const <Player>[];
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
