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

/// Schémas d'une tactique : un par étape, numérotés si la tactique est animée.
List<pw.Widget> _stepImages(Tactic t, List<Uint8List> pngs, double width) => [
      for (final (i, png) in pngs.indexed) ...[
        if (pngs.length > 1) pdfText('Étape ${i + 1} / ${pngs.length}', size: 9, bold: true, color: pdfGrey),
        pdfImage(png, width: t.pitch == 'full' ? width : width * 0.7),
        pw.SizedBox(height: 6),
      ],
    ];

/// Bloc d'une tactique dans un PDF : nom, type, schémas (toutes les étapes), notes et légende.
List<pw.Widget> tacticPdfBlock(Tactic t, List<Uint8List> pngs, Map<String, Player> players, {double width = 300}) {
  final legend = tacticLegend(t, players);
  return [
    pdfText(t.name, size: 11, bold: true),
    pdfText(tacticLabel(t), size: 9, color: pdfGrey),
    pw.SizedBox(height: 6),
    ..._stepImages(t, pngs, width),
    if ((t.notes ?? '').isNotEmpty) ...[pw.SizedBox(height: 6), pdfText(t.notes!, size: 9)],
    if (legend.isNotEmpty) ...[pw.SizedBox(height: 6), pdfTable(const ['Pion', 'Joueur', 'Rôle'], legend)],
    pw.SizedBox(height: 10),
  ];
}

/// Une tactique seule, sur une page A4.
Future<Uint8List> buildTacticPdf({required Tactic tactic, required List<Uint8List> pngs, required Map<String, Player> players, required String team}) =>
    buildPdfDocument(
      title: tactic.name,
      subtitle: '$team · ${tacticLabel(tactic)}${pngs.length > 1 ? ' · animée, ${pngs.length} étapes' : ''}',
      body: () => [
        ..._stepImages(tactic, pngs, 470),
        if ((tactic.notes ?? '').isNotEmpty) ...[pdfSection('Notes'), pdfText(tactic.notes!)],
        if (tacticLegend(tactic, players).isNotEmpty) ...[
          pdfSection('Joueurs et rôles'),
          pdfTable(const ['Pion', 'Joueur', 'Rôle'], tacticLegend(tactic, players)),
        ],
      ],
    );
