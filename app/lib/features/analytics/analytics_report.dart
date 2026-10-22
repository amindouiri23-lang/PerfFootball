import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../matches/match_repository.dart';
import '../sessions/session_repository.dart';
import '../team/team_repository.dart';
import 'analytics_data.dart';

// Contenu exportable du tableau de bord : une page = indicateurs, graphiques et tableaux. Le PDF et l'Excel
// sont construits à partir de ce même contenu, pour dire la même chose que l'écran.

class ReportTable {
  const ReportTable(this.title, this.headers, this.rows);

  final String title;
  final List<String> headers;
  /// Cellules : texte, nombre, ou null (vide).
  final List<List<Object?>> rows;
}

class ReportChart {
  const ReportChart(this.title, this.labels, this.series);

  final String title;
  final List<String> labels;
  /// Série → une valeur par libellé (null = pas de valeur).
  final Map<String, List<double?>> series;
}

class ReportPage {
  const ReportPage(this.title, {this.kpis = const [], this.charts = const [], this.tables = const []});

  final String title;
  final List<(String, String)> kpis;
  final List<ReportChart> charts;
  final List<ReportTable> tables;
}

/// Les pages de tableau de bord, dans l'ordre de l'écran.
const dashboardPages = ['overview', 'load', 'wellness', 'matches', 'injuries'];
const dashboardPageTitles = {
  'overview': 'Vue d\'ensemble',
  'load': 'Charge et ACWR',
  'wellness': 'Bien-être',
  'matches': 'Matchs',
  'injuries': 'Blessures',
};

final _num = NumberFormat('#,##0.##', 'fr_FR');
final _week = DateFormat('d MMM', 'fr_FR');
final _date = DateFormat('dd/MM/yyyy', 'fr_FR');

String fmtNum(num? v) => v == null ? '—' : _num.format(v);
String fmtPct(double? v) => v == null ? '—' : '${(v * 100).round()} %';
String fmtAcwr(double? v) => v == null ? '—' : v.toStringAsFixed(2).replaceAll('.', ',');
String weekLabel(DateTime w) => 'Sem. ${_week.format(w)}';
String dayLabelShort(DateTime d) => DateFormat('d MMM', 'fr_FR').format(d);
const matchResultLabels = {'W': 'Victoire', 'D': 'Nul', 'L': 'Défaite'};

String scoreOf(FootballMatch m) => m.goalsFor == null || m.goalsAgainst == null ? '' : '${m.goalsFor} - ${m.goalsAgainst}';

