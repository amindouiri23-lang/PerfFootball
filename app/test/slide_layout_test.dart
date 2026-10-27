import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:perffoot/data/database.dart';
import 'package:perffoot/features/tactics/tactic_board.dart';
import 'package:perffoot/features/tactics/tactic_render.dart';
import 'package:perffoot/features/viewing/slide_layout.dart';

void main() {
  test('mise en page : texte et images relus à l\'identique ; vide = valeurs par défaut', () {
    final l = SlideLayout(
      text: SlideTextBox(x: 0.1, y: 0.5, w: 0.4, size: 1.6, align: 'center', bold: true, color: 'yellow'),
      images: [SlideImage(path: 'teams/t/viewing/v/a.jpg', x: 0.6, y: 0.1, w: 0.3, ar: 1.5)],
    );
    final back = SlideLayout.decode(l.encode());
    expect(back.text.size, 1.6);
    expect(back.text.align, 'center');
    expect(back.text.bold, isTrue);
    expect(back.text.color, 'yellow');
    expect(back.images.single.path, 'teams/t/viewing/v/a.jpg');
    // Hauteur déduite du rapport de l'image et de la scène 16:9.
    expect(back.images.single.h, closeTo(0.3 * (16 / 9) / 1.5, 1e-9));
    expect(SlideLayout.decode(null).images, isEmpty);
    expect(SlideLayout.decode(null).text.align, 'left');
  });

  test('affichage des joueurs : numéro, initiales, et initiales à défaut', () {
    final p = Player(id: 'p', createdAt: 'x', updatedAt: 'x', deleted: false, isDirty: false, teamId: 't',
        firstName: 'Youssef', lastName: 'Ayari', position: 'MID', shirtNumber: 10);
    final noNumber = p.copyWith(id: 'q', shirtNumber: const Value(null));
    final players = {'p': p, 'q': noNumber};
    final a = BoardToken(id: 'a', kind: 'us', x: 0, y: 0, playerId: 'p');
    final b = BoardToken(id: 'b', kind: 'us', x: 0, y: 0, playerId: 'q');
    expect(tokenText(a, players), '10');
    expect(tokenText(a, players, 'initials'), 'YA');
    expect(tokenText(b, players), 'YA');
    expect(tokenText(a, players, 'photo_number'), '10');
    expect(tokenPhoto(a, players, 'number'), isNull);
    // Choix enregistré avec la tactique, et conservé dans l'animation.
    final board = TacticBoard(tokens: [a], display: 'initials');
    expect(TacticBoard.decode(board.encode()).display, 'initials');
    expect(board.frameAt(0).display, 'initials');
  });
}
