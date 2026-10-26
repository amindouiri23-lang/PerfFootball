import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/browser_fullscreen.dart';
import '../../core/permissions.dart';
import '../../core/pdf_kit.dart';
import '../../core/router.dart';
import '../../core/save_file.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../team/team_repository.dart';
import '../team/team_screen.dart' show NoTeamScreen;
import '../../core/theme.dart';
import 'tactic_board.dart';
import 'tactic_equipment.dart';
import 'tactic_layouts.dart';
import 'tactic_export.dart';
import 'tactic_render.dart';
import 'tactic_repository.dart';
import '../team/team_filter.dart';

/// Bibliothèque des tactiques de l'équipe : coups de pied arrêtés et situations personnalisées.
class TacticsListScreen extends ConsumerStatefulWidget {
  const TacticsListScreen({super.key});

  @override
  ConsumerState<TacticsListScreen> createState() => _TacticsListScreenState();
}

class _TacticsListScreenState extends ConsumerState<TacticsListScreen> {
  String? _kind;

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const NoTeamScreen();
    final all = ref.watch(tacticsProvider(team.id)).value ?? const <Tactic>[];
    final links = ref.watch(teamTacticLinksProvider(team.id)).value ?? const <TacticLink>[];
    final tactics = all.where((t) => _kind == null || t.kind == _kind).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tactiques'), actions: const [SyncIndicator()], bottom: teamFilterBar(ref)),
      floatingActionButton: !ref.watch(permsProvider).can('tactiques.add') ? null : FloatingActionButton.extended(
        onPressed: () async {
          final id = await showTacticInfoSheet(context, ref, teamId: team.id);
          if (id != null && context.mounted) context.go('/team/tactics/$id');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle tactique'),
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: [
            for (final e in <String?, String>{null: 'Toutes', ...tacticKinds}.entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(e.value), selected: _kind == e.key, onSelected: (_) => setState(() => _kind = e.key)),
              ),
          ]),
        ),
        if (tactics.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Aucune tactique pour l\'instant. Créez vos corners, coups francs et situations de jeu, '
              'puis rattachez-les à vos séances et à vos matchs.',
              textAlign: TextAlign.center,
            ),
          ),
        for (final t in tactics)
          ListTile(
            leading: SizedBox(width: 56, child: TacticThumbnail(t)),
            title: Text(t.name),
            subtitle: Text(tacticSummary(t, links)),
            onTap: () => context.go('/team/tactics/${t.id}'),
          ),
      ]),
    );
  }
}

/// « Corner · Offensif · 3 séances · 1 match ».
String tacticSummary(Tactic t, List<TacticLink> links) {
  final mine = links.where((l) => l.tacticId == t.id);
  final sessions = mine.where((l) => l.sessionId != null).length;
  final matches = mine.where((l) => l.matchId != null).length;
  return [
    tacticKinds[t.kind] ?? t.kind,
    tacticSides[t.side] ?? t.side,
    if (sessions > 0) '$sessions séance${sessions > 1 ? 's' : ''}',
    if (matches > 0) '$matches match${matches > 1 ? 's' : ''}',
  ].join(' · ');
}

/// Miniature non modifiable du tableau (étape 1, à l'horizontale comme dans l'éditeur).
class TacticThumbnail extends StatelessWidget {
  const TacticThumbnail(this.tactic, {super.key});

  final Tactic tactic;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: BoardView(
          board: TacticBoard.decode(tactic.board),
          pitch: tactic.pitch,
          players: const {},
          showCaptions: false,
          horizontal: true,
        ),
      );
}

/// Terrain avec pions et flèches, à l'étape [step]. Sans rappels, il est en lecture seule.
class BoardView extends StatefulWidget {
  const BoardView({
    super.key,
    required this.board,
    required this.pitch,
    required this.players,
    this.step = 0,
    this.horizontal = false,
    this.showCaptions = true,
    this.arrowMode,
    this.onTokenMoved,
    this.onTokenMoveEnd,
    this.onTokenTap,
    this.onArrowDrawn,
    this.onArrowTap,
    this.onArrowBent,
    this.onArrowBendEnd,
  });

  final TacticBoard board;
  final String pitch;
  final Map<String, Player> players;
  /// Étape affichée (0 = étape 1).
  final int step;
  /// Terrain couché, but du haut à droite.
  final bool horizontal;
  final bool showCaptions;
  /// 'run' ou 'ball' : un glissé sur le terrain trace une flèche (les pions ne bougent plus).
  final String? arrowMode;
  /// Nouvelle position du pion pendant le glissé, en fraction du terrain.
  final void Function(BoardToken token, Offset position)? onTokenMoved;
  final VoidCallback? onTokenMoveEnd;
  final ValueChanged<BoardToken>? onTokenTap;
  final ValueChanged<BoardArrow>? onArrowDrawn;
  final ValueChanged<BoardArrow>? onArrowTap;
  /// Poignée du milieu d'une flèche glissée : la flèche se courbe pour passer par ce point.
  final void Function(BoardArrow arrow, Offset through)? onArrowBent;
  final VoidCallback? onArrowBendEnd;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  BoardArrow? _preview;
  final _area = GlobalKey();
  /// Écart entre le doigt et le centre du pion saisi : le pion ne saute pas sous le doigt.
  Offset _grab = Offset.zero;

  String _text(BoardToken t) => tokenText(t, widget.players);

  String? _caption(BoardToken t) => tokenCaption(t, widget.players);

