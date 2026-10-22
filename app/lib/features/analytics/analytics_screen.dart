import 'dart:math' as math;

import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/permissions.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../data/sync.dart';
import '../matches/match_repository.dart';
import '../matches/matches_list_screen.dart' show ScoreChip;
import '../sessions/session_repository.dart';
import '../team/team_filter.dart';
import '../team/team_repository.dart';
import '../team/team_screen.dart' show NoTeamScreen;
import '../tests/test_repository.dart' show seasonOf;
import '../wellness/wellness_repository.dart';
import 'analytics_data.dart';
import 'analytics_export.dart';
import 'analytics_report.dart';
import 'save_file.dart';

/// Réponses de bien-être d'une équipe (séances et questionnaires).
final _teamWellnessProvider = StreamProvider.family<List<WellnessEntry>, String>((ref, teamId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellness)..where((w) => w.teamId.equals(teamId) & w.deleted.equals(false))).watch();
});

/// Période du tableau de bord.
enum _Period { weeks4, months3, season, all, custom }

const _periodLabels = {
  _Period.weeks4: '4 semaines',
  _Period.months3: '3 mois',
  _Period.season: 'Saison',
  _Period.all: 'Tout',
  _Period.custom: 'Dates…',
};

const _sessionColor = Color(0xFFC8102E);
const _matchColor = Color(0xFF1565C0);
const _green = Color(0xFF2E7D32);
const _orange = Color(0xFFEF6C00);

