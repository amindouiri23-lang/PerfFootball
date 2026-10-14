import 'xlsx.dart';

// Lecture des quatre fichiers Excel du club (specs E39) : chaque format est reconnu à ses en-têtes,
// puis converti en un « plan d'import » neutre, que l'écran fait valider avant d'écrire quoi que ce soit.

enum ImportKind { training, playingTime, tests, profiles }

const importKindLabels = {
  ImportKind.training: 'Suivi d\'entraînement (charge de la semaine)',
  ImportKind.playingTime: 'Temps de jeu des matchs',
  ImportKind.tests: 'Tests physiques et mesures',
  ImportKind.profiles: 'Fiches de renseignements des joueurs (formulaire)',
};

/// Un nom de joueur tel qu'écrit dans le fichier, avec son poste s'il y figure.
class ImportedName {
  ImportedName(this.name, {this.positionText});
  final String name;
  final String? positionText;
}

class PlannedSession {
  PlannedSession(this.date, this.index, {this.plannedDurationMin, this.plannedRpe});
  final String date;
  /// 1 ou 2 : séance du matin / de l'après-midi.
  final int index;
  final int? plannedDurationMin;
  final int? plannedRpe;
  /// nom → présence et charge.
  final rows = <String, ({bool present, String? reason, int? durationMin, int? rpe})>{};
}

class PlannedMatch {
  PlannedMatch({
    required this.date, required this.opponent, required this.competition, this.phase, this.matchday,
    this.goalsFor, this.goalsAgainst, required this.homeAway,
  });
  final String date;
  final String opponent;
  final String competition;
  final String? phase;
  final int? matchday;
  final int? goalsFor;
  final int? goalsAgainst;
  final String homeAway;
  /// nom → minutes jouées.
  final minutes = <String, int>{};

  int get durationMin {
    final max = minutes.values.fold(0, (m, v) => v > m ? v : m);
    if (competition != 'friendly') return 90;
    return max.clamp(20, 130);
  }
}

class PlannedProfile {
  PlannedProfile(this.name);
  final String name;
  String? birthDate;
  final profile = <String, String?>{};
  final medical = <String, String?>{};
}

class ImportPlan {
  ImportPlan(this.kind, this.description);
  final ImportKind kind;
  final String description;
  final names = <String, ImportedName>{};
  final sessions = <PlannedSession>[];
  final matches = <PlannedMatch>[];
  /// nom → (code du test, essai) → valeur.
  final tests = <String, Map<(String, int), double>>{};
  final profiles = <PlannedProfile>[];
  final warnings = <String>[];

  void addName(String name, {String? position}) =>
      names.putIfAbsent(normalizeName(name), () => ImportedName(name.trim(), positionText: position));
}

// ---------------------------------------------------------------------------
// Noms
// ---------------------------------------------------------------------------

