"""Génère le projet Power BI powerbi/PerfFoot.pbip (modèle TMDL + rapport), connecté aux vues
`reporting` de Supabase avec l'utilisateur en lecture seule powerbi_reader.

Usage : python tools/powerbi/build_pbip.py
Le projet ne contient pas de données : Power BI les charge à l'actualisation (identifiants demandés).
"""
import json
import re
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "powerbi"
NAME = "PerfFoot"
SERVER = "aws-0-eu-north-1.pooler.supabase.com:5432"
DATABASE = "postgres"
NS = uuid.UUID("71d5779a-5c07-404c-8757-26e95c0f8b4a")  # identifiants stables d'une génération à l'autre


def uid(*parts):
    return str(uuid.uuid5(NS, "pbi:" + ":".join(parts)))


def q(name):
    """Nom TMDL / DAX : entre apostrophes s'il contient autre chose que [A-Za-z0-9_]."""
    return name if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name) else "'" + name.replace("'", "''") + "'"


# ---------------------------------------------------------------------------
# Libellés français (mêmes valeurs que l'application)
# ---------------------------------------------------------------------------
LABELS = {
    "position": {"GK": "Gardien", "DEF": "Défenseur", "MID": "Milieu", "FWD": "Attaquant"},
    "session_type": {"technical": "Technique", "tactical": "Tactique", "physical": "Physique", "mixed": "Mixte",
                     "recovery": "Récupération", "gym": "Musculation", "other": "Autre"},
    "absence": {"injured": "Blessé", "sick": "Malade", "national_team": "Sélection", "personal": "Personnel",
                "other": "Autre", "not_selected": "Non retenu", "suspended": "Suspendu"},
    "home_away": {"H": "Domicile", "A": "Extérieur", "N": "Neutre"},
    "competition": {"league": "Championnat", "cup": "Coupe", "friendly": "Amical", "tournament": "Tournoi"},
    "result": {"W": "Victoire", "D": "Nul", "L": "Défaite"},
    "role": {"starter": "Titulaire", "sub": "Remplaçant"},
    "event": {"goal": "But", "yellow_card": "Carton jaune", "red_card": "Carton rouge"},
    "body_area": {"head": "Tête", "neck": "Cou", "shoulder": "Épaule", "arm": "Bras", "back": "Dos",
                  "hip_groin": "Hanche/aine", "thigh_front": "Cuisse avant", "thigh_back": "Cuisse arrière",
                  "knee": "Genou", "calf": "Mollet", "ankle": "Cheville", "foot": "Pied", "other": "Autre"},
    "side": {"left": "Gauche", "right": "Droit", "both": "Les deux"},
    "injury_type": {"muscle": "Musculaire", "ligament": "Ligamentaire", "bone": "Osseuse", "contusion": "Contusion",
                    "tendon": "Tendineuse", "other": "Autre"},
    "mechanism": {"contact": "Contact", "non_contact": "Sans contact", "overuse": "Surmenage"},
    "severity": {"minor": "Légère", "moderate": "Modérée", "severe": "Grave"},
    "status": {"planned": "Planifié", "in_progress": "En cours", "completed": "Terminé"},
}


def m_record(d):
    return "[" + ", ".join(f'#"{k}" = "{v}"' for k, v in d.items()) + "]"


