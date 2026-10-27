import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<bool> claimLocalStore() async => true;

/// Fichier créé par driftDatabase(name: 'perffoot') : dossier documents de l'application.
Future<void> deleteLocalStore() async {
  final dir = await getApplicationDocumentsDirectory();
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final f = File('${dir.path}/perffoot.sqlite$suffix');
    if (await f.exists()) await f.delete();
  }
}

bool reloadApp() => false;
