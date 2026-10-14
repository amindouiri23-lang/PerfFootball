import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Lecteur .xlsx minimal : un classeur est un zip de fichiers XML. On ne lit que ce dont l'import a
/// besoin — la valeur affichée de chaque cellule (valeur calculée des formules comprise) et
/// l'identifiant de son remplissage, pour reconnaître les statuts codés en couleur.
class XlsxCell {
  const XlsxCell(this.value, this.fillId);

  /// Texte, ou nombre (double) ; null si la cellule est vide.
  final Object? value;

  /// Remplissage de la cellule (0 et 1 = aucun, conventions d'Excel).
  final int fillId;

  String? get text {
    final v = value;
    if (v == null) return null;
    final s = v is double ? (v == v.roundToDouble() ? v.toInt().toString() : v.toString()) : v.toString();
    return s.trim().isEmpty ? null : s.trim();
  }

  /// Nombre ; accepte un texte « 3,28 ». null si vide ou illisible (ex. « 3,,28 »).
  double? get number {
    final v = value;
    if (v is double) return v;
    if (v is String) return double.tryParse(v.trim().replaceAll(',', '.'));
    return null;
  }
}

class XlsxSheet {
  XlsxSheet(this.name, this._cells);

  final String name;
  final Map<(int, int), XlsxCell> _cells;

  /// Cellule (ligne et colonne à partir de 1, comme dans Excel) ; vide si absente.
  XlsxCell cell(int row, int col) => _cells[(row, col)] ?? const XlsxCell(null, 0);

  String? text(int row, int col) => cell(row, col).text;
  double? number(int row, int col) => cell(row, col).number;

  int get maxRow => _cells.keys.fold(0, (m, k) => k.$1 > m ? k.$1 : m);
  int get maxCol => _cells.keys.fold(0, (m, k) => k.$2 > m ? k.$2 : m);

  /// Première cellule dont le texte satisfait [test], ligne par ligne.
  (int, int)? find(bool Function(String text) test) {
    final keys = _cells.keys.toList()..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
    for (final k in keys) {
      final t = _cells[k]!.text;
      if (t != null && test(t)) return k;
    }
    return null;
  }
}

/// Index de colonne Excel : « A » → 1, « AA » → 27.
int columnIndex(String letters) => letters.codeUnits.fold(0, (n, c) => n * 26 + c - 64);

/// Date d'un numéro de série Excel (jours depuis le 30/12/1899).
DateTime excelDate(double serial) => DateTime.utc(1899, 12, 30).add(Duration(days: serial.floor()));

List<XlsxSheet> readXlsx(Uint8List bytes) {
  final zip = ZipDecoder().decodeBytes(bytes);
  XmlDocument? doc(String path) {
    final f = zip.findFile(path);
    final data = f?.readBytes();
    return data == null ? null : XmlDocument.parse(utf8.decode(data));
  }

  final shared = [
    for (final si in doc('xl/sharedStrings.xml')?.findAllElements('si') ?? const <XmlElement>[])
      si.findAllElements('t').map((t) => t.innerText).join(),
  ];
  final fills = [
    for (final xf in doc('xl/styles.xml')?.findAllElements('cellXfs').firstOrNull?.findElements('xf') ?? const <XmlElement>[])
      int.tryParse(xf.getAttribute('fillId') ?? '0') ?? 0,
  ];
  final rels = {
    for (final r in doc('xl/_rels/workbook.xml.rels')?.findAllElements('Relationship') ?? const <XmlElement>[])
      r.getAttribute('Id'): r.getAttribute('Target'),
  };

  final sheets = <XlsxSheet>[];
  for (final s in doc('xl/workbook.xml')?.findAllElements('sheet') ?? const <XmlElement>[]) {
    final rid = s.attributes.firstWhere((a) => a.name.local == 'id').value;
    var target = rels[rid]!;
    target = target.startsWith('/') ? target.substring(1) : 'xl/$target';
    final sheet = doc(target);
    if (sheet == null) continue;
    final cells = <(int, int), XlsxCell>{};
    for (final c in sheet.findAllElements('c')) {
      final ref = c.getAttribute('r')!;
      final m = RegExp(r'^([A-Z]+)(\d+)$').firstMatch(ref)!;
      final style = int.tryParse(c.getAttribute('s') ?? '');
      final fill = style != null && style < fills.length ? fills[style] : 0;
      final raw = c.findElements('v').firstOrNull?.innerText;
      final Object? value = switch (c.getAttribute('t')) {
        's' => raw == null ? null : shared[int.parse(raw)],
        'inlineStr' => c.findAllElements('t').map((t) => t.innerText).join(),
        'str' || 'b' => raw,
        'e' => null, // erreur de formule (#DIV/0!…)
        _ => raw == null ? null : double.tryParse(raw),
      };
      cells[(int.parse(m.group(2)!), columnIndex(m.group(1)!))] = XlsxCell(value, fill);
    }
    sheets.add(XlsxSheet(s.getAttribute('name') ?? '', cells));
  }
  return sheets;
}