# ---------------------------------------------------------------------------
# Tables : (nom du modèle, vue, colonnes, libellés M, colonnes M ajoutées)
# colonne = (nom dans le modèle, colonne source, type TMDL, caché, format)
# ---------------------------------------------------------------------------
S, I, D, B, F = "string", "int64", "dateTime", "boolean", "double"
TABLES = [
    ("Équipes", "teams", [
        ("id", "id", S, True, None), ("Équipe", "name", S, False, None), ("Club", "club_name", S, False, None),
        ("Catégorie", "category", S, False, None), ("Saison", "season", S, False, None)], {}, []),
    ("Joueurs", "players", [
        ("id", "id", S, True, None), ("team_id", "team_id", S, True, None), ("Joueur", "full_name", S, False, None),
        ("Numéro", "shirt_number", I, False, "0"), ("Poste", "position", S, False, None),
        ("Date de naissance", "birth_date", D, False, "dd/mm/yyyy"), ("Taille (cm)", "height_cm", I, False, "0"),
        ("Supprimé", "is_deleted", B, False, None)], {"position": "position"}, []),
    ("Séances", "sessions", [
        ("id", "id", S, True, None), ("Date", "date", D, False, "dd/mm/yyyy"), ("Type", "type", S, False, None),
        ("Durée prévue (min)", "planned_duration_min", I, False, "0"), ("Objectif", "objective", S, False, None),
        ("Remarques", "remarks", S, False, None), ("État", "status", S, False, None)],
        {"type": "session_type", "status": "status"}, []),
    ("Présences", "session_players", [
        ("id", "id", S, True, None), ("session_id", "session_id", S, True, None), ("player_id", "player_id", S, True, None),
        ("Date", "date", D, False, "dd/mm/yyyy"), ("Type de séance", "session_type", S, False, None),
        ("Présent", "present", B, False, None), ("Motif d'absence", "absence_reason", S, False, None),
        ("Durée (min)", "duration_min", I, False, "0"), ("RPE", "rpe", I, False, "0"), ("Remarque", "remark", S, False, None)],
        {"session_type": "session_type", "absence_reason": "absence"}, []),
    ("Bien-être", "wellness", [
        ("id", "id", S, True, None), ("session_id", "session_id", S, True, None), ("player_id", "player_id", S, True, None),
        ("Date", "date", D, False, "dd/mm/yyyy"), ("Sommeil (h)", "sleep_hours", F, False, "0.0"),
        ("Qualité du sommeil", "sleep_quality", I, False, "0"), ("Fatigue", "fatigue", I, False, "0"),
        ("Courbatures", "soreness", I, False, "0"), ("Stress", "stress", I, False, "0"), ("Humeur", "mood", I, False, "0"),
        ("Score (/25)", "total_score", I, False, "0"), ("Remarque", "remark", S, False, None)], {}, []),
    ("Matchs", "matches", [
        ("id", "id", S, True, None), ("Date", "date", D, False, "dd/mm/yyyy"), ("Adversaire", "opponent", S, False, None),
        ("Lieu", "home_away", S, False, None), ("Compétition", "competition", S, False, None),
        ("Durée (min)", "duration_min", I, False, "0"), ("Buts pour", "goals_for", I, False, "0"),
        ("Buts contre", "goals_against", I, False, "0"), ("Score", "score", S, False, None),
        ("Résultat", "result", S, False, None), ("État", "status", S, False, None)],
        {"home_away": "home_away", "competition": "competition", "result": "result", "status": "status"},
        [("score", 'each if [goals_for] = null or [goals_against] = null then null '
                   'else Text.From([goals_for]) & " - " & Text.From([goals_against])', "text")]),
    ("Feuilles de match", "match_players", [
        ("id", "id", S, True, None), ("match_id", "match_id", S, True, None), ("player_id", "player_id", S, True, None),
        ("Date", "date", D, False, "dd/mm/yyyy"), ("Adversaire", "opponent", S, False, None),
        ("Présent", "present", B, False, None), ("Motif d'absence", "absence_reason", S, False, None),
        ("Rôle", "role", S, False, None), ("Minutes jouées", "minutes_played", I, False, "0"),
        ("RPE", "rpe", I, False, "0"), ("Remarque", "remark", S, False, None)],
        {"absence_reason": "absence", "role": "role"}, []),
    ("Événements", "match_events", [
        ("id", "id", S, True, None), ("match_id", "match_id", S, True, None), ("player_id", "player_id", S, True, None),
        ("assist_player_id", "assist_player_id", S, True, None), ("Date", "date", D, False, "dd/mm/yyyy"),
        ("Type", "type", S, False, None), ("Minute", "minute", I, False, "0")], {"type": "event"}, []),
    ("Blessures", "injuries", [
        ("id", "id", S, True, None), ("player_id", "player_id", S, True, None), ("Date", "date", D, False, "dd/mm/yyyy"),
        ("Minute", "minute", I, False, "0"), ("Zone", "body_area", S, False, None), ("Côté", "side", S, False, None),
        ("Type", "type", S, False, None), ("Circonstance", "mechanism", S, False, None),
        ("Gravité", "severity", S, False, None), ("Retour prévu", "expected_return_date", D, False, "dd/mm/yyyy"),
        ("Date de retour", "return_date", D, False, "dd/mm/yyyy"), ("En cours", "is_open", B, False, None),
        ("Jours d'absence", "days_out", I, False, "0")],
        {"body_area": "body_area", "side": "side", "type": "injury_type", "mechanism": "mechanism", "severity": "severity"}, []),
]

