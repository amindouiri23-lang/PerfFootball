-- Comptes (journal du 2026-10-22) : l'administrateur peut supprimer un compte, en plus de le désactiver ;
-- un compte désactivé n'apparaît plus dans le staff de l'équipe.

-- 1. Staff de l'équipe : sans les comptes désactivés (réactivés, ils réapparaissent).
create or replace function public.team_staff(p_team_id uuid)
returns table (user_id uuid, first_name text, last_name text, app_role text, member_role text, disabled boolean,
               photo_path text)
language sql
stable
security definer
set search_path = ''
as $$
  select m.user_id, p.first_name, p.last_name,
         coalesce(u.raw_app_meta_data ->> 'role', 'observer'), m.role,
         coalesce(u.banned_until > now(), false), p.photo_path
  from public.team_members m
  join auth.users u on u.id = m.user_id
  left join public.staff_profiles p on p.id = m.user_id
  where m.team_id = p_team_id
    and not m.deleted
    and m.role <> 'player'
    and coalesce(u.raw_app_meta_data ->> 'role', '') <> 'player'
    and not coalesce(u.banned_until > now(), false)
    and public.is_staff_member(p_team_id)
  order by p.last_name, p.first_name;
$$;

-- 2. Suppression d'un compte (fonction admin-users, action « delete ») : le profil, les appartenances et les
-- exceptions de permissions partent avec lui (on delete cascade). Deux références n'ont pas de cascade et
-- bloqueraient la suppression ; elles gardent l'identifiant sans contrainte :
--   teams.created_by          : l'équipe reste, son créateur n'est qu'un historique ;
--   session_comments.author_id : le commentaire reste, signé par author_name.
alter table public.teams drop constraint teams_created_by_fkey;
alter table public.session_comments drop constraint session_comments_author_id_fkey;
