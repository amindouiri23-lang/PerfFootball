import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'analytics_report.dart';

// Export du tableau de bord : PDF (une page par onglet, A4 paysage) et Excel (un onglet par page).

/// En-tête commun : « Cadet A · 1 sept. 2026 – 22 oct. 2026 ».
class ReportHeader {
  const ReportHeader({required this.team, required this.period, this.position, this.player});

  final String team;
  final String period;
  final String? position;
  final String? player;

  List<String> get lines => [
        'Équipe : $team',
        'Période : $period',
        if (position != null) 'Poste : $position',
        if (player != null) 'Joueur (charge et ACWR) : $player',
        'Édité le ${DateFormat('d MMMM y à HH:mm', 'fr_FR').format(DateTime.now())}',
      ];
}

String _cell(Object? v) => switch (v) {
      null => '',
      double d => fmtNum(d),
      num n => fmtNum(n),
      _ => '$v',
    };

// ---------------------------------------------------------------------------
// PDF
// ---------------------------------------------------------------------------

const _red = PdfColor.fromInt(0xFFC8102E);
const _grey = PdfColor.fromInt(0xFF6B6B6B);
const _seriesColors = [PdfColor.fromInt(0xFFC8102E), PdfColor.fromInt(0xFF1565C0), PdfColor.fromInt(0xFF2E7D32)];

/// Polices standard du PDF : Latin-1 seulement ; les quelques signes hors Latin-1 sont remplacés.
String _latin1(String s) => s
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

Future<Uint8List> buildPdf(ReportHeader header, List<ReportPage> pages) async {
  final doc = pw.Document(title: 'PerfFoot - Tableau de bord', author: 'PerfFoot');
  pw.Widget text(String s, {double size = 9, bool bold = false, PdfColor? color}) => pw.Text(_latin1(s),
      style: pw.TextStyle(fontSize: size, fontWeight: bold ? pw.FontWeight.bold : null, color: color));

  for (final page in pages) {
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(28),
      header: (context) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 10),
        padding: const pw.EdgeInsets.only(bottom: 6),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _red, width: 2))),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Expanded(child: text('PerfFoot - ${page.title}', size: 16, bold: true, color: _red)),
          text(header.lines.take(header.lines.length - 1).join('   ·   '), size: 8, color: _grey),
        ]),
      ),
      footer: (context) => pw.Row(children: [
        pw.Expanded(child: text(header.lines.last, size: 7, color: _grey)),
        text('Page ${context.pageNumber} / ${context.pagesCount}', size: 7, color: _grey),
      ]),
      build: (context) => [
        if (page.kpis.isNotEmpty)
          pw.Row(children: [
            for (final k in page.kpis)
              pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.only(right: 6, bottom: 10),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    text(k.$2, size: 16, bold: true),
                    text(k.$1, size: 8, color: _grey),
                  ]),
                ),
              ),
          ]),
        for (final c in page.charts)
          if (c.labels.isNotEmpty) ...[
            text(c.title, size: 11, bold: true),
            pw.SizedBox(height: 4),
            pw.SizedBox(height: 170, child: _pdfChart(c)),
            pw.SizedBox(height: 12),
          ],
        for (final t in page.tables) ...[
          text(t.title, size: 11, bold: true),
          pw.SizedBox(height: 4),
          if (t.rows.isEmpty)
            text('Aucune donnée sur la période.', color: _grey)
          else
            // Tableau large (joueur × semaines) : les 12 dernières colonnes, l'Excel garde tout.
            _pdfTable(t),
          pw.SizedBox(height: 12),
        ],
      ],
    ));
  }
  return doc.save();
}

