import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Éléments communs des documents PDF (tableau de bord, tactique, programme de séance, feuille de match).

const pdfRed = PdfColor.fromInt(0xFFC8102E);
const pdfGrey = PdfColor.fromInt(0xFF6B6B6B);

/// Polices standard du PDF : Latin-1 seulement ; les quelques signes hors Latin-1 sont remplacés.
String pdfLatin1(String s) => s
    .replaceAll('—', '-')
    .replaceAll('–', '-')
    .replaceAll('’', "'")
    .replaceAll('…', '...')
    .replaceAll('≤', '<=')
    .replaceAll('≥', '>=')
    .replaceAll('œ', 'oe')
    .replaceAll(' ', ' ')
    .replaceAll(' ', ' ')
    .replaceAll(RegExp(r'[^\x00-\xFF]'), '?');

pw.Widget pdfText(String s, {double size = 10, bool bold = false, PdfColor? color, bool italic = false}) => pw.Text(
      pdfLatin1(s),
      style: pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : null,
        fontStyle: italic ? pw.FontStyle.italic : null,
        color: color,
      ),
    );

/// Titre de section, en rouge.
pw.Widget pdfSection(String title) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
      child: pdfText(title, size: 12, bold: true, color: pdfRed),
    );

/// Tableau : en-tête rouge, colonnes de nombres à droite.
pw.Widget pdfTable(List<String> headers, List<List<Object?>> rows) => pw.TableHelper.fromTextArray(
      headers: [for (final h in headers) pdfLatin1(h)],
      data: [for (final r in rows) [for (final c in r) pdfLatin1(c == null ? '' : '$c')]],
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: pdfRed),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        for (var c = 0; c < headers.length; c++)
          c: rows.isNotEmpty && rows.every((r) => r[c] == null || r[c] is num) ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    );

/// Tableau libellé → valeur, sans en-tête (informations d'une séance, d'un match).
pw.Widget pdfFacts(List<(String, String?)> rows) => pw.Table(
      columnWidths: const {0: pw.FixedColumnWidth(110), 1: pw.FlexColumnWidth()},
      border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      children: [
        for (final (k, v) in rows)
          pw.TableRow(children: [
            pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 3), child: pdfText(k, size: 9, color: pdfGrey)),
            pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 3), child: pdfText(v ?? '', size: 9)),
          ]),
      ],
    );

/// Document A4 portrait d'une ou plusieurs pages : en-tête (titre, sous-titre), pied (date d'édition, page).
Future<Uint8List> buildPdfDocument({
  required String title,
  required String subtitle,
  required List<pw.Widget> Function() body,
  PdfPageFormat format = PdfPageFormat.a4,
}) {
  final doc = pw.Document(title: pdfLatin1(title), author: 'PerfFoot');
  final edited = 'Édité le ${DateFormat('d MMMM y à HH:mm', 'fr_FR').format(DateTime.now())} · PerfFoot';
  doc.addPage(pw.MultiPage(
    pageFormat: format,
    margin: const pw.EdgeInsets.all(32),
    header: (context) => pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: pdfRed, width: 2))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pdfText(title, size: 17, bold: true, color: pdfRed),
        if (subtitle.isNotEmpty) pdfText(subtitle, size: 9, color: pdfGrey),
      ]),
    ),
    footer: (context) => pw.Row(children: [
      pw.Expanded(child: pdfText(edited, size: 7, color: pdfGrey)),
      pdfText('Page ${context.pageNumber} / ${context.pagesCount}', size: 7, color: pdfGrey),
    ]),
    build: (context) => body(),
  ));
  return doc.save();
}

/// Image PNG centrée, à la largeur voulue (points).
pw.Widget pdfImage(Uint8List png, {double width = 300}) =>
    pw.Center(child: pw.Image(pw.MemoryImage(png), width: width));

/// Nom de fichier sans accents ni signes : « Corner_rentrant_2026-10-23 ».
String fileSafe(String s) {
  const from = 'àâäáãéèêëíìîïóòôöõúùûüçñÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ';
  const to = 'aaaaaeeeeiiiiooooouuuucnAAAEEEEIIOOUUUC';
  final b = StringBuffer();
  for (final r in s.runes) {
    final c = String.fromCharCode(r);
    final i = from.indexOf(c);
    b.write(i >= 0 ? to[i] : c);
  }
  return b.toString().replaceAll(RegExp(r'[^A-Za-z0-9\-]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
}
