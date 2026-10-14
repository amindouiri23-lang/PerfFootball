import 'package:flutter/material.dart';

// Identité Club Africain, esprit jeu de foot (FIFA / Football Manager) : rouge et blanc du club,
// fond « stade » sombre par défaut, titres en capitales condensées (Barlow Condensed).

/// Rouge du club — couleur d'accent unique.
const clubRed = Color(0xFFE30613);
const clubRedBright = Color(0xFFFF2E3B);

/// Fonds du thème sombre, du plus profond au plus élevé.
const pitchBlack = Color(0xFF0E0E13);
const panel = Color(0xFF1A1A22);
const panelHigh = Color(0xFF24242E);

const displayFont = 'BarlowCondensed';

/// Titres « jeu » : capitales condensées, légèrement espacées. À utiliser avec un texte en majuscules.
TextStyle gameTitle(BuildContext context, {double size = 20, Color? color}) => TextStyle(
      fontFamily: displayFont,
      fontWeight: FontWeight.w700,
      fontSize: size,
      letterSpacing: 0.8,
      height: 1.05,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );

/// Petite étiquette de section : « PROCHAIN MATCH ».
TextStyle sectionLabel(BuildContext context) => TextStyle(
      fontFamily: displayFont,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 1.6,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

/// Thème Material 3 pensé pour le bord du terrain : gros boutons (56 dp), champs contrastés.
ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = dark
      ? const ColorScheme.dark(
          primary: clubRed,
          onPrimary: Colors.white,
          primaryContainer: Color(0xFF4A0A10),
          onPrimaryContainer: Color(0xFFFFD9DB),
          secondary: Colors.white,
          onSecondary: pitchBlack,
          secondaryContainer: panelHigh,
          onSecondaryContainer: Colors.white,
          tertiary: Color(0xFFFFC857),
          onTertiary: pitchBlack,
          tertiaryContainer: Color(0xFF3D3015),
          onTertiaryContainer: Color(0xFFFFE3A3),
          error: Color(0xFFFF5A5F),
          onError: pitchBlack,
          errorContainer: Color(0xFF3A1416),
          onErrorContainer: Color(0xFFFFB3B6),
          surface: pitchBlack,
          onSurface: Color(0xFFF4F4F6),
          onSurfaceVariant: Color(0xFF9A9AA6),
          surfaceContainerLowest: Color(0xFF09090D),
          surfaceContainerLow: Color(0xFF14141A),
          surfaceContainer: panel,
          surfaceContainerHigh: panelHigh,
          surfaceContainerHighest: Color(0xFF2C2C37),
          outline: Color(0xFF4A4A57),
          outlineVariant: Color(0xFF2E2E39),
        )
      : ColorScheme.fromSeed(seedColor: clubRed, brightness: Brightness.light)
          .copyWith(primary: clubRed, onPrimary: Colors.white);

  const buttonSize = Size.fromHeight(56);
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  const condensed = TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700, letterSpacing: 0.6);
  final base = ThemeData(brightness: brightness, useMaterial3: true).textTheme;
  final textTheme = base.copyWith(
    displaySmall: base.displaySmall?.merge(condensed),
    headlineMedium: base.headlineMedium?.merge(condensed),
    headlineSmall: base.headlineSmall?.merge(condensed),
    titleLarge: base.titleLarge?.merge(condensed).copyWith(fontSize: 24),
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.4),
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: displayFont, fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: 0.8,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: dark ? panel : null,
      elevation: dark ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? const Color(0xFF09090D) : null,
      indicatorColor: clubRed,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? Colors.white : scheme.onSurfaceVariant),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontFamily: displayFont, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.8,
            color: s.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant,
          )),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: dark ? const Color(0xFF09090D) : null,
      indicatorColor: clubRed,
      selectedIconTheme: const IconThemeData(color: Colors.white),
    ),
    chipTheme: ChipThemeData(
      selectedColor: clubRed,
      checkmarkColor: Colors.white,
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      filled: dark,
      fillColor: dark ? panel : null,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: const TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700, fontSize: 19, letterSpacing: 1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: buttonSize,
        shape: buttonShape,
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
        textStyle: const TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700, fontSize: 19, letterSpacing: 1),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: clubRed,
      foregroundColor: Colors.white,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant),
  );
}
