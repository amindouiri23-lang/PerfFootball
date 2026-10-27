import 'local_store_io.dart' if (dart.library.js_interop) 'local_store_web.dart' as impl;

// Copie locale des données (SQLite) : un seul onglet à la fois sur le web, et effacement complet pour la
// reconstruire depuis le serveur quand elle est abîmée.

/// Web : réserve la base locale pour cet onglet (verrou du navigateur, tenu tant que l'onglet est ouvert).
/// false si un autre onglet de PerfFoot l'utilise déjà : deux onglets qui écrivent le même fichier l'abîment.
/// Toujours true sur téléphone.
Future<bool> claimLocalStore() => impl.claimLocalStore();

/// Efface la copie locale (fichier SQLite ou base du navigateur). La base doit être fermée avant.
Future<void> deleteLocalStore() => impl.deleteLocalStore();

/// Après effacement : recharge la page (web) ; sur téléphone, false (l'application doit être relancée).
bool reloadApp() => impl.reloadApp();
