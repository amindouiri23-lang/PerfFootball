# Spécifications fonctionnelles — Application de suivi de la performance

| | |
|---|---|
| **Version** | 1.0 — brouillon |
| **Date** | 7 octobre 2026 |
| **Destinataires** | Préparateur physique, staff technique, équipe de développement |
| **Document technique associé** | `01-architecture-and-rules.md` (architecture, modèle de données, règles de développement) |

---

## 1. Présentation

### 1.1 Objectif

L'application permet au **préparateur physique** d'une équipe de football de saisir, au bord du
terrain, les données de ses joueurs pendant les **séances d'entraînement** et les **matchs** :
présence, blessures, remarques, temps de jeu, événements de match, ressenti de l'effort et
questionnaire de bien-être. Ces données alimentent ensuite des **tableaux de bord Power BI**.

### 1.2 Utilisateurs

| Profil | Rôle dans la v1 |
|---|---|
| **Préparateur physique / membre du staff** | Utilisateur principal : gère son équipe, ses joueurs, ses séances et ses matchs. |
| **Joueur** | N'a pas de compte. Il peut remplir son questionnaire de bien-être sur l'appareil du staff. |
| **Administrateur** | Membre du staff avec un droit en plus : crée les comptes, réinitialise les mots de passe et désactive les comptes depuis l'écran *Administration*. Pas d'inscription libre. |

### 1.3 Principes

- **Application entièrement en français.**
- **Téléphones et tablettes** : une seule application dont l'affichage s'adapte à la largeur de
  l'écran. Android d'abord, **iOS ensuite** sans réécriture.
- **Fonctionne sans connexion** : tout est enregistré sur l'appareil, puis synchronisé
  automatiquement dès que le réseau revient.
- **Saisie rapide** : peu de clavier, des valeurs par défaut partout, des gros boutons.
- **Enregistrement automatique** : pas de perte de données si l'application est fermée.

---

## 2. Périmètre

### 2.1 Inclus dans la v1

