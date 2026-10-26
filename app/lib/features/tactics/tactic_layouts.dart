import '../matches/lineup_screen.dart' show formations;
import 'tactic_board.dart';

// Dispositions prêtes à poser sur le tableau : dispositifs (nous ou adversaires), coups de pied arrêtés et
// ateliers d'entraînement avec leur matériel. Positions en fraction du terrain en portrait : x en largeur,
// y depuis le but du haut (le but attaqué ; à l'horizontale, il est à droite).

/// Un élément d'une disposition : sorte de pion, position, texte du pion et légende.
typedef LayoutItem = ({String kind, double x, double y, String? label, String? role, double angle});

class TacticLayout {
  const TacticLayout(this.name, this.category, this.items, {this.description});

  final String name;
  final String category;
  final String? description;
  final List<LayoutItem> Function(String pitch) items;
}

LayoutItem _i(String kind, double x, double y, [String? label, String? role, double angle = 0]) =>
    (kind: kind, x: x, y: y, label: label, role: role, angle: angle);

/// Profondeur d'un dispositif (y de 0,17 à 0,92 sur terrain entier) ramenée au terrain affiché.
double _depth(double y, String pitch) => pitch == 'full' ? y : 0.12 + (y - 0.17) * (0.83 / 0.75);

List<LayoutItem> _formation(String name, String pitch, {required bool us}) => [
      for (final (i, (role, x, y)) in formations[name]!.indexed)
        us
            ? _i('us', x, _depth(y, pitch), '${i + 1}', role)
            // L'adversaire défend le but du haut : dispositif retourné, gardien en haut.
            : _i('them', 1 - x, pitch == 'full' ? 1 - y : 1 - _depth(y, pitch), '${i + 1}', role),
    ];

const layoutCategories = ['Dispositif de l\'équipe', 'Dispositif adverse', 'Coups de pied arrêtés', 'Ateliers d\'entraînement'];

