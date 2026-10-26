import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/pdf_kit.dart';
import '../../core/permissions.dart';
import '../../core/router.dart';
import '../../core/save_file.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../sessions/session_repository.dart' show isoDate;
import '../tactics/tactic_board.dart';
import '../tactics/tactic_repository.dart';
import '../tactics/tactic_screens.dart' show BoardView, TacticThumbnail;
import '../team/team_filter.dart';
import '../team/team_repository.dart';
import '../team/team_screen.dart' show NoTeamScreen;
import 'video_view.dart';
import 'viewing_export.dart';
import 'viewing_repository.dart';

const _slideIcons = {'text': Icons.notes, 'tactic': Icons.sports_soccer, 'video': Icons.ondemand_video};

/// Séances de visionnage de l'équipe.
class ViewingListScreen extends ConsumerWidget {
  const ViewingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const NoTeamScreen();
    final sessions = ref.watch(viewingSessionsProvider(team.id)).value ?? const <ViewingSession>[];
    final slides = ref.watch(teamViewingSlidesProvider(team.id)).value ?? const <ViewingSlide>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Visionnage'), actions: const [SyncIndicator()], bottom: teamFilterBar(ref)),
      floatingActionButton: !ref.watch(permsProvider).can('visionnage.add')
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final id = await showViewingInfoSheet(context, ref, teamId: team.id);
                if (id != null && context.mounted) context.go('/team/viewing/$id');
              },
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle séance de visionnage'),
            ),
      body: sessions.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aucune séance de visionnage.\nPréparez une présentation : diapositives de texte, tactiques animées '
                  'et vidéos (lien YouTube, Vimeo…), à projeter devant les joueurs.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(padding: const EdgeInsets.only(bottom: 88), children: [
              for (final v in sessions)
                ListTile(
                  leading: const Icon(Icons.slideshow),
                  title: Text(v.title),
                  subtitle: Text(() {
                    final n = slides.where((s) => s.sessionId == v.id).length;
                    return '${v.dateLabel} · $n diapositive${n > 1 ? 's' : ''}';
                  }()),
                  trailing: IconButton(
                    tooltip: 'Présenter',
                    icon: const Icon(Icons.play_circle_outline),
                    onPressed: () => context.push('/present/${v.id}'),
                  ),
                  onTap: () => context.go('/team/viewing/${v.id}'),
                ),
            ]),
    );
  }
}

/// Titre, date et notes d'une séance de visionnage ; renvoie l'id créé (création) ou null.
Future<String?> showViewingInfoSheet(BuildContext context, WidgetRef ref, {required String teamId, ViewingSession? session}) {
  final title = TextEditingController(text: session?.title ?? '');
  final notes = TextEditingController(text: session?.notes ?? '');
  var date = session?.date == null ? (session == null ? DateTime.now() : null) : DateTime.parse(session!.date!);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(session == null ? 'Nouvelle séance de visionnage' : 'Informations', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: title,
            autofocus: session == null,
            maxLength: 100,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Titre *', hintText: 'Ex. Analyse du match contre l\'EST'),
            onChanged: (_) => setState(() {}),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(date == null ? 'Sans date' : DateFormat('EEEE d MMMM y', 'fr_FR').format(date!)),
            trailing: const Icon(Icons.edit_calendar),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null) setState(() => date = d);
            },
          ),
          TextField(
            controller: notes,
            maxLines: 3,
            maxLength: 2000,
            decoration: const InputDecoration(labelText: 'Notes (facultatif)'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: title.text.trim().isEmpty
                ? null
                : () async {
                    final repo = ref.read(viewingRepositoryProvider);
                    final n = notes.text.trim().isEmpty ? null : notes.text.trim();
                    final d = date == null ? null : isoDate(date!);
                    if (session == null) {
                      final id = await repo.createSession(teamId: teamId, title: title.text.trim(), date: d, notes: n);
                      if (context.mounted) Navigator.of(context).pop(id);
                    } else {
                      await repo.updateSession(session.id, title: title.text.trim(), date: d, notes: n);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
            child: Text(session == null ? 'Créer' : 'Enregistrer'),
          ),
        ]),
      ),
    ),
  );
}

