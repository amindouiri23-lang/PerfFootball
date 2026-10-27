import 'dart:convert';

import 'package:flutter/material.dart';

// Mise en page d'une diapositive, sur une scène 16:9 (positions et tailles en fraction de la scène, donc
// identiques à l'écran, en présentation plein écran et dans le PDF) :
//  - le bloc de texte d'une diapositive texte : position, largeur, taille, alignement, gras, couleur ;
//  - les images posées sur n'importe quelle diapositive : position, largeur, rapport largeur / hauteur.

/// Rapport largeur / hauteur de la scène d'une diapositive.
const slideAspect = 16 / 9;

/// Couleurs proposées pour le texte (fond sombre de la présentation).
const slideTextColors = {
  'white': Colors.white,
  'yellow': Color(0xFFFFD600),
  'red': Color(0xFFE30613),
  'blue': Color(0xFF64B5F6),
  'green': Color(0xFF81C784),
};

class SlideTextBox {
  SlideTextBox({this.x = 0.06, this.y = 0.18, this.w = 0.8, this.size = 1, this.align = 'left', this.bold = false, this.color = 'white'});

  /// Coin haut gauche et largeur, en fraction de la scène.
  double x, y, w;
  /// Taille du texte : 1 = normale (0,6 à 2,5).
  double size;
  /// left, center, right.
  String align;
  bool bold;
  /// Clé de [slideTextColors].
  String color;

  factory SlideTextBox.fromJson(Map<String, dynamic> j) => SlideTextBox(
        x: (j['x'] as num?)?.toDouble() ?? 0.06,
        y: (j['y'] as num?)?.toDouble() ?? 0.18,
        w: (j['w'] as num?)?.toDouble() ?? 0.8,
        size: (j['size'] as num?)?.toDouble() ?? 1,
        align: j['align'] as String? ?? 'left',
        bold: j['bold'] as bool? ?? false,
        color: j['color'] as String? ?? 'white',
      );

  Map<String, dynamic> toJson() => {'x': _r(x), 'y': _r(y), 'w': _r(w), 'size': _r(size), 'align': align, 'bold': bold, 'color': color};

  TextAlign get textAlign => switch (align) { 'center' => TextAlign.center, 'right' => TextAlign.right, _ => TextAlign.left };

  Color get textColor => slideTextColors[color] ?? Colors.white;
}

class SlideImage {
  SlideImage({required this.path, this.x = 0.55, this.y = 0.2, this.w = 0.38, this.ar = 4 / 3});

  /// Chemin dans le stockage photos (`teams/<team_id>/viewing/…`).
  final String path;
  double x, y, w;
  /// Largeur / hauteur de l'image d'origine.
  double ar;

  /// Hauteur en fraction de la hauteur de la scène.
  double get h => w * slideAspect / ar;

  factory SlideImage.fromJson(Map<String, dynamic> j) => SlideImage(
        path: j['path'] as String,
        x: (j['x'] as num?)?.toDouble() ?? 0.55,
        y: (j['y'] as num?)?.toDouble() ?? 0.2,
        w: (j['w'] as num?)?.toDouble() ?? 0.38,
        ar: (j['ar'] as num?)?.toDouble() ?? 4 / 3,
      );

  Map<String, dynamic> toJson() => {'path': path, 'x': _r(x), 'y': _r(y), 'w': _r(w), 'ar': _r(ar)};
}

class SlideLayout {
  SlideLayout({SlideTextBox? text, List<SlideImage>? images}) : text = text ?? SlideTextBox(), images = images ?? [];

  final SlideTextBox text;
  final List<SlideImage> images;

  factory SlideLayout.decode(String? s) {
    if (s == null || s.trim().isEmpty) return SlideLayout();
    final j = jsonDecode(s) as Map<String, dynamic>;
    return SlideLayout(
      text: j['text'] == null ? null : SlideTextBox.fromJson(j['text'] as Map<String, dynamic>),
      images: [for (final i in (j['images'] as List? ?? const [])) SlideImage.fromJson(i as Map<String, dynamic>)],
    );
  }

  String encode() => jsonEncode({'text': text.toJson(), 'images': [for (final i in images) i.toJson()]});
}

double _r(double v) => (v * 1000).round() / 1000;