CALENDAR_M = """let
    Debut = #date(2025, 7, 1),
    Fin = Date.AddDays(Date.From(DateTime.LocalNow()), 60),
    Dates = List.Dates(Debut, Duration.Days(Fin - Debut) + 1, #duration(1, 0, 0, 0)),
    Base = Table.FromList(Dates, Splitter.SplitByNothing(), {"Date"}),
    Typed = Table.TransformColumnTypes(Base, {{"Date", type date}}),
    Semaine = Table.AddColumn(Typed, "Semaine", each Date.StartOfWeek([Date], Day.Monday), type date),
    Mois = Table.AddColumn(Semaine, "Mois", each Date.ToText([Date], "yyyy-MM"), type text),
    Saison = Table.AddColumn(Mois, "Saison", each
        let y = Date.Year([Date]) in
            if Date.Month([Date]) >= 7 then Text.From(y) & "-" & Text.From(y + 1)
            else Text.From(y - 1) & "-" & Text.From(y), type text)
in
    Saison"""
CALENDAR_COLS = [("Date", "Date", D, False, "dd/mm/yyyy"), ("Semaine", "Semaine", D, False, "dd/mm/yyyy"),
                 ("Mois", "Mois", S, False, None), ("Saison", "Saison", S, False, None)]

# Mesures : (nom, DAX, format). La charge d'entraînement = RPE × minutes (unités arbitraires, UA).
MEASURES = [
    ("Joueurs suivis", "CALCULATE(COUNTROWS(Joueurs), Joueurs[Supprimé] = FALSE())", "0"),
    ("Présence %", "DIVIDE(CALCULATE(COUNTROWS('Présences'), 'Présences'[Présent] = TRUE()), COUNTROWS('Présences'))", "0%"),
    ("Charge séances (UA)", "SUMX('Présences', 'Présences'[RPE] * 'Présences'[Durée (min)])", "#,0"),
    ("Charge matchs (UA)", "SUMX('Feuilles de match', 'Feuilles de match'[RPE] * 'Feuilles de match'[Minutes jouées])", "#,0"),
    ("Charge totale (UA)", "[Charge séances (UA)] + [Charge matchs (UA)]", "#,0"),
    ("Charge aiguë 7 j (UA)",
     "CALCULATE([Charge totale (UA)], DATESINPERIOD(Calendrier[Date], MAX(Calendrier[Date]), -7, DAY))", "#,0"),
    ("Charge chronique (UA/sem.)",
     "DIVIDE(CALCULATE([Charge totale (UA)], DATESINPERIOD(Calendrier[Date], MAX(Calendrier[Date]), -28, DAY)), 4)", "#,0"),
    ("ACWR", "DIVIDE([Charge aiguë 7 j (UA)], [Charge chronique (UA/sem.)])", "0.00"),
    ("Minutes jouées", "SUM('Feuilles de match'[Minutes jouées])", "#,0"),
    ("Matchs joués", "CALCULATE(COUNTROWS('Feuilles de match'), 'Feuilles de match'[Minutes jouées] > 0)", "0"),
    ("Buts", "CALCULATE(COUNTROWS('Événements'), 'Événements'[Type] = \"But\")", "0"),
    ("Passes décisives",
     "CALCULATE(COUNTROWS('Événements'), 'Événements'[Type] = \"But\", USERELATIONSHIP('Événements'[assist_player_id], Joueurs[id]))", "0"),
    ("Cartons jaunes", "CALCULATE(COUNTROWS('Événements'), 'Événements'[Type] = \"Carton jaune\")", "0"),
    ("Cartons rouges", "CALCULATE(COUNTROWS('Événements'), 'Événements'[Type] = \"Carton rouge\")", "0"),
    ("Bien-être moyen (/25)", "AVERAGE('Bien-être'[Score (/25)])", "0.0"),
    ("Sommeil moyen (h)", "AVERAGE('Bien-être'[Sommeil (h)])", "0.0"),
    ("Nombre de blessures", "COUNTROWS(Blessures)", "0"),
    ("Blessures en cours", "CALCULATE(COUNTROWS(Blessures), Blessures[En cours] = TRUE())", "0"),
    ("Jours d'absence", "SUM(Blessures[Jours d'absence])", "#,0"),
]

