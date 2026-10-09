import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/auth_repository.dart';
import 'router.dart';

/// Bucket privé des photos (migration 20261009000003) : `teams/<team_id>/…`, `profiles/<user_id>.jpg`.
const _bucket = 'photos';

/// URL signée (1 h) d'une photo ; null si hors ligne ou introuvable — l'avatar affiche alors les initiales.
final photoUrlProvider = FutureProvider.family<String?, String>((ref, path) async {
  try {
    return await ref.watch(supabaseProvider).storage.from(_bucket).createSignedUrl(path, 3600);
  } catch (_) {
    return null;
  }
});

/// Avatar rond : la photo si elle existe et que le réseau répond, sinon les initiales.
class PhotoAvatar extends ConsumerWidget {
  const PhotoAvatar({super.key, required this.path, required this.initials, this.radius = 20});

  final String? path;
  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = path == null ? null : ref.watch(photoUrlProvider(path!)).value;
    return CircleAvatar(
      radius: radius,
      foregroundImage: url == null ? null : NetworkImage(url),
      child: Text(initials, style: TextStyle(fontSize: radius * 0.7)),
    );
  }
}

/// Choisit une photo (appareil photo ou galerie), la réduit à 512 px et l'envoie à [storagePath].
/// Renvoie le chemin enregistré, ou null si annulé ou en échec (message affiché).
/// L'envoi demande le réseau : les photos ne passent pas par la base locale.
Future<String?> pickAndUploadPhoto(BuildContext context, WidgetRef ref, String storagePath) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: const Text('Prendre une photo'),
          onTap: () => Navigator.of(context).pop(ImageSource.camera),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('Choisir dans la galerie'),
          onTap: () => Navigator.of(context).pop(ImageSource.gallery),
        ),
      ]),
    ),
  );
  if (source == null) return null;
  final file = await ImagePicker().pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
  if (file == null) return null;
  try {
    final bytes = await file.readAsBytes();
    await ref.read(supabaseProvider).storage.from(_bucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: file.mimeType ?? 'image/jpeg'),
        );
    ref.invalidate(photoUrlProvider(storagePath));
    if (context.mounted) showMessage(context, 'Photo enregistrée');
    return storagePath;
  } on StorageException catch (e) {
    if (context.mounted) showMessage(context, 'Photo refusée : ${e.message}');
  } catch (_) {
    if (context.mounted) showMessage(context, 'Une connexion internet est nécessaire pour la photo.');
  }
  return null;
}
