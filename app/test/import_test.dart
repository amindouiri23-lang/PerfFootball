import 'package:flutter_test/flutter_test.dart';
import 'package:perffoot/data/database.dart';
import 'package:perffoot/features/import/import_repository.dart';
import 'package:perffoot/features/import/importers.dart';

Player _player(String id, String first, String last) => Player(
      id: id, createdAt: '', updatedAt: '', deleted: false, isDirty: false, teamId: 't', firstName: first,
      lastName: last, position: 'MID');

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

  test('matchNames : un joueur déjà reconnu ne reçoit pas un second nom proche', () {
    final plan = ImportPlan(ImportKind.training, 'semaine')
      ..addName('Martin Lucas') // identique à « Lucas Martin »
      ..addName('Marin Lucas') // proche de « Lucas Martin », mais c'est un autre joueur
      ..addName('Duran Kevin'); // faute de frappe de « Kevin Durand »
    final m = matchNames(plan, [_player('a', 'Lucas', 'Martin'), _player('b', 'Kevin', 'Durand')]);
    expect(m[normalizeName('Martin Lucas')]!.playerId, 'a');
    expect(m[normalizeName('Marin Lucas')]!.create, isTrue);
    expect(m[normalizeName('Duran Kevin')]!.playerId, 'b');
    expect(m[normalizeName('Duran Kevin')]!.confidence, lessThan(1));
  });

  group('cleanFormValue', () {
    test('retire la traduction arabe d\'un libellé du formulaire', () {
      expect(cleanFormValue('Marié(e) (متزوج/متزوجة)'), 'Marié(e)');
      expect(cleanFormValue('Nom (الاسم)'), 'Nom');
    });
    test('garde une réponse écrite en arabe', () {
      expect(cleanFormValue('تونس'), 'تونس');
      expect(cleanFormValue('معهد (المنزه)'), 'معهد (المنزه)');
    });
    test('réponses vides', () {
      expect(cleanFormValue(' . '), isNull);
      expect(cleanFormValue('anonymous'), isNull);
    });
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