pw.Widget _pdfTable(ReportTable t) {
  const maxCols = 14;
  final cut = t.headers.length > maxCols ? t.headers.length - maxCols + 1 : 0;
  List<T> trim<T>(List<T> l) => cut == 0 ? l : [l.first, ...l.sublist(cut + 1)];
  return pw.TableHelper.fromTextArray(
    headers: [for (final h in trim(t.headers)) _latin1(h)],
    data: [for (final r in t.rows) [for (final c in trim(r)) _latin1(_cell(c))]],
    headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: const pw.BoxDecoration(color: _red),
    cellStyle: const pw.TextStyle(fontSize: 8),
    // Colonnes de texte à gauche, colonnes de nombres à droite.
    cellAlignments: {
      for (var c = 0; c < trim(t.headers).length; c++)
        c: t.rows.any((r) => trim(r)[c] is num) ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
    },
    oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
  );
}

pw.Widget _pdfChart(ReportChart c) {
  final values = [for (final s in c.series.values) ...s.whereType<double>()];
  final max = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
  final top = max <= 0 ? 1.0 : _niceCeil(max);
  // Un seul libellé : l'axe aurait une étendue nulle (division par zéro) ; une colonne vide l'élargit.
  final labels = c.labels.length == 1 ? [...c.labels, ''] : c.labels;
  // Libellés espacés si nombreux, pour rester lisibles.
  final every = (labels.length / 16).ceil().clamp(1, 1000);
  final series = c.series.entries.toList();
  final barWidth = (520 / (labels.length * series.length + 1)).clamp(2.0, 18.0);
  return pw.Column(children: [
    pw.Expanded(
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis.fromStrings(
            [for (var i = 0; i < labels.length; i++) i % every == 0 ? _latin1(labels[i]) : ''],
            marginStart: 14, marginEnd: 14, ticks: true, textStyle: const pw.TextStyle(fontSize: 6)),
          yAxis: pw.FixedAxis([for (var i = 0; i <= 4; i++) top * i / 4],
              format: (v) => fmtNum(v), divisions: true, textStyle: const pw.TextStyle(fontSize: 7)),
        ),
        datasets: [
          for (var s = 0; s < series.length; s++)
            pw.BarDataSet(
              legend: _latin1(series[s].key),
              color: _seriesColors[s % _seriesColors.length],
              width: barWidth,
              offset: series.length == 1 ? 0 : (s - (series.length - 1) / 2) * barWidth,
              data: [
                for (var i = 0; i < c.labels.length; i++)
                  if (series[s].value[i] != null) pw.PointChartValue(i.toDouble(), series[s].value[i]!),
              ],
            ),
        ],
      ),
    ),
    if (series.length > 1)
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        for (var s = 0; s < series.length; s++) ...[
          pw.Container(width: 8, height: 8, color: _seriesColors[s % _seriesColors.length]),
          pw.SizedBox(width: 3),
          pw.Text(_latin1(series[s].key), style: const pw.TextStyle(fontSize: 7)),
          pw.SizedBox(width: 12),
        ],
      ]),
  ]);
}

double _niceCeil(double v) {
  var step = 1.0;
  while (step * 10 < v) {
    step *= 10;
  }
  for (final m in [1, 2, 2.5, 5, 10]) {
    if (step * m >= v) return step * m;
  }
  return step * 10;
}

// ---------------------------------------------------------------------------
// Excel (.xlsx écrit à la main : quelques fichiers XML dans un zip)
// ---------------------------------------------------------------------------

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

String _col(int i) {
  var s = '';
  for (var n = i + 1; n > 0; n = (n - 1) ~/ 26) {
    s = String.fromCharCode(65 + (n - 1) % 26) + s;
  }
  return s;
}

/// Onglet Excel : 31 caractères au plus, sans : \ / ? * [ ].
String _sheetName(String s) => s.replaceAll(RegExp(r'[:\\/?*\[\]]'), ' ').substring(0, s.length.clamp(0, 31));

