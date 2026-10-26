import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../auth/auth_repository.dart';
import 'match_repository.dart'
    show competitions, eventColors, eventIcons, forfeitGoals, homeAwayLabels, matchClockLabel, matchStatuses;

/// Match d'une équipe du club, vu en lecture seule (fonction serveur club_results).
class ClubMatch {
  ClubMatch(Map<String, dynamic> j)
      : id = j['match_id'] as String,
        team = j['team_name'] as String,
        date = DateTime.parse(j['date'] as String),
        time = (j['kick_off_time'] as String).substring(0, 5),
        opponent = j['opponent'] as String,
        homeAway = j['home_away'] as String,
        competition = j['competition'] as String,
        matchday = j['matchday'] as int?,
        status = j['status'] as String,
        goalsFor = j['goals_for'] as int?,
        goalsAgainst = j['goals_against'] as int?,
        forfeitBy = j['forfeit_by'] as String?,
        events = [for (final e in (j['events'] as List<dynamic>? ?? const [])) e as Map<String, dynamic>],
        durationMin = j['duration_min'] as int? ?? 90,
        period = j['period'] as String?,
        firstHalfStartedAt = j['first_half_started_at'] as String?,
        secondHalfStartedAt = j['second_half_started_at'] as String?,
        addedTime1 = j['added_time_1'] as int?,
        addedTime2 = j['added_time_2'] as int?;

  final String id;
  final String team;
  final DateTime date;
  final String time;
  final String opponent;
  final String homeAway;
  final String competition;
  final int? matchday;
  final String status;
  final int? goalsFor;
  final int? goalsAgainst;
  final String? forfeitBy;
  final List<Map<String, dynamic>> events;
  final int durationMin;
  final String? period;
  final String? firstHalfStartedAt;
  final String? secondHalfStartedAt;
  final int? addedTime1;
  final int? addedTime2;

  /// Minute du match en cours (« 23' », « 45+2' », « MT »), ou null si le chrono n'a pas été lancé.
  String? get clock {
    final c = matchClockLabel(period, firstHalfStartedAt, secondHalfStartedAt, durationMin);
    return c.isEmpty ? null : c;
  }

  /// Temps additionnel joué : « +2 / +4 ».
  String? get addedTime => addedTime1 == null && addedTime2 == null ? null : '+${addedTime1 ?? 0} / +${addedTime2 ?? 0}';

  bool get live => status == 'in_progress';
  bool get played => {'completed', 'forfeit', 'abandoned'}.contains(status);
  bool get upcoming => status == 'planned';

  /// Score vu depuis le club : « 2 - 1 » (domicile ou extérieur, le club est toujours à gauche).
  String get score => goalsFor == null && goalsAgainst == null ? 'vs' : '${goalsFor ?? 0} - ${goalsAgainst ?? 0}';
}

final clubResultsProvider = FutureProvider<List<ClubMatch>>((ref) async {
  try {
    final rows = await ref.watch(supabaseProvider).rpc<List<dynamic>>('club_results');
    return [for (final r in rows.cast<Map<String, dynamic>>()) ClubMatch(r)];
  } catch (_) {
    throw const AppException(networkErrorMessage);
  }
});

/// Résultats du club : matchs en direct, résultats et matchs à venir de toutes les équipes du club,
/// pour tout le monde (même sans être affecté à l'équipe). Lecture seule, mis à jour toutes les 20 s.
class ClubResultsScreen extends ConsumerStatefulWidget {
  const ClubResultsScreen({super.key});

  @override
  ConsumerState<ClubResultsScreen> createState() => _ClubResultsScreenState();
}

