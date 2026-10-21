import 'package:flutter_test/flutter_test.dart';
import 'package:perffoot/features/matches/match_form_screen.dart';

void main() {
  final all = [...ligue1Clubs.keys, 'Olympique Sidi Bouzid'];

  test('champ vide : toute la liste de Ligue 1', () {
    expect(opponentOptions('', all), containsAll(ligue1Clubs.keys));
    expect(ligue1Clubs, hasLength(15));
  });

  test('recherche sans accents et par sigle', () {
    expect(opponentOptions('etoi', all), ['Étoile du Sahel']);
    expect(opponentOptions('EST', all), contains('Espérance de Tunis'));
    expect(opponentOptions('css', all), ['CS Sfaxien']);
    expect(opponentOptions('sidi', all), ['Olympique Sidi Bouzid']);
  });

  test('nom inconnu : aucune suggestion, la saisie libre reste possible', () {
    expect(opponentOptions('Nouvelle équipe', all), isEmpty);
  });
}
