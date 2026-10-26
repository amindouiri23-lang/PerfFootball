import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// Tableau tactique : pions et flèches posés sur un terrain vu de dessus, but attaqué (ou défendu) en haut.
// Positions en fraction du terrain en portrait (x : largeur, y : longueur, 0 à 1) : la même tactique
// s'affiche en portrait ou à l'horizontale (but à droite), sur téléphone, tablette et PC.
// Une tactique animée a plusieurs étapes : chaque étape déplace des pions et porte ses propres flèches.

/// Pion : us = notre joueur, them = adversaire, ball = ballon. x, y : position à l'étape 1.
class BoardToken {
  BoardToken({required this.id, required this.kind, required this.x, required this.y, this.label, this.role, this.playerId});

  final String id;
  final String kind;
  double x;
  double y;
  /// Texte du pion sans joueur (numéro, lettre).
  String? label;
  /// Rôle affiché sous le pion : « Tireur », « 1er poteau »…
  String? role;
  String? playerId;

  factory BoardToken.fromJson(Map<String, dynamic> j) => BoardToken(
        id: j['id'] as String, kind: j['kind'] as String,
        x: (j['x'] as num).toDouble(), y: (j['y'] as num).toDouble(),
        label: j['label'] as String?, role: j['role'] as String?, playerId: j['playerId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'kind': kind, 'x': _round(x), 'y': _round(y),
        if (label != null) 'label': label, if (role != null) 'role': role, if (playerId != null) 'playerId': playerId,
      };

  BoardToken copyAt(Offset p) => BoardToken(id: id, kind: kind, x: p.dx, y: p.dy, label: label, role: role, playerId: playerId);
}

/// Flèche : run = course d'un joueur, ball = trajectoire du ballon. (cx, cy) : point de contrôle d'une
/// flèche courbe (courbe de Bézier quadratique) ; null = flèche droite.
class BoardArrow {
  BoardArrow({required this.id, required this.kind, required this.x1, required this.y1, required this.x2, required this.y2,
      this.cx, this.cy});

  final String id;
  final String kind;
  double x1, y1, x2, y2;
  double? cx, cy;

  bool get curved => cx != null && cy != null;