Uint8List buildXlsx(ReportHeader header, List<ReportPage> pages) {
  // Styles : 0 normal, 1 gras, 2 titre (gras, grand), 3 en-tête (gras blanc sur rouge).
  final sheets = <String>[];
  final widths = <List<int>>[];
  for (final page in pages) {
    final rows = <String>[];
    final w = <int>[];
    var r = 0;
    void row(List<Object?> cells, {int style = 0}) {
      r++;
      final xs = StringBuffer('<row r="$r">');
      for (var c = 0; c < cells.length; c++) {
        final v = cells[c];
        if (v == null) continue;
        final ref = '${_col(c)}$r';
        final s = style == 0 ? '' : ' s="$style"';
        if (v is num) {
          xs.write('<c r="$ref"$s><v>$v</v></c>');
        } else {
          xs.write('<c r="$ref" t="inlineStr"$s><is><t xml:space="preserve">${_esc('$v')}</t></is></c>');
        }
        final len = (v is num ? _cell(v) : '$v').length;
        while (w.length <= c) {
          w.add(8);
        }
        if (len + 2 > w[c]) w[c] = (len + 2).clamp(8, 45);
      }
      xs.write('</row>');
      rows.add(xs.toString());
    }

    row(['PerfFoot - ${page.title}'], style: 2);
    for (final l in header.lines) {
      row([l]);
    }
    if (page.kpis.isNotEmpty) {
      r++;
      row(['Indicateur', 'Valeur'], style: 3);
      for (final k in page.kpis) {
        row([k.$1, k.$2]);
      }
    }
    for (final c in page.charts) {
      if (c.labels.isEmpty) continue;
      r++;
      row([c.title], style: 1);
      row(['', ...c.series.keys], style: 3);
      for (var i = 0; i < c.labels.length; i++) {
        row([c.labels[i], for (final s in c.series.values) s[i]]);
      }
    }
    for (final t in page.tables) {
      r++;
      row([t.title], style: 1);
      row(t.headers, style: 3);
      for (final x in t.rows) {
        row(x);
      }
    }
    sheets.add(rows.join());
    widths.add(w);
  }

  final names = <String>[];
  for (final p in pages) {
    var n = _sheetName(p.title);
    for (var i = 2; names.contains(n); i++) {
      n = _sheetName('${p.title} $i');
    }
    names.add(n);
  }
  final a = Archive();
  void add(String path, String xml) {
    final bytes = utf8.encode(xml);
    a.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  add('[Content_Types].xml', '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
      '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
      '${[for (var i = 1; i <= pages.length; i++) '<Override PartName="/xl/worksheets/sheet$i.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'].join()}'
      '</Types>');
  add('_rels/.rels', '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
      '</Relationships>');
  add('xl/workbook.xml', '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets>'
      '${[for (var i = 0; i < pages.length; i++) '<sheet name="${_esc(names[i])}" sheetId="${i + 1}" r:id="rId${i + 1}"/>'].join()}'
      '</sheets></workbook>');
  add('xl/_rels/workbook.xml.rels', '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '${[for (var i = 1; i <= pages.length; i++) '<Relationship Id="rId$i" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet$i.xml"/>'].join()}'
      '<Relationship Id="rId${pages.length + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
      '</Relationships>');
  add('xl/styles.xml', '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<fonts count="4"><font><sz val="11"/><name val="Calibri"/></font>'
      '<font><b/><sz val="11"/><name val="Calibri"/></font>'
      '<font><b/><sz val="14"/><color rgb="FFC8102E"/><name val="Calibri"/></font>'
      '<font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Calibri"/></font></fonts>'
      '<fills count="3"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill>'
      '<fill><patternFill patternType="solid"><fgColor rgb="FFC8102E"/><bgColor indexed="64"/></patternFill></fill></fills>'
      '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
      '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
      '<cellXfs count="4"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
      '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
      '<xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
      '<xf numFmtId="0" fontId="3" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1"/></cellXfs>'
      '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
      '</styleSheet>');
  for (var i = 0; i < pages.length; i++) {
    final cols = widths[i].isEmpty
        ? ''
        : '<cols>${[for (var c = 0; c < widths[i].length; c++) '<col min="${c + 1}" max="${c + 1}" width="${widths[i][c]}" customWidth="1"/>'].join()}</cols>';
    add('xl/worksheets/sheet${i + 1}.xml', '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">$cols<sheetData>${sheets[i]}</sheetData></worksheet>');
  }
  return Uint8List.fromList(ZipEncoder().encode(a));
}
