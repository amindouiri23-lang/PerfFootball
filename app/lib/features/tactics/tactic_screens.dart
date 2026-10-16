import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/router.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../team/team_repository.dart';
import '../team/team_screen.dart' show NoTeamScreen;
import 'tactic_board.dart';
import 'tactic_repository.dart';

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
      appBar: AppBar(title: const Text('Tactiques'), actions: const [SyncIndicator()]),
      floatingActionButton: FloatingActionButton.extended(
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

/// Miniature non modifiable du tableau.
class TacticThumbnail extends StatelessWidget {
  const TacticThumbnail(this.tactic, {super.key});

  final Tactic tactic;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: BoardView(board: TacticBoard.decode(tactic.board), pitch: tactic.pitch, players: const {}, showCaptions: false),
      );
}

/// Terrain avec pions et flèches. Sans rappels, il est en lecture seule.
class BoardView extends StatefulWidget {
  const BoardView({
    super.key,
    required this.board,
    required this.pitch,
    required this.players,
    this.showCaptions = true,
    this.arrowMode,
    this.onTokenMoved,
    this.onTokenMoveEnd,
    this.onTokenTap,
    this.onArrowDrawn,
    this.onArrowTap,
  });

  final TacticBoard board;
  final String pitch;
  final Map<String, Player> players;
  final bool showCaptions;
  /// 'run' ou 'ball' : un glissé sur le terrain trace une flèche (les pions ne bougent plus).
  final String? arrowMode;
  final void Function(BoardToken token, Offset delta)? onTokenMoved;
  final VoidCallback? onTokenMoveEnd;
  final ValueChanged<BoardToken>? onTokenTap;
  final ValueChanged<BoardArrow>? onArrowDrawn;
  final ValueChanged<BoardArrow>? onArrowTap;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  BoardArrow? _preview;

  String _text(BoardToken t) {
    final p = widget.players[t.playerId];
    if (p != null) return p.shirtNumber?.toString() ?? p.initials;
    return t.label ?? '';
  }

  /// Sous le pion : le nom du joueur (suivi de son rôle s'il en a un), sinon le rôle seul.
  String? _caption(BoardToken t) {
    final name = widget.players[t.playerId]?.lastName;
    if (name == null) return t.role;
    return t.role == null ? name : '$name · ${t.role}';
  }

  @override
  Widget build(BuildContext context) {
    final editable = widget.onTokenMoved != null;
    return AspectRatio(
      aspectRatio: pitchWidthM / pitchLengthM(widget.pitch),
      child: LayoutBuilder(builder: (context, c) {
        final size = c.biggest;
        final ts = (size.width * 0.075).clamp(8.0, 36.0);
        Offset frac(Offset p) => Offset((p.dx / size.width).clamp(0.0, 1.0), (p.dy / size.height).clamp(0.0, 1.0));
        final drawing = widget.arrowMode != null;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: widget.onArrowTap == null
              ? null
              : (d) {
                  final hit = widget.board.arrows.where((a) => distanceToArrow(d.localPosition, a, size) < 14).firstOrNull;
                  if (hit != null) widget.onArrowTap!(hit);
                },
          onPanStart: !drawing
              ? null
              : (d) {
                  final f = frac(d.localPosition);
                  setState(() => _preview = BoardArrow(id: 'preview', kind: widget.arrowMode!, x1: f.dx, y1: f.dy, x2: f.dx, y2: f.dy));
                },
          onPanUpdate: !drawing
              ? null
              : (d) {
                  final f = frac(d.localPosition);
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
                  final length = Offset((a.x2 - a.x1) * size.width, (a.y2 - a.y1) * size.height).distance;
                  if (length > 16) {
                    widget.onArrowDrawn?.call(BoardArrow(
                        id: DateTime.now().microsecondsSinceEpoch.toString(), kind: a.kind, x1: a.x1, y1: a.y1, x2: a.x2, y2: a.y2));
                  }
                },
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: CustomPaint(painter: PitchPainter(pitch: widget.pitch, arrows: widget.board.arrows, preview: _preview))),
            for (final t in widget.board.tokens)
              Positioned(
                left: t.x * size.width - ts * 2,
                top: t.y * size.height - (t.kind == 'ball' ? ts * 0.35 : ts / 2),
                width: ts * 4,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: IgnorePointer(
                    ignoring: !editable || drawing,
                    child: GestureDetector(
                      onTap: () => widget.onTokenTap?.call(t),
                      onPanUpdate: (d) => widget.onTokenMoved?.call(t, Offset(d.delta.dx / size.width, d.delta.dy / size.height)),
                      onPanEnd: (_) => widget.onTokenMoveEnd?.call(),
                      child: TokenView(kind: t.kind, text: _text(t), caption: widget.showCaptions ? _caption(t) : null, size: ts),
                    ),
                  ),
                ),
              ),
          ]),
        );
      }),
    );
  }
}