/// Tableau de bord : les pages du rapport Power BI, calculées en direct sur les données de l'appareil,
/// filtrables (équipe, période, poste, joueur) et exportables en PDF ou en Excel.
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _Period _period = _Period.season;
  DateTimeRange? _custom;
  String? _position;
  String? _playerId;
  bool _exporting = false;

  (DateTime, DateTime) _range(AnalyticsInput input) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case _Period.weeks4:
        return (weekStart(today).subtract(const Duration(days: 21)), today);
      case _Period.months3:
        return (DateTime(today.year, today.month - 3, today.day), today);
      case _Period.season:
        return (DateTime(seasonOf(today), 7, 1), today);
      case _Period.custom:
        final r = _custom!;
        return (DateTime(r.start.year, r.start.month, r.start.day), DateTime(r.end.year, r.end.month, r.end.day));
      case _Period.all:
        final dates = [
          for (final s in input.sessions) DateTime.parse(s.date),
          for (final m in input.matches) DateTime.parse(m.date),
          for (final w in input.wellness) w.day,
          for (final i in input.injuries) DateTime.parse(i.date),
        ];
        final first = dates.isEmpty ? today : dates.reduce((a, b) => a.isBefore(b) ? a : b);
        final last = dates.isEmpty ? today : dates.reduce((a, b) => a.isAfter(b) ? a : b);
        return (first, last.isAfter(today) ? last : today);
    }
  }

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const NoTeamScreen();
    final perms = ref.watch(permsProvider);
    final pages = [
      'overview',
      'load',
      if (perms.can('bienetre.view')) 'wellness',
      'matches',
      if (perms.can('blessures.view')) 'injuries',
    ];

    final sessions = ref.watch(sessionsProvider(team.id)).value ?? const <TrainingSession>[];
    final surveys = ref.watch(surveysProvider(team.id)).value ?? const <WellnessSurvey>[];
    final sessionDates = {for (final s in sessions) s.id: s.date};
    final surveyDates = {for (final s in surveys) s.id: s.date};
    final input = AnalyticsInput(
      players: ref.watch(playersProvider(team.id)).value ?? const <Player>[],
      sessions: sessions,
      sessionPlayers: ref.watch(teamSessionPlayersProvider(team.id)).value ?? const <SessionPlayer>[],
      matches: ref.watch(matchesProvider(team.id)).value ?? const <FootballMatch>[],
      matchPlayers: ref.watch(teamMatchPlayersProvider(team.id)).value ?? const <MatchPlayer>[],
      events: ref.watch(teamMatchEventsProvider(team.id)).value ?? const <MatchEvent>[],
      wellness: [
        for (final w in ref.watch(_teamWellnessProvider(team.id)).value ?? const <WellnessEntry>[])
          if ((w.surveyId != null ? surveyDates[w.surveyId] : sessionDates[w.sessionId]) case final String d)
            (entry: w, day: DateTime.parse(d)),
      ],
      injuries: ref.watch(teamInjuriesProvider(team.id)).value ?? const <Injury>[],
    );
    if (_playerId != null && !input.players.any((p) => p.id == _playerId)) _playerId = null;
    final (from, to) = _range(input);
    final filter = AnalyticsFilter(from: from, to: to, position: _position, playerId: _playerId);
    final a = Analytics.compute(input, filter);
    final fmt = DateFormat('d MMM y', 'fr_FR');
    final periodLabel = '${fmt.format(from)} – ${fmt.format(to)}';

    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tableau de bord'),
          bottom: teamFilterBar(ref),
          actions: [
            if (perms.can('analyse.export'))
              _exporting
                  ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  : PopupMenuButton<String>(
                      tooltip: 'Exporter',
                      icon: const Icon(Icons.file_download_outlined),
                      onSelected: (f) => _export(f, team, a, pages, periodLabel),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'pdf', child: ListTile(leading: Icon(Icons.picture_as_pdf_outlined), title: Text('Exporter en PDF'))),
                        PopupMenuItem(value: 'xlsx', child: ListTile(leading: Icon(Icons.grid_on), title: Text('Exporter en Excel'))),
                      ],
                    ),
          ],
        ),
        body: Column(children: [
          SizedBox(
            height: 52,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(12, 8, 12, 4), children: [
              for (final p in _Period.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(p == _Period.custom && _custom != null && _period == p ? periodLabel : _periodLabels[p]!),
                    selected: _period == p,
                    onSelected: (_) => p == _Period.custom ? _pickRange(from, to) : setState(() => _period = p),
                  ),
                ),
              const SizedBox(width: 6),
              DropdownButton<String?>(
                value: _position,
                underline: const SizedBox(),
                hint: const Text('Tous les postes'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tous les postes')),
                  for (final e in positions.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => setState(() => _position = v),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${team.name} · $periodLabel', style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
          TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [
            for (final p in pages) Tab(text: dashboardPageTitles[p]),
          ]),
          Expanded(
            child: TabBarView(children: [
              for (final p in pages)
                switch (p) {
                  'overview' => _OverviewPage(a: a),
                  'load' => _LoadPage(a: a, players: a.rows.map((r) => r.player).toList(), playerId: _playerId,
                      onPlayer: (id) => setState(() => _playerId = id)),
                  'wellness' => _WellnessPage(a: a),
                  'matches' => _MatchesPage(a: a),
                  _ => _InjuriesPage(a: a),
                },
            ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _pickRange(DateTime from, DateTime to) async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _custom ?? DateTimeRange(start: from, end: to),
      helpText: 'Période du tableau de bord',
    );
    if (r != null) {
      setState(() {
        _custom = r;
        _period = _Period.custom;
      });
    }
  }

  Future<void> _export(String format, Team team, Analytics a, List<String> pages, String period) async {
    setState(() => _exporting = true);
    try {
      final header = ReportHeader(
        team: team.name,
        period: period,
        position: _position == null ? null : positions[_position],
        player: _playerId == null ? null : a.rows.where((r) => r.player.id == _playerId).firstOrNull?.player.fullName,
      );
      final report = buildReport(a, pages.toSet());
      final stamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final base = 'PerfFoot_tableau_de_bord_${team.name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}_$stamp';
      final (bytes, mime, name) = format == 'pdf'
          ? (await buildPdf(header, report), 'application/pdf', '$base.pdf')
          : (buildXlsx(header, report), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', '$base.xlsx');
      await saveFile(bytes, name, mime);
    } catch (e) {
      if (mounted) showMessage(context, 'Export impossible : $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Éléments communs
// ---------------------------------------------------------------------------

class _Kpis extends StatelessWidget {
  const _Kpis(this.items);

  final List<(String, String, IconData)> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, c) {
      final perRow = c.maxWidth > 700 ? items.length : (c.maxWidth > 420 ? 3 : 2);
      final w = (c.maxWidth - 8 * (perRow - 1)) / perRow;
      return Wrap(spacing: 8, runSpacing: 8, children: [
        for (final k in items)
          SizedBox(
            width: w,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(k.$3, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(height: 6),
                  Text(k.$2, style: theme.textTheme.headlineSmall),
                  Text(k.$1, style: theme.textTheme.bodySmall),
                ]),
              ),
            ),
          ),
      ]);
    });
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.child);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title.toUpperCase(), style: sectionLabel(context)),
          const SizedBox(height: 8),
          child,
        ]),
      );
}