final tacticLayouts = <TacticLayout>[
  for (final f in formations.keys)
    TacticLayout(f, layoutCategories[0], (p) => _formation(f, p, us: true), description: 'Nos 11 joueurs, numérotés, avec leur poste'),
  for (final f in formations.keys)
    TacticLayout(f, layoutCategories[1], (p) => _formation(f, p, us: false), description: 'L\'adversaire, gardien devant le but attaqué'),
  TacticLayout('Corner offensif (côté droit)', layoutCategories[2], (_) => [
        _i('ball', 0.985, 0.008),
        _i('us', 0.96, 0.03, 'T', 'Tireur'),
        _i('us', 0.56, 0.07, '9', '1er poteau'),
        _i('us', 0.44, 0.09, '10', '2e poteau'),
        _i('us', 0.5, 0.12, '5', 'Point de penalty'),
        _i('us', 0.62, 0.15, '4', 'Retour'),
        _i('us', 0.38, 0.2, '8', 'Entrée de surface'),
        _i('them', 0.5, 0.015, 'G', 'Gardien'),
        _i('them', 0.55, 0.05),
        _i('them', 0.46, 0.06),
        _i('them', 0.52, 0.1),
        _i('them', 0.6, 0.11),
      ]),
  TacticLayout('Coup franc axial avec mur', layoutCategories[2], (_) => [
        _i('ball', 0.5, 0.31),
        _i('us', 0.47, 0.35, 'T', 'Tireur'),
        _i('us', 0.56, 0.35, '10', 'Feinte'),
        _i('us', 0.36, 0.2, '9'),
        _i('us', 0.64, 0.2, '11'),
        for (final x in [0.44, 0.48, 0.52, 0.56]) _i('them', x, 0.22, null, 'Mur'),
        _i('them', 0.5, 0.015, 'G', 'Gardien'),
      ]),
  TacticLayout('Penalty', layoutCategories[2], (_) => [
        _i('ball', 0.5, 0.105),
        _i('us', 0.5, 0.15, 'T', 'Tireur'),
        _i('them', 0.5, 0.012, 'G', 'Gardien'),
        for (final (i, x) in [0.3, 0.38, 0.62, 0.7].indexed) _i(i.isEven ? 'us' : 'them', x, 0.33),
      ]),
  TacticLayout('Slalom entre piquets', layoutCategories[3], (_) => [
        for (var k = 0; k < 6; k++) _i('pole', 0.5, 0.3 + k * 0.1),
        _i('cone', 0.44, 0.92),
        _i('cone', 0.56, 0.92),
        _i('ball', 0.5, 0.88),
        _i('us', 0.5, 0.95, '1', 'Départ'),
      ], description: 'Conduite de balle entre 6 piquets'),
  TacticLayout('Conduite en zigzag (plots)', layoutCategories[3], (_) => [
        for (var k = 0; k < 6; k++) _i('cone', k.isEven ? 0.42 : 0.58, 0.3 + k * 0.1),
        _i('ball', 0.42, 0.9),
        _i('us', 0.42, 0.95, '1', 'Départ'),
      ]),
  TacticLayout('Rondo 4 contre 2', layoutCategories[3], (_) => [
        for (final (x, y) in [(0.35, 0.35), (0.65, 0.35), (0.65, 0.65), (0.35, 0.65)]) _i('cone', x, y),
        for (final (i, (x, y)) in [(0.5, 0.35), (0.65, 0.5), (0.5, 0.65), (0.35, 0.5)].indexed) _i('us', x, y, '${i + 1}'),
        _i('them', 0.46, 0.48, 'A'),
        _i('them', 0.55, 0.53, 'B'),
        _i('ball', 0.5, 0.38),
      ], description: 'Carré de plots, 4 joueurs sur les côtés, 2 au milieu'),
  TacticLayout('Jeu réduit 4 contre 4 (mini-buts)', layoutCategories[3], (_) => [
        // Les deux mini-buts se font face.
        _i('minigoal', 0.5, 0.25, null, null, 90),
        _i('minigoal', 0.5, 0.8, null, null, 270),
        for (final (x, y) in [(0.25, 0.25), (0.75, 0.25), (0.25, 0.8), (0.75, 0.8)]) _i('cone', x, y),
        for (final (i, (x, y)) in [(0.35, 0.62), (0.65, 0.62), (0.4, 0.5), (0.6, 0.5)].indexed) _i('us', x, y, '${i + 1}'),
        for (final (i, (x, y)) in [(0.35, 0.4), (0.65, 0.4), (0.45, 0.45), (0.55, 0.56)].indexed) _i('them', x, y, '${i + 1}'),
        _i('ball', 0.5, 0.52),
      ]),
  TacticLayout('Parcours de vitesse et coordination', layoutCategories[3], (_) => [
        _i('ladder', 0.5, 0.78),
        // Haies en travers de la course.
        for (var k = 0; k < 3; k++) _i('hurdle', 0.5, 0.62 - k * 0.07, null, null, 90),
        for (var k = 0; k < 4; k++) _i('pole', k.isEven ? 0.46 : 0.54, 0.38 - k * 0.06),
        _i('cone', 0.44, 0.15),
        _i('cone', 0.56, 0.15),
        _i('us', 0.5, 0.9, '1', 'Départ'),
      ], description: 'Échelle, haies, piquets puis sprint jusqu\'aux plots'),
  TacticLayout('Frappes au but contre mannequins', layoutCategories[3], (_) => [
        // Mannequins de face, épaules en travers de la frappe.
        for (final x in [0.44, 0.5, 0.56]) _i('dummy', x, 0.2, null, null, 90),
        for (final x in [0.35, 0.5, 0.65]) _i('ball', x, 0.32),
        _i('us', 0.5, 0.38, '9', 'Tireur'),
        _i('them', 0.5, 0.015, 'G', 'Gardien'),
      ]),
];

/// Pions d'une disposition, avec des identifiants neufs (ajoutés à ce qui est déjà sur le terrain).
List<BoardToken> layoutTokens(TacticLayout l, String pitch) {
  final base = DateTime.now().microsecondsSinceEpoch;
  return [
    for (final (i, it) in l.items(pitch).indexed)
      BoardToken(
          id: '${base}_$i', kind: it.kind, x: it.x.clamp(0.0, 1.0), y: it.y.clamp(0.0, 1.0), label: it.label, role: it.role,
          angle: it.angle),
  ];
}