/// Éditeur : déplacer les pions, tracer les courses et la trajectoire du ballon, symétrie, partage en image.
/// Chaque geste est enregistré sur l'appareil puis synchronisé.
class TacticEditorScreen extends ConsumerStatefulWidget {
  const TacticEditorScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<TacticEditorScreen> createState() => _TacticEditorScreenState();
}

class _TacticEditorScreenState extends ConsumerState<TacticEditorScreen> {
  TacticBoard? _board;
  final List<String> _undo = [];
  String? _arrowMode;
  final _capture = GlobalKey();

  TacticRepository get _repo => ref.read(tacticRepositoryProvider);

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
    final players = {for (final p in ref.watch(playersProvider(t.teamId)).value ?? const <Player>[]) p.id: p};
    final links = ref.watch(teamTacticLinksProvider(t.teamId)).value ?? const <TacticLink>[];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.name),
        actions: [
          IconButton(
            tooltip: 'Annuler la dernière modification',
            icon: const Icon(Icons.undo),
            onPressed: _undo.isEmpty
                ? null
                : () {
                    setState(() => _board = TacticBoard.decode(_undo.removeLast()));
                    _save();
                  },
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              switch (v) {
                case 'info':
                  await showTacticInfoSheet(context, ref, teamId: t.teamId, tactic: t);
                case 'share':
                  await _share(t);
                case 'duplicate':
                  final id = await _repo.duplicate(t.copyWith(board: board.encode()));
                  if (context.mounted) {
                    showMessage(context, 'Copie créée');
                    context.go('/team/tactics/$id');
                  }
                case 'clear':
                  _change(board.arrows.clear);
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
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'info', child: Text('Modifier les informations')),
              PopupMenuItem(value: 'share', child: Text('Partager en image')),
              PopupMenuItem(value: 'duplicate', child: Text('Dupliquer')),
              PopupMenuItem(value: 'clear', child: Text('Effacer toutes les flèches')),
              PopupMenuItem(value: 'delete', child: Text('Supprimer la tactique')),
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
              Text(
                _arrowMode == null
                    ? 'Glissez les pions pour les placer. Touchez un pion pour lui donner un rôle ou un joueur, une flèche pour la retirer.'
                    : 'Glissez sur le terrain pour tracer ${_arrowMode == 'run' ? 'une course' : 'la trajectoire du ballon'}.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
              ),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Align(
                alignment: Alignment.topCenter,
                child: RepaintBoundary(
                  key: _capture,
                  child: BoardView(
                    board: board,
                    pitch: t.pitch,
                    players: players,
                    arrowMode: _arrowMode,
                    onTokenMoved: (token, d) {
                      if (!_dragging) {
                        _dragging = true;
                        _snapshot();
                      }
                      setState(() {
                        token.x = (token.x + d.dx).clamp(0.0, 1.0);
                        token.y = (token.y + d.dy).clamp(0.0, 1.0);
                      });
                    },
                    onTokenMoveEnd: () {
                      _dragging = false;
                      _save();
                    },
                    onTokenTap: (token) => _editToken(token, players),
                    onArrowDrawn: (a) => _change(() => board.arrows.add(a)),
                    onArrowTap: (a) {
                      _change(() => board.arrows.remove(a));
                      showMessage(context, 'Flèche retirée (Annuler pour la remettre)');
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
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
                  showMessage(context, 'Tactique retournée gauche / droite');
                },
              ),
            ]),
          ),
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

  /// Toucher un pion : rôle, joueur, numéro, suppression.
  Future<void> _editToken(BoardToken token, Map<String, Player> players) async {
    final board = _board!;
    if (token.kind == 'ball') {
      final remove = await showModalBottomSheet<bool>(
        context: context,
        builder: (context) => SafeArea(
          child: ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Retirer le ballon'),
            onTap: () => Navigator.of(context).pop(true),
          ),
        ),
      );
      if (remove == true) _change(() => board.tokens.remove(token));
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
        _change(() => board.tokens.remove(token));
      case 'player':
        if (!mounted) return;
        final placed = board.tokens.where((t) => t != token).map((t) => t.playerId).whereType<String>().toSet();
        final choice = await _pickPlayer(context, players, exclude: placed, title: 'Joueur du pion');
        if (choice != null) _change(() => token.playerId = choice.isEmpty ? null : choice);
    }
  }

  Future<void> _share(Tactic t) async {
    final boundary = _capture.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    final file = '${t.name.replaceAll(RegExp(r'[^\w\- ]'), '').trim().replaceAll(' ', '_')}.png';
    await SharePlus.instance.share(ShareParams(
      title: t.name,
      files: [XFile.fromData(bytes, mimeType: 'image/png', name: file)],
      fileNameOverrides: [file],
    ));
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