| # | Fonctionnalité |
|---|---|
| F1 | Connexion, mot de passe oublié (réinitialisation par l'administrateur), mot de passe temporaire à changer, déconnexion |
| F2 | Profil de l'utilisateur : consultation, modification, changement de mot de passe |
| F3 | Création et modification d'une équipe |
| F4 | Effectif : ajouter, modifier, supprimer des joueurs ; fiche joueur |
| F5 | Séances : liste triée par date, création, modification, suppression |
| F6 | Déroulé d'une séance : informations → appel des présents → blessures et remarques → clôture → bien-être |
| F7 | Matchs : liste triée par date, création, modification, suppression |
| F8 | Déroulé d'un match : informations → joueurs présents → événements (buts, passes décisives, cartons, blessures) → temps de jeu et score |
| F9 | Infirmerie : blessures en cours, retour de blessure |
| F10 | Synchronisation et paramètres |
| F11 | Administration des comptes : créer, réinitialiser le mot de passe, désactiver (administrateurs) |

### 2.2 Hors v1 (évolutions prévues)

1. Tests physiques (CMJ, sprints, VMA, Yo-Yo…) et mesures corporelles (poids, masse grasse).
2. Import des données GPS (Catapult, STATSports…).
3. Remplacements en tant qu'événements de match (calcul automatique du temps de jeu).
4. Graphiques dans l'application (charge hebdomadaire, évolution du bien-être).
5. Alertes (charge trop élevée, bien-être bas).
6. Invitation d'autres membres du staff dans une équipe, avec des rôles.
7. Mode joueur verrouillé par code pour le questionnaire de bien-être.
8. Export automatique CSV vers SharePoint pour Power BI.
9. Version iOS publiée.

---

## 3. Navigation

### 3.1 Arborescence

```
Connexion (E01)
 ├── Mot de passe oublié (E02) : contacter l'administrateur
 ├── Connexion avec un mot de passe temporaire → Nouveau mot de passe obligatoire (E03)
 └── Première connexion sans équipe → Créer mon équipe (E06)

Application (barre de navigation)
 ├── Accueil (E10) ─────────── Infirmerie (E27)
 ├── Séances (E11)
 │    ├── Nouvelle séance (E12) → Appel (E13) → Séance en cours (E14)
 │    │        Séance en cours → Blessure (E15) · Remarque (E16) · Clôture (E17) → Bien-être (E18)
 │    └── Détail d'une séance (E19)
 ├── Matchs (E20)
 │    ├── Nouveau match (E21) → Joueurs présents (E22) → Match en cours (E23)
 │    │        Match en cours → Événement (E24) · Blessure (E15) · Remarque (E16) · Fin de match (E25)
 │    └── Détail d'un match (E26)
 ├── Équipe (E07)
 │    ├── Fiche joueur (E08) → Modifier le joueur (E09)
 │    └── Ajouter un joueur (E09) · Modifier l'équipe (E06)
 └── Profil (E04)
      ├── Changer le mot de passe (E05)
      ├── Synchronisation et paramètres (E28)
      └── Administration — administrateurs (E29)
           ├── Créer un compte (E30)
           └── Réinitialiser un mot de passe (E31)
```

### 3.2 Barre de navigation

- **Téléphone** : barre en bas de l'écran, 5 onglets — *Accueil · Séances · Matchs · Équipe · Profil*.
- **Tablette** : les mêmes 5 onglets dans une colonne à gauche de l'écran.
- En haut de chaque écran, un **indicateur de synchronisation** (nuage) affiche le nombre de
  données pas encore envoyées.

---

## 4. Règles d'ergonomie

### 4.1 Adaptation à l'écran

| Largeur de l'écran | Appareil type | Affichage |
|---|---|---|
| moins de 600 dp | Téléphone | Une colonne. Une carte par joueur dans les listes de saisie. |
| 600 à 840 dp | Petite tablette, téléphone à l'horizontale | Navigation à gauche. Les joueurs sont affichés en grille (2 colonnes). |
| plus de 840 dp | Tablette | Navigation à gauche, **liste et détail côte à côte** (ex. : liste des séances à gauche, séance ouverte à droite). |

### 4.2 Règles générales

- Zones tactiles d'au moins **48 dp**, boutons principaux d'au moins **56 dp** de haut.
- **Éviter le clavier** : listes de choix (puces), sélecteurs de date et d'heure, compteurs +/−.
  Le clavier numérique n'apparaît que pour les minutes et les valeurs mesurées.
- **Valeurs par défaut** : date du jour, heure arrondie au quart d'heure suivant, durée prévue, tous
  les joueurs présents.
- **Enregistrement automatique** sur les écrans de saisie ; un bouton « Valider » uniquement pour
  passer à l'étape suivante.
- **Fort contraste** (lisible en plein soleil) et **mode sombre**.
- Couleurs de l'échelle d'effort et du bien-être : vert (facile / bon) → orange → rouge
  (difficile / mauvais). La couleur n'est jamais le seul repère : le chiffre est toujours affiché.
- Toute **suppression** demande une confirmation.
- Toute action qui échoue affiche un message court en bas de l'écran.

### 4.3 Échelles utilisées

**Effort ressenti (RPE, échelle CR-10)**, demandé environ 30 minutes après la séance :

| Note | Libellé | Note | Libellé |
|---|---|---|---|
| 0 | Repos | 6 | Difficile + |
| 1 | Très très facile | 7 | Très difficile |
| 2 | Facile | 8 | Très difficile + |
| 3 | Modéré | 9 | Presque maximal |
| 4 | Un peu difficile | 10 | Maximal |
| 5 | Difficile | | |

**Bien-être (wellness)** : cinq questions notées de **1 à 5, où 5 est toujours le meilleur état**,
plus les heures de sommeil.

| Question | 1 | 5 |
|---|---|---|
| Qualité du sommeil | Très mauvaise | Excellente |
| Fatigue | Épuisé | Très frais |
| Courbatures | Très douloureuses | Aucune |
| Stress | Très stressé | Très détendu |
| Humeur | Très mauvaise | Excellente |

---

## 5. Description des écrans

Chaque écran est décrit avec : **objectif**, **accès**, **contenu**, **actions**, **règles de
gestion** et **scénario** (déroulement normal, puis cas particuliers).

### 5.1 Authentification

### E01 — Connexion

<!-- maquette:E01 -->

**Objectif** : identifier le membre du staff.

**Accès** : au lancement de l'application si aucune session n'est ouverte.

**Contenu**

| Élément | Type | Obligatoire | Règle |
|---|---|---|---|
| Logo et nom de l'application | Image | — | |
| Adresse e-mail | Champ e-mail | Oui | Format e-mail valide |
| Mot de passe | Champ masqué + icône « afficher » | Oui | |
| Se souvenir de moi | — | — | Toujours actif : la session reste ouverte jusqu'à la déconnexion |
| Se connecter | Bouton principal | — | Actif quand les deux champs sont remplis |
| Mot de passe oublié ? | Lien | — | Ouvre E02 |

**Règles de gestion**

- Pas d'inscription libre : les comptes sont créés par un administrateur (E30).
- Connexion avec un **mot de passe temporaire** → **E03 — Nouveau mot de passe obligatoire**.
- La **première connexion** demande une connexion internet ; ensuite l'application fonctionne hors ligne.
- Après connexion : si l'utilisateur n'a **aucune équipe**, il arrive sur **E06 — Créer mon équipe** ;
  sinon sur **E10 — Accueil**.

**Scénario**

1. L'utilisateur ouvre l'application.
2. Il saisit son e-mail et son mot de passe, puis appuie sur **Se connecter**.
3. L'application vérifie les identifiants, télécharge les données de son équipe et affiche l'Accueil.

*Cas particuliers*

- Identifiants incorrects → message « E-mail ou mot de passe incorrect. »
- Pas de réseau à la première connexion → message « Connectez-vous à internet pour la première connexion. »
- Trois échecs de suite → rappel du lien « Mot de passe oublié ? ».

### E02 — Mot de passe oublié

<!-- maquette:E02 -->

**Objectif** : indiquer à l'utilisateur comment récupérer l'accès à son compte.

**Accès** : lien « Mot de passe oublié ? » de E01.

**Contenu** : texte d'explication « Votre mot de passe est réinitialisé par l'administrateur de
l'application. Contactez-le : il vous communiquera un mot de passe temporaire. », bouton **Retour à
la connexion**.

**Règles de gestion**

- L'application **n'envoie aucun e-mail** : la réinitialisation est faite par un administrateur
  depuis l'écran **E31**.

**Scénario**

1. L'utilisateur a oublié son mot de passe et appuie sur **Mot de passe oublié ?**.
2. Il lit le message et contacte l'administrateur (téléphone, en personne…).
3. L'administrateur lui communique un **mot de passe temporaire** (E31).
4. L'utilisateur se connecte avec ce mot de passe dans E01 → l'application ouvre **E03**.

### E03 — Nouveau mot de passe obligatoire

<!-- maquette:E03 -->

**Objectif** : obliger l'utilisateur à remplacer un mot de passe temporaire.

**Accès** : automatiquement après une connexion avec un **mot de passe temporaire** (compte créé ou
mot de passe réinitialisé par l'administrateur). L'écran ne peut pas être quitté autrement que par
**Valider** ou **Se déconnecter**.

**Contenu**

| Élément | Type | Obligatoire | Règle |
|---|---|---|---|
| Texte | Texte | — | « Pour votre sécurité, choisissez votre propre mot de passe. » |
| Nouveau mot de passe | Champ masqué | Oui | 8 caractères minimum, dont 1 chiffre ; différent du mot de passe temporaire |
| Confirmer le mot de passe | Champ masqué | Oui | Identique au précédent |
| Valider | Bouton principal | — | |
| Se déconnecter | Lien | — | |

**Scénario**

1. L'utilisateur se connecte avec le mot de passe temporaire reçu de l'administrateur.
2. L'écran « Nouveau mot de passe » s'ouvre ; il saisit et confirme son nouveau mot de passe.
3. Il appuie sur **Valider** → « Mot de passe modifié » ; il arrive sur l'Accueil (ou sur E06 s'il
   n'a pas encore d'équipe).

*Cas particuliers*

- Les deux mots de passe diffèrent → message sous le second champ.
- Pas de réseau → « Une connexion internet est nécessaire. »

### 5.2 Profil

### E04 — Mon profil

<!-- maquette:E04 -->

**Objectif** : consulter et modifier ses informations personnelles.

**Accès** : onglet **Profil**.

**Contenu**

| Élément | Type | Obligatoire | Règle |
|---|---|---|---|
| Photo | Image (appareil photo ou galerie) | Non | Compressée à environ 100 Ko |
| Prénom, Nom | Texte | Oui | |
| Fonction | Liste : Préparateur physique, Entraîneur, Entraîneur adjoint, Kinésithérapeute, Médecin, Autre | Oui | |
| Téléphone | Téléphone | Non | |
| E-mail | Texte | — | Lecture seule |
| Équipe active | Texte | — | Lien vers E07 |
| Changer le mot de passe | Ligne de menu | — | Ouvre E05 |
| Synchronisation et paramètres | Ligne de menu | — | Ouvre E28 |
| Administration | Ligne de menu | — | Administrateurs uniquement ; ouvre E29 |
| Se déconnecter | Bouton secondaire (rouge) | — | |

**Scénario**

1. L'utilisateur ouvre l'onglet Profil et appuie sur **Modifier**.
2. Il change sa photo, sa fonction ou son téléphone, puis appuie sur **Enregistrer**.
3. Message « Profil mis à jour ».

*Cas particuliers*

- **Déconnexion avec des données non synchronisées** → « 12 données ne sont pas encore envoyées.
  Synchronisez avant de vous déconnecter, sinon elles seront perdues. » avec les choix
  **Synchroniser** / **Annuler**. La déconnexion n'est possible qu'une fois tout synchronisé.

### E05 — Changer le mot de passe

<!-- maquette:E05 -->

**Objectif** : modifier son mot de passe en étant connecté.

**Contenu** : mot de passe actuel, nouveau mot de passe, confirmation, bouton **Enregistrer**
(mêmes règles que E03 ; le nouveau mot de passe doit être différent de l'actuel).

**Scénario**

1. L'utilisateur saisit son mot de passe actuel puis le nouveau, deux fois.
2. Il appuie sur **Enregistrer** → « Mot de passe modifié ».

*Cas particuliers* : mot de passe actuel incorrect → message sous le champ ; pas de réseau →
« Une connexion internet est nécessaire. »

### 5.3 Équipe et joueurs

### E06 — Créer / modifier mon équipe

<!-- maquette:E06 -->

**Objectif** : créer l'équipe suivie, ou modifier ses informations.

**Accès** : automatiquement à la première connexion sans équipe ; depuis E07 (menu ⋮ → *Modifier
l'équipe* ou *Créer une autre équipe*).

**Contenu**

| Élément | Type | Obligatoire | Règle |
|---|---|---|---|
| Logo | Image | Non | |
| Nom de l'équipe | Texte | Oui | Ex. « Seniors A » |
| Club | Texte | Non | |
| Catégorie | Liste : Seniors, U21, U19, U17, U15, Autre | Oui | |
| Saison | Liste | Oui | Saison en cours proposée par défaut (ex. 2026-2027) |
| Créer l'équipe / Enregistrer | Bouton principal | — | |

**Règles de gestion**

- L'utilisateur qui crée l'équipe en est le **propriétaire** ; lui seul la voit dans la v1.
- Un utilisateur peut suivre plusieurs équipes ; une seule est **active** à la fois (choix dans E07).
- La suppression d'une équipe n'est pas proposée dans la v1 (elle supprimerait tout l'historique).

**Scénario**

1. À sa première connexion, le préparateur arrive sur « Créer mon équipe ».
2. Il saisit « Seniors A », choisit la catégorie Seniors et la saison 2026-2027.
3. Il appuie sur **Créer l'équipe** → l'écran Équipe s'ouvre avec un effectif vide et le bouton
   **Ajouter un joueur** mis en avant.

### E07 — Mon équipe (effectif)

<!-- maquette:E07 -->

**Objectif** : voir et gérer la liste des joueurs.

**Accès** : onglet **Équipe**.

**Contenu**

- **En-tête** : logo, nom de l'équipe, catégorie, saison ; menu ⋮ : *Modifier l'équipe*,
  *Changer d'équipe*, *Créer une autre équipe*, *Infirmerie*.
- **Recherche** par nom et **filtres** par poste : Tous · Gardiens · Défenseurs · Milieux · Attaquants.
- **Liste des joueurs**, triée par poste puis par numéro : photo ou initiales, numéro, prénom et nom,
  poste, pastille rouge **Blessé** si une blessure est en cours.
- Compteur : « 24 joueurs ».
- Bouton flottant **+ Ajouter un joueur**.

**Actions** : appuyer sur un joueur → E08 ; glisser une ligne vers la gauche → *Modifier* / *Supprimer*.

**Scénario**

1. Le préparateur ouvre l'onglet Équipe.
2. Il filtre sur « Défenseurs » et voit 8 joueurs.
3. Il appuie sur un joueur pour ouvrir sa fiche.

*Cas particulier* : effectif vide → illustration et texte « Aucun joueur pour l'instant. Ajoutez
votre premier joueur. »

### E08 — Fiche joueur

<!-- maquette:E08 -->

**Objectif** : voir l'identité et l'historique d'un joueur.

**Accès** : depuis E07, ou en appuyant sur un nom dans une séance ou un match.

**Contenu**

- **En-tête** : photo, numéro, prénom et nom, poste, âge, pied fort, taille ; pastille *Blessé* le
  cas échéant.
- **Statistiques de la saison** : séances présentes / total (taux de présence), matchs joués,
  minutes jouées, buts, passes décisives, cartons jaunes et rouges.
- **Onglets** :
  - *Séances* : date, type, présent ou absent (motif), RPE, remarque.
  - *Matchs* : date, adversaire, minutes, buts, passes, cartons, remarque.
  - *Blessures* : date, zone, type, gravité, date de retour (ou « en cours »).
  - *Bien-être* : date de la séance, score total sur 25.
- Bouton **Modifier** (E09) et menu ⋮ → **Supprimer le joueur**.

**Règles de gestion**

- Les statistiques sont **calculées** à l'affichage à partir des données saisies (jamais saisies à
  la main).
- **Supprimer un joueur** le retire de l'effectif et des prochaines séances. Son historique est
  conservé pour Power BI. Confirmation : « Supprimer Karim Ben Ali ? Il n'apparaîtra plus dans
  l'effectif. Ses données passées sont conservées pour les statistiques. »

**Scénario**

1. Le préparateur ouvre la fiche d'un joueur depuis l'effectif.
2. Il consulte l'onglet *Blessures* pour voir la dernière blessure.
3. Il appuie sur une ligne de l'onglet *Séances* pour ouvrir la séance correspondante (E19).

### E09 — Ajouter / modifier un joueur

<!-- maquette:E09 -->

**Objectif** : créer ou modifier la fiche d'un joueur.

**Accès** : bouton **+ Ajouter un joueur** de E07 ; bouton **Modifier** de E08.

**Contenu**

| Élément | Type | Obligatoire | Règle |
|---|---|---|---|
| Photo | Image | Non | Appareil photo ou galerie, compressée |
| Prénom | Texte | Oui | |
| Nom | Texte | Oui | |
| Numéro de maillot | Nombre | Non | 1 à 99 ; avertissement si déjà pris dans l'équipe |
| Poste | Puces : Gardien · Défenseur · Milieu · Attaquant | Oui | |
| Date de naissance | Sélecteur de date | Non | Âge affiché à côté |
| Pied fort | Puces : Droit · Gauche · Les deux | Non | |
| Taille (cm) | Nombre | Non | 140 à 220 |
| Enregistrer | Bouton principal | — | |
| Enregistrer et ajouter un autre | Bouton secondaire | — | Création uniquement : vide le formulaire pour enchaîner |

**Scénario**

1. Le préparateur appuie sur **+ Ajouter un joueur**.
2. Il saisit « Karim », « Ben Ali », numéro 4, poste Défenseur, pied Droit.
3. Il appuie sur **Enregistrer et ajouter un autre** et enchaîne avec le joueur suivant.
4. Après le dernier joueur, il appuie sur **Enregistrer** et revient à l'effectif.

*Cas particuliers*

- Numéro déjà utilisé → avertissement « Le numéro 4 est déjà porté par Youssef Trabelsi. »,
  l'enregistrement reste possible.
- Quitter avec des modifications non enregistrées → « Abandonner les modifications ? ».

### 5.4 Accueil

### E10 — Accueil

<!-- maquette:E10 -->

**Objectif** : donner accès en un geste à ce qui se passe aujourd'hui.

**Accès** : onglet **Accueil** ; écran par défaut après la connexion.

**Contenu**

- Salutation et date du jour : « Bonjour Nizar — mardi 7 octobre ».
- **Aujourd'hui** : la ou les séances et matchs du jour, avec leur état (*Planifiée*, *En cours*,
  *Terminée*) et un bouton d'action adapté (*Démarrer l'appel*, *Reprendre*, *Voir*).
- **Prochain match** : date, heure, adversaire, compte à rebours en jours.
- **Infirmerie** : nombre de joueurs blessés, avec leurs noms → E27.
- **Actions rapides** : *+ Nouvelle séance*, *+ Nouveau match*.

**Scénario**

1. Le matin, le préparateur ouvre l'application.
2. Il voit la séance de 10:00 prévue et appuie sur **Démarrer l'appel** → E13.

### 5.5 Séances d'entraînement

Une séance passe par trois états : **Planifiée** (informations saisies) → **En cours** (appel
confirmé) → **Terminée** (clôture validée). Elle reste modifiable à tous les états.

### E11 — Liste des séances

<!-- maquette:E11 -->

**Objectif** : retrouver toutes les séances, triées par date.

**Accès** : onglet **Séances**.

**Contenu**

- Deux sections : **À venir** (de la plus proche à la plus lointaine), puis **Passées** (de la plus
  récente à la plus ancienne). Les séances sont regroupées par semaine (« Semaine du 6 octobre »).
- Chaque ligne : date et heure, type (pastille de couleur), durée prévue, état, nombre de présents
  (« 21/24 »).
- **Filtres** : type de séance, mois.
- Bouton flottant **+ Nouvelle séance**.

**Actions** : appuyer sur une séance → E14 si elle est en cours, E19 sinon ; glisser vers la gauche →
*Modifier* / *Supprimer*.

**Règles de gestion**

- **Supprimer une séance** supprime aussi son appel, ses remarques et son questionnaire de
  bien-être. Les blessures déclarées sont **conservées** (elles concernent le joueur), mais ne sont
  plus rattachées à la séance. Confirmation obligatoire.

**Scénario**

1. Le préparateur ouvre l'onglet Séances.
2. Il voit la séance de demain en haut, puis les séances passées.
3. Il glisse une séance créée par erreur vers la gauche, appuie sur **Supprimer**, puis confirme.

### E12 — Nouvelle séance : informations

<!-- maquette:E12 -->

**Objectif** : créer une séance (étape 1 sur 3).

**Accès** : **+ Nouvelle séance** (E10, E11) ; **Modifier** depuis E14 ou E19.

**Contenu**

| Élément | Type | Obligatoire | Règle |
|---|---|---|---|
| Date | Sélecteur de date | Oui | Aujourd'hui par défaut |
| Heure de début | Sélecteur d'heure | Oui | Quart d'heure suivant par défaut |
| Type de séance | Puces : Technique · Tactique · Physique · Mixte · Récupération · Musculation · Autre | Oui | |
| Durée prévue | Compteur +/− 5 min | Oui | 90 min par défaut, de 10 à 240 |
| Objectif | Texte court | Non | Ex. « Travail de pressing haut » |
| Démarrer l'appel | Bouton principal | — | Enregistre et ouvre E13 |
| Enregistrer pour plus tard | Bouton secondaire | — | Enregistre la séance à l'état *Planifiée* |

**Scénario**

1. Le préparateur appuie sur **+ Nouvelle séance**.
2. La date du jour et 10:00 sont proposées ; il choisit le type **Physique** et laisse 90 minutes.
3. Il appuie sur **Démarrer l'appel** → E13.

*Variante* : il prépare la séance du lendemain et appuie sur **Enregistrer pour plus tard** ; la
séance apparaît dans « À venir ».

*Cas particulier* : une autre séance existe déjà à la même date et à la même heure →
avertissement « Une séance existe déjà le 7 octobre à 10:00. Continuer ? ».

### E13 — Appel des joueurs

<!-- maquette:E13 -->

**Objectif** : indiquer les joueurs présents (étape 2 sur 3).

**Accès** : **Démarrer l'appel** (E12, E10) ; *Modifier l'appel* depuis E14.

**Contenu**

- Rappel de la séance : date, heure, type.
- Compteur en direct : « **22 présents** · 2 absents ».
- **Liste de tous les joueurs de l'effectif, tous cochés par défaut** : case à cocher, photo, numéro,
  nom, poste ; pastille *Blessé* si une blessure est en cours.
- Quand on **décoche** un joueur, une rangée de puces apparaît pour le **motif d'absence**
  (facultatif) : Blessé · Malade · Sélection · Personnel · Autre.
- Bouton **Tout cocher / Tout décocher**.
- Bouton principal **Confirmer les présents (22)**.

**Règles de gestion**

- Un joueur blessé reste coché par défaut, mais sa pastille *Blessé* attire l'attention ; si on le
  décoche, le motif *Blessé* est proposé en premier.
- La confirmation fait passer la séance à l'état **En cours**.
- Sur tablette, les joueurs sont présentés en grille de cartes (2 à 4 colonnes) ; un appui sur la
  carte coche ou décoche.

**Scénario**

1. Le préparateur voit les 24 joueurs cochés.
2. Il décoche Youssef (motif *Malade*) et Ali (motif *Sélection*).
3. Le bouton affiche **Confirmer les présents (22)** ; il appuie dessus → E14.

### E14 — Séance en cours

<!-- maquette:E14 -->

**Objectif** : pendant la séance, déclarer les blessures et noter des remarques (étape 3 sur 3).

**Accès** : après la confirmation de l'appel ; depuis E10 ou E11 pour une séance *En cours*.

**Contenu**

- **En-tête** : date, heure, type, durée prévue, état *En cours* ; menu ⋮ : *Modifier les
  informations* (E12), *Modifier l'appel* (E13), *Supprimer la séance*.
- **Remarques sur la séance** : zone de texte (bouton ✎) → E16.
- **Joueurs présents** : une ligne par joueur avec deux boutons :
  - **🩹 Blessure** → E15 (le joueur est pré-sélectionné) ;
  - **✎ Remarque** → E16 (remarque sur ce joueur pour cette séance).
  Une icône sous le nom indique qu'une blessure ou une remarque est déjà saisie.
- **Absents** : liste repliée avec leur motif.
- Bouton principal **Terminer la séance** → E17.

**Règles de gestion**

- Les remarques et les blessures sont enregistrées dès leur validation, même si la séance n'est pas
  terminée.
- Un joueur blessé pendant la séance reste « présent » (il a participé) ; sa durée réelle pourra être
  réduite à la clôture.

**Scénario**

1. Pendant la séance, Karim se blesse à la cuisse.
2. Le préparateur appuie sur **🩹 Blessure** sur la ligne de Karim et remplit E15.
3. Il appuie sur **✎ Remarque** sur la ligne de Mehdi : « Très bonne intensité sur les sprints. »
4. Il ajoute une remarque sur la séance : « Terrain lourd, séance raccourcie de 10 minutes. »
5. À la fin, il appuie sur **Terminer la séance**.

### E15 — Déclarer une blessure

<!-- maquette:E15 -->

**Objectif** : enregistrer les détails d'une blessure.

**Accès** : bouton **🩹 Blessure** dans E14 ou E23 ; **+ Blessure** dans E27 ou E08 (blessure hors
séance).

**Contenu**

| Élément | Type | Obligatoire | Règle |
|---|---|---|---|
| Joueur | Liste | Oui | Pré-rempli depuis une séance ou un match |
| Contexte | Texte | — | Automatique : « Séance du 7/10 » ou « Match contre CA Bizertin » |
| Minute | Nombre | Non | Matchs uniquement, de 1 à 130 |
| Zone du corps | Grille de puces : Tête · Cou · Épaule · Bras · Dos · Hanche/aine · Cuisse avant · Cuisse arrière · Genou · Mollet · Cheville · Pied · Autre | Oui | |
| Côté | Puces : Gauche · Droit · Les deux | Non | |
| Type | Puces : Musculaire · Ligamentaire · Osseuse · Contusion · Tendineuse · Autre | Oui | |
| Circonstance | Puces : Contact · Sans contact · Surmenage | Oui | |
| Gravité estimée | Puces : Légère (≤ 3 j) · Modérée (4 à 28 j) · Grave (> 28 j) | Oui | |
| Date de retour prévue | Sélecteur de date | Non | |
| Description | Texte libre | Non | |
| Enregistrer | Bouton principal | — | |

**Règles de gestion**

- La blessure reste **en cours** tant qu'aucune date de retour réelle n'est saisie (E27).
- Un joueur avec une blessure en cours porte la pastille *Blessé* partout dans l'application.

**Scénario**

1. Depuis E14, le préparateur appuie sur **🩹 Blessure** sur la ligne de Karim.
2. Il choisit *Cuisse arrière*, *Droit*, *Musculaire*, *Sans contact*, gravité *Modérée*.
3. Il écrit « Douleur en fin de sprint, arrêt immédiat. » et appuie sur **Enregistrer**.
4. Retour à E14 ; l'icône 🩹 apparaît sous le nom de Karim.

### E16 — Remarque (séance ou joueur)

<!-- maquette:E16 -->

**Objectif** : écrire une remarque libre.

**Accès** : bouton ✎ dans E14, E23, E19 ou E26. S'ouvre en **panneau par-dessus l'écran**
(sans quitter la séance).

**Contenu** : titre (« Remarque sur la séance » ou « Remarque — Mehdi Jaziri »), zone de texte de
1 000 caractères maximum avec la **dictée vocale** du clavier, boutons **Annuler** / **Enregistrer**.

**Règles de gestion** : une seule remarque par joueur et par séance ; la rouvrir permet de la
modifier ou de la vider.

**Scénario**

1. Le préparateur appuie sur ✎ à côté de Mehdi.
2. Il dicte « Très bonne intensité sur les sprints. » et appuie sur **Enregistrer**.

### E17 — Clôture de la séance

<!-- maquette:E17 -->

**Objectif** : confirmer la durée réelle de chaque joueur et recueillir l'effort ressenti (RPE).

**Accès** : **Terminer la séance** dans E14.

**Contenu**

- Bouton **Appliquer la durée prévue à tous** (90 min).
- Pour chaque joueur présent : nom, **durée réelle** (compteur +/− 5 min, durée prévue par défaut),
  **RPE** (puces 0 à 10 colorées).
- Les joueurs **sans RPE** sont affichés **en premier** ; compteur « RPE saisis : 18/22 ».
- Bouton principal **Valider la clôture**.

**Règles de gestion**

- Le RPE est **facultatif** : on peut valider sans l'avoir saisi pour tous ; il reste modifiable
  ensuite depuis E19.
- La validation fait passer la séance à l'état **Terminée**.
- La charge de séance (RPE × durée) n'est **pas** stockée : elle est calculée dans Power BI.

**Scénario**

1. Le préparateur appuie sur **Terminer la séance**.
2. Il réduit la durée de Karim (blessé) à 35 minutes.
3. 30 minutes après la séance, il demande à chaque joueur sa note et appuie sur la puce
   correspondante.
4. Il appuie sur **Valider la clôture**. L'application propose : « Remplir le questionnaire de
   bien-être maintenant ? » → **Oui** ouvre E18, **Plus tard** revient à la liste des séances.

### E18 — Questionnaire de bien-être

<!-- maquette:E18 -->

**Objectif** : recueillir l'état de forme de chaque joueur présent après la séance.

**Accès** : après la clôture (E17) ; bouton **Bien-être** dans E19.

**Contenu**

- **Liste des joueurs présents** avec l'état : à remplir, ou rempli (score total sur 25, coche verte).
  Compteur « 15/22 remplis ».
- **Questionnaire d'un joueur**, en plein écran, pensé pour être tendu au joueur :
  - nom et photo du joueur en grand ;
  - **heures de sommeil** : curseur de 0 à 14 h, par pas de 0,5 ;
  - **5 questions** (qualité du sommeil, fatigue, courbatures, stress, humeur), chacune avec
    **5 gros boutons** illustrés d'un visage, du rouge (1) au vert (5) ;
  - remarque facultative ;
  - boutons **Valider et joueur suivant** et **Valider**.

**Règles de gestion**

- Un seul questionnaire par joueur et par séance ; le rouvrir permet de le corriger.
- Toutes les questions doivent avoir une réponse pour valider (la remarque est facultative).

**Scénario**

1. Le préparateur tend la tablette à Mehdi.
2. Mehdi indique 7,5 h de sommeil, répond aux 5 questions et appuie sur **Valider et joueur suivant**.
3. Le questionnaire du joueur suivant s'ouvre ; ainsi de suite jusqu'au dernier.
4. Retour à la liste : « 22/22 remplis ».

### E19 — Détail d'une séance

<!-- maquette:E19 -->

**Objectif** : consulter et corriger une séance terminée ou planifiée.

**Accès** : appui sur une séance dans E11, E08 ou E10.

**Contenu**

- **Informations** : date, heure, type, durée prévue, objectif, état.
- **Remarques sur la séance**.
- **Présence** : présents et absents (avec motif).
- **Par joueur** : durée, RPE, remarque, icône de blessure.
- **Blessures déclarées** pendant la séance.
- **Bien-être** : nombre de questionnaires remplis, accès à E18.
- Menu ⋮ : *Modifier les informations* (E12), *Modifier l'appel* (E13), *Modifier les durées et
  RPE* (E17), *Supprimer la séance*.
- Pour une séance *Planifiée* : bouton principal **Démarrer l'appel**.

**Scénario**

1. Le lendemain, le préparateur ouvre la séance d'hier.
2. Il constate qu'il manque le RPE d'un joueur, ouvre *Modifier les durées et RPE* et le complète.

### 5.6 Matchs

Un match suit les mêmes états qu'une séance : **Planifié** → **En cours** → **Terminé**.

### E20 — Liste des matchs

<!-- maquette:E20 -->

**Objectif** : retrouver tous les matchs, triés par date.

**Accès** : onglet **Matchs**.

**Contenu**

- Sections **À venir** (du plus proche au plus lointain) et **Passés** (du plus récent au plus ancien).
- Chaque ligne : date et heure, adversaire, Domicile / Extérieur, compétition, **score** coloré
  (vert victoire, gris nul, rouge défaite) ou état.
- **Filtre** par compétition.
- Résumé de la saison en haut : matchs joués, victoires, nuls, défaites.
- Bouton flottant **+ Nouveau match**.

**Actions** : appuyer sur un match → E23 s'il est en cours, E26 sinon ; glisser vers la gauche →
*Modifier* / *Supprimer* (mêmes règles que pour les séances).

### E21 — Nouveau match : informations

<!-- maquette:E21 -->

**Objectif** : créer un match.

**Accès** : **+ Nouveau match** (E10, E20) ; **Modifier** depuis E23 ou E26.

**Contenu**

| Élément | Type | Obligatoire | Règle |
|---|---|---|---|
| Date | Sélecteur de date | Oui | Aujourd'hui par défaut |
| Heure du coup d'envoi | Sélecteur d'heure | Oui | |
| Adversaire | Texte avec suggestions | Oui | Suggère les adversaires déjà saisis |
| Lieu | Puces : Domicile · Extérieur · Neutre | Oui | |
| Compétition | Puces : Championnat · Coupe · Amical · Tournoi | Oui | |
| Durée du match | Compteur | Oui | 90 min par défaut |
| Choisir les joueurs présents | Bouton principal | — | Enregistre et ouvre E22 |
| Enregistrer pour plus tard | Bouton secondaire | — | État *Planifié* |

**Scénario**

1. Le préparateur appuie sur **+ Nouveau match**.
2. Il saisit samedi 11 octobre, 15:00, « CA Bizertin », Extérieur, Championnat.
3. Il appuie sur **Enregistrer pour plus tard** ; le match apparaît dans « À venir ».

### E22 — Joueurs présents (feuille de match)

<!-- maquette:E22 -->

**Objectif** : indiquer les joueurs présents pour le match et qui est titulaire.

**Accès** : **Choisir les joueurs présents** (E21) ; *Démarrer* depuis E10 ou E26.

**Contenu**

- **Liste de l'effectif, tous cochés par défaut**, comme pour l'appel d'une séance (E13).
- Motif pour un joueur décoché : Non retenu · Blessé · Malade · Suspendu · Sélection · Autre.
- Pour chaque joueur coché : puces **Titulaire** / **Remplaçant** (Remplaçant par défaut).
- Compteurs : « 18 présents · **11 titulaires** · 7 remplaçants ».
- Bouton principal **Confirmer la feuille de match**.

**Règles de gestion**

- Si le nombre de titulaires est différent de 11 → avertissement « 10 titulaires sélectionnés.
  Continuer ? » (non bloquant : une équipe peut jouer à 10).
- Un joueur avec un carton rouge reçu au match précédent porte la pastille *Suspendu ?* pour
  rappel (information seulement).
- La confirmation fait passer le match à l'état **En cours**.

**Scénario**

1. Le préparateur décoche les 6 joueurs non retenus (motif *Non retenu*).
2. Il marque 11 joueurs **Titulaire** ; les 7 autres restent **Remplaçant**.
3. Il appuie sur **Confirmer la feuille de match** → E23.

### E23 — Match en cours

<!-- maquette:E23 -->

**Objectif** : enregistrer les événements du match, pendant ou après la rencontre.

**Accès** : après E22 ; depuis E10 ou E20 pour un match *En cours*.

**Contenu**

- **Tableau de score** : équipe, adversaire, score calculé à partir des buts saisis (le score de
  l'adversaire se règle avec +/−).
- **Boutons d'ajout rapide** : **⚽ But** · **🟨 Jaune** · **🟥 Rouge** · **🩹 Blessure**.
- **Chronologie** des événements, triée par minute : minute, icône, joueur (et passeur pour un but).
  Appuyer sur un événement permet de le modifier ou de le supprimer.
- **Joueurs** : titulaires puis remplaçants, avec leurs événements et un bouton ✎ **Remarque**.
- **Remarques sur le match** (✎).
- Bouton principal **Fin du match** → E25.

**Règles de gestion**

- Les événements peuvent être saisis en direct ou après le match : seule la minute compte.
- Un deuxième carton jaune pour le même joueur propose automatiquement d'ajouter le carton rouge.

**Scénario**

1. À la 23e minute, Mehdi marque sur une passe d'Ali : le préparateur appuie sur **⚽ But** (E24).
2. À la 41e, Karim reçoit un carton jaune : **🟨 Jaune**.
3. À la 67e, Youssef se blesse : **🩹 Blessure** ouvre E15 avec la minute.
4. Le score adverse est réglé à 1 avec le bouton +.
5. Au coup de sifflet final, il appuie sur **Fin du match**.

### E24 — Ajouter un événement

<!-- maquette:E24 -->

**Objectif** : saisir un but ou un carton en quelques secondes.

**Accès** : boutons ⚽, 🟨, 🟥 de E23. S'ouvre en **panneau par-dessus l'écran**.

**Contenu**

| Élément | Type | Obligatoire | Règle |
|---|---|---|---|
| Type | Puces : But · Carton jaune · Carton rouge | Oui | Pré-sélectionné selon le bouton utilisé |
| Minute | Nombre (clavier numérique) | Oui | De 1 à 130 |
| Joueur | Grille des joueurs présents (numéro + nom) | Oui | |
| Passeur décisif | Grille des joueurs présents + « Aucun » | Non | Uniquement pour un but ; le buteur n'est pas proposé |
| Remarque | Texte court | Non | Ex. « Penalty », « Coup franc » |
| Enregistrer | Bouton principal | — | |

**Scénario**

1. Le préparateur appuie sur **⚽ But**.
2. Il tape 23, choisit Mehdi (n° 9) comme buteur et Ali (n° 10) comme passeur.
3. Il appuie sur **Enregistrer** : la chronologie et le score se mettent à jour.

### E25 — Fin de match

<!-- maquette:E25 -->

**Objectif** : confirmer le score final, le temps de jeu et l'effort ressenti.

**Accès** : **Fin du match** dans E23.

**Contenu**

- **Score final** : buts de l'équipe (pré-rempli avec le nombre de buts saisis, modifiable pour un
  but contre son camp de l'adversaire) et buts de l'adversaire.
- **Temps de jeu** de chaque joueur présent (compteur +/−, clavier numérique possible) :
  - titulaire : durée du match par défaut ;
  - remplaçant : 0 par défaut (à saisir s'il est entré) ;
  - joueur exclu : la minute de son carton rouge par défaut.
- **RPE** de chaque joueur ayant joué (puces 0 à 10, facultatif).
- Remarques sur le match.
- Bouton principal **Valider le match**.

**Règles de gestion**

- Un joueur avec 0 minute n'a pas de RPE à saisir.
- La validation fait passer le match à l'état **Terminé**. Tout reste modifiable depuis E26.

**Scénario**

1. Le score 1-1 est proposé ; le préparateur confirme.
2. Il saisit 25 minutes pour Sami, entré à la 65e, et 67 minutes pour Youssef, sorti blessé.
3. Il saisit les RPE et appuie sur **Valider le match**.

### E26 — Détail d'un match

<!-- maquette:E26 -->

**Objectif** : consulter et corriger un match.

**Contenu** : informations du match, score, chronologie des événements, tableau des joueurs
(rôle, minutes, buts, passes, cartons, RPE, remarque), blessures, remarques. Menu ⋮ : *Modifier
les informations* (E21), *Modifier la feuille de match* (E22), *Modifier les événements* (E23),
*Modifier temps de jeu et RPE* (E25), *Supprimer le match*.

**Scénario** : le lundi, le préparateur corrige la minute d'entrée d'un remplaçant depuis
*Modifier temps de jeu et RPE*.

### 5.7 Infirmerie

### E27 — Infirmerie

<!-- maquette:E27 -->

**Objectif** : suivre les joueurs blessés et enregistrer leur retour.

**Accès** : carte *Infirmerie* de l'Accueil ; menu de E07.

**Contenu**

- **Blessures en cours** : joueur, zone et côté, type, gravité, date de la blessure, nombre de jours
  d'absence, date de retour prévue. Bouton **Retour du joueur**.
- **Historique** (blessures terminées) : repliable, triée de la plus récente à la plus ancienne.
- Bouton flottant **+ Blessure** (blessure survenue hors séance, ouvre E15).

**Règles de gestion** : **Retour du joueur** demande la date de retour réelle (aujourd'hui par
défaut) ; la blessure passe dans l'historique et la pastille *Blessé* disparaît.

**Scénario**

1. Karim est rétabli : le préparateur ouvre l'Infirmerie.
2. Il appuie sur **Retour du joueur** sur la ligne de Karim, confirme la date du jour.
3. Karim n'apparaît plus comme blessé.

### 5.8 Synchronisation et paramètres

### E28 — Synchronisation et paramètres

<!-- maquette:E28 -->

**Objectif** : vérifier que les données sont bien envoyées et régler l'application.

**Accès** : Profil → *Synchronisation et paramètres* ; appui sur l'indicateur de synchronisation.

**Contenu**

- **Synchronisation** : état (*À jour*, *En attente*, *Hors ligne*, *Erreur*), date et heure de la
  dernière synchronisation réussie, nombre de données en attente, bouton **Synchroniser maintenant**,
  dernier message d'erreur le cas échéant.
- **Paramètres** : thème (Clair · Sombre · Système), durée de séance par défaut, durée de match par
  défaut.
- **À propos** : version de l'application.

**Scénario**

1. Après une séance sans réseau, l'indicateur affiche « 46 en attente ».
2. De retour au club avec le Wi-Fi, la synchronisation part toute seule ; l'état passe à *À jour*.

### 5.9 Administration

Ces écrans ne sont visibles que par un **administrateur** (entrée *Administration* dans le Profil).
Ils remplacent tout envoi d'e-mail : l'administrateur crée les comptes et réinitialise les mots de
passe lui-même.

### E29 — Comptes du staff

<!-- maquette:E29 -->

**Objectif** : voir et gérer les comptes des membres du staff.

**Accès** : Profil → *Administration* (administrateurs uniquement).

**Contenu**

- **Recherche** par nom ou e-mail.
- **Liste des comptes** : initiales, prénom et nom, e-mail, fonction, pastille d'état : *Actif*,
  *Mot de passe temporaire* (pas encore changé), *Désactivé*, *Administrateur*.
- Pour chaque compte, menu ⋮ : *Réinitialiser le mot de passe* (E31), *Désactiver le compte* ou
  *Réactiver le compte*.
- Bouton flottant **+ Créer un compte** (E30).

**Règles de gestion**

- **Désactiver** un compte bloque immédiatement toute nouvelle connexion (téléphone perdu, départ du
  club). Les données saisies par ce membre sont conservées. Confirmation obligatoire.
- Un administrateur ne peut ni se désactiver ni réinitialiser son propre mot de passe ici (il
  utilise E05).
- Ces actions demandent une **connexion internet**.

**Scénario**

1. Un téléphone du staff a été perdu : l'administrateur ouvre *Administration*.
2. Il ouvre le menu ⋮ du compte concerné, appuie sur **Désactiver le compte** et confirme.
3. La pastille passe à *Désactivé*.

### E30 — Créer un compte

<!-- maquette:E30 -->

**Objectif** : créer le compte d'un membre du staff.

**Accès** : bouton **+ Créer un compte** de E29.

**Contenu**

| Élément | Type | Obligatoire | Règle |
|---|---|---|---|
| Prénom, Nom | Texte | Oui | |
| Adresse e-mail | Champ e-mail | Oui | Format valide, unique ; sert d'identifiant de connexion |
| Fonction | Liste (comme E04) | Oui | |
| Administrateur | Interrupteur | Non | Désactivé par défaut |
| Créer le compte | Bouton principal | — | |

**Règles de gestion**

- L'application **génère un mot de passe temporaire** (12 caractères) et l'affiche une seule fois
  (fenêtre de E31) ; l'utilisateur devra le changer à sa première connexion (E03).
- Aucun e-mail n'est envoyé : l'administrateur transmet lui-même l'identifiant et le mot de passe
  temporaire.

**Scénario**

1. L'administrateur appuie sur **+ Créer un compte**.
2. Il saisit « Walid Gharsalli », walid@club.tn, fonction *Entraîneur adjoint*.
3. Il appuie sur **Créer le compte** ; le mot de passe temporaire s'affiche (E31).
4. Il le transmet à Walid, qui se connecte et choisit son propre mot de passe (E03).

*Cas particulier* : e-mail déjà utilisé → « Un compte existe déjà avec cette adresse. »

### E31 — Mot de passe temporaire

<!-- maquette:E31 -->

**Objectif** : réinitialiser le mot de passe d'un membre du staff et lui transmettre le mot de passe
temporaire.

**Accès** : menu ⋮ d'un compte dans E29 → *Réinitialiser le mot de passe* ; automatiquement après la
création d'un compte (E30).

**Contenu**

- Confirmation : « Réinitialiser le mot de passe de Walid Gharsalli ? Son mot de passe actuel ne
  fonctionnera plus. » → **Réinitialiser** / **Annuler**.
- Puis fenêtre de résultat : identifiant (e-mail), **mot de passe temporaire** en grands caractères,
  boutons **Copier** et **Partager** (WhatsApp, SMS…), bouton **Terminé**.

**Règles de gestion**

- Le mot de passe temporaire est **affiché une seule fois** : il n'est stocké nulle part en clair.
- À la prochaine connexion, l'utilisateur est obligé d'en choisir un nouveau (E03).
- Les sessions déjà ouvertes de l'utilisateur sont fermées.

**Scénario**

1. Walid a oublié son mot de passe et appelle l'administrateur.
2. L'administrateur ouvre E29, menu ⋮ de Walid → **Réinitialiser le mot de passe** → confirme.
3. Le mot de passe temporaire s'affiche ; il appuie sur **Partager** et l'envoie par WhatsApp.
4. Walid se connecte avec ce mot de passe et en choisit un nouveau (E03).

---

## 6. Scénarios de bout en bout

### 6.1 Première utilisation

1. Le premier administrateur est désigné une fois pour toutes dans Supabase (par le développeur) ;
   il crée ensuite le compte du préparateur depuis l'application (E30).
2. Le préparateur installe l'application, se connecte avec son mot de passe temporaire (E01) et
   choisit son propre mot de passe (E03).
3. Il crée son équipe « Seniors A » (E06).
4. Il ajoute ses 24 joueurs à la suite avec **Enregistrer et ajouter un autre** (E09).
5. Il complète son profil (E04).

### 6.2 Une séance complète

1. Accueil → **+ Nouvelle séance** : aujourd'hui, 10:00, Physique, 90 min (E12).
2. **Démarrer l'appel** : il décoche 2 absents, avec leur motif (E13) → **Confirmer les présents (22)**.
3. Pendant la séance (E14) : il déclare la blessure de Karim (E15), ajoute une remarque sur Mehdi
   et une remarque sur la séance (E16).
4. **Terminer la séance** (E17) : il ajuste la durée de Karim et saisit les RPE → **Valider la clôture**.
5. **Questionnaire de bien-être** (E18) : chaque joueur remplit le sien sur la tablette.
6. De retour au Wi-Fi, tout est synchronisé et visible dans Power BI.

### 6.3 Un match complet

1. Le jeudi, il crée le match de samedi contre le CA Bizertin (E21) et l'enregistre pour plus tard.
2. Samedi, depuis l'Accueil, il ouvre le match et choisit les présents et les titulaires (E22).
3. Pendant le match (E23, E24) : but de Mehdi à la 23e (passe d'Ali), carton jaune de Karim à la
   41e, blessure de Youssef à la 67e (E15).
4. **Fin du match** (E25) : score 1-1, temps de jeu des remplaçants, RPE → **Valider le match**.

### 6.4 Mot de passe oublié

1. E01 → **Mot de passe oublié ?** → l'application lui indique de contacter l'administrateur (E02).
2. L'administrateur réinitialise son mot de passe (E29 → E31) et lui transmet le mot de passe temporaire.
3. Il se connecte avec ce mot de passe, en choisit un nouveau (E03) et arrive sur l'Accueil.

### 6.5 Travail sans réseau

1. Le terrain n'a pas de réseau : l'indicateur affiche *Hors ligne*.
2. Toute la séance est saisie normalement ; l'indicateur affiche « 46 en attente ».
3. De retour au Wi-Fi, la synchronisation est automatique (E28 affiche *À jour*).
4. Si deux membres du staff ont saisi le même joueur pour la même séance, **une seule ligne** est
   conservée : la dernière enregistrée.

---

## 7. Règles de validation

| Donnée | Règle |
|---|---|
| E-mail | Format valide |
| Mot de passe | 8 caractères minimum, dont au moins 1 chiffre |
| Prénom, nom | 1 à 50 caractères |
| Numéro de maillot | 1 à 99 ; avertissement si déjà pris |
| Taille | 140 à 220 cm |
| Durée prévue d'une séance | 10 à 240 min |
| Durée réelle d'un joueur | 0 à 240 min |
| Durée d'un match | 20 à 130 min |
| Temps de jeu | 0 à durée du match + 30 (prolongations) |
| Minute d'un événement | 1 à 130 |
| RPE | Entier de 0 à 10 |
| Bien-être | Entier de 1 à 5 pour chaque question |
| Heures de sommeil | 0 à 14, par pas de 0,5 |
| Remarques | 1 000 caractères maximum |
| Date de retour de blessure | Égale ou postérieure à la date de la blessure |

Une valeur hors limites est **refusée** avec un message sous le champ. Un **avertissement**
demande seulement une confirmation.

---

## 8. Critères d'acceptation de la v1

1. **Mode avion activé**, le préparateur crée une séance, fait l'appel, déclare une blessure, saisit
   les RPE et les questionnaires ; les données arrivent dans Supabase moins d'une minute après le
   retour du réseau.
2. L'appel de **24 joueurs avec 2 absents** prend **moins de 30 secondes**.
3. La saisie d'un but avec passeur prend **moins de 10 secondes**.
4. Tous les écrans sont utilisables sur un **téléphone de 360 dp de large** et une **tablette de
   10 pouces**, en portrait et en paysage, en mode clair et sombre.
5. Un administrateur crée un compte et réinitialise un mot de passe **sans aucun e-mail** ;
   l'utilisateur est obligé de remplacer le mot de passe temporaire à sa connexion suivante ;
   un compte désactivé ne peut plus se connecter.
6. Un joueur supprimé n'apparaît plus dans l'effectif ni dans les nouvelles séances, mais ses données
   passées restent dans Power BI.
7. **Power BI Desktop** se connecte à Supabase et affiche la présence, les minutes jouées, les buts et
   la charge (RPE × durée) par joueur et par semaine.

---

## 9. Points à valider avec le préparateur physique

| # | Question | Hypothèse retenue en attendant |
|---|---|---|
| Q1 | Le **RPE** n'a pas été demandé explicitement : faut-il le garder ? Il est indispensable pour calculer la charge d'entraînement dans Power BI. | Gardé, mais facultatif (E17, E25) |
| Q2 | Le questionnaire de bien-être est demandé **après** la séance. Il se remplit souvent le **matin, avant** la séance : quel moment choisir ? | Après la séance, comme demandé |
| Q3 | Faut-il suivre les **remplacements** (minute d'entrée et de sortie) pour calculer le temps de jeu automatiquement ? | Non : temps de jeu saisi à la main avec des valeurs par défaut |
| Q4 | Les autres membres du staff doivent-ils accéder à la même équipe dès la v1 ? | Non : un compte, ses équipes ; invitations en v2 |
| Q5 | Faut-il un **mode joueur verrouillé** par code pour le questionnaire ? | Non en v1 |
| Q6 | Les listes de valeurs (types de séance, zones du corps, motifs d'absence) conviennent-elles ? | Celles de ce document |