/// Préparation d'une séance de visionnage : diapositives dans l'ordre (glisser pour réordonner).
class ViewingEditorScreen extends ConsumerWidget {
  const ViewingEditorScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(viewingSessionProvider(id)).value;
    if (v == null || v.deleted) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Séance de visionnage introuvable.')));
    final slides = ref.watch(viewingSlidesProvider(id)).value ?? const <ViewingSlide>[];
    final tactics = {for (final t in ref.watch(tacticsProvider(v.teamId)).value ?? const <Tactic>[]) t.id: t};
    final perms = ref.watch(permsProvider);
    final editable = perms.can('visionnage.edit');
    final repo = ref.read(viewingRepositoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(v.title), actions: [
        const SyncIndicator(),
        IconButton(
          tooltip: 'Présenter',
          icon: const Icon(Icons.play_circle_outline),
          onPressed: slides.isEmpty ? null : () => context.push('/present/$id'),
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'info':
                await showViewingInfoSheet(context, ref, teamId: v.teamId, session: v);
              case 'pdf':
                try {
                  final bytes = await ref.read(viewingExportProvider).pdf(v);
                  await saveFile(bytes, 'Visionnage_${fileSafe(v.title)}.pdf', 'application/pdf');
                } catch (e) {
                  if (context.mounted) showMessage(context, 'Export impossible : $e');
                }
              case 'delete':
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Supprimer « ${v.title} » ?'),
                    content: const Text('La présentation et ses diapositives seront supprimées. Les tactiques restent.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
                      FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
                    ],
                  ),
                );
                if (ok == true) {
                  await repo.deleteSession(v.id);
                  if (context.mounted) context.go('/team/viewing');
                }
            }
          },
          itemBuilder: (_) => [
            if (editable) const PopupMenuItem(value: 'info', child: Text('Modifier les informations')),
            const PopupMenuItem(value: 'pdf', child: Text('Exporter en PDF')),
            if (perms.can('visionnage.delete')) const PopupMenuItem(value: 'delete', child: Text('Supprimer la séance')),
          ],
        ),
      ]),
      floatingActionButton: !editable
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addSlide(context, ref, v),
              icon: const Icon(Icons.add),
              label: const Text('Diapositive'),
            ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text([v.dateLabel, if (v.notes != null) v.notes!].join(' · '), style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: slides.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Ajoutez des diapositives : un texte, une tactique (animée ou non) ou une vidéo par son lien.',
                        textAlign: TextAlign.center),
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  buildDefaultDragHandles: editable,
                  itemCount: slides.length,
                  onReorderItem: (from, to) {
                    final list = [...slides];
                    list.insert(to, list.removeAt(from));
                    repo.reorder(list);
                  },
                  itemBuilder: (context, i) {
                    final s = slides[i];
                    final t = tactics[s.tacticId];
                    return ListTile(
                      key: ValueKey(s.id),
                      leading: s.kind == 'tactic' && t != null
                          ? SizedBox(width: 56, child: TacticThumbnail(t))
                          : CircleAvatar(child: Icon(_slideIcons[s.kind])),
                      title: Text('${i + 1}. ${slideTitle(s, t)}'),
                      subtitle: Text(
                        switch (s.kind) {
                          'tactic' => [
                              'Tactique',
                              if (t != null && TacticBoard.decode(t.board).animated) 'animée',
                              if (s.body != null) s.body!,
                            ].join(' · '),
                          'video' => 'Vidéo · ${s.videoUrl}',
                          _ => s.body ?? 'Texte',
                        },
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: editable ? () => showSlideSheet(context, ref, v, kind: s.kind, slide: s) : null,
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Future<void> _addSlide(BuildContext context, WidgetRef ref, ViewingSession v) async {
    final kind = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final e in slideKinds.entries)
            ListTile(
              leading: Icon(_slideIcons[e.key]),
              title: Text(e.value),
              subtitle: Text(switch (e.key) {
                'text' => 'Un titre et un texte, comme une diapositive',
                'tactic' => 'Une tactique de l\'équipe, animée si elle a plusieurs étapes',
                _ => 'Un lien YouTube, Vimeo ou un fichier vidéo',
              }),
              onTap: () => Navigator.of(context).pop(e.key),
            ),
        ]),
      ),
    );
    if (kind != null && context.mounted) await showSlideSheet(context, ref, v, kind: kind);
  }
}

