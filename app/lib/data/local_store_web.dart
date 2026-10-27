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

/// Repart sur une base neuve : la base abîmée est encore ouverte par la page (son effacement serait mis en
/// attente par le navigateur) ; elle est donc mise de côté et effacée au prochain démarrage (connection_web.dart).
Future<void> deleteLocalStore() async {
  final storage = web.window.localStorage;
  storage.setItem('perffoot-db-trash', storage.getItem('perffoot-db') ?? 'perffoot');
  storage.setItem('perffoot-db', 'perffoot-${DateTime.now().millisecondsSinceEpoch}');
}

bool reloadApp() {
  web.window.location.reload();
  return true;
}
