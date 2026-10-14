import 'package:flutter_test/flutter_test.dart';
import 'package:perffoot/features/import/importers.dart';

// Rapprochement des noms et lecture des postes des fichiers Excel du club (données fictives).
void main() {
  group('normalizeName', () {
    test('ordre des mots, casse et accents sans effet', () {
      expect(normalizeName('Moreau lucas'), normalizeName('Lucas MOREAU'));
      expect(normalizeName('Théo Lefèbvre'), normalizeName('theo lefebvre'));
    });
    test('« Med » vaut « Mohamed »', () {
      expect(normalizeName('Med Amine Martin'), normalizeName('Mohamed Amine Martin'));
    });
    test('un prénom seul, créé en « Hugo Hugo », garde la même clé', () {
      expect(normalizeName('Hugo Hugo'), normalizeName('Hugo'));
    });
  });

  test('nameSimilarity repère une faute de frappe', () {
    expect(nameSimilarity(normalizeName('Durand Kevin'), normalizeName('Duran Kevin')), greaterThan(0.75));
    expect(nameSimilarity(normalizeName('Durand Kevin'), normalizeName('Blanc Romain')), lessThan(0.75));
  });

  group('splitName', () {
    test('« Nom Prénom » des feuilles de charge', () {
      final n = splitName('Ben Salem Lucas', lastFirst: true);
      expect((n.first, n.last), ('Lucas', 'Ben Salem'));
    });
    test('« Prénom Nom » du formulaire', () {
      final n = splitName('hugo lambert', lastFirst: false);
      expect((n.first, n.last), ('Hugo', 'Lambert'));
    });
  });

  group('parsePosition', () {
    test('abréviations du club, poste secondaire', () {
      expect(parsePosition('DD'), (group: 'DEF', detailed: 'RB', secondary: null));
      expect(parsePosition('DG/DC'), (group: 'DEF', detailed: 'LB', secondary: 'CB'));
      expect(parsePosition('AG/D'), (group: 'FWD', detailed: 'LW', secondary: 'RW'));
      expect(parsePosition('GB').group, 'GK');
    });
    test('saisie libre du formulaire, fautes comprises', () {
      expect(parsePosition('Ariére droit').detailed, 'RB');
      expect(parsePosition('Allier gauche').detailed, 'LW');
      expect(parsePosition('Pivot').detailed, 'DM');
      expect(parsePosition('Axial').detailed, 'CB');
      expect(parsePosition('Milieux').group, 'MID');
      expect(parsePosition(null).group, 'MID');
    });
  });
}
