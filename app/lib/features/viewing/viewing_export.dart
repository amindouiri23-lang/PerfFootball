import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/pdf_kit.dart';
import '../../data/database.dart';
import '../tactics/tactic_render.dart';
import '../tactics/tactic_repository.dart';
import '../team/team_repository.dart';
import 'viewing_repository.dart';
import 'viewing_screens.dart' show slideTitle;

final viewingExportProvider = Provider<ViewingExport>((ref) => ViewingExport(ref));

/// Séance de visionnage en PDF, A4 paysage : une page par diapositive (toutes les étapes d'une tactique
/// animée, le lien cliquable d'une vidéo).
class ViewingExport {
  ViewingExport(this._ref);

  final Ref _ref;

  Future<Uint8List> pdf(ViewingSession v) async {
    final slides = await _ref.read(viewingSlidesProvider(v.id).future);
    final tactics = {for (final t in await _ref.read(tacticsProvider(v.teamId).future)) t.id: t};
    final players = {for (final p in await _ref.read(playersProvider(v.teamId).future)) p.id: p};
    final images = <String, List<Uint8List>>{
      for (final s in slides)
        if (tactics[s.tacticId] case final Tactic t) s.id: await renderTacticSteps(t, players, width: 1100),
    };
    final team = (_ref.read(teamsProvider).value ?? const <Team>[]).where((t) => t.id == v.teamId).firstOrNull?.name ?? '';

    pw.Widget slide(int i, ViewingSlide s) {
      final t = tactics[s.tacticId];
      final pngs = images[s.id] ?? const <Uint8List>[];
      final full = t?.pitch == 'full';
      // Largeur d'un schéma selon le nombre d'étapes : tout tient sur la page.
      final w = pngs.length <= 1 ? (full ? 560.0 : 330.0) : (full ? 370.0 : 240.0);
      return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pdfText('${i + 1}. ${slideTitle(s, t)}', size: 20, bold: true),
        pw.SizedBox(height: 8),
        if (s.kind == 'text')
          for (final line in (s.body ?? '').split('\n').where((l) => l.trim().isNotEmpty))
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pdfText('•  ', size: 14, bold: true, color: pdfRed),
                pw.Expanded(child: pdfText(line.trim().replaceFirst(RegExp(r'^[-•*]\s*'), ''), size: 14)),
              ]),
            )
        else if (s.body != null)
          pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child: pdfText(s.body!, size: 12)),
        if (s.kind == 'tactic')
          pngs.isEmpty
              ? pdfText('Tactique supprimée.', color: pdfGrey, italic: true)
              : pw.Wrap(spacing: 12, runSpacing: 8, children: [
                  for (final (k, png) in pngs.indexed)
                    pw.Column(children: [
                      if (pngs.length > 1) pdfText('Étape ${k + 1} / ${pngs.length}', size: 9, bold: true, color: pdfGrey),
                      pw.Image(pw.MemoryImage(png), width: w),
                    ]),
                ]),
        if (s.kind == 'video' && s.videoUrl != null) ...[
          pdfText('Vidéo :', size: 12, bold: true),
          pw.UrlLink(
            destination: s.videoUrl!,
            child: pw.Text(pdfLatin1(s.videoUrl!), style: const pw.TextStyle(fontSize: 12, color: PdfColors.blue, decoration: pw.TextDecoration.underline)),
          ),
        ],
      ]);
    }

    return buildPdfDocument(
      title: v.title,
      subtitle: [team, v.dateLabel, '${slides.length} diapositive${slides.length > 1 ? 's' : ''}'].join(' · '),
      format: PdfPageFormat.a4.landscape,
      body: () => [
        if (v.notes != null) ...[pdfText(v.notes!, size: 11), pw.SizedBox(height: 10)],
        for (final (i, s) in slides.indexed) ...[if (i > 0) pw.NewPage(), slide(i, s)],
      ],
    );
  }
}
