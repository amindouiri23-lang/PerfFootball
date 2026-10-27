import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../tactics/tactic_board.dart';
import '../tactics/tactic_repository.dart';
import '../tactics/tactic_screens.dart' show BoardView;
import 'slide_layout.dart';
import 'slide_stage.dart';
import 'viewing_repository.dart';
import 'viewing_screens.dart' show slideTitle;

/// Mise en page d'une diapositive : aperçu 16:9 où l'on glisse le texte et les images (poignée jaune pour la
/// taille), réglages du texte (taille, alignement, gras, couleur, position rapide) et ajout d'images.
class SlideLayoutScreen extends ConsumerStatefulWidget {
  const SlideLayoutScreen({super.key, required this.sessionId, required this.slideId});

  final String sessionId;
  final String slideId;

  @override
  ConsumerState<SlideLayoutScreen> createState() => _SlideLayoutScreenState();
}

class _SlideLayoutScreenState extends ConsumerState<SlideLayoutScreen> {
  SlideLayout? _layout;
  StageSelection _selected;
  bool _adding = false;

  void _save(ViewingSlide s) => ref.read(viewingRepositoryProvider).updateLayout(s.id, _layout!.encode());

  void _edit(ViewingSlide s, VoidCallback change) {
    setState(change);
    _save(s);
  }

