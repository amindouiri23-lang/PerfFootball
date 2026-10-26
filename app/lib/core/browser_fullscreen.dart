import 'browser_fullscreen_io.dart' if (dart.library.js_interop) 'browser_fullscreen_web.dart' as impl;

/// Plein écran du navigateur (version web) : masque la barre d'adresse et les onglets. Sans effet sur téléphone,
/// où l'application passe elle-même en mode immersif.
void enterBrowserFullscreen() => impl.enterBrowserFullscreen();

void exitBrowserFullscreen() => impl.exitBrowserFullscreen();
