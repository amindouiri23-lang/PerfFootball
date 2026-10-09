import 'package:flutter/material.dart';

/// Vert du club — couleur d'accent unique (specs §4.2).
const seedColor = Color(0xFF0B6E4F);

/// Thème Material 3 pensé pour le bord du terrain : gros boutons (56 dp), champs contrastés.
ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
  const buttonSize = Size.fromHeight(56);
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: buttonSize, shape: buttonShape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: buttonSize, shape: buttonShape),
    ),
  );
}