Widget _empty(String text) => Padding(padding: const EdgeInsets.all(16), child: Center(child: Text(text, textAlign: TextAlign.center)));

Widget _legend(List<(String, Color)> items) => Wrap(spacing: 16, children: [
      for (final (l, c) in items)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(l, style: const TextStyle(fontSize: 12)),
        ]),
    ]);

/// Libellés de l'axe horizontal : un sur [every] pour rester lisible.
SideTitles _bottomTitles(List<String> labels) {
  final every = math.max(1, (labels.length / 6).ceil());
  return SideTitles(
    showTitles: true,
    reservedSize: 26,
    interval: 1,
    getTitlesWidget: (v, meta) {
      final i = v.round();
      if (i < 0 || i >= labels.length || i % every != 0 || v != i.toDouble()) return const SizedBox();
      return SideTitleWidget(meta: meta, child: Text(labels[i], style: const TextStyle(fontSize: 10)));
    },
  );
}

SideTitles _leftTitles({double reserved = 40}) => SideTitles(
      showTitles: true,
      reservedSize: reserved,
      getTitlesWidget: (v, meta) => v == meta.max || v == meta.min && v != 0
          ? const SizedBox()
          : SideTitleWidget(meta: meta, child: Text(fmtNum(v), style: const TextStyle(fontSize: 10))),
    );

FlTitlesData _titles(List<String> labels, {double reserved = 40}) => FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      bottomTitles: AxisTitles(sideTitles: _bottomTitles(labels)),
      leftTitles: AxisTitles(sideTitles: _leftTitles(reserved: reserved)),
    );

/// Barres horizontales simples (temps de jeu, zones de blessure).
class _HBars extends StatelessWidget {
  const _HBars(this.items, {this.unit = '', this.onTap});

  final List<(String, num, String?)> items;
  final String unit;
  final void Function(String id)? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = items.isEmpty ? 1 : items.map((e) => e.$2).reduce((a, b) => a > b ? a : b);
    return Column(children: [
      for (final (label, v, id) in items)
        InkWell(
          onTap: id == null || onTap == null ? null : () => onTap!(id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              SizedBox(width: 130, child: Text(label, overflow: TextOverflow.ellipsis)),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: max == 0 ? 0 : v / max,
                    minHeight: 12,
                    color: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              SizedBox(width: 64, child: Text('${fmtNum(v)}$unit', textAlign: TextAlign.end, style: theme.textTheme.titleSmall)),
            ]),
          ),
        ),
    ]);
  }
}

/// Tableau défilant horizontalement, triable en touchant l'en-tête d'une colonne numérique.
class _SortableTable extends StatefulWidget {
  const _SortableTable({required this.headers, required this.rows, this.ids, this.onTap, this.cellColor, this.initialSort});

  final List<String> headers;
  final List<List<Object?>> rows;
  /// Identifiant de chaque ligne (joueur, match) pour [onTap].
  final List<String>? ids;
  final void Function(String id)? onTap;
  final Color? Function(int column, Object? value)? cellColor;
  final int? initialSort;

  @override
  State<_SortableTable> createState() => _SortableTableState();
}

