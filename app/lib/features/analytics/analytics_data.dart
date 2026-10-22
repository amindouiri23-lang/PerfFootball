import '../../data/database.dart';

// Tableau de bord (remplace le rapport Power BI) : mêmes pages, mêmes calculs, sur les données de l'appareil.
// Charge = RPE × minutes ; aiguë = 7 derniers jours ; chronique = 28 derniers jours ÷ 4 ; ACWR = aiguë ÷ chronique.
// Ce fichier ne dépend pas de Flutter : les calculs se testent seuls (test/analytics_test.dart).

/// Données d'une équipe, telles que lues dans la base locale.
class AnalyticsInput {
  const AnalyticsInput({
    required this.players,
    required this.sessions,
    required this.sessionPlayers,
    required this.matches,
    required this.matchPlayers,
    required this.events,
    required this.wellness,
    required this.injuries,
  });

  final List<Player> players;
  final List<TrainingSession> sessions;
  final List<SessionPlayer> sessionPlayers;
  final List<FootballMatch> matches;
  final List<MatchPlayer> matchPlayers;
  final List<MatchEvent> events;
  /// Réponses au questionnaire de bien-être, avec leur date (celle de la séance ou du questionnaire).
  final List<({WellnessEntry entry, DateTime day})> wellness;
  final List<Injury> injuries;
}

/// Période et joueurs retenus. [to] est inclus.
class AnalyticsFilter {
  const AnalyticsFilter({required this.from, required this.to, this.position, this.playerId});

  final DateTime from;
  final DateTime to;
  /// GK, DEF, MID, FWD ; null = tous.
  final String? position;
  /// Joueur seul (page Charge et ACWR) ; null = toute l'équipe.
  final String? playerId;

  bool inPeriod(DateTime d) => !d.isBefore(from) && !d.isAfter(to);
}

/// Une charge (séance ou match) d'un joueur un jour donné.
typedef LoadEntry = ({String playerId, DateTime day, int load, bool match});

/// Lundi de la semaine de [d].
DateTime weekStart(DateTime d) => DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

DateTime _day(String iso) {
  final d = DateTime.parse(iso);
  return DateTime(d.year, d.month, d.day);
}

class PlayerRow {
  PlayerRow(this.player);

  final Player player;
  int sessionsPlanned = 0;
  int sessionsPresent = 0;
  int matchesPlayed = 0;
  int minutes = 0;
  int goals = 0;
  int assists = 0;
  int yellows = 0;
  int reds = 0;
  int sessionLoad = 0;
  int matchLoad = 0;
  double? acwr;

  int get load => sessionLoad + matchLoad;
  double? get attendance => sessionsPlanned == 0 ? null : sessionsPresent / sessionsPlanned;
}

class WeekLoad {
  WeekLoad(this.week);

  final DateTime week;
  int sessions = 0;
  int matches = 0;
  double? acwr;

  int get total => sessions + matches;
}

class WellnessDay {
  WellnessDay(this.day);

  final DateTime day;
  final List<int> scores = [];
  final List<double> sleep = [];

  double get score => scores.reduce((a, b) => a + b) / scores.length;
  double get sleepHours => sleep.reduce((a, b) => a + b) / sleep.length;
}

class InjuryRow {
  const InjuryRow(this.injury, this.player, this.daysOut);

  final Injury injury;
  final Player? player;
  final int daysOut;

  bool get open => injury.returnDate == null;
}

/// Toutes les pages du tableau de bord pour un filtre.
class Analytics {
  Analytics._(this.filter);

  final AnalyticsFilter filter;

  // Vue d'ensemble
  late final int playersFollowed;
  late final double? attendance;
  late final int totalLoad;
  late final double? wellnessAvg;
  late final int openInjuries;
  late final List<WeekLoad> weeks;
  late final List<PlayerRow> rows;

  // Charge et ACWR : ACWR par semaine (équipe ou joueur choisi) et charge joueur × semaine.
  late final Map<String, Map<DateTime, int>> loadByPlayerWeek;

  // Bien-être
  late final List<WellnessDay> wellnessDays;
  late final Map<String, Map<DateTime, double>> wellnessByPlayerDay;