class _ClubResultsScreenState extends ConsumerState<ClubResultsScreen> {
  String? _team;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => ref.invalidate(clubResultsProvider));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(clubResultsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Résultats du club')),
      body: results.when(
        skipLoadingOnRefresh: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(e is AppException ? e.message : networkErrorMessage),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => ref.invalidate(clubResultsProvider), child: const Text('Réessayer')),
          ]),
        ),
        data: (all) {
          final teams = {for (final m in all) m.team}.toList()..sort();
          final list = all.where((m) => _team == null || m.team == _team).toList();
          final live = list.where((m) => m.live).toList();
          final played = list.where((m) => m.played || m.status == 'cancelled' || m.status == 'postponed').toList();
          final upcoming = list.where((m) => m.upcoming).toList()..sort((a, b) => a.date.compareTo(b.date));
          Widget header(String text, {Color? color}) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(text, style: theme.textTheme.labelLarge?.copyWith(color: color ?? theme.colorScheme.primary)),
              );
          return RefreshIndicator(
            onRefresh: () => ref.refresh(clubResultsProvider.future),
            child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(children: [
                  for (final t in <String?>[null, ...teams])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(t ?? 'Toutes les équipes'),
                        selected: _team == t,
                        onSelected: (_) => setState(() => _team = t),
                      ),
                    ),
                ]),
              ),
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Aucun match ces trois derniers mois ni dans le mois à venir.', textAlign: TextAlign.center),
                ),
              if (live.isNotEmpty) ...[
                header('EN DIRECT', color: Colors.green.shade600),
                for (final m in live) _MatchCard(m),
              ],
              if (played.isNotEmpty) ...[
                header('RÉSULTATS'),
                for (final m in played) _MatchCard(m),
              ],
              if (upcoming.isNotEmpty) ...[
                header('À VENIR'),
                for (final m in upcoming) _MatchCard(m),
              ],
            ]),
          );
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard(this.m);

  final ClubMatch m;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final day = DateFormat('EEE d MMM', 'fr_FR').format(m.date);
    final result = m.status == 'completed' || m.status == 'forfeit'
        ? ((m.goalsFor ?? 0) > (m.goalsAgainst ?? 0) ? 'W' : (m.goalsFor ?? 0) < (m.goalsAgainst ?? 0) ? 'L' : 'D')
        : null;
    final (bg, fg) = switch (result) {
      'W' => (const Color(0xFFC8E6C9), const Color(0xFF1B5E20)),
      'L' => (theme.colorScheme.errorContainer, theme.colorScheme.onErrorContainer),
      _ => (theme.colorScheme.surfaceContainerHighest, theme.colorScheme.onSurfaceVariant),
    };
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: ExpansionTile(
        shape: const Border(),
        title: Row(children: [
          Expanded(
            child: Text('${m.team}  ·  ${m.opponent}', style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: m.live ? Colors.green.shade600 : bg, borderRadius: BorderRadius.circular(12)),
            child: Text(m.upcoming ? m.time : m.live && m.clock != null ? '${m.score} · ${m.clock}' : m.score,
                style: TextStyle(color: m.live ? Colors.white : fg, fontWeight: FontWeight.bold)),
          ),
        ]),
        subtitle: Text([
          '${day[0].toUpperCase()}${day.substring(1)} · ${m.time}',
          homeAwayLabels[m.homeAway] ?? m.homeAway,
          [competitions[m.competition] ?? m.competition, if (m.matchday != null) 'J${m.matchday}'].join(' '),
          if (m.live) m.clock == null ? 'en cours' : 'en cours · ${m.clock}',
          if (!m.live && m.addedTime != null) 'temps additionnel ${m.addedTime}',
          if (m.status == 'forfeit')
            m.forfeitBy == 'opponent' ? 'victoire $forfeitGoals-0 par forfait' : 'défaite 0-$forfeitGoals par forfait',
          if ({'abandoned', 'postponed', 'cancelled'}.contains(m.status)) (matchStatuses[m.status] ?? m.status).toLowerCase(),
        ].join(' · ')),
        children: [
          if (m.events.isEmpty)
            const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 12), child: Text('Aucun événement.')),
          for (final e in m.events)
            ListTile(
              dense: true,
              leading: SizedBox(width: 36, child: Text("${e['minute']}'", style: const TextStyle(fontWeight: FontWeight.bold))),
              title: Row(children: [
                Icon(eventIcons[e['type']] ?? Icons.circle, color: eventColors[e['type']], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(switch (e['type']) {
                    'goal' => '${e['player']}${e['other'] != null ? ' (passe de ${e['other']})' : ''}',
                    'substitution' => 'Entre ${e['player']}, sort ${e['other']}',
                    'yellow_card' => '${e['player']} · carton jaune',
                    'red_card' => '${e['player']} · carton rouge',
                    'opponent_goal' => 'But ${m.opponent}${e['player'] == null ? '' : ' · ${e['player']}'}',
                    _ => '${e['player']}',
                  }),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}