  factory BoardArrow.fromJson(Map<String, dynamic> j) => BoardArrow(
        id: j['id'] as String, kind: j['kind'] as String,
        x1: (j['x1'] as num).toDouble(), y1: (j['y1'] as num).toDouble(),
        x2: (j['x2'] as num).toDouble(), y2: (j['y2'] as num).toDouble(),
        cx: (j['cx'] as num?)?.toDouble(), cy: (j['cy'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'kind': kind, 'x1': _round(x1), 'y1': _round(y1), 'x2': _round(x2), 'y2': _round(y2),
        if (curved) 'cx': _round(cx!), if (curved) 'cy': _round(cy!),
      };

  /// Point de la flèche à t (0 = départ, 1 = arrivée), en fraction du terrain.
  Offset point(double t) {
    final p1 = Offset(x1, y1), p2 = Offset(x2, y2);
    if (!curved) return Offset.lerp(p1, p2, t)!;
    final c = Offset(cx!, cy!);
    final u = 1 - t;
    return p1 * (u * u) + c * (2 * u * t) + p2 * (t * t);
  }

  /// Courbe la flèche pour qu'elle passe par [m] en son milieu (poignée de l'éditeur).
  void bendThrough(Offset m) {
    cx = (2 * m.dx - (x1 + x2) / 2).clamp(-0.2, 1.2);
    cy = (2 * m.dy - (y1 + y2) / 2).clamp(-0.2, 1.2);
  }

  void straighten() {
    cx = null;
    cy = null;
  }

  BoardArrow copy() => BoardArrow(id: id, kind: kind, x1: x1, y1: y1, x2: x2, y2: y2, cx: cx, cy: cy);
}

double _round(double v) => (v * 1000).round() / 1000;

/// Étape 2 et suivantes d'une tactique animée : positions des pions déplacés (les autres gardent leur
/// position de l'étape précédente) et flèches de l'étape.
class BoardStep {
  BoardStep({Map<String, Offset>? pos, List<BoardArrow>? arrows}) : pos = pos ?? {}, arrows = arrows ?? [];

  final Map<String, Offset> pos;
  final List<BoardArrow> arrows;

  factory BoardStep.fromJson(Map<String, dynamic> j) => BoardStep(
        pos: {
          for (final e in (j['pos'] as Map<String, dynamic>? ?? const {}).entries)
            e.key: Offset(((e.value as List)[0] as num).toDouble(), ((e.value as List)[1] as num).toDouble()),
        },
        arrows: [for (final a in (j['arrows'] as List? ?? const [])) BoardArrow.fromJson(a as Map<String, dynamic>)],
      );

  Map<String, dynamic> toJson() => {
        'pos': {for (final e in pos.entries) e.key: [_round(e.value.dx), _round(e.value.dy)]},
        'arrows': [for (final a in arrows) a.toJson()],
      };
}

class TacticBoard {
  TacticBoard({List<BoardToken>? tokens, List<BoardArrow>? arrows, List<BoardStep>? steps})
      : tokens = tokens ?? [],
        arrows = arrows ?? [],
        steps = steps ?? [];

  final List<BoardToken> tokens;
  /// Flèches de l'étape 1.
  final List<BoardArrow> arrows;
  /// Étapes 2, 3… d'une tactique animée (vide : tactique fixe).
  final List<BoardStep> steps;

  factory TacticBoard.decode(String text) {
    final j = text.trim().isEmpty ? const <String, dynamic>{} : jsonDecode(text) as Map<String, dynamic>;
    return TacticBoard(
      tokens: [for (final t in (j['tokens'] as List? ?? const [])) BoardToken.fromJson(t as Map<String, dynamic>)],
      arrows: [for (final a in (j['arrows'] as List? ?? const [])) BoardArrow.fromJson(a as Map<String, dynamic>)],
      steps: [for (final s in (j['steps'] as List? ?? const [])) BoardStep.fromJson(s as Map<String, dynamic>)],
    );
  }

  String encode() => jsonEncode({
        'tokens': [for (final t in tokens) t.toJson()],
        'arrows': [for (final a in arrows) a.toJson()],
        if (steps.isNotEmpty) 'steps': [for (final s in steps) s.toJson()],
      });

  int get stepCount => 1 + steps.length;
  bool get animated => steps.isNotEmpty;

  /// Position d'un pion à une étape (0 = étape 1) : la dernière position connue jusqu'à cette étape.
  Offset positionAt(BoardToken t, int step) {
    for (var s = step.clamp(0, steps.length); s > 0; s--) {
      final p = steps[s - 1].pos[t.id];
      if (p != null) return p;
    }
    return Offset(t.x, t.y);
  }

  void setPosition(BoardToken t, int step, Offset p) {
    if (step == 0) {
      t
        ..x = p.dx
        ..y = p.dy;
    } else {
      steps[step - 1].pos[t.id] = p;
    }
  }

  List<BoardArrow> arrowsAt(int step) => step == 0 ? arrows : steps[step - 1].arrows;

  /// Ajoute une étape juste après l'étape [after] (0 = étape 1) : les pions partent de ses positions, sans flèche.
  void addStep(int after) {
    steps.insert(after, BoardStep(pos: {for (final t in tokens) t.id: positionAt(t, after)}));
  }

  /// Retire l'étape [step] (1 et plus) ; l'étape 1 reste toujours.
  void removeStep(int step) {
    if (step >= 1 && step <= steps.length) steps.removeAt(step - 1);
  }

  void removeToken(BoardToken t) {
    tokens.remove(t);
    for (final s in steps) {
      s.pos.remove(t.id);
    }
  }

  /// Image d'un instant de l'animation : [t] de 0 (étape 1) à stepCount - 1 (dernière étape). Les pions
  /// glissent d'une étape à la suivante ; les flèches affichées sont celles de l'étape de départ.
  TacticBoard frameAt(double t) {
    final at = t.clamp(0.0, (stepCount - 1).toDouble());
    final k = at.floor();
    final f = Curves.easeInOut.transform(at - k);
    final next = math.min(k + 1, stepCount - 1);
    return TacticBoard(
      tokens: [for (final tk in tokens) tk.copyAt(Offset.lerp(positionAt(tk, k), positionAt(tk, next), f)!)],
      arrows: [for (final a in arrowsAt(f > 0.98 ? next : k)) a.copy()],
    );
  }

  /// L'étape [step] figée, comme une tactique fixe (export en image, diapositive).
  TacticBoard stepBoard(int step) => frameAt(step.toDouble());

  /// Symétrie gauche / droite : un corner à gauche devient un corner à droite.
  void mirror() {
    void flip(BoardArrow a) {
      a
        ..x1 = 1 - a.x1
        ..x2 = 1 - a.x2;
      if (a.cx != null) a.cx = 1 - a.cx!;
    }

    for (final t in tokens) {
      t.x = 1 - t.x;
    }
    arrows.forEach(flip);
    for (final s in steps) {
      for (final e in s.pos.entries.toList()) {
        s.pos[e.key] = Offset(1 - e.value.dx, e.value.dy);
      }
      s.arrows.forEach(flip);
    }
  }

  BoardToken? get ball => tokens.where((t) => t.kind == 'ball').firstOrNull;
}

/// Dimensions du terrain en mètres : largeur 68, longueur 105 (demi-terrain : 52,5).
const pitchWidthM = 68.0;
double pitchLengthM(String pitch) => pitch == 'full' ? 105.0 : 52.5;

/// Rapport largeur / hauteur du terrain affiché.
double pitchAspect(String pitch, {bool horizontal = false}) =>
    horizontal ? pitchLengthM(pitch) / pitchWidthM : pitchWidthM / pitchLengthM(pitch);

/// Fraction du terrain (repère portrait) → point à l'écran. À l'horizontale, le but du haut passe à droite.
Offset boardToScreen(Offset f, Size size, bool horizontal) =>
    horizontal ? Offset((1 - f.dy) * size.width, f.dx * size.height) : Offset(f.dx * size.width, f.dy * size.height);

/// Point à l'écran → fraction du terrain (repère portrait), bornée au terrain.
Offset screenToBoard(Offset p, Size size, bool horizontal) {
  final f = horizontal ? Offset(p.dy / size.height, 1 - p.dx / size.width) : Offset(p.dx / size.width, p.dy / size.height);
  return Offset(f.dx.clamp(0.0, 1.0), f.dy.clamp(0.0, 1.0));
}

/// Couleurs fixes du tableau : un terrain reste vert en thème clair comme en thème sombre.
const tokenUsColor = Color(0xFFE30613);
const tokenThemColor = Color(0xFF1E6FD9);
const _grassA = Color(0xFF2E7D32);
const _grassB = Color(0xFF2A7430);
const _runColor = Color(0xFFFFC94D);

/// Dessin du terrain et des flèches. Les pions sont des widgets posés par-dessus (déplaçables).
class PitchPainter extends CustomPainter {
  PitchPainter({required this.pitch, required this.arrows, this.preview, this.horizontal = false});

  final String pitch;
  final List<BoardArrow> arrows;
  /// Flèche en cours de tracé.
  final BoardArrow? preview;
  /// Terrain couché, but du haut à droite.
  final bool horizontal;

  @override
  void paint(Canvas canvas, Size size) {
    if (!horizontal) return _paintPortrait(canvas, size);
    // À l'horizontale : le dessin en portrait, tourné d'un quart de tour (le haut passe à droite).
    canvas.save();
    canvas.translate(size.width, 0);
    canvas.rotate(math.pi / 2);
    _paintPortrait(canvas, Size(size.height, size.width));
    canvas.restore();
  }

  void _paintPortrait(Canvas canvas, Size size) {
    final s = size.width / pitchWidthM; // pixels par mètre
    // Bandes de tonte.
    const bands = 10;
    for (var i = 0; i < bands; i++) {
      canvas.drawRect(Rect.fromLTWH(0, size.height * i / bands, size.width, size.height / bands + 1),
          Paint()..color = i.isEven ? _grassA : _grassB);
    }
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, s * 0.25);
    canvas.drawRect(Offset.zero & size, line);
    void goalEnd({required bool top}) {
      double y(double m) => top ? m * s : size.height - m * s;
      final cx = size.width / 2;
      // Surface de réparation (40,32 × 16,5), surface de but (18,32 × 5,5), point et arc de penalty.
      canvas.drawRect(Rect.fromPoints(Offset(cx - 20.16 * s, y(0)), Offset(cx + 20.16 * s, y(16.5))), line);
      canvas.drawRect(Rect.fromPoints(Offset(cx - 9.16 * s, y(0)), Offset(cx + 9.16 * s, y(5.5))), line);
      canvas.drawCircle(Offset(cx, y(11)), math.max(1.5, s * 0.3), Paint()..color = Colors.white);
      final arc = Rect.fromCircle(center: Offset(cx, y(11)), radius: 9.15 * s);
      const half = 0.9273; // acos(5,5 / 9,15) : l'arc commence à la ligne de la surface
      canvas.drawArc(arc, top ? math.pi / 2 - half : -math.pi / 2 - half, 2 * half, false, line);
      // But (7,32 m) en trait épais sur la ligne.
      canvas.drawLine(Offset(cx - 3.66 * s, y(0)), Offset(cx + 3.66 * s, y(0)),
          Paint()
            ..color = Colors.white
            ..strokeWidth = math.max(3, s * 0.8));
      // Arcs de coin : un quart de cercle tourné vers l'intérieur du terrain.
      for (final (x, start) in [(0.0, top ? 0.0 : -math.pi / 2), (size.width, top ? math.pi / 2 : math.pi)]) {
        canvas.drawArc(Rect.fromCircle(center: Offset(x, y(0)), radius: 1.2 * s), start, math.pi / 2, false, line);
      }
    }

    goalEnd(top: true);
    if (pitch == 'full') {
      goalEnd(top: false);
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), line);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 9.15 * s, line);
    } else {
      // Ligne médiane en bas, avec la moitié du rond central.
      canvas.drawArc(Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: 9.15 * s), math.pi, math.pi, false, line);
    }

    for (final a in [...arrows, ?preview]) {
      _arrow(canvas, size, a);
    }
  }

  void _arrow(Canvas canvas, Size size, BoardArrow a) {
    Offset px(double x, double y) => Offset(x * size.width, y * size.height);
    final p1 = px(a.x1, a.y1);
    final p2 = px(a.x2, a.y2);
    final c = a.curved ? px(a.cx!, a.cy!) : null;
    final run = a.kind == 'run';
    final paint = Paint()
      ..color = run ? _runColor : Colors.white
      ..strokeWidth = (size.width / 160).clamp(1.0, run ? 2.5 : 2.0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(p1.dx, p1.dy);
    if (c != null) {
      path.quadraticBezierTo(c.dx, c.dy, p2.dx, p2.dy);
    } else {
      path.lineTo(p2.dx, p2.dy);
    }
    final metric = path.computeMetrics().firstOrNull;
    if (metric == null || metric.length < 1) return;
    final len = metric.length;
    // Trait discontinu : tirets pour une course, pointillés pour le ballon, le long de la courbe.
    final (dash, gap) = run ? (8.0, 5.0) : (2.0, 5.0);
    for (var t = 0.0; t < len - 6; t += dash + gap) {
      canvas.drawPath(metric.extractPath(t, math.min(t + dash, len - 6)), paint);
    }
    // Pointe, dans l'axe de la fin de la flèche, proportionnée au terrain.
    final from = c ?? p1;
    final d = p2 - from;
    if (d.distance < 0.01) return;
    final dir = d / d.distance;
    final normal = Offset(-dir.dy, dir.dx);
    final h = (size.width * 0.03).clamp(3.0, 11.0);
    final head = Path()
      ..moveTo(p2.dx, p2.dy)
      ..lineTo((p2 - dir * h + normal * h * 0.55).dx, (p2 - dir * h + normal * h * 0.55).dy)
      ..lineTo((p2 - dir * h - normal * h * 0.55).dx, (p2 - dir * h - normal * h * 0.55).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = paint.color);
  }

  @override
  bool shouldRepaint(PitchPainter old) => true;
}