# Relations : (plusieurs → un, actif)
RELATIONSHIPS = [
    ("Joueurs", "team_id", "Équipes", "id", True),
    ("Présences", "player_id", "Joueurs", "id", True),
    ("Présences", "session_id", "Séances", "id", True),
    ("Présences", "Date", "Calendrier", "Date", True),
    ("Bien-être", "player_id", "Joueurs", "id", True),
    ("Bien-être", "session_id", "Séances", "id", True),
    ("Bien-être", "Date", "Calendrier", "Date", True),
    ("Feuilles de match", "player_id", "Joueurs", "id", True),
    ("Feuilles de match", "match_id", "Matchs", "id", True),
    ("Feuilles de match", "Date", "Calendrier", "Date", True),
    ("Événements", "player_id", "Joueurs", "id", True),
    ("Événements", "assist_player_id", "Joueurs", "id", False),  # passes décisives (USERELATIONSHIP)
    ("Événements", "match_id", "Matchs", "id", True),
    ("Événements", "Date", "Calendrier", "Date", True),
    ("Blessures", "player_id", "Joueurs", "id", True),
    ("Blessures", "Date", "Calendrier", "Date", True),
]


# ---------------------------------------------------------------------------
# TMDL
# ---------------------------------------------------------------------------
def tmdl_columns(table, cols):
    out = []
    for name, src, dtype, hidden, fmt in cols:
        out.append(f"\tcolumn {q(name)}")
        out.append(f"\t\tdataType: {dtype}")
        if fmt:
            out.append(f"\t\tformatString: {fmt}")
        if hidden:
            out.append("\t\tisHidden")
        out.append(f"\t\tlineageTag: {uid(table, 'col', name)}")
        out.append("\t\tsummarizeBy: none")
        out.append(f"\t\tsourceColumn: {src}")
        out.append("")
    return out


def tmdl_partition(table, m):
    lines = [f"\tpartition {q(table)} = m", "\t\tmode: import", "\t\tsource ="]
    lines += ["\t\t\t\t" + l for l in m.splitlines()]
    return lines + [""]


def m_for_view(view, labels, added):
    steps = ["let",
             "    Source = PostgreSQL.Database(Serveur, BaseDeDonnees),",
             f'    Data = Source{{[Schema = "reporting", Item = "{view}"]}}[Data],']
    prev = "Data"
    for col, kind in labels.items():
        steps.append(f"    Libelles_{col} = Table.TransformColumns({prev}, "
                     f"{{{{\"{col}\", each if _ = null then null else Record.FieldOrDefault({m_record(LABELS[kind])}, _, _), type text}}}}),")
        prev = f"Libelles_{col}"
    for col, expr, mtype in added:
        steps.append(f'    Ajout_{col} = Table.AddColumn({prev}, "{col}", {expr}, type {mtype}),')
        prev = f"Ajout_{col}"
    steps[-1] = steps[-1].rstrip(",")
    return "\n".join(steps + ["in", f"    {prev}"])


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")


