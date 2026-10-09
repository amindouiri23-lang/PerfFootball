"""Génère docs/Specifications-fonctionnelles-v1.pdf.

Source : docs/02-specifications-fonctionnelles.md + tools/pdf/maquettes.html + tools/pdf/style.css.
Chaque marqueur <!-- maquette:EXX --> du Markdown est remplacé par le bloc « @@ EXX » des maquettes.
Le PDF est imprimé par Chrome ou Edge en mode headless.

Usage : python tools/pdf/build_pdf.py
"""
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import markdown
from markdown.extensions.toc import slugify_unicode

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
SPECS = ROOT / "docs" / "02-specifications-fonctionnelles.md"
OUT_HTML = HERE / "build" / "specifications.html"
OUT_PDF = ROOT / "docs" / "Specifications-fonctionnelles-v1.pdf"

TABS = [("Accueil", "⌂"), ("Séances", "🏃"), ("Matchs", "⚽"), ("Équipe", "👥"), ("Profil", "👤")]
BROWSERS = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "google-chrome", "chromium", "msedge",
]


def nav(active, cls):
    items = "".join(
        f'<span class="{"on" if name == active else ""}"><i>{icon}</i>{name}</span>' for name, icon in TABS
    )
    return f'<div class="{cls}">{items}</div>'


def load_mockups():
    text = (HERE / "maquettes.html").read_text(encoding="utf-8")
    text = re.sub(r"<!--.*?-->", "", text, count=1, flags=re.S)  # commentaire d'en-tête
    blocks = {}
    for part in re.split(r"^@@ ", text, flags=re.M)[1:]:
        key, _, html = part.partition("\n")
        html = html.replace("{{status}}", '<div class="status"><span>9:41</span><span>▂▄▆ 🔋</span></div>')
        html = re.sub(r"\{\{nav:(.+?)\}\}", lambda m: nav(m.group(1), "nav"), html)
        html = re.sub(r"\{\{rail:(.+?)\}\}", lambda m: nav(m.group(1), "rail"), html)
        blocks[key.strip()] = html.strip()
    return blocks


def build_html():
    src = SPECS.read_text(encoding="utf-8")
    cover_md, _, body_md = src.partition("\n## 1.")
    body_md = "## 1." + body_md

    md = markdown.Markdown(
        extensions=["tables", "fenced_code", "toc"],
        extension_configs={"toc": {"toc_depth": "2-3", "slugify": slugify_unicode}},
    )
    body = md.convert(body_md)
    toc = md.toc
    cover = markdown.markdown(cover_md, extensions=["tables"])

    mockups = load_mockups()
    missing = []

    def insert(m):
        key = m.group(1)
        if key not in mockups:
            missing.append(key)
            return ""
        return f'<div class="maquettes">{mockups[key]}</div>'

    body = re.sub(r"<!-- maquette:(\S+) -->", insert, body)
    if missing:
        sys.exit(f"Maquettes absentes de maquettes.html : {', '.join(missing)}")

    body = re.sub(r'<h3 id="([^"]+)">(E\d\d)', r'<h3 class="ecran" id="\1">\2', body)
    body = re.sub(r'<h3 id="([^"]+)">(5\.\d)', r'<h3 class="groupe" id="\1">\2', body)

    css = (HERE / "style.css").read_text(encoding="utf-8")
    return f"""<!doctype html>
<html lang="fr"><head><meta charset="utf-8"><title>Spécifications fonctionnelles v1</title>
<style>{css}
h3.groupe {{ break-before: page; }}
h2 + p + h3.groupe, h3.groupe + h3.ecran, h3.groupe + p + h3.ecran {{ break-before: auto; }}
</style></head><body>
<section class="cover"><div class="tag">Cahier des charges</div><div class="bar"></div>{cover}</section>
<section class="toc"><h1>Sommaire</h1>{toc}</section>
{body}
</body></html>"""


def find_browser():
    for b in BROWSERS:
        path = shutil.which(b) or (b if Path(b).exists() else None)
        if path:
            return path
    sys.exit("Chrome ou Edge introuvable.")


def main():
    OUT_HTML.parent.mkdir(exist_ok=True)
    OUT_HTML.write_text(build_html(), encoding="utf-8")
    with tempfile.TemporaryDirectory() as profile:
        subprocess.run([
            find_browser(), "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
            f"--user-data-dir={profile}", f"--print-to-pdf={OUT_PDF}", OUT_HTML.as_uri(),
        ], check=True, capture_output=True)
    print(f"PDF généré : {OUT_PDF}")


if __name__ == "__main__":
    main()
