import 'package:flutter_test/flutter_test.dart';
import 'package:perffoot/core/permissions.dart';
import 'package:perffoot/core/router.dart';

void main() {
  test('administrateur : tout ; joueur : rien par la matrice', () {
    expect(const Perms(role: 'admin').can('matchs.delete'), isTrue);
    expect(const Perms(role: 'player', rolePerms: {'matchs.view': true}).can('matchs.view'), isFalse);
  });

  test('une exception du compte l\'emporte sur la matrice du rôle', () {
    const p = Perms(role: 'assistant_coach', rolePerms: {'matchs.delete': false, 'tests.view': true},
        overrides: {'matchs.delete': true, 'tests.view': false});
    expect(p.can('matchs.delete'), isTrue);
    expect(p.can('tests.view'), isFalse);
    expect(p.can('inconnue.view'), isFalse);
  });

  test('chaque écran demande la bonne permission', () {
    expect(requiredPermission('/sessions/new'), 'seances.add');
    expect(requiredPermission('/sessions/abc/attendance'), 'seances.appel');
    expect(requiredPermission('/sessions/abc'), 'seances.view');
    expect(requiredPermission('/matches/abc/squad'), 'matchs.jouer');
    expect(requiredPermission('/matches/abc/tactic/t1'), 'tactiques.view');
    expect(requiredPermission('/team/players/p1/medical'), 'medical.edit');
    expect(requiredPermission('/team/import'), 'import.use');
    expect(requiredPermission('/team'), 'effectif.view');
    expect(requiredPermission('/home'), isNull);
    expect(requiredPermission('/profile'), isNull);
  });

  test('toutes les clés du catalogue ont un libellé', () {
    for (final f in permissionCatalog) {
      for (final a in f.actions.keys) {
        expect(permissionLabel('${f.key}.$a'), contains(f.label));
      }
    }
  });
}