  // Matchs
  late final List<FootballMatch> matches;

  // Blessures
  late final List<InjuryRow> injuries;
  late final Map<String, int> injuriesByArea;

  int get injuryCount => injuries.length;
  int get daysOut => injuries.fold(0, (s, i) => s + i.daysOut);

  static Analytics compute(AnalyticsInput input, AnalyticsFilter f, {DateTime? today}) {
    final a = Analytics._(f);
    final now = today ?? DateTime.now();
    final players = input.players.where((p) => f.position == null || p.position == f.position).toList()
      ..sort((x, y) => x.lastName.toLowerCase().compareTo(y.lastName.toLowerCase()));
    final ids = {for (final p in players) p.id};
    final byId = {for (final p in input.players) p.id: p};
    a.playersFollowed = players.length;

    // Charges de toute l'histoire : l'ACWR du début de période a besoin des 4 semaines qui précèdent.
    final sessions = {for (final s in input.sessions) s.id: s};
    final matches = {for (final m in input.matches) m.id: m};
    final loads = <LoadEntry>[];
    for (final r in input.sessionPlayers) {
      final s = sessions[r.sessionId];
      if (s == null || !ids.contains(r.playerId) || !r.present || r.rpe == null || r.durationMin == null) continue;
      loads.add((playerId: r.playerId, day: _day(s.date), load: r.rpe! * r.durationMin!, match: false));
    }
    for (final r in input.matchPlayers) {
      final m = matches[r.matchId];
      if (m == null || !ids.contains(r.playerId) || r.rpe == null || (r.minutesPlayed ?? 0) == 0) continue;
      loads.add((playerId: r.playerId, day: _day(m.date), load: r.rpe! * r.minutesPlayed!, match: true));
    }
    final inPeriod = loads.where((l) => f.inPeriod(l.day)).toList();

    // Lignes par joueur
    final rows = {for (final p in players) p.id: PlayerRow(p)};
    for (final r in input.sessionPlayers) {
      final s = sessions[r.sessionId];
      final row = rows[r.playerId];
      if (s == null || row == null || s.status != 'completed' || !f.inPeriod(_day(s.date))) continue;
      row.sessionsPlanned++;
      if (r.present) row.sessionsPresent++;
    }
    for (final r in input.matchPlayers) {
      final m = matches[r.matchId];
      final row = rows[r.playerId];
      if (m == null || row == null || !f.inPeriod(_day(m.date)) || (r.minutesPlayed ?? 0) == 0) continue;
      row.matchesPlayed++;
      row.minutes += r.minutesPlayed!;
    }
    for (final e in input.events) {
      final m = matches[e.matchId];
      if (m == null || !f.inPeriod(_day(m.date))) continue;
      final row = rows[e.playerId];
      switch (e.type) {
        case 'goal':
          row?.goals++;
          if (e.assistPlayerId != null) rows[e.assistPlayerId]?.assists++;
        case 'yellow_card':
          row?.yellows++;
        case 'red_card':
          row?.reds++;
      }
    }
    for (final l in inPeriod) {
      final row = rows[l.playerId]!;
      if (l.match) {
        row.matchLoad += l.load;
      } else {
        row.sessionLoad += l.load;
      }
    }
    final acwrDay = f.to.isAfter(now) ? DateTime(now.year, now.month, now.day) : f.to;
    for (final row in rows.values) {
      row.acwr = acwr(loads.where((l) => l.playerId == row.player.id), acwrDay);
    }
    a.rows = rows.values.toList()..sort((x, y) => y.load.compareTo(x.load));
    final planned = a.rows.fold(0, (s, r) => s + r.sessionsPlanned);
    a.attendance = planned == 0 ? null : a.rows.fold(0, (s, r) => s + r.sessionsPresent) / planned;
    a.totalLoad = inPeriod.fold(0, (s, l) => s + l.load);

    // Semaines (équipe, ou le joueur choisi pour la page Charge et ACWR)
    final scoped = f.playerId == null ? loads : loads.where((l) => l.playerId == f.playerId).toList();
    final weeks = <DateTime, WeekLoad>{};
    for (var w = weekStart(f.from); !w.isAfter(f.to); w = DateTime(w.year, w.month, w.day + 7)) {
      weeks[w] = WeekLoad(w);
    }
    for (final l in scoped.where((l) => f.inPeriod(l.day))) {
      final w = weeks[weekStart(l.day)]!;
      if (l.match) {
        w.matches += l.load;
      } else {
        w.sessions += l.load;
      }
    }
    for (final w in weeks.values) {
      final end = DateTime(w.week.year, w.week.month, w.week.day + 6);
      if (!end.isAfter(DateTime(now.year, now.month, now.day + 6))) {
        w.acwr = acwr(scoped, end.isAfter(now) ? DateTime(now.year, now.month, now.day) : end);
      }
    }
    a.weeks = weeks.values.toList();
    a.loadByPlayerWeek = {};
    for (final l in inPeriod) {
      final m = a.loadByPlayerWeek.putIfAbsent(l.playerId, () => {});
      m[weekStart(l.day)] = (m[weekStart(l.day)] ?? 0) + l.load;
    }

    // Bien-être
    final days = <DateTime, WellnessDay>{};
    a.wellnessByPlayerDay = {};
    final allScores = <int>[];
    for (final w in input.wellness) {
      if (!ids.contains(w.entry.playerId) || !f.inPeriod(w.day)) continue;
      final score = w.entry.sleepQuality + w.entry.fatigue + w.entry.soreness + w.entry.stress + w.entry.mood;
      final d = days.putIfAbsent(w.day, () => WellnessDay(w.day));
      d.scores.add(score);
      d.sleep.add(w.entry.sleepHours);
      allScores.add(score);
      a.wellnessByPlayerDay.putIfAbsent(w.entry.playerId, () => {})[w.day] = score.toDouble();
    }
    a.wellnessDays = days.values.toList()..sort((x, y) => x.day.compareTo(y.day));
    a.wellnessAvg = allScores.isEmpty ? null : allScores.reduce((x, y) => x + y) / allScores.length;

    // Matchs de la période, du plus récent au plus ancien
    a.matches = input.matches.where((m) => f.inPeriod(_day(m.date))).toList()..sort((x, y) => y.date.compareTo(x.date));

    // Blessures : survenues dans la période ; jours d'absence jusqu'au retour (ou jusqu'à aujourd'hui)
    a.injuries = [
      for (final i in input.injuries)
        if (ids.contains(i.playerId) && f.inPeriod(_day(i.date)))
          InjuryRow(i, byId[i.playerId],
              (i.returnDate == null ? DateTime(now.year, now.month, now.day) : _day(i.returnDate!)).difference(_day(i.date)).inDays),
    ]..sort((x, y) => y.injury.date.compareTo(x.injury.date));
    a.openInjuries = input.injuries.where((i) => ids.contains(i.playerId) && i.returnDate == null).length;
    a.injuriesByArea = {};
    for (final i in a.injuries) {
      a.injuriesByArea[i.injury.bodyArea] = (a.injuriesByArea[i.injury.bodyArea] ?? 0) + 1;
    }
    return a;
  }
}

/// ACWR au jour [day] : charge des 7 derniers jours ÷ (charge des 28 derniers jours ÷ 4). Null sans charge chronique,
/// ou sans au moins 3 semaines de recul : une seule semaine de charge donnerait un ACWR de 4, qui ne dit rien.
double? acwr(Iterable<LoadEntry> loads, DateTime day) {
  final end = DateTime(day.year, day.month, day.day + 1);
  final history = DateTime(day.year, day.month, day.day - 20);
  if (!loads.any((l) => l.day.isBefore(history))) return null;
  int sum(int days) {
    final start = DateTime(day.year, day.month, day.day - days + 1);
    return loads.where((l) => !l.day.isBefore(start) && l.day.isBefore(end)).fold(0, (s, l) => s + l.load);
  }

  final chronic = sum(28) / 4;
  return chronic == 0 ? null : sum(7) / chronic;
}
