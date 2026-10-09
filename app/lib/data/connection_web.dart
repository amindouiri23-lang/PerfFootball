import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

/// Web (version de test) : SQLite WebAssembly sur le fil principal, fichiers dans IndexedDB.
/// Pas de worker : certains navigateurs intégrés refusent les téléchargements depuis un SharedWorker.
/// Nécessite web/sqlite3.wasm à la version du paquet sqlite3.
QueryExecutor openConnection() => LazyDatabase(() async {
      final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
      final fileSystem = await IndexedDbFileSystem.open(dbName: 'perffoot');
      sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
      return WasmDatabase(sqlite3: sqlite3, path: '/perffoot.db', fileSystem: fileSystem);
    });
