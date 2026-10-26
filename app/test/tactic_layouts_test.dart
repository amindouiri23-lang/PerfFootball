import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:perffoot/features/tactics/tactic_board.dart';
import 'package:perffoot/features/tactics/tactic_layouts.dart';

void main() {
  test('toutes les dispositions tiennent dans le terrain, sur les deux tailles de terrain', () {
    for (final l in tacticLayouts) {
      for (final pitch in ['half', 'full']) {
        final tokens = layoutTokens(l, pitch);
        expect(tokens, isNotEmpty, reason: l.name);
        for (final t in tokens) {
          expect(t.x, inInclusiveRange(0, 1), reason: '${l.name} $pitch');
          expect(t.y, inInclusiveRange(0, 1), reason: '${l.name} $pitch');
        }
        expect(tokens.map((t) => t.id).toSet().length, tokens.length, reason: 'identifiants uniques');
      }
    }
  });

  test('dispositif : 11 joueurs ; adverse : gardien près du but attaqué', () {
    final us = layoutTokens(tacticLayouts.firstWhere((l) => l.name == '4-4-2' && l.category == layoutCategories[0]), 'full');
    expect(us.where((t) => t.kind == 'us'), hasLength(11));
    final them = layoutTokens(tacticLayouts.firstWhere((l) => l.name == '4-4-2' && l.category == layoutCategories[1]), 'full');
    final keeper = them.firstWhere((t) => t.role == 'GB');
    expect(keeper.y, lessThan(0.15));
  });

  test('le matériel glisse en ligne droite et ne s\'accroche pas à une course', () {
    final cone = BoardToken(id: 'c', kind: 'cone', x: 0.5, y: 0.5);
    final board = TacticBoard(tokens: [cone]);
    board.addArrow(0, BoardArrow(id: 'r', kind: 'run', x1: 0.5, y1: 0.5, x2: 0.9, y2: 0.9));
    board.addStep(0);
    expect(board.positionAt(cone, 1), const Offset(0.5, 0.5));
  });
}
