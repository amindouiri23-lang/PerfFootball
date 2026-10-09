import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

// Valeurs passées au build : flutter run --dart-define-from-file=env.json
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(_supabaseUrl.isNotEmpty, 'Lancer avec --dart-define-from-file=env.json');
  await initializeDateFormatting('fr_FR');
  await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseKey);
  // Pas de nouvel essai automatique : une erreur s'affiche avec un bouton « Réessayer ».
  runApp(ProviderScope(retry: (_, _) => null, child: const PerfFootApp()));
}
