# Rapport Power BI — PerfFoot

Projet Power BI (format **.pbip**) déjà connecté à la base Supabase de l'application.
Il ne contient pas de données : Power BI les charge à chaque **actualisation**.

## Ouvrir le rapport (première fois)

1. Installer **Power BI Desktop** (gratuit, Microsoft Store ou site de Microsoft), version récente.
2. Ouvrir `PerfFoot.pbip` (double-clic).
   - Si Power BI refuse le format : *Fichier → Options et paramètres → Options → Fonctionnalités en
     préversion* → cocher **« Enregistrement de projet Power BI (.pbip) »** et **« Stocker le modèle
     sémantique au format TMDL »**, redémarrer Power BI, rouvrir le fichier.
3. Cliquer sur **Actualiser** (ruban *Accueil*). Power BI demande les identifiants de la base :
   - onglet **Base de données** ;
   - **Nom d'utilisateur** : `powerbi_reader.adxmbdzmxfplubtrqcwt`
   - **Mot de passe** : valeur de `POWERBI_DB_PASSWORD` dans le fichier `.env` du projet
     (à demander au développeur — ne jamais l'envoyer par e-mail ou messagerie en clair).
   - Si Power BI propose une connexion non chiffrée, **refuser** : Supabase accepte le chiffrement.
4. Les données apparaissent. Ensuite, un clic sur **Actualiser** suffit pour voir les dernières saisies.

Le serveur (`aws-0-eu-north-1.pooler.supabase.com:5432`) et la base (`postgres`) sont des
paramètres du rapport : *Transformer les données → Modifier les paramètres*.

## Ce que contient le rapport

| Page | Contenu |
|---|---|
| **Vue d'ensemble** | Joueurs suivis, présence, charge totale, bien-être moyen, blessures en cours ; charge par semaine (séances / matchs) ; tableau par joueur ; filtres saison et poste |
| **Charge et ACWR** | ACWR par semaine (risque au-dessus de 1,5) ; charge par joueur et par semaine ; filtre joueur |
| **Bien-être** | Évolution du bien-être (/25) et du sommeil ; tableau joueurs × jours |
| **Matchs** | Résultats ; temps de jeu par joueur ; buts, passes décisives, cartons |
| **Blessures** | Blessures en cours, nombre, jours d'absence ; liste détaillée ; blessures par zone du corps |

## Les calculs

- **Charge (UA)** = RPE × minutes, pour chaque joueur à chaque séance et chaque match
  (ex. RPE 7 pendant 90 min = 630 UA). Ce n'est pas stocké dans l'application : Power BI le calcule.
- **Charge aiguë** = charge des 7 derniers jours.
- **Charge chronique** = moyenne hebdomadaire des 28 derniers jours.
- **ACWR** = aiguë ÷ chronique. Entre 0,8 et 1,3 : zone habituelle ; au-dessus de 1,5 : hausse brutale,
  risque de blessure accru.
- **Bien-être** = somme des 5 notes de 1 à 5 (sur 25 ; plus c'est haut, mieux c'est).
- Les joueurs supprimés dans l'application restent dans les statistiques passées
  (colonne *Supprimé* de la table Joueurs).

## Modifier le rapport

Les modifications faites dans Power BI Desktop s'enregistrent dans ce dossier (fichiers texte,
versionnés avec Git). Pour régénérer le rapport d'origine : `python tools/powerbi/build_pbip.py`
(attention : écrase les modifications faites dans Power BI Desktop).

## Limites

- **Pas de temps réel** : Power BI montre les données de la dernière actualisation.
- **Partage en ligne** (service Power BI) : demande en général une licence Power BI Pro, et
  l'actualisation planifiée depuis Supabase une passerelle (gateway) — voir la phase 2 (export CSV vers
  SharePoint) dans `docs/01-architecture-and-rules.md`.
