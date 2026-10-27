import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/local_store.dart';

// Valeurs passées au build : flutter run --dart-define-from-file=env.json
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Toute erreur non gérée est journalisée avec sa pile (sinon « Uncaught Error » sans détail sur le web).
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Erreur non gérée : $error\n$stack');
    return true;
  };
  assert(_supabaseUrl.isNotEmpty, 'Lancer avec --dart-define-from-file=env.json');
  await initializeDateFormatting('fr_FR');
  await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseKey);
  // Web : un seul onglet à la fois sur la copie locale des données (deux onglets l'abîmeraient).
  if (!await claimLocalStore()) {
    runApp(const _OtherTabApp());
    return;
  }
  // Pas de nouvel essai automatique : une erreur s'affiche avec un bouton « Réessayer ».
  runApp(ProviderScope(retry: (_, _) => null, child: const PerfFootApp()));
}

/// PerfFoot est déjà ouvert dans un autre onglet ou une autre fenêtre de ce navigateur.
class _OtherTabApp extends StatelessWidget {
  const _OtherTabApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset('assets/images/club_crest.png', height: 96),
                const SizedBox(height: 24),
                const Text('PerfFoot est déjà ouvert dans un autre onglet', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                const SizedBox(height: 12),
                const Text(
                  'Utilisez l\'onglet déjà ouvert, ou fermez-le puis réessayez ici. '
                  'Deux onglets en même temps abîmeraient les données enregistrées sur cet appareil.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(onPressed: reloadApp, icon: const Icon(Icons.refresh), label: const Text('Réessayer')),
              ]),
            ),
          ),
        ),
      );
}