  /// Position du doigt sur le terrain, zoom compris (le tableau peut être agrandi dans l'éditeur).
  Offset _toBoard(Offset global) {
    final box = _area.currentContext!.findRenderObject() as RenderBox;
    return screenToBoard(box.globalToLocal(global), box.size, widget.horizontal);
  }

  @override
  Widget build(BuildContext context) {
    final editable = widget.onTokenMoved != null;
    final h = widget.horizontal;
    final arrows = widget.board.arrowsAt(widget.step);
    return AspectRatio(
      aspectRatio: pitchAspect(widget.pitch, horizontal: h),
      child: LayoutBuilder(builder: (context, c) {
        final size = c.biggest;
        // Taille des pions : proportionnelle à la largeur du terrain (68 m), dans les deux sens.
        final ts = ((h ? size.height : size.width) * 0.075).clamp(8.0, 36.0);
        final drawing = widget.arrowMode != null;
        Offset screen(Offset f) => boardToScreen(f, size, h);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: widget.onArrowTap == null
              ? null
              : (d) {
                  final hit = arrows.where((a) => distanceToArrow(d.localPosition, a, size, horizontal: h) < 14).firstOrNull;
                  if (hit != null) widget.onArrowTap!(hit);
                },
          onPanStart: !drawing
              ? null
              : (d) {
                  final f = screenToBoard(d.localPosition, size, h);
                  setState(() => _preview = BoardArrow(id: 'preview', kind: widget.arrowMode!, x1: f.dx, y1: f.dy, x2: f.dx, y2: f.dy));
                },
          onPanUpdate: !drawing
              ? null
              : (d) {
                  final f = screenToBoard(d.localPosition, size, h);
                  setState(() => _preview
                    ?..x2 = f.dx
                    ..y2 = f.dy);
                },
          onPanEnd: !drawing
              ? null
              : (_) {
                  final a = _preview;
                  setState(() => _preview = null);
                  if (a == null) return;
                  final length = (screen(Offset(a.x2, a.y2)) - screen(Offset(a.x1, a.y1))).distance;
                  if (length > 16) {
                    widget.onArrowDrawn?.call(BoardArrow(
                        id: DateTime.now().microsecondsSinceEpoch.toString(), kind: a.kind, x1: a.x1, y1: a.y1, x2: a.x2, y2: a.y2));
                  }
                },
          child: SizedBox(
            key: _area,
            width: size.width,
            height: size.height,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(
                child: CustomPaint(painter: PitchPainter(pitch: widget.pitch, arrows: arrows, preview: _preview, horizontal: h)),
              ),
              // Poignées : glisser le milieu d'une flèche la courbe.
              if (widget.onArrowBent != null && !drawing)
                for (final a in arrows)
                  Positioned(
                    left: screen(a.point(0.5)).dx - 11,
                    top: screen(a.point(0.5)).dy - 11,
                    width: 22,
                    height: 22,
                    child: GestureDetector(
                      onTap: () => widget.onArrowTap?.call(a),
                      onPanUpdate: (d) => widget.onArrowBent!(a, _toBoard(d.globalPosition)),
                      onPanEnd: (_) => widget.onArrowBendEnd?.call(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
              for (final t in widget.board.tokens)
                Builder(builder: (context) {
                  final p = screen(widget.board.positionAt(t, widget.step));
                  return Positioned(
                    left: p.dx - ts * 2,
                    // Matériel centré sur sa position ; joueur : le rond sur la position, la légende dessous.
                    top: p.dy - (isPlayerToken(t.kind) ? ts / 2 : equipmentSize(t.kind, ts).height / 2),
                    width: ts * 4,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: IgnorePointer(
                        ignoring: !editable || drawing,
                        child: GestureDetector(
                          onTap: () => widget.onTokenTap?.call(t),
                          onPanStart: (d) => _grab = _toBoard(d.globalPosition) - widget.board.positionAt(t, widget.step),
                          onPanUpdate: (d) {
                            final f = _toBoard(d.globalPosition) - _grab;
                            widget.onTokenMoved?.call(t, Offset(f.dx.clamp(0.0, 1.0), f.dy.clamp(0.0, 1.0)));
                          },
                          onPanEnd: (_) => widget.onTokenMoveEnd?.call(),
                          child: TokenView(
                            kind: t.kind,
                            text: _text(t),
                            caption: widget.showCaptions ? _caption(t) : null,
                            size: ts,
                            angle: t.angle,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ]),
          ),
        );
      }),
    );
  }
}

/// Éditeur : terrain à l'horizontale, zoomable ; pions, courses et trajectoires du ballon (droites ou
/// courbes), étapes d'une tactique animée et lecture de l'animation. Chaque geste est enregistré sur
/// l'appareil puis synchronisé.
class TacticEditorScreen extends ConsumerStatefulWidget {
  const TacticEditorScreen({super.key, required this.id, this.fullscreen = false, this.initialStep = 0});

  final String id;
  /// Plein écran : sans barre de titre ni navigation, le terrain occupe tout l'écran.
  final bool fullscreen;
  /// Étape affichée à l'ouverture (celle de l'éditeur d'où l'on passe en plein écran).
  final int initialStep;

  @override
  ConsumerState<TacticEditorScreen> createState() => _TacticEditorScreenState();
}

class _TacticEditorScreenState extends ConsumerState<TacticEditorScreen> with SingleTickerProviderStateMixin {
  TacticBoard? _board;
  final List<String> _undo = [];
  String? _arrowMode;
  /// Étape modifiée (0 = étape 1).
  late int _step = widget.initialStep;
  /// Zoom du terrain ; « Déplacer » active le pincement et le glissé de la vue (sinon le doigt bouge les pions).
  final _zoom = TransformationController();
  bool _panMode = false;
  Size _boardSize = Size.zero;
  late final AnimationController _play = AnimationController(vsync: this)..addListener(() => setState(() {}));
  bool _playing = false;
  bool _orientationSet = false;
  /// Plein écran : barre d'outils dépliée.
  bool _toolsOpen = true;

  @override
  void initState() {
    super.initState();
    if (widget.fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      enterBrowserFullscreen();
    }
  }

  /// Ouvre le même tableau en plein écran ; au retour, reprend le tableau tel qu'il y a été modifié.
  Future<void> _openFullscreen(Tactic t) async {
    final result = await context.push<String>('/fullscreen/tactic/${t.id}?step=$_step');
    if (!mounted) return;
    setState(() {
      _board = result == null ? null : TacticBoard.decode(result);
      _undo.clear();
    });
  }

  void _leaveFullscreen() {
    exitBrowserFullscreen();
    context.pop(_board?.encode());
  }

  TacticRepository get _repo => ref.read(tacticRepositoryProvider);

  @override
  void dispose() {
    if (widget.fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(const []);
      exitBrowserFullscreen();
    }
    _play.dispose();
    _zoom.dispose();
    super.dispose();
  }

  /// Mémorise l'état avant une modification (bouton « Annuler »).
  void _snapshot() {
    _undo.add(_board!.encode());
    if (_undo.length > 50) _undo.removeAt(0);
  }

  void _save() => _repo.saveBoard(widget.id, _board!);

  void _change(VoidCallback edit) {
    _snapshot();
    setState(edit);
    _save();
  }

  /// Zoom d'un facteur [f] autour de [focal] (centre du terrain par défaut), entre 1 et 5.
  void _zoomBy(double f, [Offset? focal]) {
    final m = _zoom.value.clone();
    final current = m.getMaxScaleOnAxis();
    final target = (current * f).clamp(1.0, 5.0);
    if (target <= 1.0001) {
      setState(() => _zoom.value = Matrix4.identity());
      return;
    }
    final k = target / current;
    final c = focal ?? Offset(_boardSize.width / 2, _boardSize.height / 2);
    final scene = MatrixUtils.transformPoint(Matrix4.inverted(m), c);
    m
      ..translateByDouble(scene.dx, scene.dy, 0, 1)
      ..scaleByDouble(k, k, 1, 1)
      ..translateByDouble(-scene.dx, -scene.dy, 0, 1);
    setState(() => _zoom.value = m);
  }

  Future<void> _togglePlay() async {
    final board = _board!;
    if (_playing) {
      _play.stop();
      setState(() => _playing = false);
      return;
    }
    setState(() {
      _playing = true;
      _arrowMode = null;
    });
    _play
      ..duration = Duration(milliseconds: 1500 * (board.stepCount - 1))
      ..value = 0;
    await _play.forward().orCancel.catchError((_) {});
    // Lecture finie : on reste sur l'étape atteinte (la dernière), sans revenir en arrière.
    if (mounted) {
      setState(() {
        if (_playing) _step = (_play.value * (board.stepCount - 1)).round();
        _playing = false;
      });
    }
  }

  Future<void> _arrowActions(BoardArrow a) async {
    final board = _board!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (a.curved)
            ListTile(
              leading: const Icon(Icons.horizontal_rule),
              title: const Text('Redresser la flèche'),
              onTap: () => Navigator.of(context).pop('straight'),
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Retirer la flèche'),
            onTap: () => Navigator.of(context).pop('delete'),
          ),
        ]),
      ),
    );
    switch (choice) {
      case 'straight':
        _change(a.straighten);
      case 'delete':
        _change(() => board.arrowsAt(_step).remove(a));
        if (mounted) showMessage(context, 'Flèche retirée (Annuler pour la remettre)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(tacticProvider(widget.id));
    final t = async.value;
    if (t == null || t.deleted) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: async.isLoading ? const CircularProgressIndicator() : const Text('Tactique introuvable.')),
      );
    }
    _board ??= TacticBoard.decode(t.board);
    final board = _board!;
    if (_step >= board.stepCount) _step = board.stepCount - 1;
    final players = {for (final p in ref.watch(playersProvider(t.teamId)).value ?? const <Player>[]) p.id: p};
    final links = ref.watch(teamTacticLinksProvider(t.teamId)).value ?? const <TacticLink>[];
    final theme = Theme.of(context);
    final perms = ref.watch(permsProvider);
    final editable = perms.can('tactiques.edit') && !_playing;

    final view = _playing
        // _play va de 0 à 1 : toute l'animation, de l'étape 1 à la dernière.
        ? BoardView(board: board.frameAt(_play.value * (board.stepCount - 1)), pitch: t.pitch, players: players, horizontal: true)
        : IgnorePointer(
            ignoring: !editable || _panMode,
            child: BoardView(
              board: board,
              pitch: t.pitch,
              players: players,
              step: _step,
              horizontal: true,
              arrowMode: _arrowMode,
              onTokenMoved: (token, p) {
                if (!_dragging) {
                  _dragging = true;
                  _snapshot();
                }
                setState(() => board.setPosition(token, _step, p));
              },
              onTokenMoveEnd: () {
                _dragging = false;
                _save();
              },
              onTokenTap: (token) => _editToken(token, players),
              onArrowDrawn: (a) => _change(() => board.addArrow(_step, a)),
              onArrowTap: _arrowActions,
              onArrowBent: (a, through) {
                if (!_dragging) {
                  _dragging = true;
                  _snapshot();
                }
                setState(() => a.bendThrough(through));
              },
              onArrowBendEnd: () {
                _dragging = false;
                _save();
              },
            ),
          );

    // Étapes d'une tactique animée.
    final steps = board.animated || editable ? SizedBox(
              height: 48,
              child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
                for (var s = 0; s < board.stepCount; s++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
                    child: ChoiceChip(
                      label: Text(board.animated ? 'Étape ${s + 1}' : 'Étape unique'),
                      selected: !_playing && _step == s,
                      onSelected: _playing ? null : (_) => setState(() => _step = s),
                    ),
                  ),
                if (editable)
                  IconButton(
                    tooltip: 'Ajouter une étape (animation)',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _change(() {
                      board.addStep(_step);
                      _step++;
                    }),
                  ),
                if (editable && _step > 0)
                  IconButton(
                    tooltip: 'Supprimer l\'étape ${_step + 1}',
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _change(() {
                      board.removeStep(_step);
                      _step--;
                    }),
                  ),
                if (board.animated)
                  TextButton.icon(
                    onPressed: _togglePlay,
                    icon: Icon(_playing ? Icons.stop : Icons.play_arrow),
                    label: Text(_playing ? 'Arrêter' : 'Lire l\'animation'),
                  ),
              ]),
            ) : null;
    final tools = editable && !_panMode ? Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Wrap(spacing: 8, runSpacing: 4, alignment: WrapAlignment.center, children: [
              ActionChip(
                avatar: const CircleAvatar(backgroundColor: tokenUsColor, radius: 8),
                label: const Text('Joueur'),
                onPressed: () => _addPlayer(players),
              ),
              ActionChip(
                avatar: const CircleAvatar(backgroundColor: tokenThemColor, radius: 8),
                label: const Text('Adversaire'),
                onPressed: () => _change(() => board.tokens.add(_newToken('them', board))),
              ),
              if (board.ball == null)
                ActionChip(
                  avatar: const Icon(Icons.sports_soccer, size: 18),
                  label: const Text('Ballon'),
                  onPressed: () => _change(() => board.tokens.add(BoardToken(id: 'ball', kind: 'ball', x: 0.5, y: 0.5))),
                ),
              ActionChip(
                avatar: const Icon(Icons.grid_view, size: 18),
                label: const Text('Dispositions'),
                onPressed: () => _pickLayout(t.pitch),
              ),
              ActionChip(
                avatar: const Icon(Icons.sports, size: 18),
                label: const Text('Matériel'),
                onPressed: _pickEquipment,
              ),
              FilterChip(
                avatar: const Icon(Icons.trending_up, size: 18),
                label: const Text('Course'),
                selected: _arrowMode == 'run',
                onSelected: (v) => setState(() => _arrowMode = v ? 'run' : null),
              ),
              FilterChip(
                avatar: const Icon(Icons.more_horiz, size: 18),
                label: const Text('Ballon →'),
                selected: _arrowMode == 'ball',
                onSelected: (v) => setState(() => _arrowMode = v ? 'ball' : null),
              ),
              ActionChip(
                avatar: const Icon(Icons.flip, size: 18),
                label: const Text('Symétrie'),
                onPressed: () {
                  _change(board.mirror);
                  showMessage(context, 'Tactique retournée : côté opposé du terrain');
                },
              ),
            ]),
          ) : null;
    // Le plus grand terrain horizontal qui tient dans la place disponible, avec ses boutons de zoom.
    Widget pitchArea(EdgeInsets padding) => Padding(padding: padding, child: LayoutBuilder(builder: (context, c) {
                // Le plus grand terrain horizontal qui tient dans la place disponible.
                final aspect = pitchAspect(t.pitch, horizontal: true);
                var w = c.maxWidth, h = w / aspect;
                if (h > c.maxHeight) {
                  h = c.maxHeight;
                  w = h * aspect;
                }
                _boardSize = Size(w, h);
                return Stack(children: [
                  Center(
                    child: SizedBox(
                      width: w,
                      height: h,
                      child: _panMode
                          ? InteractiveViewer(transformationController: _zoom, minScale: 1, maxScale: 5, child: view)
                          : Listener(
                              // Molette de la souris : zoom sous le pointeur.
                              onPointerSignal: (e) {
                                if (e is PointerScrollEvent) _zoomBy(e.scrollDelta.dy < 0 ? 1.15 : 1 / 1.15, e.localPosition);
                              },
                              child: ClipRect(child: Transform(transform: _zoom.value, child: view)),
                            ),
                    ),
                  ),
                  // À gauche : notre moitié de terrain ; le but et les coins sont à droite.
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(tooltip: 'Zoomer', icon: const Icon(Icons.zoom_in), onPressed: () => _zoomBy(1.4)),
                        IconButton(tooltip: 'Dézoomer', icon: const Icon(Icons.zoom_out), onPressed: () => _zoomBy(1 / 1.4)),
                        IconButton(
                          tooltip: 'Terrain entier',
                          icon: const Icon(Icons.fit_screen),
                          onPressed: () => setState(() => _zoom.value = Matrix4.identity()),
                        ),
                        IconButton(
                          tooltip: _panMode ? 'Revenir à l\'édition' : 'Déplacer la vue',
                          isSelected: _panMode,
                          icon: const Icon(Icons.pan_tool_outlined),
                          selectedIcon: const Icon(Icons.pan_tool),
                          onPressed: () => setState(() => _panMode = !_panMode),
                        ),
                      ]),
                    ),
                  ),
                ]);
              }));
    final undo = IconButton(
      tooltip: 'Annuler la dernière modification',
      icon: const Icon(Icons.undo),
      onPressed: _undo.isEmpty
          ? null
          : () {
              setState(() => _board = TacticBoard.decode(_undo.removeLast()));
              _save();
            },
    );

    if (widget.fullscreen) {
      // Plein écran : tout l'écran pour le terrain ; outils posés dessus, sur un fond sombre translucide.
      final glass = Colors.black.withValues(alpha: 0.55);
      if (!_orientationSet) {
        _orientationSet = true;
        // Terrain entier : bien plus large que haut, il occupe l'écran d'un téléphone tenu à l'horizontale.
        if (t.pitch == 'full') {
          SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
        }
      }
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _leaveFullscreen();
        },
        child: Theme(
          data: ThemeData.dark(useMaterial3: true).copyWith(colorScheme: theme.colorScheme),
          child: Scaffold(
            backgroundColor: const Color(0xFF0E0F12),
            body: Stack(children: [
              Positioned.fill(child: pitchArea(const EdgeInsets.fromLTRB(56, 52, 4, 4))),
              Positioned(
                left: 4,
                top: 4,
                child: Material(
                  color: glass,
                  borderRadius: BorderRadius.circular(12),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(tooltip: 'Quitter le plein écran', icon: const Icon(Icons.fullscreen_exit), onPressed: _leaveFullscreen),
                    if (editable) undo,
                  ]),
                ),
              ),
              if (steps != null)
                Positioned(
                  left: 120,
                  right: 4,
                  top: 4,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Material(color: glass, borderRadius: BorderRadius.circular(12), child: steps),
                  ),
                ),
              if (tools != null)
                Positioned(
                  left: 56,
                  right: 4,
                  bottom: 4,
                  child: Center(
                    child: Material(
                      color: glass,
                      borderRadius: BorderRadius.circular(16),
                      child: _toolsOpen
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              Flexible(child: tools),
                              IconButton(tooltip: 'Masquer les outils', icon: const Icon(Icons.expand_more), onPressed: () => setState(() => _toolsOpen = false)),
                            ])
                          : IconButton(tooltip: 'Afficher les outils', icon: const Icon(Icons.construction), onPressed: () => setState(() => _toolsOpen = true)),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.name),
        actions: [
          if (editable) undo,
          IconButton(tooltip: 'Plein écran', icon: const Icon(Icons.fullscreen), onPressed: () => _openFullscreen(t)),
          PopupMenuButton<String>(
            onSelected: (v) async {
              switch (v) {
                case 'info':
                  await showTacticInfoSheet(context, ref, teamId: t.teamId, tactic: t);
                case 'png':
                  await _export(t, board, players, pdf: false);
                case 'pdf':
                  await _export(t, board, players, pdf: true);
                case 'duplicate':
                  final id = await _repo.duplicate(t.copyWith(board: board.encode()));
                  if (context.mounted) {
                    showMessage(context, 'Copie créée');
                    context.go('/team/tactics/$id');
                  }
                case 'clear':
                  _change(board.arrowsAt(_step).clear);
                case 'delete':
                  if (await _confirmDelete(context, t) && context.mounted) {
                    await _repo.delete(t.id);
                    if (context.mounted) {
                      showMessage(context, 'Tactique supprimée');
                      context.pop();
                    }
                  }
              }
            },
            itemBuilder: (_) => [
              if (editable) const PopupMenuItem(value: 'info', child: Text('Modifier les informations')),
              PopupMenuItem(value: 'png', child: Text(board.animated ? 'Exporter l\'étape en image (PNG)' : 'Exporter en image (PNG)')),
              PopupMenuItem(value: 'pdf', child: Text(board.animated ? 'Exporter en PDF (toutes les étapes)' : 'Exporter en PDF')),
              if (perms.can('tactiques.add')) const PopupMenuItem(value: 'duplicate', child: Text('Dupliquer')),
              if (editable)
                PopupMenuItem(value: 'clear', child: Text(board.animated ? 'Effacer les flèches de l\'étape' : 'Effacer toutes les flèches')),
              if (perms.can('tactiques.delete')) const PopupMenuItem(value: 'delete', child: Text('Supprimer la tactique')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${tacticSummary(t, links)} · ${tacticPitches[t.pitch]}', style: theme.textTheme.bodySmall),
              if (t.notes != null) Text(t.notes!, style: theme.textTheme.bodySmall),
              if (editable)
              Text(
                _panMode
                    ? 'Pincez ou glissez pour zoomer et déplacer la vue. Touchez la main pour revenir à l\'édition.'
                    : _arrowMode == null
                        ? 'Glissez les pions pour les placer, le rond d\'une flèche pour la courber. Touchez un pion ou une flèche pour la modifier.'
                        : 'Glissez depuis ${_arrowMode == 'run' ? 'un joueur pour tracer sa course' : 'le ballon pour tracer sa trajectoire'} : '
                            'à l\'étape suivante, il arrive au bout et l\'animation suit la flèche, même courbée.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
              ),
            ]),
          ),
          ?steps,
          Expanded(child: pitchArea(const EdgeInsets.fromLTRB(12, 4, 12, 0))),
          ?tools,
        ]),
      ),
    );
  }

  bool _dragging = false;

  /// Nouveau pion au milieu du terrain, décalé pour ne pas recouvrir le précédent.
  BoardToken _newToken(String kind, TacticBoard board, {String? playerId, String? label}) {
    final n = board.tokens.where((t) => t.kind == kind).length;
    return BoardToken(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      kind: kind,
      x: 0.3 + (n % 5) * 0.1,
      y: (kind == 'us' ? 0.55 : 0.4) + (n ~/ 5) * 0.08,
      playerId: playerId,
      label: label,
    );
  }

  Future<void> _addPlayer(Map<String, Player> players) async {
    final board = _board!;
    final placed = board.tokens.map((t) => t.playerId).whereType<String>().toSet();
    final choice = await _pickPlayer(context, players, exclude: placed, title: 'Ajouter un joueur');
    if (choice == null) return;
    final n = board.tokens.where((t) => t.kind == 'us').length + 1;
    _change(() => board.tokens.add(_newToken('us', board, playerId: choice.isEmpty ? null : choice, label: choice.isEmpty ? '$n' : null)));
  }

  /// Disposition prête : dispositif, coup de pied arrêté ou atelier ; ajoutée au terrain, ou à la place.
  Future<void> _pickLayout(String pitch) async {
    final board = _board!;
    var replace = false;
    final layout = await showModalBottomSheet<TacticLayout>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (context, scroll) => ListView(controller: scroll, children: [
            ListTile(title: Text('Dispositions prêtes', style: Theme.of(context).textTheme.titleMedium)),
            if (board.tokens.isNotEmpty)
              SwitchListTile(
                title: const Text('Vider le terrain avant'),
                subtitle: const Text('Sinon la disposition s\'ajoute à ce qui est déjà placé'),
                value: replace,
                onChanged: (v) => setSheet(() => replace = v),
              ),
            for (final cat in layoutCategories) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(cat.toUpperCase(), style: sectionLabel(context)),
              ),
              for (final l in tacticLayouts.where((l) => l.category == cat))
                ListTile(
                  dense: true,
                  title: Text(l.name),
                  subtitle: l.description == null ? null : Text(l.description!),
                  onTap: () => Navigator.of(context).pop(l),
                ),
            ],
          ]),
        ),
      ),
    );
    if (layout == null) return;
    _change(() {
      if (replace) {
        for (final tk in [...board.tokens]) {
          board.removeToken(tk);
        }
        board.arrowsAt(_step).clear();
      }
      for (final tk in layoutTokens(layout, pitch)) {
        board.tokens.add(tk);
        // À une étape suivante, la disposition apparaît où elle est posée.
        if (_step > 0) board.setPosition(tk, _step, Offset(tk.x, tk.y));
      }
    });
  }

  /// Matériel d'entraînement : posé au centre du terrain, à déplacer ensuite.
  Future<void> _pickEquipment() async {
    final board = _board!;
    final kind = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Matériel', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in equipmentKinds.entries)
                ActionChip(
                  avatar: Icon(equipmentIcons[e.key], size: 18),
                  label: Text(e.value),
                  onPressed: () => Navigator.of(context).pop(e.key),
                ),
            ]),
          ]),
        ),
      ),
    );
    if (kind == null) return;
    final n = board.tokens.where((tk) => tk.kind == kind).length;
    final tk = BoardToken(
      id: '${kind}_${DateTime.now().microsecondsSinceEpoch}',
      kind: kind,
      x: (0.42 + (n % 4) * 0.05).clamp(0.0, 1.0),
      y: (0.45 + (n ~/ 4) * 0.06).clamp(0.0, 1.0),
    );
    _change(() {
      board.tokens.add(tk);
      if (_step > 0) board.setPosition(tk, _step, Offset(tk.x, tk.y));
    });
  }

  /// Toucher un pion : rôle, joueur, numéro, suppression.
  Future<void> _editToken(BoardToken token, Map<String, Player> players) async {
    final board = _board!;
    if (!isPlayerToken(token.kind)) {
      // Matériel : orientation (visible tout de suite sur le terrain) ou retrait.
      final before = token.angle;
      _snapshot();
      final remove = await showModalBottomSheet<bool>(
        context: context,
        useRootNavigator: true,
        barrierColor: Colors.black26,
        builder: (context) => StatefulBuilder(
          builder: (context, setSheet) {
            void turn(double d) {
              setSheet(() {});
              setState(() => token.rotate(d));
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('${equipmentKinds[token.kind] ?? 'Matériel'} · orientation ${token.angle.round()}°',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton.filledTonal(tooltip: 'Tourner de 45° à gauche', onPressed: () => turn(-45), icon: const Icon(Icons.rotate_left)),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(tooltip: 'Tourner de 15° à gauche', onPressed: () => turn(-15), icon: const Icon(Icons.chevron_left)),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(tooltip: 'Quart de tour', onPressed: () => turn(90), icon: const Icon(Icons.screen_rotation_alt)),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(tooltip: 'Tourner de 15° à droite', onPressed: () => turn(15), icon: const Icon(Icons.chevron_right)),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(tooltip: 'Tourner de 45° à droite', onPressed: () => turn(45), icon: const Icon(Icons.rotate_right)),
                  ]),
                  Slider(
                    value: token.angle,
                    max: 359,
                    divisions: 72,
                    label: '${token.angle.round()}°',
                    onChanged: (v) {
                      setSheet(() {});
                      setState(() => token.angle = v);
                    },
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.delete_outline),
                    label: Text('Retirer : ${(equipmentKinds[token.kind] ?? 'élément').toLowerCase()}'),
                  ),
                ]),
              ),
            );
          },
        ),
      );
      if (remove == true) {
        setState(() => board.removeToken(token));
        _save();
      } else if (token.angle != before) {
        _save();
      } else {
        _undo.removeLast(); // rien n'a changé : pas d'étape d'annulation
      }
      return;
    }
    final role = TextEditingController(text: token.role ?? '');
    final label = TextEditingController(text: token.label ?? '');
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: StatefulBuilder(
          builder: (context, setSheet) => SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(token.kind == 'us' ? 'Notre joueur' : 'Adversaire', style: Theme.of(context).textTheme.titleMedium),
              if (token.kind == 'us')
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: Text(players[token.playerId]?.fullName ?? 'Aucun joueur (rôle seulement)'),
                  trailing: const Text('Changer'),
                  onTap: () => Navigator.of(context).pop('player'),
                ),
              if (players[token.playerId] == null)
                TextField(controller: label, maxLength: 3, decoration: const InputDecoration(labelText: 'Numéro ou lettre sur le pion')),
              TextField(controller: role, maxLength: 20, decoration: const InputDecoration(labelText: 'Rôle', hintText: 'Tireur')),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final r in tacticRoles)
                  ActionChip(label: Text(r), onPressed: () => setSheet(() => role.text = r)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                    onPressed: () => Navigator.of(context).pop('delete'),
                    child: const Text('Retirer le pion'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => Navigator.of(context).pop('save'), child: const Text('Enregistrer'))),
              ]),
            ]),
          ),
        ),
      ),
    );
    switch (result) {
      case 'save':
        _change(() {
          token.role = role.text.trim().isEmpty ? null : role.text.trim();
          token.label = label.text.trim().isEmpty ? null : label.text.trim();
        });
      case 'delete':
        _change(() => board.removeToken(token));
      case 'player':
        if (!mounted) return;
        final placed = board.tokens.where((t) => t != token).map((t) => t.playerId).whereType<String>().toSet();
        final choice = await _pickPlayer(context, players, exclude: placed, title: 'Joueur du pion');
        if (choice != null) _change(() => token.playerId = choice.isEmpty ? null : choice);
    }
  }

  /// Exporte la tactique telle qu'affichée (modifications en cours comprises), en image ou en PDF.
  Future<void> _export(Tactic t, TacticBoard board, Map<String, Player> players, {required bool pdf}) async {
    try {
      final current = t.copyWith(board: board.encode());
      final name = fileSafe(t.name);
      if (pdf) {
        final team = ref.read(activeTeamProvider).value?.name ?? '';
        final pngs = await renderTacticSteps(current, players, width: 1200);
        await saveFile(await buildTacticPdf(tactic: current, pngs: pngs, players: players, team: team), '$name.pdf', 'application/pdf');
      } else {
        final png = await renderTacticPng(current, players, width: 1200, step: _step);
        await saveFile(png, board.animated ? '${name}_etape_${_step + 1}.png' : '$name.png', 'image/png');
      }
    } catch (e) {
      if (mounted) showMessage(context, 'Export impossible : $e');
    }
  }
}

