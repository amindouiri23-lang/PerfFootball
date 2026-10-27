import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/photos.dart';
import '../../core/router.dart';
import '../../data/database.dart';
import '../auth/auth_repository.dart';
import 'slide_layout.dart';

/// Logo du club, en haut à droite de chaque diapositive.
const clubCrestAsset = 'assets/images/club_crest.png';
const slideBackground = Color(0xFF0E0F12);

/// Élément sélectionné dans l'éditeur de mise en page : 'text' ou l'index d'une image.
typedef StageSelection = Object?;

/// Scène 16:9 d'une diapositive : fond, logo du club, titre et contenu (tactique, vidéo) ou bloc de texte placé,
/// images posées. Avec les rappels, le texte et les images se déplacent et se redimensionnent au doigt.
class SlideStage extends StatelessWidget {
  const SlideStage({
    super.key,
    required this.slide,
    required this.layout,
    required this.title,
    this.content,
    this.selected,
    this.onSelect,
    this.onChanged,
    this.onChangeEnd,
  });

  final ViewingSlide slide;
  final SlideLayout layout;
  /// Titre affiché en haut d'une diapositive tactique ou vidéo.
  final String title;
  /// Tactique ou vidéo (sous le titre) ; null pour une diapositive texte.
  final Widget? content;
  final StageSelection selected;
  final ValueChanged<StageSelection>? onSelect;
  /// Un élément a bougé (pendant le geste) ; [onChangeEnd] à la fin du geste, pour enregistrer.
  final VoidCallback? onChanged;
  final VoidCallback? onChangeEnd;

  bool get _editing => onChanged != null;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: slideAspect,
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          final t = layout.text;
          final titleStyle = TextStyle(color: Colors.white, fontSize: w * 0.04, fontWeight: FontWeight.bold, height: 1.15);
          return ClipRect(
            child: Container(
              color: slideBackground,
              child: Stack(children: [
                // Titre et contenu d'une diapositive tactique ou vidéo.
                if (slide.kind != 'text') ...[
                  Positioned(
                    left: w * 0.04,
                    right: w * 0.14,
                    top: h * 0.04,
                    child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle),
                  ),
                  if (slide.body != null)
                    Positioned(
                      left: w * 0.04,
                      right: w * 0.14,
                      top: h * 0.12,
                      child: Text(slide.body!, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: w * 0.022)),
                    ),
                  Positioned(
                    left: w * 0.04,
                    right: w * 0.04,
                    top: h * (slide.body != null ? 0.22 : 0.15),
                    bottom: h * 0.04,
                    child: content ?? const SizedBox(),
                  ),
                ],
                // Bloc de texte placé.
                if (slide.kind == 'text' && (slide.title != null || slide.body != null))
                  _movable(
                    id: 'text',
                    left: t.x * w,
                    top: t.y * h,
                    width: t.w * w,
                    onDrag: (d) {
                      t
                        ..x = (t.x + d.dx / w).clamp(0.0, 1 - t.w)
                        ..y = (t.y + d.dy / h).clamp(0.0, 0.95);
                    },
                    onResize: (d) => t.w = (t.w + d.dx / w).clamp(0.12, 1 - t.x),
                    child: SlideTextView(slide: slide, box: t, stageWidth: w),
                  ),
                for (final (i, img) in layout.images.indexed)
                  _movable(
                    id: i,
                    left: img.x * w,
                    top: img.y * h,
                    width: img.w * w,
                    height: img.h * h,
                    onDrag: (d) {
                      img
                        ..x = (img.x + d.dx / w).clamp(-img.w * 0.5, 1 - img.w * 0.5)
                        ..y = (img.y + d.dy / h).clamp(-img.h * 0.5, 1 - img.h * 0.5);
                    },
                    onResize: (d) => img.w = (img.w + d.dx / w).clamp(0.06, 1.2),
                    child: SlideImageView(path: img.path),
                  ),
                // Logo du club, en haut à droite (au-dessus de tout).
                Positioned(
                  right: w * 0.02,
                  top: h * 0.03,
                  height: h * 0.1,
                  child: IgnorePointer(child: Image.asset(clubCrestAsset, fit: BoxFit.contain)),
                ),
              ]),
            ),
          );
        }),
      );

  /// Élément déplaçable (glisser) et redimensionnable (poignée en bas à droite) quand l'éditeur est actif.
  Widget _movable({
    required Object id,
    required double left,
    required double top,
    required double width,
    double? height,
    required void Function(Offset delta) onDrag,
    required void Function(Offset delta) onResize,
    required Widget child,
  }) {
    final isSelected = selected == id;
    if (!_editing) return Positioned(left: left, top: top, width: width, height: height, child: child);
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect?.call(id),
        onPanStart: (_) => onSelect?.call(id),
        onPanUpdate: (d) {
          onDrag(d.delta);
          onChanged?.call();
        },
        onPanEnd: (_) => onChangeEnd?.call(),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? const Color(0xFFFFD600) : Colors.white24, width: isSelected ? 2 : 1),
            ),
            child: child,
          ),
          if (isSelected)
            Positioned(
              right: -12,
              bottom: -12,
              width: 24,
              height: 24,
              child: GestureDetector(
                onPanUpdate: (d) {
                  onResize(d.delta);
                  onChanged?.call();
                },
                onPanEnd: (_) => onChangeEnd?.call(),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD600),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.open_in_full, size: 12, color: Colors.black),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Titre et texte d'une diapositive texte, dans le style choisi (une ligne = une puce).
