import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:perffoot/core/pdf_kit.dart';
import 'package:perffoot/data/database.dart';
import 'package:perffoot/features/tactics/tactic_board.dart';
import 'package:perffoot/features/tactics/tactic_export.dart';
import 'package:perffoot/features/tactics/tactic_render.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  final player = Player(id: 'p1', createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't',
      firstName: 'Youssef', lastName: 'Ayari', position: 'MID', shirtNumber: 10);
  final board = TacticBoard(
    tokens: [
      BoardToken(id: 'a', kind: 'us', x: 0.2, y: 0.1, role: 'Tireur', playerId: 'p1'),
      BoardToken(id: 'b', kind: 'them', x: 0.5, y: 0.2, label: 'G'),
      BoardToken(id: 'c', kind: 'ball', x: 0.02, y: 0.01),
    ],
    arrows: [BoardArrow(id: 'r', kind: 'ball', x1: 0.02, y1: 0.01, x2: 0.5, y2: 0.15)],
  );
  final tactic = Tactic(id: 't1', createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't',
      name: 'Corner rentrant', kind: 'corner', side: 'attack', pitch: 'half', board: board.encode(), notes: 'Premier poteau');

  testWidgets('schéma de la tactique en PNG, puis en PDF', (tester) async {
    await tester.runAsync(() async {
      final png = await renderTacticPng(tactic, {'p1': player}, width: 400);
      expect(png.sublist(1, 4), 'PNG'.codeUnits);
      final pdf = await buildTacticPdf(tactic: tactic, pngs: [png], players: {'p1': player}, team: 'Cadet A');
      expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    });
  });

  test('légende : numéro, joueur et rôle des pions renseignés', () {
    expect(tacticLegend(tactic, {'p1': player}), [
      ['10', 'Youssef Ayari', 'Tireur'],
    ]);
  });

  test('nom de fichier sans accents ni signes', () {
    expect(fileSafe('Étoile du Sahel · J5'), 'Etoile_du_Sahel_J5');
  });
}
