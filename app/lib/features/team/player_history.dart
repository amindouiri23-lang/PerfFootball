import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/sync.dart';

// Historique d'un joueur (E08), lu dans la base locale. Les séances et matchs supprimés sont exclus.

typedef SessionLine = ({TrainingSession session, SessionPlayer row});
typedef MatchLine = ({FootballMatch match, MatchPlayer row});
typedef WellnessLine = ({TrainingSession session, WellnessEntry entry});

final playerSessionsProvider = StreamProvider.family<List<SessionLine>, String>((ref, playerId) {
  final db = ref.watch(databaseProvider);
  final q = db.select(db.sessionPlayers).join([innerJoin(db.sessions, db.sessions.id.equalsExp(db.sessionPlayers.sessionId))])
    ..where(db.sessionPlayers.playerId.equals(playerId) &
        db.sessionPlayers.deleted.equals(false) &
        db.sessions.deleted.equals(false))
    ..orderBy([OrderingTerm.desc(db.sessions.date), OrderingTerm.desc(db.sessions.startTime)]);
  return q.watch().map((rows) => [
        for (final r in rows) (session: r.readTable(db.sessions), row: r.readTable(db.sessionPlayers)),
      ]);
});

final playerMatchesProvider = StreamProvider.family<List<MatchLine>, String>((ref, playerId) {
  final db = ref.watch(databaseProvider);
  final q = db.select(db.matchPlayers).join([innerJoin(db.matches, db.matches.id.equalsExp(db.matchPlayers.matchId))])
    ..where(db.matchPlayers.playerId.equals(playerId) & db.matchPlayers.deleted.equals(false) & db.matches.deleted.equals(false))
    ..orderBy([OrderingTerm.desc(db.matches.date)]);
  return q.watch().map((rows) => [
        for (final r in rows) (match: r.readTable(db.matches), row: r.readTable(db.matchPlayers)),
      ]);
});

/// Buts, cartons (joueur) et passes décisives (passeur) des matchs non supprimés.
final playerEventsProvider = StreamProvider.family<List<MatchEvent>, String>((ref, playerId) {
  final db = ref.watch(databaseProvider);
  final q = db.select(db.matchEvents).join([innerJoin(db.matches, db.matches.id.equalsExp(db.matchEvents.matchId))])
    ..where((db.matchEvents.playerId.equals(playerId) | db.matchEvents.assistPlayerId.equals(playerId)) &
        db.matchEvents.deleted.equals(false) &
        db.matches.deleted.equals(false));
  return q.watch().map((rows) => [for (final r in rows) r.readTable(db.matchEvents)]);
});

final playerInjuriesProvider = StreamProvider.family<List<Injury>, String>((ref, playerId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.injuries)
        ..where((i) => i.playerId.equals(playerId) & i.deleted.equals(false))
        ..orderBy([(i) => OrderingTerm.desc(i.date)]))
      .watch();
});

final playerWellnessProvider = StreamProvider.family<List<WellnessLine>, String>((ref, playerId) {
  final db = ref.watch(databaseProvider);
  final q = db.select(db.wellness).join([innerJoin(db.sessions, db.sessions.id.equalsExp(db.wellness.sessionId))])
    ..where(db.wellness.playerId.equals(playerId) & db.wellness.deleted.equals(false) & db.sessions.deleted.equals(false))
    ..orderBy([OrderingTerm.desc(db.sessions.date)]);
  return q.watch().map((rows) => [
        for (final r in rows) (session: r.readTable(db.sessions), entry: r.readTable(db.wellness)),
      ]);
});

/// Statistiques de la fiche joueur, calculées à l'affichage (jamais saisies, specs E08).
class PlayerStats {
  PlayerStats(List<SessionLine> sessions, List<MatchLine> matches, List<MatchEvent> events, String playerId)
      : sessionsHeld = sessions.where((l) => l.session.status != 'planned').length,
        sessionsPresent = sessions.where((l) => l.session.status != 'planned' && l.row.present).length,
        matchesPlayed = matches.where((l) => l.row.present && (l.row.minutesPlayed ?? 0) > 0).length,
        minutes = matches.fold(0, (sum, l) => sum + (l.row.present ? l.row.minutesPlayed ?? 0 : 0)),
        goals = events.where((e) => e.type == 'goal' && e.playerId == playerId).length,
        assists = events.where((e) => e.type == 'goal' && e.assistPlayerId == playerId).length,
        yellows = events.where((e) => e.type == 'yellow_card' && e.playerId == playerId).length,
        reds = events.where((e) => e.type == 'red_card' && e.playerId == playerId).length;

  final int sessionsHeld;
  final int sessionsPresent;
  final int matchesPlayed;
  final int minutes;
  final int goals;
  final int assists;
  final int yellows;
  final int reds;

  /// Taux de présence aux séances, en %, ou null sans séance.
  int? get attendance => sessionsHeld == 0 ? null : (sessionsPresent * 100 / sessionsHeld).round();
}
