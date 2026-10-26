import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../team/team_repository.dart';
import 'tactic_board.dart';
import 'tactic_equipment.dart';

// Dessin d'un tableau tactique en image PNG, sans l'afficher : pour l'export d'une tactique et pour les
// documents PDF (programme de séance, feuille de match). Même rendu que l'écran : terrain, flèches, pions.

/// Texte du pion : numéro du joueur (ou ses initiales), sinon le texte libre du pion.
String tokenText(BoardToken t, Map<String, Player> players) {
  final p = players[t.playerId];
  if (p != null) return p.shirtNumber?.toString() ?? p.initials;
  return t.label ?? '';
}

/// Sous le pion : le nom du joueur (suivi de son rôle s'il en a un), sinon le rôle seul.
String? tokenCaption(BoardToken t, Map<String, Player> players) {
  final name = players[t.playerId]?.lastName;
  if (name == null) return t.role;
  return t.role == null ? name : '$name · ${t.role}';
}

/// Tableau en PNG, [width] pixels de large (hauteur selon le terrain), à l'étape [step].
Future<Uint8List> renderBoardPng({
  required TacticBoard board,
  required String pitch,
  required String Function(BoardToken) text,
  required String? Function(BoardToken) caption,
  double width = 900,
  /// Diamètre d'un pion, en fraction de la largeur du terrain (68 m) ; plus grand pour une composition.
  double tokenSize = 0.06,
  /// Terrain couché, but du haut à droite (comme dans l'éditeur).
  bool horizontal = false,
  int step = 0,
}) async {
  final size = Size(width, width / pitchAspect(pitch, horizontal: horizontal));
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & size);
  PitchPainter(pitch: pitch, arrows: board.arrowsAt(step), horizontal: horizontal).paint(canvas, size);
  final ts = (horizontal ? size.height : size.width) * tokenSize;
  for (final t in board.tokens) {
    final c = boardToScreen(board.positionAt(t, step), size, horizontal);
    if (!isPlayerToken(t.kind)) {
      canvas
        ..save()
        ..translate(c.dx, c.dy)
        ..rotate(t.angle * math.pi / 180);
      paintEquipment(canvas, Offset.zero, t.kind, ts);
      canvas.restore();
      continue;
    }
    final r = ts / 2;
    canvas.drawCircle(c, r, Paint()..color = t.kind == 'us' ? tokenUsColor : tokenThemColor);
    canvas.drawCircle(c, r, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = ts * 0.07);
    final label = text(t);
    if (label.isNotEmpty) {
      _paintText(canvas, label, c, ts * (label.length > 2 ? 0.32 : 0.42), Colors.white, bold: true);
    }
    final cap = caption(t);
    if (cap != null && cap.isNotEmpty) {
      final tp = _layout(cap, ts * 0.3, Colors.white, maxWidth: ts * 4);
      final box = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r + 2 + tp.height / 2),
        width: tp.width + 8,
        height: tp.height + 2,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(4)), Paint()..color = Colors.black.withValues(alpha: 0.6));
      tp.paint(canvas, Offset(box.center.dx - tp.width / 2, box.center.dy - tp.height / 2));
    }
  }
  final image = await recorder.endRecording().toImage(size.width.round(), size.height.round());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

TextPainter _layout(String s, double fontSize, Color color, {bool bold = false, double? maxWidth, String? fontFamily, String? package}) =>
    TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : null,
          fontFamily: fontFamily,
          package: package,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth ?? double.infinity);

void _paintText(Canvas canvas, String s, Offset center, double fontSize, Color color,
    {bool bold = false, String? fontFamily, String? package}) {
  final tp = _layout(s, fontSize, color, bold: bold, fontFamily: fontFamily, package: package);
  tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
}

/// Une tactique enregistrée, telle qu'elle s'affiche dans l'éditeur (à l'horizontale), à l'étape [step].
Future<Uint8List> renderTacticPng(Tactic t, Map<String, Player> players, {double width = 900, int step = 0}) => renderBoardPng(
      board: TacticBoard.decode(t.board),
      pitch: t.pitch,
      text: (b) => tokenText(b, players),
      caption: (b) => tokenCaption(b, players),
      width: width,
      horizontal: true,
      step: step,
    );

/// Toutes les étapes d'une tactique (une seule pour une tactique fixe).
Future<List<Uint8List>> renderTacticSteps(Tactic t, Map<String, Player> players, {double width = 900}) async => [
      for (var s = 0; s < TacticBoard.decode(t.board).stepCount; s++) await renderTacticPng(t, players, width: width, step: s),
    ];
