import 'package:flutter_test/flutter_test.dart';
import 'package:perffoot/data/database.dart';
import 'package:perffoot/features/matches/match_repository.dart';
import 'package:perffoot/features/tactics/tactic_board.dart';
import 'package:perffoot/features/tactics/tactic_repository.dart';

FootballMatch _match(String status, int? gf, int? ga) => FootballMatch(
      id: 'm', createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't', date: '2026-10-18',
      kickOffTime: '15:00:00', opponent: 'EST', homeAway: 'H', competition: 'league', durationMin: 90,
      goalsFor: gf, goalsAgainst: ga, status: status, rpeRequested: false,
    );

void main() {
  test('le tableau se relit à l\'identique', () {
    final board = startingBoard('corner', 'attack', 'half')
      ..tokens.add(BoardToken(id: 'p', kind: 'us', x: 0.3, y: 0.2, role: 'Tireur', playerId: 'j1'))
      ..arrows.add(BoardArrow(id: 'a', kind: 'run', x1: 0.3, y1: 0.4, x2: 0.45, y2: 0.1));
    final back = TacticBoard.decode(board.encode());
    expect(back.encode(), board.encode());
    expect(back.tokens.firstWhere((t) => t.id == 'p').role, 'Tireur');
    expect(back.ball, isNotNull);
  });

  test('la symétrie fait passer un corner de gauche à droite', () {
    final board = startingBoard('corner', 'attack', 'half')
      ..arrows.add(BoardArrow(id: 'a', kind: 'ball', x1: 0.1, y1: 0, x2: 0.4, y2: 0.1));
    board.mirror();
    expect(board.ball!.x, closeTo(0.98, 1e-9));
    expect(board.arrows.single.x2, closeTo(0.6, 1e-9));
  });

  test('un tableau vide (valeur par défaut du serveur) se lit sans erreur', () {
    expect(TacticBoard.decode('{}').tokens, isEmpty);
  });

  test('forfait compté au bilan, match arrêté ou annulé non compté', () {
    expect(_match('forfeit', 3, 0).result, 'W');
    expect(_match('forfeit', 0, 3).result, 'L');
    expect(_match('abandoned', 1, 0).result, isNull);
    expect(_match('cancelled', null, null).result, isNull);
    expect(_match('completed', 2, 2).result, 'D');
    expect(_match('postponed', null, null).notPlayed, isTrue);
  });
}
