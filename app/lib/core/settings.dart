import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sync.dart';

/// Réglages de l'appareil (E28), conservés à la déconnexion (voir AppDatabase.wipe).
const themeKey = 'theme';
const sessionDurationKey = 'session_duration';
const matchDurationKey = 'match_duration';
const deviceSettingKeys = {themeKey, sessionDurationKey, matchDurationKey};

const themeModes = {'system': 'Système', 'light': 'Clair', 'dark': 'Sombre'};

final themeModeProvider = StreamProvider<ThemeMode>((ref) => ref.watch(databaseProvider).watchSetting(themeKey).map(
      (v) => switch (v) { 'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system },
    ));

final themeSettingProvider = StreamProvider<String>(
  (ref) => ref.watch(databaseProvider).watchSetting(themeKey).map((v) => v ?? 'system'),
);

/// Durée par défaut (minutes) d'une nouvelle séance ou d'un nouveau match.
final defaultDurationProvider = StreamProvider.family<int, String>((ref, key) =>
    ref.watch(databaseProvider).watchSetting(key).map((v) => int.tryParse(v ?? '') ?? 90));

/// Version affichée dans « À propos » (fournie par flutter build).
const appVersion = String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: 'dev');
const appBuild = String.fromEnvironment('FLUTTER_BUILD_NUMBER', defaultValue: '0');
