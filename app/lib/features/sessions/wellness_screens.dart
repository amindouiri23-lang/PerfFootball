import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../data/database.dart';
import '../team/team_repository.dart';
import 'session_repository.dart';

/// Les cinq questions, notées de 1 à 5 — 5 est toujours le meilleur état (specs §4.3).
const wellnessQuestions = [
  (key: 'sleep_quality', label: 'Qualité du sommeil', low: 'Très mauvaise', high: 'Excellente'),
  (key: 'fatigue', label: 'Fatigue', low: 'Épuisé', high: 'Très frais'),
  (key: 'soreness', label: 'Courbatures', low: 'Très douloureuses', high: 'Aucune'),
  (key: 'stress', label: 'Stress', low: 'Très stressé', high: 'Très détendu'),
  (key: 'mood', label: 'Humeur', low: 'Très mauvaise', high: 'Excellente'),
];

const _faces = [
  Icons.sentiment_very_dissatisfied,
  Icons.sentiment_dissatisfied,
  Icons.sentiment_neutral,
  Icons.sentiment_satisfied,
  Icons.sentiment_very_satisfied,
];
const _faceColors = [Color(0xFFC62828), Color(0xFFEF6C00), Color(0xFFF9A825), Color(0xFF7CB342), Color(0xFF2E7D32)];

int wellnessTotal(WellnessEntry w) => w.sleepQuality + w.fatigue + w.soreness + w.stress + w.mood;

/// Présents de la séance, triés par numéro.
List<SessionPlayer> _presentRows(List<SessionPlayer> rows, Map<String, Player> players) =>
    rows.where((r) => r.present).toList()
      ..sort((a, b) => (players[a.playerId]?.shirtNumber ?? 999).compareTo(players[b.playerId]?.shirtNumber ?? 999));

/// E18 — Liste des présents : à remplir, puis remplis (score sur 25).
class WellnessListScreen extends ConsumerWidget {
  const WellnessListScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider(sessionId)).value;
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final players = {for (final p in ref.watch(playersProvider(s.teamId)).value ?? const <Player>[]) p.id: p};
    final present = _presentRows(ref.watch(sessionPlayersProvider(sessionId)).value ?? const <SessionPlayer>[], players);
    final done = {for (final w in ref.watch(sessionWellnessProvider(sessionId)).value ?? const <WellnessEntry>[]) w.playerId: w};
    final todo = present.where((r) => !done.containsKey(r.playerId)).toList();
    final filled = present.where((r) => done.containsKey(r.playerId)).toList();
    final theme = Theme.of(context);

    Widget tile(SessionPlayer r) {
      final p = players[r.playerId];
      final w = done[r.playerId];
      return ListTile(
        leading: CircleAvatar(child: Text(p?.initials ?? '?')),
        title: Text(p?.fullName ?? '—'),
        trailing: w == null
            ? const Icon(Icons.chevron_right)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text('${wellnessTotal(w)}/25'),
              ]),
        onTap: () => context.go('/sessions/$sessionId/wellness/${r.playerId}'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bien-être'),
        actions: [Center(child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text('${filled.length}/${present.length} remplis'),
        ))],
      ),
      body: ListView(children: [
        ListTile(title: Text('Séance du ${s.dayLabel} · ${sessionTypes[s.type]}')),
        if (todo.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Text('À remplir (${todo.length})', style: theme.textTheme.titleSmall)),
          for (final r in todo) tile(r),
        ],
        if (filled.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Text('Remplis (${filled.length})', style: theme.textTheme.titleSmall)),
          for (final r in filled) tile(r),
        ],
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton(onPressed: () => context.go('/sessions/$sessionId'), child: const Text('Retour à la séance')),
        ),
      ),
    );
  }
}

/// E18 — Questionnaire d'un joueur, en plein écran, pensé pour être tendu au joueur.
class WellnessFormScreen extends ConsumerStatefulWidget {
  const WellnessFormScreen({super.key, required this.sessionId, required this.playerId});

  final String sessionId;
  final String playerId;

  @override
  ConsumerState<WellnessFormScreen> createState() => _WellnessFormScreenState();
}