String slideTitle(ViewingSlide s, Tactic? t) =>
    (s.title?.isNotEmpty ?? false) ? s.title! : s.kind == 'tactic' ? (t?.name ?? 'Tactique supprimée') : slideKinds[s.kind]!;

/// Création ou modification d'une diapositive (et suppression en modification).
Future<void> showSlideSheet(BuildContext context, WidgetRef ref, ViewingSession v, {required String kind, ViewingSlide? slide}) {
  final title = TextEditingController(text: slide?.title ?? '');
  final body = TextEditingController(text: slide?.body ?? '');
  final url = TextEditingController(text: slide?.videoUrl ?? '');
  String? tacticId = slide?.tacticId;
  final repo = ref.read(viewingRepositoryProvider);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final tactics = ref.watch(tacticsProvider(v.teamId)).value ?? const <Tactic>[];
        return StatefulBuilder(builder: (context, setState) {
          final link = Uri.tryParse(url.text.trim());
          final urlOk = link != null && link.hasScheme && link.host.isNotEmpty;
          final ok = switch (kind) {
            'tactic' => tacticId != null,
            'video' => urlOk,
            _ => title.text.trim().isNotEmpty || body.text.trim().isNotEmpty,
          };
          String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('${slide == null ? 'Nouvelle diapositive' : 'Diapositive'} · ${slideKinds[kind]}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                if (kind == 'tactic') ...[
                  DropdownButtonFormField<String>(
                    initialValue: tactics.any((t) => t.id == tacticId) ? tacticId : null,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Tactique *'),
                    items: [
                      for (final t in tactics)
                        DropdownMenuItem(
                          value: t.id,
                          child: Text('${t.name}${TacticBoard.decode(t.board).animated ? ' (animée)' : ''}', overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (id) => setState(() => tacticId = id),
                  ),
                  if (tactics.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Aucune tactique : créez-en une dans Équipe → Tactiques.'),
                    ),
                  const SizedBox(height: 12),
                ],
                if (kind == 'video') ...[
                  TextField(
                    controller: url,
                    autofocus: slide == null,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'Lien de la vidéo *',
                      hintText: 'https://www.youtube.com/watch?v=…',
                      helperText: embedOf(url.text) != null
                          ? 'Vidéo lue dans la présentation'
                          : urlOk
                              ? 'Lien ouvert dans le navigateur pendant la présentation'
                              : null,
                      errorText: url.text.trim().isNotEmpty && !urlOk
                          ? 'Collez le lien complet, qui commence par https://'
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: title,
                  autofocus: slide == null && kind == 'text',
                  maxLength: 150,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: kind == 'text' ? 'Titre' : 'Titre (facultatif)'),
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: body,
                  minLines: kind == 'text' ? 5 : 2,
                  maxLines: 12,
                  maxLength: 5000,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: kind == 'text' ? 'Texte' : 'Commentaire (facultatif)',
                    hintText: kind == 'text' ? 'Une idée par ligne : chaque ligne devient une puce' : null,
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                  if (slide != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await repo.deleteSlide(slide.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Supprimer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                    onPressed: !ok
                        ? null
                        : () async {
                            if (slide == null) {
                              await repo.addSlide(v, kind: kind, title: opt(title), body: opt(body), tacticId: tacticId, videoUrl: opt(url));
                            } else {
                              await repo.updateSlide(slide.id, title: opt(title), body: opt(body), tacticId: tacticId, videoUrl: opt(url));
                            }
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    child: Text(slide == null ? 'Ajouter' : 'Enregistrer'),
                  ),
                  ),
                ]),
            ]),
          );
        });
      },
    ),
  );
}