const _accents = {'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'à': 'a', 'â': 'a', 'ä': 'a', 'î': 'i', 'ï': 'i',
  'ô': 'o', 'ö': 'o', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ç': 'c'};

/// Clé de comparaison : minuscules, sans accents, « Med » = « Mohamed », mots triés et sans doublon
/// (« Moreau lucas » et « Lucas Moreau » donnent la même clé ; un prénom seul, « Hugo », créé en
/// « Hugo Hugo », garde la clé « hugo »).
String normalizeName(String name) {
  var s = name.toLowerCase();
  _accents.forEach((k, v) => s = s.replaceAll(k, v));
  final words = s
      .split(RegExp(r'[^a-z]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => const {'med': 'mohamed', 'mohammed': 'mohamed', 'mhamed': 'mohamed'}[w] ?? w)
      .toSet()
      .toList()
    ..sort();
  return words.join(' ');
}

/// Ressemblance de 0 à 1 (distance d'édition) : repère « Durand » / « Duran », « Lefebvre » / « Lefèvre ».
double nameSimilarity(String a, String b) {
  if (a == b) return 1;
  final m = a.length, n = b.length;
  if (m == 0 || n == 0) return 0;
  var prev = List<int>.generate(n + 1, (j) => j);
  for (var i = 1; i <= m; i++) {
    final cur = List<int>.filled(n + 1, 0)..[0] = i;
    for (var j = 1; j <= n; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      cur[j] = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost].reduce((x, y) => x < y ? x : y);
    }
    prev = cur;
  }
  return 1 - prev[n] / (m > n ? m : n);
}

String _capitalize(String s) => s
    .split(' ')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

/// Découpe proposée pour créer un joueur. [lastFirst] : le fichier écrit « Nom Prénom ».
({String first, String last}) splitName(String name, {required bool lastFirst}) {
  final w = name.trim().split(RegExp(r'\s+'));
  if (w.length == 1) return (first: _capitalize(w[0]), last: _capitalize(w[0]));
  // « Ben Salem » : particule rattachée au nom.
  if (lastFirst) {
    final n = w[0].toLowerCase() == 'ben' && w.length > 2 ? 2 : 1;
    return (first: _capitalize(w.sublist(n).join(' ')), last: _capitalize(w.sublist(0, n).join(' ')));
  }
  final ben = w.indexWhere((x) => x.toLowerCase() == 'ben');
  final cut = ben > 0 ? ben : w.length - 1;
  return (first: _capitalize(w.sublist(0, cut).join(' ')), last: _capitalize(w.sublist(cut).join(' ')));
}

/// Poste des feuilles du club (« DD », « DG/DC », « MO ») ou du formulaire (« Ailier droit »)
/// → poste large, poste précis, poste secondaire.
({String group, String? detailed, String? secondary}) parsePosition(String? text) {
  const codes = {
    'GB': 'GK', 'G': 'GK', 'DC': 'CB', 'DD': 'RB', 'DG': 'LB', 'MD': 'DM', 'MC': 'CM', 'MO': 'AM',
    'AD': 'RW', 'AG': 'LW', 'AC': 'ST', 'ATT': 'ST',
  };
  const groups = {
    'GK': 'GK', 'CB': 'DEF', 'RB': 'DEF', 'LB': 'DEF', 'DM': 'MID', 'CM': 'MID', 'AM': 'MID',
    'RW': 'FWD', 'LW': 'FWD', 'ST': 'FWD',
  };
  if (text == null || text.trim().isEmpty) return (group: 'MID', detailed: null, secondary: null);
  final parts = text.toUpperCase().split('/').map((p) => p.trim()).toList();
  if (codes.containsKey(parts.first)) {
    final d = codes[parts.first]!;
    // « AG/D » : ailier gauche, aussi à droite.
    final second = parts.length > 1
        ? codes[parts[1]] ?? (parts[1] == 'D' ? codes['${parts.first[0]}D'] : parts[1] == 'G' ? codes['${parts.first[0]}G'] : null)
        : null;
    return (group: groups[d]!, detailed: d, secondary: second == d ? null : second);
  }
  // Saisie libre du formulaire, fautes comprises (« Ariére », « Allier », « Pivo »).
  final t = text.toLowerCase().replaceAll('allier', 'ailier').replaceAll('é', 'e').replaceAll('è', 'e');
  final back = t.contains('arri') || t.contains('arie') || t.contains('lateral');
  String? d;
  if (t.contains('gard')) {
    d = 'GK';
  } else if (back && t.contains('droit')) {
    d = 'RB';
  } else if (back && t.contains('gauche')) {
    d = 'LB';
  } else if (t.contains('axia') || (t.contains('central') && t.contains('def'))) {
    d = 'CB';
  } else if (t.contains('ailier') && t.contains('droit')) {
    d = 'RW';
  } else if (t.contains('ailier') && t.contains('gauche')) {
    d = 'LW';
  } else if (t.contains('offensif')) {
    d = 'AM';
  } else if (t.contains('defensif') || t.contains('pivo')) {
    d = 'DM';
  } else if (t.contains('regisseur') || t.contains('relayeur')) {
    d = 'CM';
  } else if (t.contains('avant') || t.contains('pointe') || t.contains('attaqu')) {
    d = 'ST';
  }
  final group = d != null
      ? groups[d]!
      : t.contains('def') || back
          ? 'DEF'
          : t.contains('ailier')
              ? 'FWD'
              : 'MID';
  return (group: group, detailed: d, secondary: null);
}

// ---------------------------------------------------------------------------
// Reconnaissance du format
// ---------------------------------------------------------------------------

/// Reconnaît le format du classeur et le lit ; renvoie null si aucun format n'est reconnu.
ImportPlan? parseWorkbook(List<XlsxSheet> sheets) {
  for (final s in sheets) {
    bool has(String needle) => s.find((t) => t.toLowerCase().contains(needle)) != null;
    if (has('charge programm') && has('rpe')) return _training(s);
    if (has('temps de jeu')) return _playingTime(s);
    if (has('anthropom') || (has('cmj') && has('vma'))) return _tests(s);
    if (has('nationalit') && has('date de naissance')) return _profiles(s);
  }
  return null;
}

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ---------------------------------------------------------------------------
// 1. Suivi d'entraînement hebdomadaire
// ---------------------------------------------------------------------------
ImportPlan _training(XlsxSheet s) {
  final title = s.text(1, 1) ?? 'Semaine';
  final plan = ImportPlan(ImportKind.training, title);

  // Charge programmée : ligne « Jour », puis deux lignes par jour (séances 1 et 2), colonnes C (volume) et D (RPE).
  final dayHeader = s.find((t) => t == 'Jour')!;
  final firstDayRow = dayHeader.$1 + 1;

  // Tableau des joueurs : ligne « Nom & Prénom », dates juste en dessous, un bloc de 3 colonnes par jour.
  final head = s.find((t) => t.toLowerCase().startsWith('nom') && t.contains('Pr'))!;
  final nameCol = head.$2;
  final numberCol = nameCol - 1;
  final positionCol = s.find((t) => t == 'Poste')?.$2;
  // « lundi » de la ligne d'en-tête des joueurs (le tableau de charge programmée a aussi un « Lundi »).
  var firstDayCol = nameCol + 4;
  for (var c = nameCol + 1; c <= s.maxCol; c++) {
    if (s.text(head.$1, c)?.toLowerCase() == 'lundi') {
      firstDayCol = c;
      break;
    }
  }
  final days = <({int col, String date})>[];
  for (var d = 0; d < 7; d++) {
    final col = firstDayCol + 3 * d;
    final serial = s.number(head.$1 + 1, col);
    if (serial != null) days.add((col: col, date: _iso(excelDate(serial))));
  }
  if (days.isEmpty) {
    plan.warnings.add('Dates des jours introuvables : import impossible.');
    return plan;
  }

  // Légende des couleurs (sous le tableau) : chaque libellé donne la couleur d'un statut.
  final legend = <int, String>{};
  void legendFor(String needle, String reason) {
    final at = s.find((t) => t.toLowerCase().contains(needle));
    if (at != null && s.cell(at.$1, at.$2).fillId > 1) legend[s.cell(at.$1, at.$2).fillId] = reason;
  }
  legendFor('bless', 'injured');
  legendFor('absent', 'other');
  legendFor('national', 'national_team');
  legendFor('senior', 'other_team');

  final sessions = <String, PlannedSession>{};
  for (var d = 0; d < days.length; d++) {
    for (var k = 1; k <= 2; k++) {
      final row = firstDayRow + 2 * d + (k - 1);
      final volume = s.number(row, 3);
      if (volume == null || volume <= 0) continue;
      final rpe = s.number(row, 4);
      final ps = PlannedSession(days[d].date, k,
          plannedDurationMin: volume.round().clamp(10, 240), plannedRpe: rpe?.round().clamp(0, 10));
      sessions['${days[d].date}:$k'] = ps;
    }
  }

  var skipped = 0;
  for (var r = head.$1 + 3; r <= s.maxRow; r++) {
    final name = s.text(r, nameCol);
    if (name == null || s.number(r, numberCol) == null) continue;
    plan.addName(name, position: positionCol == null ? null : s.text(r, positionCol));
    for (final day in days) {
      final rpeCell = s.cell(r, day.col);
      final text = rpeCell.text;
      final rpe = rpeCell.number;
      final volume = s.number(r, day.col + 1);
      final status = legend[rpeCell.fillId];
      final ({bool present, String? reason, int? durationMin, int? rpe}) entry;
      if (status != null) {
        entry = (present: false, reason: status, durationMin: null, rpe: null);
      } else if (text != null && rpe == null) {
        if (text.toLowerCase().contains('repos')) {
          entry = (present: false, reason: 'rest', durationMin: null, rpe: null);
        } else {
          continue; // jour de match (nom des deux équipes) : pas une séance
        }
      } else if (rpe != null) {
        entry = (present: true, reason: null, durationMin: volume?.round().clamp(0, 240), rpe: rpe.round().clamp(0, 10));
      } else {
        skipped++;
        continue;
      }
      final session = sessions.putIfAbsent('${day.date}:1', () => PlannedSession(day.date, 1,
          plannedDurationMin: volume?.round().clamp(10, 240)));
      session.rows[name.trim()] = entry;
    }
  }
  // Un jour sans séance prévue ni joueur présent (dimanche « Repos ») n'est pas une séance.
  plan.sessions.addAll(sessions.values.where((s) => s.plannedDurationMin != null || s.rows.values.any((r) => r.present)));
  if (skipped > 0) plan.warnings.add('$skipped case(s) joueur/jour sans RPE ni statut : ignorée(s).');
  return plan;
}

// ---------------------------------------------------------------------------
// 2. Temps de jeu
// ---------------------------------------------------------------------------
ImportPlan _playingTime(XlsxSheet s) {
  final head = s.find((t) => t.toLowerCase().startsWith('nom') && t.toLowerCase().contains('pr'))!;
  final category = s.find((t) => t.toLowerCase().contains('senior') || t.toLowerCase().contains('junior'));
  final plan = ImportPlan(ImportKind.playingTime,
      'Temps de jeu${category == null ? '' : ' — ${s.text(category.$1, category.$2)}'}');
  final hr = head.$1, nameCol = head.$2;

  // Joueurs : première ligne avec un nom sous l'en-tête.
  final playerRows = [for (var r = hr + 1; r <= s.maxRow; r++) if (s.text(r, nameCol) != null && s.number(r, nameCol) == null) r];
  final firstPlayer = playerRows.isEmpty ? s.maxRow + 1 : playerRows.first;

  String? block;
  var matchday = 0;
  for (var c = nameCol + 1; c <= s.maxCol; c++) {
    final blockTitle = s.text(hr - 2, c);
    if (blockTitle != null) {
      block = blockTitle.toUpperCase();
      matchday = 0;
    }
    final opponent = s.text(hr, c);
    if (opponent == null || RegExp(r'total|%', caseSensitive: false).hasMatch(opponent)) continue;
    final competition = block == null
        ? 'friendly'
        : block.contains('AMICA')
            ? 'friendly'
            : block.contains('COUPE')
                ? 'cup'
                : 'league';
    if (competition == 'league') matchday++;
    final serial = s.number(hr - 1, c);
    if (serial == null) {
      plan.warnings.add('Match contre $opponent sans date : non importé.');
      continue;
    }
    // Résultat « V 3/0 », « N 2/2 », « D 1/2 » (score dans l'ordre domicile / extérieur).
    int? gf, ga;
    var homeAway = 'H';
    for (var r = hr + 1; r < firstPlayer; r++) {
      final m = RegExp(r'^([VND])\s*(\d+)\s*[/-]\s*(\d+)$').firstMatch((s.text(r, c) ?? '').toUpperCase());
      if (m == null) continue;
      final a = int.parse(m.group(2)!), b = int.parse(m.group(3)!);
      final res = m.group(1)!;
      if (res == 'N') {
        gf = a;
        ga = b;
      } else {
        final win = res == 'V';
        gf = win ? (a > b ? a : b) : (a < b ? a : b);
        ga = win ? (a > b ? b : a) : (a < b ? b : a);
        // Le premier score est celui de l'équipe à domicile.
        homeAway = (win ? a > b : a < b) ? 'H' : 'A';
      }
    }
    final match = PlannedMatch(
      date: _iso(excelDate(serial)),
      opponent: opponent,
      competition: competition,
      phase: competition == 'league' && block != null
          ? (block.contains('RETOUR') ? 'second_leg' : block.contains('ALLER') ? 'first_leg' : null)
          : null,
      matchday: competition == 'league' ? matchday : null,
      goalsFor: gf,
      goalsAgainst: ga,
      homeAway: homeAway,
    );
    for (final r in playerRows) {
      final name = s.text(r, nameCol)!;
      final minutes = s.number(r, c);
      if (minutes != null) match.minutes[name.trim()] = minutes.round().clamp(0, 160);
    }
    plan.matches.add(match);
  }
  for (final r in playerRows) {
    plan.addName(s.text(r, nameCol)!);
  }
  if (plan.matches.any((m) => m.competition == 'friendly')) {
    plan.warnings.add('Matchs amicaux : durée prise égale au plus grand temps de jeu saisi.');
  }
  plan.warnings.add('Domicile ou extérieur déduit du score (domicile par défaut si inconnu) : à vérifier.');
  return plan;
}

// ---------------------------------------------------------------------------
// 3. Tests physiques
// ---------------------------------------------------------------------------
ImportPlan _tests(XlsxSheet s) {
  final category = s.find((t) => t.toLowerCase().contains('catégorie') || t.toLowerCase().contains('categorie'));
  final plan = ImportPlan(ImportKind.tests,
      'Tests physiques${category == null ? '' : ' — ${s.text(category.$1, category.$2)}'}');
  final head = s.find((t) => t.toLowerCase().startsWith('nom') && t.contains('Pr'))!;
  final hr = head.$1, nameCol = head.$2;

  // Colonnes : groupe (ligne hr), sous-groupe (hr+1), libellé (hr+2) → (code du test, essai).
  final columns = <int, (String, int)>{};
  String group = '', sub = '';
  final attemptCount = <String, int>{};
  for (var c = nameCol + 1; c <= s.maxCol; c++) {
    final g = s.text(hr, c), sg = s.text(hr + 1, c), label = (s.text(hr + 2, c) ?? '').toLowerCase();
    if (g != null) {
      group = g.toLowerCase();
      sub = '';
    }
    if (sg != null) sub = sg.toLowerCase();
    String? code;
    var attempt = 1;
    final isTrial = RegExp(r'^e\d$').hasMatch(label);
    if (group.contains('anthropo')) {
      code = label.contains('taille') ? 'height_cm' : label.contains('poids') ? 'weight_kg'
          : label.contains('maigre') ? 'lean_mass_kg' : label.contains('gras') ? 'fat_mass_kg' : null;
    } else if (group.contains('vma')) {
      code = label.contains('distance') ? 'yoyo_distance_m' : label.contains('vitesse') ? 'vma_kmh' : null;
    } else if (group.contains('vitesse') && isTrial) {
      final m = RegExp(r'(\d+)').firstMatch(sub);
      code = m == null ? null : {'5': 'sprint_5m_s', '20': 'sprint_20m_s', '30': 'sprint_30m_s'}[m.group(1)];
    } else if (group.contains('mujika')) {
      if (sub.contains('sans') && isTrial) code = 'mujika_s';
      if (sub.contains('avec')) {
        if (isTrial) code = 'mujika_ball_s';
        // « But » suit l'essai qu'il complète.
        if (label == 'but') {
          code = 'mujika_ball_goal';
          attempt = attemptCount['mujika_ball_s'] ?? 1;
        }
      }
    } else if (group.contains('cmj') && isTrial) {
      code = 'cmj_cm';
    } else if (group.contains('lombaire') && isTrial) {
      code = 'lumbar_strength';
    } else if (group.contains('jt') && isTrial) {
      code = 'five_jump_m';
    }
    if (code == null) continue;
    if (isTrial) {
      attempt = (attemptCount[code] ?? 0) + 1;
      attemptCount[code] = attempt;
    }
    columns[c] = (code, attempt);
  }

  for (var r = hr + 3; r <= s.maxRow; r++) {
    final name = s.text(r, nameCol);
    if (name == null || s.number(r, nameCol - 1) == null) continue;
    plan.addName(name);
    final values = <(String, int), double>{};
    for (final e in columns.entries) {
      final cell = s.cell(r, e.key);
      if (cell.value == null) continue;
      final v = cell.number;
      if (v == null || v < 0) {
        plan.warnings.add('${name.trim()} : valeur illisible « ${cell.text} » ignorée.');
        continue;
      }
      values[e.value] = (v * 100).round() / 100;
    }
    if (values.isNotEmpty) plan.tests[name.trim()] = values;
  }
  final empty = plan.names.length - plan.tests.length;
  if (empty > 0) plan.warnings.add('$empty joueur(s) sans aucun résultat.');
  return plan;
}

// ---------------------------------------------------------------------------
// 4. Fiches de renseignements (export Microsoft Forms)
// ---------------------------------------------------------------------------
final _arabic = RegExp(r'[؀-ۿ]');

/// Retire les traductions arabes des libellés du formulaire : « Marié(e) (متزوج/متزوجة) » → « Marié(e) ».
String? _clean(String? v) {
  if (v == null) return null;
  var s = v.replaceAll(RegExp(r'\s*\([^()]*[؀-ۿ][^()]*\)'), '').trim();
  if (_arabic.hasMatch(s) && !RegExp(r'[A-Za-z]').hasMatch(s)) return null;
  s = s.replaceAll(_arabic, '').trim();
  return s.isEmpty || s == '.' || s.toLowerCase() == 'anonymous' ? null : s;
}

ImportPlan _profiles(XlsxSheet s) {
  final plan = ImportPlan(ImportKind.profiles, 'Fiches de renseignements');
  // En-têtes de la ligne 1, ramenés à leur partie française en minuscules.
  final cols = <String, int>{};
  for (var c = 1; c <= s.maxCol; c++) {
    final h = s.text(1, c);
    if (h == null) continue;
    final key = (_clean(h) ?? '').toLowerCase().replaceAll('’', "'");
    cols.putIfAbsent(key, () => c);
  }
  int? col(bool Function(String k) test) => cols.entries.where((e) => test(e.key)).map((e) => e.value).firstOrNull;
  // Deux colonnes « Nom » (avec et sans traduction) : la première remplie l'emporte.
  final nameCols = [for (var c = 1; c <= s.maxCol; c++) if ((_clean(s.text(1, c)) ?? '').toLowerCase() == 'nom') c];
  final fields = <String, int?>{
    'nationality': col((k) => k == 'nationalité'),
    'birthPlace': col((k) => k.startsWith('lieu de naissance')),
    'address': col((k) => k == 'adresse'),
    'phone': col((k) => k.startsWith('numéro de téléphone')),
    'email': col((k) => k.startsWith('adresse de messagerie')),
    'school': col((k) => k.startsWith('établissement scolaire')),
    'schoolYear': col((k) => k.startsWith('année scolaire')),
    'fatherName': col((k) => k.startsWith('nom du père')),
    'fatherNationality': col((k) => k.startsWith('nationalité du père')),
    'fatherOccupation': col((k) => k.startsWith('profession du père')),
    'fatherMaritalStatus': col((k) => k.startsWith('situation familiale du père')),
    'motherName': col((k) => k.startsWith('nom de la mère')),
    'motherNationality': col((k) => k.startsWith('nationalité de la mère')),
    'motherMaritalStatus': col((k) => k.startsWith('situation familiale de la mère')),
    'previousClub': col((k) => k.startsWith('nom du club précédent')),
    'previousClubCity': col((k) => k.startsWith('adresse du club précédent')),
    'yearsTraining': col((k) => k.startsWith("nombre d'années")),
    'preferredRole': col((k) => k.startsWith('poste préf')),
    'remarks': col((k) => k.startsWith('remarques')),
  };
  final positionCol = col((k) => k == 'poste');
  final birthCol = col((k) => k.startsWith('date de naissance'));
  final medical = <String, int?>{
    'allergies': col((k) => k.contains('allergies')),
    'conditions': col((k) => k.contains('maladie ou une condition')),
    'lowBpAnxiety': col((k) => k.contains('tension')),
    'surgeries': col((k) => k.contains('intervention chirurgicale')),
  };
  final injuryCols = [
    col((k) => k.contains('blessure au cours des 12')),
    ...cols.entries.where((e) => e.key.startsWith('nature de la blessure') || e.key.startsWith('période')).map((e) => e.value),
  ].whereType<int>().toList()
    ..sort();

  for (var r = 2; r <= s.maxRow; r++) {
    final name = nameCols.map((c) => _clean(s.text(r, c))).whereType<String>().firstOrNull;
    if (name == null) continue;
    plan.addName(name, position: positionCol == null ? null : _clean(s.text(r, positionCol)));
    final p = PlannedProfile(name.trim());
    for (final e in fields.entries) {
      if (e.value != null) p.profile[e.key] = _clean(s.text(r, e.value!));
    }
    final years = RegExp(r'\d+').firstMatch(p.profile['yearsTraining'] ?? '');
    p.profile['yearsTraining'] = years?.group(0);
    final birth = birthCol == null ? null : s.number(r, birthCol);
    if (birth != null && birth > 10000) p.birthDate = _iso(excelDate(birth));
    for (final e in medical.entries) {
      if (e.value != null) p.medical[e.key] = _clean(s.text(r, e.value!));
    }
    final injuries = injuryCols.map((c) => _clean(s.text(r, c))).whereType<String>().toList();
    p.medical['recentInjuries'] = injuries.isEmpty ? null : injuries.join(' — ');
    plan.profiles.add(p);
  }
  plan.warnings.add('Le formulaire contient des données de santé : elles ne sont importées qu\'avec le consentement.');
  return plan;
}