def build_model():
    base = OUT / f"{NAME}.SemanticModel"
    d = base / "definition"
    write(base / "definition.pbism", json.dumps({"version": "4.0", "settings": {}}, indent=2) + "\n")
    write(d / "database.tmdl", "database\n\tcompatibilityLevel: 1567\n\n")
    all_tables = [t[0] for t in TABLES] + ["Calendrier", "Mesures"]
    write(d / "model.tmdl", "\n".join(
        ["model Model", "\tculture: fr-FR", "\tdefaultPowerBIDataSourceVersion: powerBI_V3", "\tsourceQueryCulture: fr-FR", ""]
        + [f"ref table {q(t)}" for t in all_tables] + [""]))
    write(d / "expressions.tmdl", "\n".join([
        f'expression Serveur = "{SERVER}" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]',
        f"\tlineageTag: {uid('param', 'server')}", "",
        f'expression BaseDeDonnees = "{DATABASE}" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]',
        f"\tlineageTag: {uid('param', 'database')}", ""]))
    for name, view, cols, labels, added in TABLES:
        lines = [f"table {q(name)}", f"\tlineageTag: {uid(name)}", ""]
        lines += tmdl_columns(name, cols) + tmdl_partition(name, m_for_view(view, labels, added))
        write(d / "tables" / f"{name}.tmdl", "\n".join(lines))
    write(d / "tables" / "Calendrier.tmdl", "\n".join(
        ["table Calendrier", f"\tlineageTag: {uid('Calendrier')}", ""]
        + tmdl_columns("Calendrier", CALENDAR_COLS) + tmdl_partition("Calendrier", CALENDAR_M)))
    measure_lines = ["table Mesures", f"\tlineageTag: {uid('Mesures')}", ""]
    for name, dax, fmt in MEASURES:
        measure_lines += [f"\tmeasure {q(name)} = {dax}", f"\t\tformatString: {fmt}",
                          f"\t\tlineageTag: {uid('Mesures', 'measure', name)}", ""]
    measure_lines += tmdl_columns("Mesures", [("_", "_", S, True, None)])
    measure_lines += tmdl_partition("Mesures", 'let\n    Source = #table(type table [_ = text], {})\nin\n    Source')
    write(d / "tables" / "Mesures.tmdl", "\n".join(measure_lines))
    rel = []
    for ft, fc, tt, tc, active in RELATIONSHIPS:
        rel += [f"relationship {uid('rel', ft, fc, tt, tc)}"]
        if not active:
            rel += ["\tisActive: false"]
        rel += [f"\tfromColumn: {q(ft)}.{q(fc)}", f"\ttoColumn: {q(tt)}.{q(tc)}", ""]
    write(d / "relationships.tmdl", "\n".join(rel))


# ---------------------------------------------------------------------------
# Rapport (format report.json)
# ---------------------------------------------------------------------------
def field(table, prop):
    return ("measure", "Mesures", prop) if table == "Mesures" else ("column", table, prop)


def visual(vid, vtype, x, y, w, h, roles, title, z=0):
    sources, alias = [], {}
    selects, projections = [], {}
    for role, fields in roles.items():
        projections[role] = []
        for table, prop in fields:
            kind, t, p = field(table, prop)
            if t not in alias:
                alias[t] = f"t{len(alias)}"
                sources.append({"Name": alias[t], "Entity": t, "Type": 0})
            ref = f"{t}.{p}"
            key = "Measure" if kind == "measure" else "Column"
            if not any(s["Name"] == ref for s in selects):
                selects.append({key: {"Expression": {"SourceRef": {"Source": alias[t]}}, "Property": p}, "Name": ref})
            projections[role].append({"queryRef": ref})
    cfg = {
        "name": vid,
        "layouts": [{"id": 0, "position": {"x": x, "y": y, "z": z, "width": w, "height": h}}],
        "singleVisual": {
            "visualType": vtype,
            "projections": projections,
            "prototypeQuery": {"Version": 2, "From": sources, "Select": selects},
            "drillFilterOtherVisuals": True,
            "vcObjects": {"title": [{"properties": {
                "show": {"expr": {"Literal": {"Value": "true"}}},
                "text": {"expr": {"Literal": {"Value": "'" + title.replace("'", "''") + "'"}}}}}]},
        },
    }
    return {"x": x, "y": y, "z": z, "width": w, "height": h, "config": json.dumps(cfg, ensure_ascii=False), "filters": "[]"}