/// Distance d'un point à l'écran au tracé d'une flèche (en pixels) : sert à toucher une flèche.
double distanceToArrow(Offset p, BoardArrow a, Size size, {bool horizontal = false}) {
  var best = double.infinity;
  Offset at(double t) => boardToScreen(a.point(t), size, horizontal);
  var prev = at(0);
  for (var i = 1; i <= 24; i++) {
    final next = at(i / 24);
    final d = next - prev;
    final l2 = d.dx * d.dx + d.dy * d.dy;
    final t = l2 == 0 ? 0.0 : (((p - prev).dx * d.dx + (p - prev).dy * d.dy) / l2).clamp(0.0, 1.0);
    best = math.min(best, (p - (prev + d * t)).distance);
    prev = next;
  }
  return best;
}

/// Pion dessiné : rond coloré, texte au centre, rôle en dessous.
class TokenView extends StatelessWidget {
  const TokenView({super.key, required this.kind, required this.text, this.caption, this.size = 30, this.selected = false});

  final String kind;
  final String text;
  final String? caption;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (kind == 'ball') {
      return Container(
        width: size * 0.7,
        height: size * 0.7,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black87, width: 1.5)),
        child: Icon(Icons.sports_soccer, size: size * 0.6, color: Colors.black87),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kind == 'us' ? tokenUsColor : tokenThemColor,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? _runColor : Colors.white, width: selected ? 3 : 2),
        ),
        child: Text(text,
            maxLines: 1,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: size * (text.length > 2 ? 0.32 : 0.42))),
      ),
      if (caption != null && caption!.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(3)),
          child: Text(caption!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ),
    ]);
  }
}
