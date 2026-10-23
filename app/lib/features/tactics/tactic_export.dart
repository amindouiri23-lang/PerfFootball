import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../../core/pdf_kit.dart';
import '../../data/database.dart';
import '../team/team_repository.dart';
import 'tactic_board.dart';
import 'tactic_render.dart';
import 'tactic_repository.dart';

/// Ligne « Corner · Offensif · Demi-terrain ».
String tacticLabel(Tactic t) =>
    [tacticKinds[t.kind] ?? t.kind, tacticSides[t.side] ?? t.side, tacticPitches[t.pitch] ?? t.pitch].join(' · ');

/// Pions qui portent une information (joueur ou rôle), pour la légende sous le schéma.
List<List<Object?>> tacticLegend(Tactic t, Map<String, Player> players) => [
      for (final b in TacticBoard.decode(t.board).tokens)
        if (b.kind == 'us' && (players[b.playerId] != null || (b.role ?? '').isNotEmpty))
          [tokenText(b, players), players[b.playerId]?.fullName ?? '', b.role ?? ''],
    ];

/// Bloc d'une tactique dans un PDF : nom, type, schéma, notes et légende.
List<pw.Widget> tacticPdfBlock(Tactic t, Uint8List? png, Map<String, Player> players, {double width = 300}) {
  final legend = tacticLegend(t, players);
  return [
    pdfText(t.name, size: 11, bold: true),
    pdfText(tacticLabel(t), size: 9, color: pdfGrey),
    pw.SizedBox(height: 6),
    if (png != null) pdfImage(png, width: t.pitch == 'full' ? width * 0.75 : width),
    if ((t.notes ?? '').isNotEmpty) ...[pw.SizedBox(height: 6), pdfText(t.notes!, size: 9)],
    if (legend.isNotEmpty) ...[pw.SizedBox(height: 6), pdfTable(const ['Pion', 'Joueur', 'Rôle'], legend)],
    pw.SizedBox(height: 10),
  ];
}

/// Une tactique seule, sur une page A4.
Future<Uint8List> buildTacticPdf({required Tactic tactic, required Uint8List? png, required Map<String, Player> players, required String team}) =>
    buildPdfDocument(
      title: tactic.name,
      subtitle: '$team · ${tacticLabel(tactic)}',
      body: () => [
        if (png != null) pdfImage(png, width: tactic.pitch == 'full' ? 300 : 430),
        if ((tactic.notes ?? '').isNotEmpty) ...[pdfSection('Notes'), pdfText(tactic.notes!)],
        if (tacticLegend(tactic, players).isNotEmpty) ...[
          pdfSection('Joueurs et rôles'),
          pdfTable(const ['Pion', 'Joueur', 'Rôle'], tacticLegend(tactic, players)),
        ],
      ],
    );