/// Présentation plein écran : une diapositive à la fois ; flèches du clavier, espace, glissé ou boutons.
class ViewingPresentScreen extends ConsumerStatefulWidget {
  const ViewingPresentScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ViewingPresentScreen> createState() => _ViewingPresentScreenState();
}

class _ViewingPresentScreenState extends ConsumerState<ViewingPresentScreen> {
  final _pages = PageController();
  final _focus = FocusNode();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pages.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _go(int i, int count) {
    if (i < 0 || i >= count) return;
    _pages.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final v = ref.watch(viewingSessionProvider(widget.id)).value;
    final slides = ref.watch(viewingSlidesProvider(widget.id)).value ?? const <ViewingSlide>[];
    final teamId = v?.teamId ?? '';
    final tactics = {for (final t in ref.watch(tacticsProvider(teamId)).value ?? const <Tactic>[]) t.id: t};
    final players = {for (final p in ref.watch(playersProvider(teamId)).value ?? const <Player>[]) p.id: p};
    final count = slides.length;
    void close() => context.canPop() ? context.pop() : context.go('/team/viewing/${widget.id}');

    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0F12),
        body: KeyboardListener(
          focusNode: _focus,
          autofocus: true,
          onKeyEvent: (e) {
            if (e is! KeyDownEvent) return;
            final k = e.logicalKey;
            if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.pageDown) {
              _go(_index + 1, count);
            } else if (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.pageUp) {
              _go(_index - 1, count);
            } else if (k == LogicalKeyboardKey.escape) {
              close();
            }
          },
          child: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(children: [
                  IconButton(tooltip: 'Quitter la présentation', icon: const Icon(Icons.close), onPressed: close),
                  Expanded(child: Text(v?.title ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70))),
                  Text(count == 0 ? '' : '${_index + 1} / $count', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                ]),
              ),
              Expanded(
                child: count == 0
                    ? const Center(child: Text('Aucune diapositive.'))
                    : PageView.builder(
                        controller: _pages,
                        itemCount: count,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (context, i) => _SlideView(slide: slides[i], tactic: tactics[slides[i].tacticId], players: players),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton.filledTonal(
                    tooltip: 'Précédente',
                    onPressed: _index > 0 ? () => _go(_index - 1, count) : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const SizedBox(width: 24),
                  IconButton.filledTonal(
                    tooltip: 'Suivante',
                    onPressed: _index < count - 1 ? () => _go(_index + 1, count) : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.tactic, required this.players});

  final ViewingSlide slide;
  final Tactic? tactic;
  final Map<String, Player> players;

  @override
  Widget build(BuildContext context) {
    final title = slideTitle(slide, tactic);
    return LayoutBuilder(builder: (context, c) {
      final big = c.maxWidth > 700;
      final titleStyle = TextStyle(fontSize: big ? 34 : 24, fontWeight: FontWeight.bold, color: Colors.white);
      final bodyStyle = TextStyle(fontSize: big ? 22 : 16, color: Colors.white70, height: 1.4);
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: big ? 48 : 16, vertical: 8),
        child: switch (slide.kind) {
          'tactic' => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(title, style: titleStyle, textAlign: TextAlign.center),
              if (slide.body != null) Text(slide.body!, style: bodyStyle, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Expanded(
                child: tactic == null
                    ? const Center(child: Text('Tactique supprimée.'))
                    : _AnimatedTactic(tactic: tactic!, players: players),
              ),
            ]),
          'video' => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(title, style: titleStyle, textAlign: TextAlign.center),
              if (slide.body != null) Text(slide.body!, style: bodyStyle, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Expanded(child: _Video(url: slide.videoUrl ?? '')),
            ]),
          _ => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight - 16),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (slide.title != null) Text(slide.title!, style: titleStyle.copyWith(fontSize: big ? 44 : 28)),
                  if (slide.title != null && slide.body != null) const SizedBox(height: 24),
                  for (final line in (slide.body ?? '').split('\n').where((l) => l.trim().isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('•  ', style: bodyStyle.copyWith(color: const Color(0xFFE30613), fontWeight: FontWeight.bold)),
                        Expanded(child: Text(line.trim().replaceFirst(RegExp(r'^[-•*]\s*'), ''), style: bodyStyle.copyWith(color: Colors.white))),
                      ]),
                    ),
                ]),
              ),
            ),
        },
      );
    });
  }
}