def page(pid, title, ordinal, visuals):
    return {"name": pid, "displayName": title, "displayOption": 1, "width": 1280, "height": 720,
            "ordinal": ordinal, "config": "{}", "filters": "[]", "visualContainers": visuals}


M = "Mesures"
J = "Joueurs"
C = "Calendrier"


def cards(prefix, y, names):
    w = (1240 - 10 * (len(names) - 1)) // len(names)
    return [visual(f"{prefix}{i}", "card", 20 + i * (w + 10), y, w, 110, {"Values": [(M, n)]}, n)
            for i, n in enumerate(names)]


PAGES = [
    ("p1", "Vue d'ensemble", cards("p1c", 20, ["Joueurs suivis", "Présence %", "Charge totale (UA)",
                                                 "Bien-être moyen (/25)", "Blessures en cours"]) + [
        visual("p1v1", "columnChart", 20, 150, 620, 300,
               {"Category": [(C, "Semaine")], "Y": [(M, "Charge séances (UA)"), (M, "Charge matchs (UA)")]},
               "Charge d'entraînement par semaine"),
        visual("p1v2", "slicer", 20, 470, 300, 230, {"Values": [(C, "Saison")]}, "Saison"),
        visual("p1v3", "slicer", 340, 470, 300, 230, {"Values": [(J, "Poste")]}, "Poste"),
        visual("p1v4", "tableEx", 660, 150, 600, 550,
               {"Values": [(J, "Joueur"), (M, "Présence %"), (M, "Matchs joués"), (M, "Minutes jouées"), (M, "Buts"),
                           (M, "Passes décisives"), (M, "Charge totale (UA)"), (M, "ACWR")]},
               "Joueurs"),
    ]),
    ("p2", "Charge et ACWR", [
        visual("p2v1", "slicer", 20, 20, 240, 680, {"Values": [(J, "Joueur")]}, "Joueur"),
        visual("p2v2", "lineChart", 280, 20, 980, 320, {"Category": [(C, "Semaine")], "Y": [(M, "ACWR")]},
               "ACWR (charge aiguë 7 j / chronique 28 j) — zone de risque au-dessus de 1,5"),
        visual("p2v3", "pivotTable", 280, 360, 980, 340,
               {"Rows": [(J, "Joueur")], "Columns": [(C, "Semaine")], "Values": [(M, "Charge totale (UA)")]},
               "Charge par joueur et par semaine (RPE × minutes)"),
    ]),
    ("p3", "Bien-être", [
        visual("p3v1", "lineChart", 20, 20, 1240, 300,
               {"Category": [(C, "Date")], "Y": [(M, "Bien-être moyen (/25)"), (M, "Sommeil moyen (h)")]},
               "Bien-être moyen de l'équipe (/25) et sommeil (h)"),
        visual("p3v2", "pivotTable", 20, 340, 1240, 360,
               {"Rows": [(J, "Joueur")], "Columns": [(C, "Date")], "Values": [(M, "Bien-être moyen (/25)")]},
               "Bien-être par joueur (/25)"),
    ]),
    ("p4", "Matchs", [
        visual("p4v1", "tableEx", 20, 20, 620, 320,
               {"Values": [("Matchs", "Date"), ("Matchs", "Adversaire"), ("Matchs", "Lieu"), ("Matchs", "Compétition"),
                           ("Matchs", "Score"), ("Matchs", "Résultat")]}, "Résultats"),
        visual("p4v2", "clusteredBarChart", 660, 20, 600, 320,
               {"Category": [(J, "Joueur")], "Y": [(M, "Minutes jouées")]}, "Temps de jeu"),
        visual("p4v3", "tableEx", 20, 360, 1240, 340,
               {"Values": [(J, "Joueur"), (M, "Matchs joués"), (M, "Minutes jouées"), (M, "Buts"), (M, "Passes décisives"),
                           (M, "Cartons jaunes"), (M, "Cartons rouges"), (M, "Charge matchs (UA)")]},
               "Statistiques par joueur"),
    ]),
    ("p5", "Blessures", cards("p5c", 20, ["Blessures en cours", "Nombre de blessures", "Jours d'absence"]) + [
        visual("p5v1", "tableEx", 20, 150, 800, 550,
               {"Values": [(J, "Joueur"), ("Blessures", "Date"), ("Blessures", "Zone"), ("Blessures", "Côté"),
                           ("Blessures", "Type"), ("Blessures", "Gravité"), ("Blessures", "En cours"),
                           ("Blessures", "Jours d'absence")]}, "Blessures"),
        visual("p5v2", "clusteredBarChart", 840, 150, 420, 550,
               {"Category": [("Blessures", "Zone")], "Y": [(M, "Nombre de blessures")]}, "Blessures par zone"),
    ]),
]


