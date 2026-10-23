import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Téléchargement direct : le partage du navigateur ouvrirait, sur ordinateur, la fenêtre de partage de Windows.
Future<void> saveFile(Uint8List bytes, String name, String mimeType) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final a = web.HTMLAnchorElement()
    ..href = url
    ..download = name
    ..style.display = 'none';
  web.document.body!.append(a);
  a.click();
  a.remove();
  // Laisser le navigateur lire le fichier avant de libérer l'adresse.
  Future<void>.delayed(const Duration(seconds: 30), () => web.URL.revokeObjectURL(url));
}