class _SortableTableState extends State<_SortableTable> {
  late int? _sort = widget.initialSort;
  bool _asc = false;

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) return _empty('Aucune donnée sur la période.');
    final order = List.generate(widget.rows.length, (i) => i);
    if (_sort != null) {
      int cmp(Object? x, Object? y) {
        if (x == null || y == null) return x == null ? (y == null ? 0 : 1) : -1;
        if (x is num && y is num) return _asc ? x.compareTo(y) : y.compareTo(x);
        return _asc ? '$x'.compareTo('$y') : '$y'.compareTo('$x');
      }

      order.sort((i, j) => cmp(widget.rows[i][_sort!], widget.rows[j][_sort!]));
    }
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sort,
        sortAscending: _asc,
        showCheckboxColumn: false,
        headingRowHeight: 40,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 40,
        columnSpacing: 18,
        horizontalMargin: 8,
        headingTextStyle: theme.textTheme.labelMedium,
        columns: [
          for (var c = 0; c < widget.headers.length; c++)
            DataColumn(
              label: Text(widget.headers[c]),
              numeric: c > 0 && widget.rows.any((r) => r[c] is num),
              onSort: (i, _) => setState(() {
                _asc = _sort == i ? !_asc : (i == 0);
                _sort = i;
              }),
            ),
        ],
        rows: [
          for (final i in order)
            DataRow(
              onSelectChanged: widget.ids == null || widget.onTap == null ? null : (_) => widget.onTap!(widget.ids![i]),
              cells: [
                for (var c = 0; c < widget.headers.length; c++)
                  DataCell(Builder(builder: (context) {
                    final v = widget.rows[i][c];
                    final bg = widget.cellColor?.call(c, v);
                    final t = Text(switch (v) {
                      null => '—',
                      num n => fmtNum(n),
                      DateTime d => DateFormat('dd/MM/yy').format(d),
                      _ => '$v',
                    });
                    return bg == null
                        ? t
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
                            child: t,
                          );
                  })),
              ],
            ),
        ],
      ),
    );
  }
}

Color? _acwrColor(double? v) => v == null
    ? null
    : v > 1.5
        ? Colors.red.withValues(alpha: 0.3)
        : v > 1.3 || v < 0.8
            ? _orange.withValues(alpha: 0.25)
            : _green.withValues(alpha: 0.25);

Color? _wellnessColor(double? v) => v == null
    ? null
    : v < 13
        ? Colors.red.withValues(alpha: 0.3)
        : v < 18
            ? _orange.withValues(alpha: 0.25)
            : _green.withValues(alpha: 0.25);

ListView _page(List<Widget> children) =>
    ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: children);

// ---------------------------------------------------------------------------
// Pages
// ---------------------------------------------------------------------------

class _OverviewPage extends StatelessWidget {
  const _OverviewPage({required this.a});

  final Analytics a;

