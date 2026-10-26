import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:perffoot/features/tactics/tactic_board.dart';

void main() {
  BoardToken token() => BoardToken(id: 'a', kind: 'us', x: 0.2, y: 0.8);

  test('étapes : position héritée, puis déplacée ; animation interpolée', () {
    final t = token();
    final board = TacticBoard(tokens: [t]);
    board.addStep(0);
    board.addStep(1);
    expect(board.stepCount, 3);
    expect(board.positionAt(t, 2), const Offset(0.2, 0.8));
    board.setPosition(t, 2, const Offset(0.6, 0.4));
    expect(board.positionAt(t, 1), const Offset(0.2, 0.8));
    expect(board.positionAt(t, 2), const Offset(0.6, 0.4));
    final mid = board.frameAt(1.5).tokens.single;
    expect(mid.x, closeTo(0.4, 1e-9));
    expect(mid.y, closeTo(0.6, 1e-9));
    final back = TacticBoard.decode(board.encode());
    expect(back.stepCount, 3);
    expect(back.positionAt(back.tokens.single, 2), const Offset(0.6, 0.4));
  });

  test('animation : trois étapes enchaînées, ballon le long de sa trajectoire courbe', () {
    final ball = BoardToken(id: 'ball', kind: 'ball', x: 0, y: 0);
    final p = token();
    final board = TacticBoard(tokens: [ball, p], arrows: [
      BoardArrow(id: 'b', kind: 'ball', x1: 0, y1: 0, x2: 1, y2: 0)..bendThrough(const Offset(0.5, 0.4)),
    ]);
    board
      ..addStep(0)
      ..addStep(1);
    board.setPosition(ball, 1, const Offset(1, 0));
    board.setPosition(p, 2, const Offset(0.6, 0.2));
    // Étape 1 → 2 : le ballon suit la courbe (passe par le milieu de la flèche), pas la ligne droite.
    final mid = board.frameAt(0.5).tokens.firstWhere((t) => t.kind == 'ball');
    expect(mid.x, closeTo(0.5, 1e-9));
    expect(mid.y, closeTo(0.4, 1e-9));
    // Étape 2 → 3 : le joueur glisse aussi (pas de saut).
    final p25 = board.frameAt(1.5).tokens.firstWhere((t) => t.id == 'a');
    expect(p25.x, closeTo(0.4, 1e-9));
    expect(p25.y, closeTo(0.5, 1e-9));
  });

  test('course tracée depuis un joueur : accrochée, et suivie à l\'étape ajoutée', () {
    final p = token();
    final ball = BoardToken(id: 'ball', kind: 'ball', x: 0.1, y: 0.1);
    final board = TacticBoard(tokens: [p, ball]);
    // Départ à 3 % du joueur : la flèche s'accroche à lui.
    board.addArrow(0, BoardArrow(id: 'r', kind: 'run', x1: 0.22, y1: 0.81, x2: 0.5, y2: 0.3)..bendThrough(const Offset(0.2, 0.5)));
    expect(board.arrows.single.x1, 0.2);
    expect(board.arrows.single.y1, 0.8);
    board.addStep(0);
    expect(board.positionAt(p, 1), const Offset(0.5, 0.3));
    expect(board.positionAt(ball, 1), const Offset(0.1, 0.1));
    // Le joueur passe par la courbe, pas par la ligne droite.
    final mid = board.frameAt(0.5).tokens.firstWhere((t) => t.id == 'a');
    final m = board.arrows.single.point(0.5);
    expect(mid.x, closeTo(m.dx, 1e-9));
    expect(mid.y, closeTo(m.dy, 1e-9));
    // Trajectoire tracée depuis le ballon alors que l'étape 2 existe : le ballon y est placé au bout.
    board.addArrow(0, BoardArrow(id: 'b', kind: 'ball', x1: 0.12, y1: 0.1, x2: 0.6, y2: 0.2));
    expect(board.positionAt(ball, 1), const Offset(0.6, 0.2));
  });

  test('flèche courbe : passe par la poignée, se relit, se redresse', () {
    final a = BoardArrow(id: 'r', kind: 'run', x1: 0, y1: 0, x2: 1, y2: 0)..bendThrough(const Offset(0.5, 0.3));
    expect(a.point(0.5).dx, closeTo(0.5, 1e-9));
    expect(a.point(0.5).dy, closeTo(0.3, 1e-9));
    final back = BoardArrow.fromJson(a.toJson());
    expect(back.curved, isTrue);
    back.straighten();
    expect(back.toJson().containsKey('cx'), isFalse);
  });

  test('terrain horizontal : but du haut à droite, aller-retour exact', () {
    const size = Size(300, 200);
    expect(boardToScreen(const Offset(0.5, 0), size, true), const Offset(300, 100));
    final p = boardToScreen(const Offset(0.25, 0.7), size, true);
    final f = screenToBoard(p, size, true);
    expect(f.dx, closeTo(0.25, 1e-9));
    expect(f.dy, closeTo(0.7, 1e-9));
  });

  test('symétrie : pions, étapes et courbes', () {
    final t = token();
    final board = TacticBoard(tokens: [t], arrows: [BoardArrow(id: 'r', kind: 'run', x1: 0.1, y1: 0.5, x2: 0.3, y2: 0.2, cx: 0.2, cy: 0.1)]);
    board.addStep(0);
    board.setPosition(t, 1, const Offset(0.1, 0.1));
    board.mirror();
    expect(t.x, closeTo(0.8, 1e-9));
    expect(board.positionAt(t, 1).dx, closeTo(0.9, 1e-9));
    expect(board.arrows.single.cx, closeTo(0.8, 1e-9));
  });
}
