-- Tableau de bord dans l'application (journal du 2026-10-22) : les pages du rapport Power BI (vue d'ensemble,
-- charge et ACWR, bien-être, matchs, blessures) calculées sur l'appareil, exportables en PDF et en Excel.
-- Les données viennent de la base locale, déjà filtrée par les droits de lecture : les permissions ne gouvernent
-- que l'écran et l'export. Bien-être et blessures suivent en plus « Bien-être / Voir » et « Blessures / Voir ».
--   analyse.view   : tout le staff (l'audience du rapport Power BI) ;
--   analyse.export : directeur technique, entraîneur principal, préparateur physique — les autres rôles
--                    consultent sans pouvoir faire sortir les données de l'application (réglable dans la matrice).
insert into public.role_permissions (role, permission, allowed) values
  ('technical_director', 'analyse.view', true),
  ('head_coach',         'analyse.view', true),
  ('fitness_coach',      'analyse.view', true),
  ('assistant_coach',    'analyse.view', true),
  ('medical',            'analyse.view', true),
  ('observer',           'analyse.view', true),
  ('technical_director', 'analyse.export', true),
  ('head_coach',         'analyse.export', true),
  ('fitness_coach',      'analyse.export', true),
  ('assistant_coach',    'analyse.export', false),
  ('medical',            'analyse.export', false),
  ('observer',           'analyse.export', false)
on conflict (role, permission) do nothing;
