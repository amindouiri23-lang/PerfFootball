import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Android / iOS : SQLite natif, fichier dans le dossier de l'application.
QueryExecutor openConnection() => driftDatabase(name: 'perffoot');