class SlideTextView extends StatelessWidget {
  const SlideTextView({super.key, required this.slide, required this.box, required this.stageWidth});

  final ViewingSlide slide;
  final SlideTextBox box;
  final double stageWidth;

  @override
  Widget build(BuildContext context) {
    final color = box.textColor;
    final base = stageWidth * 0.026 * box.size;
    final align = box.textAlign;
    final cross = switch (box.align) { 'center' => CrossAxisAlignment.center, 'right' => CrossAxisAlignment.end, _ => CrossAxisAlignment.start };
    final lines = (slide.body ?? '').split('\n').where((l) => l.trim().isNotEmpty).toList();
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: cross, children: [
      if (slide.title != null)
        Text(slide.title!, textAlign: align, style: TextStyle(color: color, fontSize: base * 1.7, fontWeight: FontWeight.bold, height: 1.15)),
      if (slide.title != null && lines.isNotEmpty) SizedBox(height: base * 0.8),
      for (final line in lines)
        Padding(
          padding: EdgeInsets.only(bottom: base * 0.35),
          child: Text.rich(
            TextSpan(children: [
              if (box.align == 'left') TextSpan(text: '•  ', style: TextStyle(color: const Color(0xFFE30613), fontWeight: FontWeight.bold, fontSize: base)),
              TextSpan(text: line.trim().replaceFirst(RegExp(r'^[-•*]\s*'), '')),
            ]),
            textAlign: align,
            style: TextStyle(color: color, fontSize: base, fontWeight: box.bold ? FontWeight.bold : FontWeight.normal, height: 1.3),
          ),
        ),
    ]);
  }
}

/// Image du stockage (URL signée) ; cadre gris tant qu'elle charge ou hors ligne.
class SlideImageView extends ConsumerWidget {
  const SlideImageView({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(photoUrlProvider(path)).value;
    if (url == null) {
      return Container(color: Colors.white10, child: const Center(child: Icon(Icons.image_outlined, color: Colors.white38)));
    }
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: Colors.white10));
  }
}

/// Choisit une image (galerie ou appareil photo), l'envoie dans le stockage de l'équipe et renvoie l'image
/// prête à poser (rapport largeur / hauteur lu dans le fichier). null si annulé ou en échec (message affiché).
Future<SlideImage?> pickSlideImage(BuildContext context, WidgetRef ref, {required String teamId, required String sessionId}) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    useRootNavigator: true,
    builder: (context) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('Choisir une image'),
          onTap: () => Navigator.of(context).pop(ImageSource.gallery),
        ),
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: const Text('Prendre une photo'),
          onTap: () => Navigator.of(context).pop(ImageSource.camera),
        ),
      ]),
    ),
  );
  if (source == null) return null;
  final file = await ImagePicker().pickImage(source: source, maxWidth: 1600, maxHeight: 1600, imageQuality: 85);
  if (file == null) return null;
  try {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = (await codec.getNextFrame()).image;
    final ar = frame.width / frame.height;
    final ext = (file.mimeType ?? '').contains('png') ? 'png' : 'jpg';
    final path = 'teams/$teamId/viewing/$sessionId/${const Uuid().v4()}.$ext';
    await ref.read(supabaseProvider).storage.from('photos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: file.mimeType ?? 'image/jpeg'),
        );
    // Taille de départ : au plus la moitié de la hauteur et 45 % de la largeur de la scène, centrée.
    final w = (0.5 * ar / slideAspect).clamp(0.12, 0.45);
    return SlideImage(path: path, ar: ar, w: w, x: 0.5 - w / 2, y: 0.25);
  } on StorageException catch (e) {
    if (context.mounted) showMessage(context, 'Image refusée : ${e.message}');
  } catch (_) {
    if (context.mounted) showMessage(context, 'Une connexion internet est nécessaire pour ajouter une image.');
  }
  return null;
}
