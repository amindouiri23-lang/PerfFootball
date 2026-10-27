import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/pdf_kit.dart';
import '../../data/database.dart';
import '../auth/auth_repository.dart';
import '../tactics/tactic_render.dart';
import '../tactics/tactic_repository.dart';
import '../team/team_repository.dart';
import 'slide_layout.dart';
import 'slide_stage.dart' show clubCrestAsset;
import 'viewing_repository.dart';
import 'viewing_screens.dart' show slideTitle;

final viewingExportProvider = Provider<ViewingExport>((ref) => ViewingExport(ref));

const _bg = PdfColor.fromInt(0xFF0E0F12);
const _white70 = PdfColor.fromInt(0xB3FFFFFF);

/// Séance de visionnage en PDF : une page 16:9 par diapositive, comme à l'écran (fond sombre, logo du club en
/// haut à droite, texte placé et stylé, images posées, toutes les étapes d'une tactique animée, lien cliquable
/// d'une vidéo).
class ViewingExport {
  ViewingExport(this._ref);

  final Ref _ref;

  Future<Uint8List> pdf(ViewingSession v) async {
    final slides = await _ref.read(viewingSlidesProvider(v.id).future);
    final tactics = {for (final t in await _ref.read(tacticsProvider(v.teamId).future)) t.id: t};
    final players = {for (final p in await _ref.read(playersProvider(v.teamId).future)) p.id: p};
    final steps = <String, List<Uint8List>>{
      for (final s in slides)
        if (tactics[s.tacticId] case final Tactic t) s.id: await renderTacticSteps(t, players, width: 1100),
    };
    // Images des diapositives, téléchargées une fois (une image introuvable est simplement omise).
    final storage = _ref.read(supabaseProvider).storage.from('photos');
    final pictures = <String, Uint8List>{};
    for (final s in slides) {
      for (final img in SlideLayout.decode(s.layout).images) {
        if (pictures.containsKey(img.path)) continue;
        try {
          pictures[img.path] = await storage.download(img.path);
        } catch (_) {}
      }
    }
    final crest = pw.MemoryImage((await rootBundle.load(clubCrestAsset)).buffer.asUint8List());
    final team = (_ref.read(teamsProvider).value ?? const <Team>[]).where((t) => t.id == v.teamId).firstOrNull?.name ?? '';

    // Page 16:9 (largeur A4 paysage) ; mêmes fractions que la scène à l'écran.
    const pw_ = 842.0, ph = pw_ / slideAspect;
    final format = PdfPageFormat(pw_, ph, marginAll: 0);
    final doc = pw.Document(title: pdfLatin1(v.title), author: 'PerfFoot');

    pw.Widget text(String s, {required double size, PdfColor color = PdfColors.white, bool bold = false, pw.TextAlign? align}) =>
        pw.Text(pdfLatin1(s), textAlign: align, style: pw.TextStyle(fontSize: size, color: color, fontWeight: bold ? pw.FontWeight.bold : null));

    PdfColor colorOf(String key) => PdfColor.fromInt(slideTextColors[key]?.toARGB32() ?? 0xFFFFFFFF);

    pw.Widget page(int i, ViewingSlide s) {
      final t = tactics[s.tacticId];
      final layout = SlideLayout.decode(s.layout);
      final box = layout.text;
      final title = slideTitle(s, t);
      final pngs = steps[s.id] ?? const <Uint8List>[];
      final lines = (s.body ?? '').split('\n').where((l) => l.trim().isNotEmpty).toList();
      final base = pw_ * 0.026 * box.size;
      final align = switch (box.align) { 'center' => pw.TextAlign.center, 'right' => pw.TextAlign.right, _ => pw.TextAlign.left };
      final cross = switch (box.align) {
        'center' => pw.CrossAxisAlignment.center,
        'right' => pw.CrossAxisAlignment.end,
        _ => pw.CrossAxisAlignment.start,
      };
      return pw.Container(
        color: _bg,
        child: pw.Stack(children: [
          if (s.kind != 'text') ...[
            pw.Positioned(left: pw_ * 0.04, top: ph * 0.04, child: text(title, size: pw_ * 0.034, bold: true)),
            if (s.body != null)
              pw.Positioned(
                left: pw_ * 0.04,
                top: ph * 0.12,
                child: pw.SizedBox(width: pw_ * 0.8, child: text(s.body!, size: pw_ * 0.018, color: _white70)),
              ),
            pw.Positioned(
              left: pw_ * 0.04,
              right: pw_ * 0.04,
              top: ph * (s.body != null ? 0.22 : 0.15),
              bottom: ph * 0.04,
              child: switch (s.kind) {
                'tactic' when pngs.isNotEmpty => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                    for (final (k, png) in pngs.indexed)
                      pw.Expanded(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                          child: pw.Column(children: [
                            if (pngs.length > 1) text('Étape ${k + 1} / ${pngs.length}', size: 9, color: _white70),
                            pw.Expanded(child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain)),
                          ]),
                        ),
                      ),
                  ]),
                'video' when s.videoUrl != null => pw.Center(
                    child: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
                      text('Vidéo', size: 14, bold: true),
                      pw.SizedBox(height: 6),
                      pw.UrlLink(
                        destination: s.videoUrl!,
                        child: pw.Text(pdfLatin1(s.videoUrl!),
                            style: const pw.TextStyle(fontSize: 12, color: PdfColors.lightBlue, decoration: pw.TextDecoration.underline)),
                      ),
                    ]),
                  ),
                _ => text('Tactique supprimée.', size: 12, color: _white70),
              },
            ),
          ],
          if (s.kind == 'text' && (s.title != null || lines.isNotEmpty))
            pw.Positioned(
              left: box.x * pw_,
              top: box.y * ph,
              child: pw.SizedBox(
                width: box.w * pw_,
                child: pw.Column(crossAxisAlignment: cross, children: [
                  if (s.title != null) text(s.title!, size: base * 1.7, bold: true, color: colorOf(box.color), align: align),
                  if (s.title != null && lines.isNotEmpty) pw.SizedBox(height: base * 0.8),
                  for (final line in lines)
                    pw.Padding(
                      padding: pw.EdgeInsets.only(bottom: base * 0.35),
                      child: text('${box.align == 'left' ? '•  ' : ''}${line.trim().replaceFirst(RegExp(r'^[-•*]\s*'), '')}',
                          size: base, bold: box.bold, color: colorOf(box.color), align: align),
                    ),
                ]),
              ),
            ),
          for (final img in layout.images)
            if (pictures[img.path] case final Uint8List bytes)
              pw.Positioned(
                left: img.x * pw_,
                top: img.y * ph,
                child: pw.Image(pw.MemoryImage(bytes), width: img.w * pw_, height: img.h * ph, fit: pw.BoxFit.cover),
              ),
          // Logo du club, en haut à droite.
          pw.Positioned(right: pw_ * 0.02, top: ph * 0.03, child: pw.Image(crest, height: ph * 0.1)),
          pw.Positioned(
            left: pw_ * 0.04,
            bottom: ph * 0.015,
            child: text('${v.title} · $team · ${i + 1} / ${slides.length}', size: 7, color: _white70),
          ),
        ]),
      );
    }

    // Page de garde : titre, équipe, date, logo.
    doc.addPage(pw.Page(
      pageFormat: format,
      build: (_) => pw.Container(
        color: _bg,
        child: pw.Center(
          child: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
            pw.Image(crest, height: ph * 0.25),
            pw.SizedBox(height: 16),
            text(v.title, size: 30, bold: true, align: pw.TextAlign.center),
            pw.SizedBox(height: 6),
            text([team, v.dateLabel, '${slides.length} diapositive${slides.length > 1 ? 's' : ''}'].join(' · '), size: 12, color: _white70),
            if (v.notes != null) ...[pw.SizedBox(height: 10), text(v.notes!, size: 11, color: _white70, align: pw.TextAlign.center)],
            pw.SizedBox(height: 18),
            text('Édité le ${DateFormat('d MMMM y', 'fr_FR').format(DateTime.now())} · PerfFoot', size: 8, color: _white70),
          ]),
        ),
      ),
    ));
    for (final (i, s) in slides.indexed) {
      doc.addPage(pw.Page(pageFormat: format, build: (_) => page(i, s)));
    }
    return doc.save();
  }
}
