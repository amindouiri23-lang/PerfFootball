import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';
import 'package:web/web.dart' as web;

/// Web (version de test) : SQLite WebAssembly sur le fil principal, fichiers dans IndexedDB.
/// Pas de worker : certains navigateurs intégrés refusent les téléchargements depuis un SharedWorker.
/// Nécessite web/sqlite3.wasm à la version du paquet sqlite3.
///
/// Nom de la base IndexedDB : « perffoot », ou celui choisi par la réparation (local_store_web.dart), qui
/// repart sur une base neuve ; l'ancienne est effacée ici, avant toute ouverture (elle n'est plus tenue ouverte).
QueryExecutor openConnection() => LazyDatabase(() async {
      final storage = web.window.localStorage;
      final trash = storage.getItem('perffoot-db-trash');
      if (trash != null) {
        web.window.indexedDB.deleteDatabase(trash);
        storage.removeItem('perffoot-db-trash');
      }
      final name = storage.getItem('perffoot-db') ?? 'perffoot';
      final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
      final fileSystem = await IndexedDbFileSystem.open(dbName: name);
      sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
      return WasmDatabase(sqlite3: sqlite3, path: '/perffoot.db', fileSystem: fileSystem);
    });