Future<bool> _confirmDelete(BuildContext context, Tactic t) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer « ${t.name} » ?'),
        content: const Text('Elle sera aussi retirée des séances et des matchs où elle est rattachée.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
        ],
      ),
    ) ==
    true;

/// Choix d'un joueur de l'effectif. Renvoie son id, '' pour « sans joueur », null si annulé.
Future<String?> _pickPlayer(BuildContext context, Map<String, Player> players, {required Set<String> exclude, required String title}) {
  final list = players.values.where((p) => !exclude.contains(p.id)).toList()
    ..sort((a, b) => (a.shirtNumber ?? 999).compareTo(b.shirtNumber ?? 999));
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ActionChip(
              avatar: const Icon(Icons.badge_outlined, size: 18),
              label: const Text('Pion sans joueur (rôle seulement)'),
              onPressed: () => Navigator.of(context).pop(''),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final p in list)
                ActionChip(label: Text('${p.shirtNumber ?? ''} ${p.lastName}'.trim()), onPressed: () => Navigator.of(context).pop(p.id)),
            ]),
          ]),
        ),
      ),
    ),
  );
}

/// Création (tactic null) ou modification des informations d'une tactique. Renvoie l'id.
Future<String?> showTacticInfoSheet(BuildContext context, WidgetRef ref, {required String teamId, Tactic? tactic}) {
  final name = TextEditingController(text: tactic?.name ?? '');
  final notes = TextEditingController(text: tactic?.notes ?? '');
  var kind = tactic?.kind ?? 'corner';
  var side = tactic?.side ?? 'attack';
  var pitch = tactic?.pitch ?? 'half';
  var pitchTouched = tactic != null;
  var submitted = false;
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(builder: (context, setState) {
      final theme = Theme.of(context);
      final nameOk = name.text.trim().isNotEmpty;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(tactic == null ? 'Nouvelle tactique' : 'Informations de la tactique', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              autofocus: tactic == null,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Nom *',
                hintText: 'Corner rentrant 1er poteau',
                errorText: submitted && !nameOk ? 'Obligatoire' : null,
              ),
            ),
            Text('Situation', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final e in tacticKinds.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: kind == e.key,
                  onSelected: (_) => setState(() {
                    kind = e.key;
                    if (!pitchTouched) pitch = kind == 'custom' || kind == 'kick_off' ? 'full' : 'half';
                  }),
                ),
            ]),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [for (final e in tacticSides.entries) ButtonSegment(value: e.key, label: Text(e.value))],
              selected: {side},
              onSelectionChanged: (v) => setState(() => side = v.first),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [for (final e in tacticPitches.entries) ButtonSegment(value: e.key, label: Text(e.value))],
              selected: {pitch},
              onSelectionChanged: (v) => setState(() {
                pitch = v.first;
                pitchTouched = true;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notes,
              maxLength: 1000,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Consignes', hintText: 'Signal du tireur : bras levé'),
            ),
            FilledButton(
              onPressed: () async {
                setState(() => submitted = true);
                if (!nameOk) return;
                final repo = ref.read(tacticRepositoryProvider);
                final n = notes.text.trim().isEmpty ? null : notes.text.trim();
                final String id;
                if (tactic == null) {
                  id = await repo.create(teamId: teamId, name: name.text.trim(), kind: kind, side: side, pitch: pitch, notes: n);
                } else {
                  id = tactic.id;
                  await repo.updateInfo(id, name: name.text.trim(), kind: kind, side: side, pitch: pitch, notes: n);
                }
                if (context.mounted) Navigator.of(context).pop(id);
              },
              child: Text(tactic == null ? 'Créer et placer les joueurs' : 'Enregistrer'),
            ),
          ]),
        ),
      );
    }),
  );
}

