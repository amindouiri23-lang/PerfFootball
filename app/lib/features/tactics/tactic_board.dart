import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// Tableau tactique : pions et flèches posés sur un terrain vu de dessus, but attaqué (ou défendu) en haut.
// Positions en fraction du terrain affiché (0 à 1) : la même tactique s'affiche sur téléphone, tablette et PC.

/// Pion : us = notre joueur, them = adversaire, ball = ballon.
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
}

/// Flèche : run = course d'un joueur, ball = trajectoire du ballon.
class BoardArrow {
  BoardArrow({required this.id, required this.kind, required this.x1, required this.y1, required this.x2, required this.y2});

  final String id;
  final String kind;
  double x1, y1, x2, y2;

  factory BoardArrow.fromJson(Map<String, dynamic> j) => BoardArrow(
        id: j['id'] as String, kind: j['kind'] as String,
        x1: (j['x1'] as num).toDouble(), y1: (j['y1'] as num).toDouble(),
        x2: (j['x2'] as num).toDouble(), y2: (j['y2'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'kind': kind, 'x1': _round(x1), 'y1': _round(y1), 'x2': _round(x2), 'y2': _round(y2)};
}

double _round(double v) => (v * 1000).round() / 1000;

class TacticBoard {
  TacticBoard({List<BoardToken>? tokens, List<BoardArrow>? arrows}) : tokens = tokens ?? [], arrows = arrows ?? [];

  final List<BoardToken> tokens;
  final List<BoardArrow> arrows;

  factory TacticBoard.decode(String text) {
    final j = text.trim().isEmpty ? const <String, dynamic>{} : jsonDecode(text) as Map<String, dynamic>;
    return TacticBoard(
      tokens: [for (final t in (j['tokens'] as List? ?? const [])) BoardToken.fromJson(t as Map<String, dynamic>)],
      arrows: [for (final a in (j['arrows'] as List? ?? const [])) BoardArrow.fromJson(a as Map<String, dynamic>)],
    );
  }

  String encode() => jsonEncode({'tokens': [for (final t in tokens) t.toJson()], 'arrows': [for (final a in arrows) a.toJson()]});

  /// Symétrie gauche / droite : un corner à gauche devient un corner à droite.
  void mirror() {
    for (final t in tokens) {
      t.x = 1 - t.x;
    }
    for (final a in arrows) {
      a
        ..x1 = 1 - a.x1
        ..x2 = 1 - a.x2;
    }
  }

  BoardToken? get ball => tokens.where((t) => t.kind == 'ball').firstOrNull;
}

/// Dimensions du terrain en mètres : largeur 68, longueur 105 (demi-terrain : 52,5).
const pitchWidthM = 68.0;
double pitchLengthM(String pitch) => pitch == 'full' ? 105.0 : 52.5;

/// Couleurs fixes du tableau : un terrain reste vert en thème clair comme en thème sombre.
const tokenUsColor = Color(0xFFE30613);
const tokenThemColor = Color(0xFF1E6FD9);
const _grassA = Color(0xFF2E7D32);
const _grassB = Color(0xFF2A7430);
const _runColor = Color(0xFFFFC94D);

/// Dessin du terrain et des flèches. Les pions sont des widgets posés par-dessus (déplaçables).
class PitchPainter extends CustomPainter {
  PitchPainter({required this.pitch, required this.arrows, this.preview});

  final String pitch;
  final List<BoardArrow> arrows;
  /// Flèche en cours de tracé.
  final BoardArrow? preview;

  @override
  void paint(Canvas canvas, Size size) {
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
    final p1 = Offset(a.x1 * size.width, a.y1 * size.height);
    final p2 = Offset(a.x2 * size.width, a.y2 * size.height);
    final run = a.kind == 'run';
    final paint = Paint()
      ..color = run ? _runColor : Colors.white
      ..strokeWidth = (size.width / 160).clamp(1.0, run ? 2.5 : 2.0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Trait discontinu : tirets pour une course, pointillés pour le ballon.
    final d = p2 - p1;
    final len = d.distance;
    if (len < 1) return;
    final dir = d / len;
    final (dash, gap) = run ? (8.0, 5.0) : (2.0, 5.0);
    for (var t = 0.0; t < len - 6; t += dash + gap) {
      canvas.drawLine(p1 + dir * t, p1 + dir * math.min(t + dash, len - 6), paint);
    }
    // Pointe, proportionnée au terrain (petite sur une miniature).
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

/// Distance d'un point au segment d'une flèche (en pixels) : sert à toucher une flèche pour la supprimer.
double distanceToArrow(Offset p, BoardArrow a, Size size) {
  final p1 = Offset(a.x1 * size.width, a.y1 * size.height);
  final p2 = Offset(a.x2 * size.width, a.y2 * size.height);
  final d = p2 - p1;
  final l2 = d.dx * d.dx + d.dy * d.dy;
  if (l2 == 0) return (p - p1).distance;
  final t = (((p - p1).dx * d.dx + (p - p1).dy * d.dy) / l2).clamp(0.0, 1.0);
  return (p - (p1 + d * t)).distance;
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
