import 'dart:js_interop';

import 'package:web/web.dart' as web;

void enterBrowserFullscreen() {
  if (web.document.fullscreenElement == null) {
    // Refusé hors d'un geste de l'utilisateur ou par le navigateur : l'écran reste utilisable sans.
    web.document.documentElement?.requestFullscreen().toDart.catchError((_) => null);
  }
}

void exitBrowserFullscreen() {
  if (web.document.fullscreenElement != null) web.document.exitFullscreen().toDart.catchError((_) => null);
}