/// Pages exportées, avec le filtre courant.
List<ReportPage> buildReport(Analytics a, Set<String> pages) {
  final names = {for (final r in a.rows) r.player.id: r.player.fullName};
  final weeks = a.weeks.map((w) => w.week).toList();
  final days = a.wellnessDays.map((d) => d.day).toList();
  return [
    if (pages.contains('overview'))
      ReportPage(dashboardPageTitles['overview']!, kpis: [
        ('Joueurs suivis', '${a.playersFollowed}'),
        ('Présence', fmtPct(a.attendance)),
        ('Charge totale (UA)', fmtNum(a.totalLoad)),
        ('Bien-être moyen (/25)', a.wellnessAvg == null ? '—' : fmtNum(a.wellnessAvg)),
        ('Blessures en cours', '${a.openInjuries}'),
      ], charts: [
        ReportChart('Charge par semaine (UA)', [for (final w in weeks) weekLabel(w)], {
          'Séances': [for (final w in a.weeks) w.sessions.toDouble()],
          'Matchs': [for (final w in a.weeks) w.matches.toDouble()],
        }),
      ], tables: [
        ReportTable('Par joueur', const ['Joueur', 'Poste', 'Présence', 'Matchs joués', 'Minutes', 'Buts', 'Passes déc.', 'Charge (UA)', 'ACWR'], [
          for (final r in a.rows)
            [r.player.fullName, positions[r.player.position], r.attendance == null ? null : (r.attendance! * 100).round(),
              r.matchesPlayed, r.minutes, r.goals, r.assists, r.load, r.acwr == null ? null : double.parse(r.acwr!.toStringAsFixed(2))],
        ]),
      ]),
    if (pages.contains('load'))
      ReportPage(dashboardPageTitles['load']!, charts: [
        ReportChart('ACWR par semaine${a.filter.playerId == null ? '' : ' — ${names[a.filter.playerId] ?? ''}'}',
            [for (final w in weeks) weekLabel(w)], {'ACWR': [for (final w in a.weeks) w.acwr]}),
      ], tables: [
        ReportTable('Charge par joueur et par semaine (UA)', ['Joueur', for (final w in weeks) weekLabel(w), 'Total'], [
          for (final r in a.rows)
            [r.player.fullName, for (final w in weeks) a.loadByPlayerWeek[r.player.id]?[w], r.load],
        ]),
      ]),
    if (pages.contains('wellness'))
      ReportPage(dashboardPageTitles['wellness']!, kpis: [
        ('Bien-être moyen (/25)', a.wellnessAvg == null ? '—' : fmtNum(a.wellnessAvg)),
        ('Réponses', '${a.wellnessDays.fold(0, (s, d) => s + d.scores.length)}'),
      ], charts: [
        ReportChart('Bien-être moyen (/25) et sommeil (h)', [for (final d in days) dayLabelShort(d)], {
          'Bien-être': [for (final d in a.wellnessDays) double.parse(d.score.toStringAsFixed(1))],
          'Sommeil': [for (final d in a.wellnessDays) double.parse(d.sleepHours.toStringAsFixed(1))],
        }),
      ], tables: [
        ReportTable('Bien-être par joueur et par jour (/25)', ['Joueur', for (final d in days) dayLabelShort(d)], [
          for (final r in a.rows)
            if (a.wellnessByPlayerDay.containsKey(r.player.id))
              [r.player.fullName, for (final d in days) a.wellnessByPlayerDay[r.player.id]![d]],
        ]),
      ]),
    if (pages.contains('matches'))
      ReportPage(dashboardPageTitles['matches']!, kpis: [
        ('Matchs', '${a.matches.length}'),
        ('Victoires', '${a.matches.where((m) => m.result == 'W').length}'),
        ('Nuls', '${a.matches.where((m) => m.result == 'D').length}'),
        ('Défaites', '${a.matches.where((m) => m.result == 'L').length}'),
      ], charts: [
        ReportChart('Temps de jeu (min)', [for (final r in _byMinutes(a)) r.player.fullName],
            {'Minutes': [for (final r in _byMinutes(a)) r.minutes.toDouble()]}),
      ], tables: [
        ReportTable('Résultats', const ['Date', 'Adversaire', 'Lieu', 'Compétition', 'Score', 'Résultat'], [
          for (final m in a.matches)
            [_date.format(m.day), m.opponent, homeAwayLabels[m.homeAway], competitions[m.competition], scoreOf(m),
              matchResultLabels[m.result] ?? matchStatuses[m.status]],
        ]),
        ReportTable('Statistiques des joueurs', const ['Joueur', 'Matchs joués', 'Minutes', 'Buts', 'Passes déc.', 'Cartons J', 'Cartons R', 'Charge matchs (UA)'], [
          for (final r in a.rows)
            if (r.matchesPlayed > 0 || r.goals > 0 || r.assists > 0 || r.yellows > 0 || r.reds > 0)
              [r.player.fullName, r.matchesPlayed, r.minutes, r.goals, r.assists, r.yellows, r.reds, r.matchLoad],
        ]),
      ]),
    if (pages.contains('injuries'))
      ReportPage(dashboardPageTitles['injuries']!, kpis: [
        ('Blessures en cours', '${a.openInjuries}'),
        ('Blessures (période)', '${a.injuryCount}'),
        ('Jours d\'absence', '${a.daysOut}'),
      ], charts: [
        ReportChart('Blessures par zone', [for (final e in _areas(a)) bodyAreas[e.key] ?? e.key],
            {'Blessures': [for (final e in _areas(a)) e.value.toDouble()]}),
      ], tables: [
        ReportTable('Liste des blessures', const ['Joueur', 'Date', 'Zone', 'Côté', 'Type', 'Gravité', 'En cours', 'Jours d\'absence'], [
          for (final i in a.injuries)
            [i.player?.fullName ?? '', _date.format(DateTime.parse(i.injury.date)), bodyAreas[i.injury.bodyArea],
              injurySides[i.injury.side], injuryTypes[i.injury.type], severities[i.injury.severity]?.split(' ').first,
              i.open ? 'Oui' : 'Non', i.daysOut],
        ]),
      ]),
  ];
}

List<PlayerRow> _byMinutes(Analytics a) => (a.rows.where((r) => r.minutes > 0).toList()
  ..sort((x, y) => y.minutes.compareTo(x.minutes)));

List<MapEntry<String, int>> _areas(Analytics a) => a.injuriesByArea.entries.toList()..sort((x, y) => y.value.compareTo(x.value));