  @override
  Widget build(BuildContext context) {
    final labels = [for (final w in a.weeks) DateFormat('d/M').format(w.week)];
    final maxY = a.weeks.isEmpty ? 0 : a.weeks.map((w) => w.total).reduce(math.max);
    return _page([
      _Kpis([
        ('Joueurs suivis', '${a.playersFollowed}', Icons.groups_outlined),
        ('Présence aux séances', fmtPct(a.attendance), Icons.how_to_reg_outlined),
        ('Charge totale (UA)', fmtNum(a.totalLoad), Icons.fitness_center),
        ('Bien-être moyen (/25)', a.wellnessAvg == null ? '—' : fmtNum(a.wellnessAvg!), Icons.mood),
        ('Blessures en cours', '${a.openInjuries}', Icons.healing_outlined),
      ]),
      _Section(
        'Charge par semaine (UA)',
        maxY == 0
            ? _empty('Aucune charge (RPE × minutes) sur la période.')
            : Column(children: [
                SizedBox(
                  height: 220,
                  child: BarChart(BarChartData(
                    maxY: maxY * 1.1,
                    gridData: const FlGridData(drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: _titles(labels, reserved: 44),
                    barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (g, _, r, _) => BarTooltipItem(
                        '${weekLabel(a.weeks[g.x].week)}\nSéances ${fmtNum(a.weeks[g.x].sessions)}\nMatchs ${fmtNum(a.weeks[g.x].matches)}',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )),
                    barGroups: [
                      for (var i = 0; i < a.weeks.length; i++)
                        BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: a.weeks[i].total.toDouble(),
                            width: math.max(4, math.min(18, 260 / a.weeks.length)),
                            borderRadius: BorderRadius.circular(2),
                            rodStackItems: [
                              BarChartRodStackItem(0, a.weeks[i].sessions.toDouble(), _sessionColor),
                              BarChartRodStackItem(a.weeks[i].sessions.toDouble(), a.weeks[i].total.toDouble(), _matchColor),
                            ],
                          ),
                        ]),
                    ],
                  )),
                ),
                const SizedBox(height: 6),
                _legend(const [('Séances', _sessionColor), ('Matchs', _matchColor)]),
              ]),
      ),
      _Section(
        'Par joueur',
        _SortableTable(
          headers: const ['Joueur', 'Présence %', 'Matchs', 'Minutes', 'Buts', 'Passes', 'Charge (UA)', 'ACWR'],
          rows: [
            for (final r in a.rows)
              [r.player.fullName, r.attendance == null ? null : (r.attendance! * 100).round(), r.matchesPlayed, r.minutes,
                r.goals, r.assists, r.load, r.acwr == null ? null : double.parse(r.acwr!.toStringAsFixed(2))],
          ],
          ids: [for (final r in a.rows) r.player.id],
          onTap: (id) => context.go('/team/players/$id'),
          cellColor: (c, v) => c == 7 ? _acwrColor(v as double?) : null,
          initialSort: 6,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text('Touchez un en-tête pour trier, une ligne pour ouvrir la fiche du joueur. '
            'ACWR : vert 0,8 à 1,3 · orange hors de cette zone · rouge au-dessus de 1,5.',
            style: Theme.of(context).textTheme.bodySmall),
      ),
    ]);
  }
}

class _LoadPage extends StatelessWidget {
  const _LoadPage({required this.a, required this.players, required this.playerId, required this.onPlayer});

  final Analytics a;
  final List<Player> players;
  final String? playerId;
  final ValueChanged<String?> onPlayer;

  @override
  Widget build(BuildContext context) {
    final labels = [for (final w in a.weeks) DateFormat('d/M').format(w.week)];
    final spots = [
      for (var i = 0; i < a.weeks.length; i++) a.weeks[i].acwr == null ? FlSpot.nullSpot : FlSpot(i.toDouble(), a.weeks[i].acwr!),
    ];
    final values = a.weeks.map((w) => w.acwr).whereType<double>();
    final maxY = math.max(2.0, values.isEmpty ? 0.0 : values.reduce(math.max) + 0.2);
    final weeks = a.weeks.map((w) => w.week).toList();
    final sortedPlayers = [...players]..sort((x, y) => x.fullName.compareTo(y.fullName));
    return _page([
      DropdownButtonFormField<String?>(
        initialValue: playerId,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'ACWR de', isDense: true),
        items: [
          const DropdownMenuItem(value: null, child: Text('Toute l\'équipe')),
          for (final p in sortedPlayers) DropdownMenuItem(value: p.id, child: Text(p.fullName)),
        ],
        onChanged: onPlayer,
      ),
      _Section(
        'ACWR par semaine',
        values.isEmpty
            ? _empty('Pas assez de recul pour l\'ACWR : il faut des charges (RPE × minutes) sur au moins 3 semaines.')
            : Column(children: [
                SizedBox(
                  height: 220,
                  child: LineChart(LineChartData(
                    minY: 0,
                    maxY: maxY,
                    gridData: const FlGridData(drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: _titles(labels, reserved: 36),
                    rangeAnnotations: RangeAnnotations(horizontalRangeAnnotations: [
                      HorizontalRangeAnnotation(y1: 0.8, y2: 1.3, color: _green.withValues(alpha: 0.15)),
                    ]),
                    extraLinesData: ExtraLinesData(horizontalLines: [
                      HorizontalLine(y: 1.5, color: Colors.red, strokeWidth: 1.5, dashArray: [6, 4]),
                    ]),
                    lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => [
                        for (final s in spots)
                          LineTooltipItem('${weekLabel(a.weeks[s.x.round()].week)}\nACWR ${fmtAcwr(s.y)}',
                              const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    )),
                    lineBarsData: [
                      LineChartBarData(spots: spots, color: _sessionColor, barWidth: 3, isCurved: false,
                          dotData: const FlDotData(show: true)),
                    ],
                  )),
                ),
                const SizedBox(height: 6),
                _legend([('Zone habituelle 0,8 – 1,3', _green.withValues(alpha: 0.4)), ('Risque > 1,5', Colors.red)]),
              ]),
      ),
      _Section(
        'Charge par joueur et par semaine (UA)',
        _SortableTable(
          headers: ['Joueur', for (final w in weeks) DateFormat('d/M').format(w), 'Total'],
          rows: [
            for (final r in a.rows) [r.player.fullName, for (final w in weeks) a.loadByPlayerWeek[r.player.id]?[w], r.load],
          ],
          ids: [for (final r in a.rows) r.player.id],
          onTap: (id) => onPlayer(id),
          initialSort: weeks.length + 1,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text('Touchez un joueur pour afficher son ACWR. Colonnes : lundi de chaque semaine.',
            style: Theme.of(context).textTheme.bodySmall),
      ),
    ]);
  }
}

class _WellnessPage extends StatelessWidget {
  const _WellnessPage({required this.a});