/// Tactiques rattachées à une séance (travaillées) ou à un match (prévues), avec le bouton pour les choisir.
class LinkedTactics extends ConsumerWidget {
  const LinkedTactics({super.key, required this.teamId, this.sessionId, this.matchId, required this.title, required this.basePath});

  final String teamId;
  final String? sessionId;
  final String? matchId;
  final String title;
  /// Route de la séance ou du match : la tactique s'ouvre en dessous (`basePath/tactic/id`).
  final String basePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tactics = ref.watch(tacticsProvider(teamId)).value ?? const <Tactic>[];
    final links = ref.watch(teamTacticLinksProvider(teamId)).value ?? const <TacticLink>[];
    final ids = {
      for (final l in links)
        if ((sessionId != null && l.sessionId == sessionId) || (matchId != null && l.matchId == matchId)) l.tacticId,
    };
    final linked = tactics.where((t) => ids.contains(t.id)).toList();
    final theme = Theme.of(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
        child: Row(children: [
          Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
          TextButton.icon(
            onPressed: () => _choose(context, ref, tactics, ids),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(linked.isEmpty ? 'Ajouter' : 'Modifier'),
          ),
        ]),
      ),
      if (linked.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Aucune tactique rattachée.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        ),
      for (final t in linked)
        ListTile(
          leading: SizedBox(width: 40, child: TacticThumbnail(t)),
          title: Text(t.name),
          subtitle: Text('${tacticKinds[t.kind]} · ${tacticSides[t.side]}'),
          onTap: () => context.go('$basePath/tactic/${t.id}'),
        ),
    ]);
  }

  Future<void> _choose(BuildContext context, WidgetRef ref, List<Tactic> tactics, Set<String> current) async {
    final selected = await pickTactics(context, ref, teamId: teamId, initial: current, title: title);
    if (selected == null) return;
    await ref.read(tacticRepositoryProvider).setLinks(teamId: teamId, sessionId: sessionId, matchId: matchId, tacticIds: selected);
  }
}

