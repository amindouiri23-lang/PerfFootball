import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Libéré à la fermeture de l'onglet seulement : la promesse rendue au navigateur ne se termine jamais.
final _hold = Completer<void>();

Future<bool> claimLocalStore() async {
  final granted = Completer<bool>();
  JSPromise<JSAny?> onGrant(web.Lock? lock) {
    if (!granted.isCompleted) granted.complete(lock != null);
    return lock == null ? Future<JSAny?>.value(null).toJS : _hold.future.then<JSAny?>((_) => null).toJS;
  }

  try {
    web.window.navigator.locks.request('perffoot-db', web.LockOptions(ifAvailable: true), onGrant.toJS);
  } catch (_) {
    return true; // navigateur sans verrous : on ne bloque pas
  }
  return granted.future;
}

Future<void> deleteLocalStore() {
  final done = Completer<void>();
  final req = web.window.indexedDB.deleteDatabase('perffoot');
  req.onsuccess = ((web.Event _) => done.complete()).toJS;
  req.onerror = ((web.Event _) => done.completeError(StateError('Effacement refusé par le navigateur'))).toJS;
  // Bloqué tant qu'un autre onglet garde la base ouverte : l'effacement attend sa fermeture.
  req.onblocked = ((web.Event _) {}).toJS;
  return done.future;
}

bool reloadApp() {
  web.window.location.reload();
  return true;
}