  final Analytics a;

  @override
  Widget build(BuildContext context) {
    final days = a.wellnessDays;
    final labels = [for (final d in days) DateFormat('d/M').format(d.day)];
    // Tableau : les 14 derniers jours de réponses (l'export garde toute la période).
    final shownDays = days.length > 14 ? days.sublist(days.length - 14) : days;
    return _page([
      _Kpis([
        ('Bien-être moyen (/25)', a.wellnessAvg == null ? '—' : fmtNum(a.wellnessAvg!), Icons.mood),
        ('Réponses', '${days.fold(0, (s, d) => s + d.scores.length)}', Icons.assignment_turned_in_outlined),
        ('Sommeil moyen (h)', days.isEmpty ? '—' : fmtNum(days.fold(0.0, (s, d) => s + d.sleepHours) / days.length),
            Icons.bedtime_outlined),
      ]),
      _Section(
        'Bien-être moyen (/25) et sommeil (h)',
        days.isEmpty
            ? _empty('Aucun questionnaire de bien-être sur la période.')
            : Column(children: [
                SizedBox(
                  height: 220,
                  child: LineChart(LineChartData(
                    minY: 0,
                    maxY: 25,
                    gridData: const FlGridData(drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: _titles(labels, reserved: 30),
                    lineBarsData: [
                      LineChartBarData(spots: [for (var i = 0; i < days.length; i++) FlSpot(i.toDouble(), days[i].score)],
                          color: _sessionColor, barWidth: 3, dotData: const FlDotData(show: true)),
                      LineChartBarData(spots: [for (var i = 0; i < days.length; i++) FlSpot(i.toDouble(), days[i].sleepHours)],
                          color: _matchColor, barWidth: 2, dashArray: [5, 3], dotData: const FlDotData(show: false)),
                    ],
                  )),
                ),
                const SizedBox(height: 6),
                _legend(const [('Bien-être (/25)', _sessionColor), ('Sommeil (h)', _matchColor)]),
              ]),
      ),
      _Section(
        days.length > 14 ? 'Joueurs × jours (14 derniers jours de réponse)' : 'Joueurs × jours',
        _SortableTable(
          headers: ['Joueur', for (final d in shownDays) DateFormat('d/M').format(d.day)],
          rows: [
            for (final r in a.rows)
              if (a.wellnessByPlayerDay.containsKey(r.player.id))
                [r.player.fullName, for (final d in shownDays) a.wellnessByPlayerDay[r.player.id]![d.day]],
          ],
          cellColor: (c, v) => c == 0 ? null : _wellnessColor((v as num?)?.toDouble()),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text('Score sur 25 (5 notes de 1 à 5) : vert 18 et plus · orange 13 à 17 · rouge 12 et moins.',
            style: Theme.of(context).textTheme.bodySmall),
      ),
    ]);
  }
}

class _MatchesPage extends StatelessWidget {
  const _MatchesPage({required this.a});

  final Analytics a;

  @override
  Widget build(BuildContext context) {
    final played = a.rows.where((r) => r.minutes > 0).toList()..sort((x, y) => y.minutes.compareTo(x.minutes));
    return _page([
      _Kpis([
        ('Matchs', '${a.matches.length}', Icons.sports_soccer),
        ('Victoires', '${a.matches.where((m) => m.result == 'W').length}', Icons.emoji_events_outlined),
        ('Nuls', '${a.matches.where((m) => m.result == 'D').length}', Icons.drag_handle),
        ('Défaites', '${a.matches.where((m) => m.result == 'L').length}', Icons.trending_down),
      ]),
      _Section(
        'Résultats',
        a.matches.isEmpty
            ? _empty('Aucun match sur la période.')
            : Column(children: [
                for (final m in a.matches)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${m.dayLabel} · ${m.opponent}'),
                    subtitle: Text('${homeAwayLabels[m.homeAway]} · ${m.competitionLabel}'
                        '${m.result == null ? ' · ${matchStatuses[m.status]}' : ''}'),
                    trailing: m.result == null ? null : ScoreChip(m),
                    onTap: () => context.go('/matches/${m.id}'),
                  ),
              ]),
      ),
      _Section(
        'Temps de jeu (minutes)',
        played.isEmpty
            ? _empty('Aucune minute jouée sur la période.')
            : _HBars([for (final r in played) (r.player.fullName, r.minutes, r.player.id)],
                unit: "'", onTap: (id) => context.go('/team/players/$id')),
      ),
      _Section(
        'Statistiques des joueurs',
        _SortableTable(
          headers: const ['Joueur', 'Matchs', 'Minutes', 'Buts', 'Passes', 'Jaunes', 'Rouges', 'Charge (UA)'],
          rows: [
            for (final r in a.rows)
              if (r.matchesPlayed > 0 || r.goals > 0 || r.assists > 0 || r.yellows > 0 || r.reds > 0)
                [r.player.fullName, r.matchesPlayed, r.minutes, r.goals, r.assists, r.yellows, r.reds, r.matchLoad],
          ],
          ids: [
            for (final r in a.rows)
              if (r.matchesPlayed > 0 || r.goals > 0 || r.assists > 0 || r.yellows > 0 || r.reds > 0) r.player.id,
          ],
          onTap: (id) => context.go('/team/players/$id'),
          initialSort: 2,
        ),
      ),
    ]);
  }
}

class _InjuriesPage extends StatelessWidget {
  const _InjuriesPage({required this.a});