/// Choix des tactiques (cases à cocher), avec création d'une nouvelle tactique sans quitter l'écran.
/// Renvoie la sélection, ou null si annulé.
Future<Set<String>?> pickTactics(BuildContext context, WidgetRef ref,
    {required String teamId, required Set<String> initial, required String title}) async {
  final selected = {...initial};
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final tactics = ref.watch(tacticsProvider(teamId)).value ?? const <Tactic>[];
        return StatefulBuilder(
          builder: (context, setState) => SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(padding: const EdgeInsets.all(16), child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
              if (tactics.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Aucune tactique pour l'instant : créez la première ci-dessous."),
                ),
              Flexible(
                child: ListView(shrinkWrap: true, children: [
                  for (final t in tactics)
                    CheckboxListTile(
                      value: selected.contains(t.id),
                      title: Text(t.name),
                      subtitle: Text('${tacticKinds[t.kind]} · ${tacticSides[t.side]}'),
                      onChanged: (v) => setState(() => v == true ? selected.add(t.id) : selected.remove(t.id)),
                    ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Nouvelle tactique'),
                      onPressed: () async {
                        final id = await showTacticInfoSheet(context, ref, teamId: teamId);
                        if (id != null) setState(() => selected.add(id));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Valider'))),
                ]),
              ),
            ]),
          ),
        );
      },
    ),
  );
  return ok == true ? selected : null;
}

/// Champ « Tactiques » des formulaires de séance et de match : pastilles des tactiques choisies et bouton
/// pour les choisir. Le rattachement est enregistré par le formulaire (voir [TacticRepository.setLinks]).
class TacticsField extends ConsumerWidget {
  const TacticsField({super.key, required this.teamId, required this.selected, required this.onChanged, required this.label});

  final String teamId;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tactics = ref.watch(tacticsProvider(teamId)).value ?? const <Tactic>[];
    final chosen = tactics.where((t) => selected.contains(t.id)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final t in chosen)
          InputChip(label: Text(t.name), onDeleted: () => onChanged({...selected}..remove(t.id))),
        ActionChip(
          avatar: const Icon(Icons.sports_soccer, size: 18),
          label: Text(chosen.isEmpty ? 'Choisir des tactiques' : 'Modifier'),
          onPressed: () async {
            final s = await pickTactics(context, ref, teamId: teamId, initial: selected, title: label);
            if (s != null) onChanged(s);
          },
        ),
      ]),
    ]);
  }
}