class _WellnessFormScreenState extends ConsumerState<WellnessFormScreen> {
  double _sleep = 8;
  final Map<String, int> _answers = {};
  final _remark = TextEditingController();
  bool _loaded = false;
  bool _submitted = false;

  void _load(WellnessEntry? w) {
    if (_loaded) return;
    _loaded = true;
    if (w == null) return;
    _sleep = w.sleepHours;
    _answers.addAll({'sleep_quality': w.sleepQuality, 'fatigue': w.fatigue, 'soreness': w.soreness, 'stress': w.stress, 'mood': w.mood});
    _remark.text = w.remark ?? '';
  }

  Future<void> _save({required bool next}) async {
    setState(() => _submitted = true);
    if (_answers.length < wellnessQuestions.length) return;
    final s = ref.read(sessionProvider(widget.sessionId)).value!;
    final remark = _remark.text.trim();
    await ref.read(sessionRepositoryProvider).saveWellness(
          s, widget.playerId,
          sleepHours: _sleep, sleepQuality: _answers['sleep_quality']!, fatigue: _answers['fatigue']!,
          soreness: _answers['soreness']!, stress: _answers['stress']!, mood: _answers['mood']!,
          remark: remark.isEmpty ? null : remark,
        );
    if (!mounted) return;
    if (next) {
      final players = {for (final p in ref.read(playersProvider(s.teamId)).value ?? const <Player>[]) p.id: p};
      final done = {for (final w in ref.read(sessionWellnessProvider(s.id)).value ?? const <WellnessEntry>[]) w.playerId};
      final following = _presentRows(ref.read(sessionPlayersProvider(s.id)).value ?? const <SessionPlayer>[], players)
          .where((r) => r.playerId != widget.playerId && !done.contains(r.playerId))
          .firstOrNull;
      if (following != null) {
        context.go('/sessions/${s.id}/wellness/${following.playerId}');
        return;
      }
      showMessage(context, 'Tous les questionnaires sont remplis');
    }
    context.go('/sessions/${s.id}/wellness');
  }

  @override
  void dispose() {
    _remark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = ref.watch(sessionWellnessProvider(widget.sessionId));
    final player = ref.watch(playerProvider(widget.playerId)).value;
    if (!existing.hasValue) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    _load(existing.value!.where((w) => w.playerId == widget.playerId).firstOrNull);
    final theme = Theme.of(context);
    final missing = _submitted && _answers.length < wellnessQuestions.length;

    return Scaffold(
      appBar: AppBar(title: Text(player?.fullName ?? 'Bien-être')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('Heures de sommeil : ${_sleep.toStringAsFixed(1).replaceAll('.', ',')} h', style: theme.textTheme.titleMedium),
            Slider(value: _sleep, min: 0, max: 14, divisions: 28, label: '${_sleep.toStringAsFixed(1)} h',
                onChanged: (v) => setState(() => _sleep = v)),
            for (final q in wellnessQuestions) ...[
              const SizedBox(height: 8),
              Text(q.label, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Row(children: [
                for (var v = 1; v <= 5; v++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _answers[q.key] = v),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: _faceColors[v - 1].withValues(alpha: _answers[q.key] == v ? 0.9 : 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _faceColors[v - 1], width: _answers[q.key] == v ? 2.5 : 1),
                          ),
                          child: Icon(_faces[v - 1], size: 30,
                              color: _answers[q.key] == v ? Colors.white : _faceColors[v - 1]),
                        ),
                      ),
                    ),
                  ),
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(children: [
                  Text('1 · ${q.low}', style: theme.textTheme.bodySmall),
                  const Spacer(),
                  Text('5 · ${q.high}', style: theme.textTheme.bodySmall),
                ]),
              ),
            ],
            const SizedBox(height: 12),
            TextField(controller: _remark, maxLength: 1000, decoration: const InputDecoration(labelText: 'Remarque (facultatif)')),
            if (missing)
              Text('Répondez aux 5 questions pour valider.', style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 8),
            FilledButton(onPressed: () => _save(next: true), child: const Text('Valider et joueur suivant')),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => _save(next: false), child: const Text('Valider')),
          ]),
        ),
      ),
    );
  }
}