/// Tactique d'une diapositive : à l'horizontale ; si elle est animée, lecture en boucle et étapes.
class _AnimatedTactic extends StatefulWidget {
  const _AnimatedTactic({required this.tactic, required this.players});

  final Tactic tactic;
  final Map<String, Player> players;

  @override
  State<_AnimatedTactic> createState() => _AnimatedTacticState();
}

class _AnimatedTacticState extends State<_AnimatedTactic> with SingleTickerProviderStateMixin {
  late TacticBoard _board = TacticBoard.decode(widget.tactic.board);
  late final AnimationController _play = AnimationController(vsync: this)..addListener(() => setState(() {}));
  double _t = 0;

  @override
  void didUpdateWidget(_AnimatedTactic old) {
    super.didUpdateWidget(old);
    if (old.tactic.board != widget.tactic.board) _board = TacticBoard.decode(widget.tactic.board);
  }

  @override
  void dispose() {
    _play.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_play.isAnimating) {
      _play.stop();
      setState(() {});
      return;
    }
    final last = (_board.stepCount - 1).toDouble();
    _play
      ..duration = Duration(milliseconds: 1500 * (_board.stepCount - 1))
      ..value = _t >= last ? 0 : _t / last;
    _play.forward().whenCompleteOrCancel(() => mounted ? setState(() {}) : null);
  }

  @override
  Widget build(BuildContext context) {
    final last = (_board.stepCount - 1).toDouble();
    if (_play.isAnimating) _t = _play.value * last;
    return Column(children: [
      Expanded(
        child: Center(
          child: BoardView(board: _board.frameAt(_t), pitch: widget.tactic.pitch, players: widget.players, horizontal: true),
        ),
      ),
      if (_board.animated)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
            FilledButton.icon(
              onPressed: _toggle,
              icon: Icon(_play.isAnimating ? Icons.pause : Icons.play_arrow),
              label: Text(_play.isAnimating ? 'Pause' : 'Lire'),
            ),
            for (var s = 0; s < _board.stepCount; s++)
              ChoiceChip(
                label: Text('${s + 1}'),
                selected: !_play.isAnimating && _t == s.toDouble(),
                onSelected: (_) {
                  _play.stop();
                  setState(() => _t = s.toDouble());
                },
              ),
          ]),
        ),
    ]);
  }
}

class _Video extends StatelessWidget {
  const _Video({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final e = embedOf(url);
    final player = e == null ? null : embeddedVideo(e.src, iframe: e.iframe);
    if (player != null) {
      return Center(child: AspectRatio(aspectRatio: 16 / 9, child: player));
    }
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.ondemand_video, size: 96, color: Colors.white54),
        const SizedBox(height: 12),
        Text(url, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Ouvrir la vidéo'),
        ),
      ]),
    );
  }
}