  @override
  Widget build(BuildContext context) {
    final v = ref.watch(viewingSessionProvider(widget.sessionId)).value;
    final slides = ref.watch(viewingSlidesProvider(widget.sessionId)).value ?? const <ViewingSlide>[];
    final slide = slides.where((s) => s.id == widget.slideId).firstOrNull;
    if (v == null || slide == null) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    final layout = _layout ??= SlideLayout.decode(slide.layout);
    final tactic = (ref.watch(tacticsProvider(v.teamId)).value ?? const <Tactic>[]).where((t) => t.id == slide.tacticId).firstOrNull;
    final theme = Theme.of(context);
    final t = layout.text;
    final hasText = slide.kind == 'text' && (slide.title != null || slide.body != null);
    final img = _selected is int && (_selected as int) < layout.images.length ? layout.images[_selected as int] : null;

    return Scaffold(
      appBar: AppBar(title: Text('Mise en page · ${slides.indexOf(slide) + 1}. ${slideTitle(slide, tactic)}')),
      body: ListView(padding: const EdgeInsets.fromLTRB(12, 12, 12, 32), children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            // Cadre visible : la diapositive a le même fond sombre que l'écran.
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outline)),
              child: SlideStage(
              slide: slide,
              layout: layout,
              title: slideTitle(slide, tactic),
              content: switch (slide.kind) {
                'tactic' when tactic != null => IgnorePointer(
                    child: Center(
                      child: BoardView(board: TacticBoard.decode(tactic.board), pitch: tactic.pitch, players: const {}, horizontal: true),
                    ),
                  ),
                'video' => const Center(child: Icon(Icons.ondemand_video, color: Colors.white38, size: 64)),
                _ => null,
              },
              selected: _selected,
              onSelect: (id) => setState(() => _selected = id),
              onChanged: () => setState(() {}),
              onChangeEnd: () => _save(slide),
            ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Glissez le texte ou une image pour la placer, la poignée jaune pour changer sa taille. '
            'Le logo du club reste en haut à droite.',
            style: theme.textTheme.bodySmall,
          ),
        ),
        if (hasText) ...[
          const SizedBox(height: 16),
          Text('TEXTE', style: sectionLabel(context)),
          Row(children: [
            const Icon(Icons.format_size, size: 20),
            Expanded(
              child: Slider(
                value: t.size,
                min: 0.6,
                max: 2.5,
                divisions: 19,
                label: '× ${t.size.toStringAsFixed(1)}',
                onChanged: (x) => setState(() => t.size = x),
                onChangeEnd: (_) => _save(slide),
              ),
            ),
          ]),
          Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'left', icon: Icon(Icons.format_align_left), tooltip: 'Aligné à gauche'),
                ButtonSegment(value: 'center', icon: Icon(Icons.format_align_center), tooltip: 'Centré'),
                ButtonSegment(value: 'right', icon: Icon(Icons.format_align_right), tooltip: 'Aligné à droite'),
              ],
              selected: {t.align},
              onSelectionChanged: (a) => _edit(slide, () => t.align = a.first),
            ),
            FilterChip(
              avatar: const Icon(Icons.format_bold, size: 18),
              label: const Text('Gras'),
              selected: t.bold,
              onSelected: (b) => _edit(slide, () => t.bold = b),
            ),
            for (final e in slideTextColors.entries)
              GestureDetector(
                onTap: () => _edit(slide, () => t.color = e.key),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: e.value,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.color == e.key ? theme.colorScheme.primary : Colors.grey, width: t.color == e.key ? 3 : 1),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 8),
          Text('Placer le texte', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final (label, x, y, w) in [
              ('En haut', 0.06, 0.16, 0.8),
              ('Au centre', 0.15, 0.36, 0.7),
              ('En bas', 0.06, 0.66, 0.8),
              ('À gauche', 0.05, 0.2, 0.45),
              ('À droite', 0.5, 0.2, 0.45),
            ])
              ActionChip(
                label: Text(label),
                onPressed: () => _edit(slide, () {
                  t
                    ..x = x
                    ..y = y
                    ..w = w;
                  if (label == 'Au centre') t.align = 'center';
                }),
              ),
          ]),
        ],
        const SizedBox(height: 16),
        Text('IMAGES', style: sectionLabel(context)),
        const SizedBox(height: 4),
        FilledButton.icon(
          onPressed: _adding
              ? null
              : () async {
                  setState(() => _adding = true);
                  final added = await pickSlideImage(context, ref, teamId: v.teamId, sessionId: v.id);
                  if (!mounted) return;
                  setState(() => _adding = false);
                  if (added != null) {
                    _edit(slide, () {
                      layout.images.add(added);
                      _selected = layout.images.length - 1;
                    });
                  }
                },
          icon: _adding
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.add_photo_alternate_outlined),
          label: Text(_adding ? 'Envoi de l\'image…' : 'Ajouter une image'),
        ),
        if (img != null) ...[
          const SizedBox(height: 8),
          Text('Image ${(_selected as int) + 1} sélectionnée', style: theme.textTheme.labelLarge),
          Row(children: [
            const Icon(Icons.photo_size_select_large, size: 20),
            Expanded(
              child: Slider(
                value: img.w.clamp(0.06, 1.2),
                min: 0.06,
                max: 1.2,
                onChanged: (x) => setState(() => img.w = x),
                onChangeEnd: (_) => _save(slide),
              ),
            ),
          ]),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ActionChip(
              avatar: const Icon(Icons.fit_screen, size: 18),
              label: const Text('Plein cadre'),
              onPressed: () => _edit(slide, () {
                // La plus grande taille qui tient dans la scène, centrée.
                img.w = (img.ar / slideAspect).clamp(0.0, 1.0);
                img
                  ..x = (1 - img.w) / 2
                  ..y = (1 - img.h) / 2;
              }),
            ),
            ActionChip(
              avatar: const Icon(Icons.flip_to_front, size: 18),
              label: const Text('Au premier plan'),
              onPressed: () => _edit(slide, () {
                layout.images
                  ..remove(img)
                  ..add(img);
                _selected = layout.images.length - 1;
              }),
            ),
            ActionChip(
              avatar: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Retirer l\'image'),
              onPressed: () => _edit(slide, () {
                layout.images.remove(img);
                _selected = null;
              }),
            ),
          ]),
        ],
        if (layout.images.isNotEmpty && img == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Touchez une image dans l\'aperçu pour la régler.', style: theme.textTheme.bodySmall),
          ),
      ]),
    );
  }
}
