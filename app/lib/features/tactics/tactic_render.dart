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

/// Affichages des pions des joueurs (choix de la tactique).
const tokenDisplays = {
  'number': 'Numéro',
  'initials': 'Initiales',
  'photo': 'Photo',
  'photo_number': 'Photo et numéro',
};

/// Texte du pion selon l'affichage choisi : numéro, ou initiales du prénom et du nom (aussi quand le joueur
/// n'a pas de numéro, ou pas de photo en mode photo). Pion sans joueur : son texte libre.
String tokenText(BoardToken t, Map<String, Player> players, [String display = 'number']) {
  final p = players[t.playerId];
  if (p == null) return t.label ?? '';
  return switch (display) {
    'initials' => p.initials,
    'photo' => p.initials,
    _ => p.shirtNumber?.toString() ?? p.initials,
  };
}

/// Photo du joueur à montrer dans le pion (modes photo), null sinon ou s'il n'en a pas.
String? tokenPhoto(BoardToken t, Map<String, Player> players, String display) =>
    display == 'photo' || display == 'photo_number' ? players[t.playerId]?.photoPath : null;

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
  /// Lignes fléchées sous un pion, à la place de la légende : flèche rouge vers le bas (joueur sorti) ou
  /// verte vers le haut (joueur entré).
  List<({bool out, String text})> Function(BoardToken)? changes,
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
    final lines = changes?.call(t) ?? const [];
    if (lines.isNotEmpty) {
      _paintChanges(canvas, lines, c, r + 2, ts * 0.3, ts * 4, size.height);
      continue;
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

/// Cartouche sous le pion de centre [c] (au-dessus s'il sortirait du terrain, haut [bottom]) : une ligne par
/// joueur, précédée de sa flèche.
void _paintChanges(Canvas canvas, List<({bool out, String text})> lines, Offset c, double gap, double fontSize, double maxWidth,
    double bottom) {
  final arrow = fontSize * 0.9;
  final tps = [for (final l in lines) _layout(l.text, fontSize, l.out ? Colors.white70 : Colors.white, maxWidth: maxWidth - arrow - 10)];
  final w = tps.map((tp) => tp.width).reduce(math.max) + arrow + 10;
  final h = tps.fold(0.0, (sum, tp) => sum + tp.height) + 4;
  final below = c.dy + gap + h <= bottom;
  final box = Rect.fromLTWH(c.dx - w / 2, below ? c.dy + gap : c.dy - gap - h, w, h);
  canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(4)), Paint()..color = Colors.black.withValues(alpha: 0.65));
  var y = box.top + 2;
  for (final (i, tp) in tps.indexed) {
    final out = lines[i].out;
    final color = out ? const Color(0xFFFF6B6B) : const Color(0xFF5CE69A);
    final cx = box.left + 4 + arrow / 2, cy = y + tp.height / 2, half = arrow / 2;
    // Flèche : tige et pointe, vers le bas pour une sortie, vers le haut pour une entrée.
    final dir = out ? 1.0 : -1.0;
    canvas.drawLine(Offset(cx, cy - dir * half), Offset(cx, cy + dir * half * 0.2), Paint()
      ..color = color
      ..strokeWidth = arrow * 0.22);
    canvas.drawPath(
      Path()
        ..moveTo(cx - half * 0.7, cy)
        ..lineTo(cx + half * 0.7, cy)
        ..lineTo(cx, cy + dir * half)
        ..close(),
      Paint()..color = color,
    );
    tp.paint(canvas, Offset(box.left + arrow + 6, y));
    y += tp.height;
  }
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
      // Les images exportées montrent le numéro ou les initiales (pas les photos).
      text: (b) => tokenText(b, players, TacticBoard.decode(t.board).display),
      caption: (b) => tokenCaption(b, players),
      width: width,
      horizontal: true,
      step: step,
    );

/// Toutes les étapes d'une tactique (une seule pour une tactique fixe).
Future<List<Uint8List>> renderTacticSteps(Tactic t, Map<String, Player> players, {double width = 900}) async => [
      for (var s = 0; s < TacticBoard.decode(t.board).stepCount; s++) await renderTacticPng(t, players, width: width, step: s),
    ];