def build_report():
    base = OUT / f"{NAME}.Report"
    write(base / "definition.pbir", json.dumps(
        {"version": "4.0", "datasetReference": {"byPath": {"path": f"../{NAME}.SemanticModel"}}}, indent=2) + "\n")
    report = {
        "config": json.dumps({"version": "5.43", "activeSectionIndex": 0, "defaultDrillFilterOtherVisuals": True}),
        "layoutOptimization": 0,
        "sections": [page(pid, title, i, vs) for i, (pid, title, vs) in enumerate(PAGES)],
    }
    write(base / "report.json", json.dumps(report, ensure_ascii=False, indent=2) + "\n")


def build_project():
    write(OUT / f"{NAME}.pbip", json.dumps({
        "version": "1.0",
        "artifacts": [{"report": {"path": f"{NAME}.Report"}}],
        "settings": {"enableAutoRecovery": True},
    }, indent=2) + "\n")
    write(OUT / ".gitignore", "**/.pbi/localSettings.json\n**/.pbi/cache.abf\n")


def check():
    """Chaque champ utilisé (mesures, relations, visuels) doit exister dans le modèle."""
    cols = {t[0]: {c[0] for c in t[2]} for t in TABLES}
    cols["Calendrier"] = {c[0] for c in CALENDAR_COLS}
    measures = {m[0] for m in MEASURES}
    errors = []
    for ft, fc, tt, tc, _ in RELATIONSHIPS:
        for t, c in ((ft, fc), (tt, tc)):
            if c not in cols.get(t, ()):
                errors.append(f"relation : {t}[{c}] inconnue")
    for name, dax, _ in MEASURES:
        for t, c in re.findall(r"'?([\wÀ-ÿ\- ]+?)'?\[([^\]]+)\]", dax):
            t = t.strip()
            if t == "" and c not in measures:
                errors.append(f"{name} : mesure [{c}] inconnue")
            elif t and c not in cols.get(t, ()):
                errors.append(f"{name} : {t}[{c}] inconnue")
    for _, _, vs in PAGES:
        for v in vs:
            cfg = json.loads(v["config"])
            for s in cfg["singleVisual"]["prototypeQuery"]["Select"]:
                kind = "Measure" if "Measure" in s else "Column"
                t, p = s["Name"].split(".", 1)
                if (kind == "Measure" and p not in measures) or (kind == "Column" and p not in cols.get(t, ())):
                    errors.append(f"visuel {cfg['name']} : {s['Name']} inconnu")
    if errors:
        raise SystemExit("\n".join(errors))


if __name__ == "__main__":
    check()
    build_model()
    build_report()
    build_project()
    print(f"Projet généré : {OUT / (NAME + '.pbip')}")
