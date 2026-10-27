-- Séance de visionnage, mise en page (journal du 2026-10-27) : position, taille et style du texte d'une
-- diapositive, et images posées dessus (chemin dans le stockage photos, position, largeur). JSON écrit par
-- l'application ; texte et non jsonb pour passer tel quel par la synchronisation.
-- Les images sont rangées sous teams/<team_id>/viewing/… : la règle d'accès au stockage existante
-- (membres de l'équipe) s'applique.
alter table public.viewing_slides add column layout text check (char_length(layout) <= 20000);
