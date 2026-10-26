import 'dart:math' as math;

import 'package:flutter/material.dart';

// Matériel d'entraînement posé sur le tableau : ballons, plots, piquets, mini-buts, mannequins, haies, échelle.
// Ce sont des pions comme les autres (déplaçables, animés d'une étape à l'autre), dessinés vus du dessus.

const equipmentKinds = {
  'ball': 'Ballon',
  'cone': 'Plot',
  'pole': 'Piquet',
  'minigoal': 'Mini-but',
  'dummy': 'Mannequin',
  'hurdle': 'Haie',
  'ladder': 'Échelle de rythme',
};

const equipmentIcons = {
  'ball': Icons.sports_soccer,
  'cone': Icons.change_history,
  'pole': Icons.more_vert,
  'minigoal': Icons.crop_landscape,
  'dummy': Icons.accessibility_new,
  'hurdle': Icons.horizontal_rule,
  'ladder': Icons.view_week_outlined,
};

/// Joueur (nous ou adversaire) : pion rond avec numéro et légende ; le reste est du matériel.
bool isPlayerToken(String kind) => kind == 'us' || kind == 'them';

/// Encombrement du matériel pour un pion de diamètre [ts] (sert à centrer le dessin sur sa position).
Size equipmentSize(String kind, double ts) => switch (kind) {
      'ball' => Size.square(ts * 0.7),
      'cone' => Size.square(ts * 0.6),
      'pole' => Size.square(ts * 0.45),
      'minigoal' => Size(ts * 1.4, ts * 0.6),
      'dummy' => Size(ts * 0.9, ts * 0.55),
      'hurdle' => Size(ts * 1.1, ts * 0.3),
      'ladder' => Size(ts * 2.2, ts * 0.7),
      _ => Size.square(ts * 0.6),
    };

const _orange = Color(0xFFFF8F00);
const _yellow = Color(0xFFFFD600);

/// Dessine le matériel [kind] centré sur [c] (même rendu à l'écran et dans les exports PNG / PDF).
void paintEquipment(Canvas canvas, Offset c, String kind, double ts) {
  final size = equipmentSize(kind, ts);
  final rect = Rect.fromCenter(center: c, width: size.width, height: size.height);
  final dark = Paint()
    ..color = Colors.black87
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1, ts * 0.05);
  switch (kind) {
    case 'ball':
      final r = size.width / 2;
      canvas.drawCircle(c, r, Paint()..color = Colors.white);
      canvas.drawCircle(c, r, dark);
      final tp = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.sports_soccer.codePoint),
          style: TextStyle(fontSize: r * 1.7, color: Colors.black87, fontFamily: Icons.sports_soccer.fontFamily, package: Icons.sports_soccer.fontPackage),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    case 'cone':
      // Plot vu de dessus : disque orange, sommet plus clair.
      canvas.drawCircle(c, size.width / 2, Paint()..color = _orange);
      canvas.drawCircle(c, size.width / 2, dark);
      canvas.drawCircle(c, size.width * 0.18, Paint()..color = const Color(0xFFFFE0B2));
    case 'pole':
      // Piquet vu de dessus : socle sombre, tige jaune.
      canvas.drawCircle(c, size.width / 2, Paint()..color = Colors.black54);
      canvas.drawCircle(c, size.width * 0.3, Paint()..color = _yellow);
      canvas.drawCircle(c, size.width * 0.3, dark);
    case 'minigoal':
      final frame = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, ts * 0.09);
      canvas.drawRect(rect, Paint()..color = Colors.white.withValues(alpha: 0.25));
      final path = Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.bottom);
      canvas.drawPath(path, frame);
    case 'dummy':
      // Mannequin vu de dessus : épaules et tête.
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2)), Paint()..color = const Color(0xFF37474F));
      canvas.drawCircle(c, size.height * 0.32, Paint()..color = const Color(0xFF90A4AE));
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2)), dark);
    case 'hurdle':
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2)), Paint()..color = _yellow);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2)), dark);
    case 'ladder':
      final rail = Paint()
        ..color = _yellow
        ..strokeWidth = math.max(1.5, ts * 0.07);
      canvas.drawLine(rect.topLeft, rect.topRight, rail);
      canvas.drawLine(rect.bottomLeft, rect.bottomRight, rail);
      for (var i = 0; i <= 6; i++) {
        final x = rect.left + rect.width * i / 6;
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), rail);
      }
    default:
      canvas.drawCircle(c, size.width / 2, Paint()..color = Colors.grey);
  }
}

/// Matériel affiché à l'écran.
class EquipmentView extends StatelessWidget {
  const EquipmentView({super.key, required this.kind, required this.size});

  final String kind;
  /// Diamètre d'un pion joueur au même zoom.
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = equipmentSize(kind, size);
    return CustomPaint(size: s, painter: _EquipmentPainter(kind, size));
  }
}

class _EquipmentPainter extends CustomPainter {
  _EquipmentPainter(this.kind, this.ts);

  final String kind;
  final double ts;

  @override
  void paint(Canvas canvas, Size size) => paintEquipment(canvas, Offset(size.width / 2, size.height / 2), kind, ts);

  @override
  bool shouldRepaint(_EquipmentPainter old) => old.kind != kind || old.ts != ts;
}
