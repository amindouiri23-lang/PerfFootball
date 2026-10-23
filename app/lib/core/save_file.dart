import 'dart:typed_data';

import 'save_file_io.dart' if (dart.library.js_interop) 'save_file_web.dart' as impl;

/// Remet un fichier généré à l'utilisateur : téléchargement direct dans le navigateur, menu de partage
/// d'Android sur le téléphone (enregistrer, WhatsApp, e-mail…).
Future<void> saveFile(Uint8List bytes, String name, String mimeType) => impl.saveFile(bytes, name, mimeType);
