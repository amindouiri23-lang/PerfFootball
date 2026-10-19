import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/theme.dart';
import '../../core/widgets/steppers.dart';
import '../../data/database.dart';
import '../../data/sync.dart';
import '../sessions/session_repository.dart';
import '../matches/match_repository.dart';
import '../team/team_repository.dart';
import '../wellness/wellness_repository.dart';

/// Questionnaires de bien-être du joueur (le serveur ne lui envoie que les siens).
final _myWellnessProvider = StreamProvider.family<List<WellnessEntry>, String>((ref, playerId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellness)..where((w) => w.playerId.equals(playerId) & w.deleted.equals(false))).watch();
});

/// Accueil d'un compte joueur : son dossier, son RPE et son questionnaire de bien-être après chaque séance.
class PlayerSpace extends ConsumerWidget {
  const PlayerSpace({super.key, required this.playerId});

  final String? playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = playerId;
    if (id == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Votre compte n\'est relié à aucun joueur. Demandez à l\'administrateur.', textAlign: TextAlign.center),
        ),
      );
    }
    final player = ref.watch(playerProvider(id)).value;
    if (player == null) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Chargement de votre fiche…')));
    }
    final theme = Theme.of(context);
    final sessions = {for (final s in ref.watch(sessionsProvider(player.teamId)).value ?? const <TrainingSession>[]) s.id: s};
    // Mes lignes de séance : séances commencées ou terminées où j'étais présent, la plus récente d'abord.
    final rows = (ref.watch(teamSessionPlayersProvider(player.teamId)).value ?? const <SessionPlayer>[])
        .where((r) => r.playerId == id && r.present && sessions[r.sessionId] != null && sessions[r.sessionId]!.status != 'planned')
        .toList()
      ..sort((a, b) => '${sessions[b.sessionId]!.date}${sessions[b.sessionId]!.startTime}'
          .compareTo('${sessions[a.sessionId]!.date}${sessions[a.sessionId]!.startTime}'));
    // Mes matchs : joués (ou en cours) et où j'étais sur la feuille.
    final matches = {for (final m in ref.watch(matchesProvider(player.teamId)).value ?? const <FootballMatch>[]) m.id: m};
    final matchRows = (ref.watch(teamMatchPlayersProvider(player.teamId)).value ?? const <MatchPlayer>[])
        .where((r) => r.playerId == id && r.present && {'in_progress', 'completed', 'abandoned'}.contains(matches[r.matchId]?.status))
        .toList()
      ..sort((a, b) => matches[b.matchId]!.date.compareTo(matches[a.matchId]!.date));
    // Questionnaires de bien-être qui me sont adressés, sans réponse de ma part d'abord.
    final surveys = {for (final s in ref.watch(surveysProvider(player.teamId)).value ?? const <WellnessSurvey>[]) s.id: s};
    final mine = (ref.watch(surveyPlayersProvider((teamId: player.teamId, surveyId: null))).value ?? const <WellnessSurveyPlayer>[])
        .where((c) => c.playerId == id && surveys.containsKey(c.surveyId))
        .map((c) => surveys[c.surveyId]!)
        .toList();
    final answered = {for (final w in ref.watch(_myWellnessProvider(id)).value ?? const <WellnessEntry>[]) w.surveyId};
    final pending = mine.where((s) => !answered.contains(s.id)).toList();

    Widget rpeCard(String title, int? rpe, VoidCallback onTap) => Card(
          child: ListTile(
            title: Text(title),
            trailing: rpe == null
                ? FilledButton.icon(icon: const Icon(Icons.speed), label: const Text('Mon RPE'), onPressed: onTap)
                : OutlinedButton.icon(icon: const Icon(Icons.check), label: Text('RPE $rpe'), onPressed: onTap),
          ),
        );

    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(player.fullName.toUpperCase(), style: gameTitle(context, size: 28)),
      Text('Votre espace joueur', style: theme.textTheme.bodyMedium),
      const SizedBox(height: 16),
      Text('QUESTIONNAIRES DE BIEN-ÊTRE', style: sectionLabel(context)),
      const SizedBox(height: 8),
      if (pending.isEmpty) const Text('Aucun questionnaire en attente.'),
      for (final s in pending)
        Card(
          child: ListTile(
            leading: Icon(Icons.favorite, color: theme.colorScheme.primary),
            title: Text(s.label),
            subtitle: const Text('À remplir'),
            trailing: FilledButton(onPressed: () => context.go('/home/survey/${s.id}/$id'), child: const Text('Répondre')),
          ),
        ),
      const SizedBox(height: 16),
      Text('MES SÉANCES', style: sectionLabel(context)),
      const SizedBox(height: 8),
      if (rows.isEmpty) const Text('Aucune séance pour l\'instant. Elles apparaissent ici après l\'appel du staff.'),
      for (final r in rows.take(10))
        rpeCard('${sessions[r.sessionId]!.dayLabel} · ${sessionTypes[sessions[r.sessionId]!.type]}', r.rpe,
            () => _askRpe(context, 'pendant la séance', r.rpe, (v) => ref.read(sessionRepositoryProvider).setRpe(r.id, v))),
      const SizedBox(height: 16),
      Text('MES MATCHS', style: sectionLabel(context)),
      const SizedBox(height: 8),
      if (matchRows.isEmpty) const Text('Aucun match pour l\'instant.'),
      for (final r in matchRows.take(10))
        rpeCard('${matches[r.matchId]!.dayLabel} · ${matches[r.matchId]!.opponent}', r.rpe,
            () => _askRpe(context, 'pendant le match', r.rpe, (v) => ref.read(matchRepositoryProvider).setRpe(r.id, v))),
      const SizedBox(height: 16),
      Card(
        child: ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: const Text('Mon dossier'),
          subtitle: const Text('Coordonnées, école, parents, club précédent'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/home/dossier/$id'),
        ),
      ),
    ]);
  }

  Future<void> _askRpe(BuildContext context, String when, int? current, Future<void> Function(int? v) save) async {
    int? value = current;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Effort ressenti $when (RPE)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              const Text('1 = très facile · 10 = effort maximal'),
              const SizedBox(height: 12),
              RpeSelector(value: value, onChanged: (v) => setState(() => value = v)),
              const SizedBox(height: 16),
              FilledButton(onPressed: value == null ? null : () => Navigator.of(context).pop(true), child: const Text('Enregistrer')),
            ]),
          ),
        ),
      ),
    );
    if (ok != true) return;
    await save(value);
    if (context.mounted) showMessage(context, 'RPE enregistré, merci !');
  }
}