  final Analytics a;

  @override
  Widget build(BuildContext context) {
    final areas = a.injuriesByArea.entries.toList()..sort((x, y) => y.value.compareTo(x.value));
    return _page([
      _Kpis([
        ('Blessures en cours', '${a.openInjuries}', Icons.healing_outlined),
        ('Blessures sur la période', '${a.injuryCount}', Icons.medical_services_outlined),
        ('Jours d\'absence', '${a.daysOut}', Icons.event_busy_outlined),
      ]),
      _Section(
        'Blessures par zone',
        areas.isEmpty ? _empty('Aucune blessure sur la période.') : _HBars([for (final e in areas) (bodyAreas[e.key] ?? e.key, e.value, null)]),
      ),
      _Section(
        'Liste des blessures',
        _SortableTable(
          headers: const ['Joueur', 'Date', 'Zone', 'Type', 'Gravité', 'En cours', 'Jours'],
          rows: [
            for (final i in a.injuries)
              [i.player?.fullName ?? '—', DateTime.parse(i.injury.date), injuryLabel(i.injury),
                injuryTypes[i.injury.type], severities[i.injury.severity]?.split(' ').first, i.open ? 'Oui' : 'Non', i.daysOut],
          ],
          ids: [for (final i in a.injuries) i.injury.playerId],
          onTap: (id) => context.go('/team/players/$id'),
          cellColor: (c, v) => c == 5 && v == 'Oui' ? Colors.red.withValues(alpha: 0.25) : null,
        ),
      ),
    ]);
  }
}
