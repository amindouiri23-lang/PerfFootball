-- Staff d'une équipe : chaque compte affecté à l'équipe (hors comptes joueurs), avec son rôle.
-- Les profils du staff ne sont lisibles que par leur propriétaire (staff_profiles) : cette fonction
-- n'expose que le nom et le rôle, et seulement aux membres de l'équipe.
create or replace function public.team_staff(p_team_id uuid)
returns table (user_id uuid, first_name text, last_name text, app_role text, member_role text, disabled boolean)
language sql
stable
security definer
set search_path = ''
as $$
  select m.user_id, p.first_name, p.last_name,
         coalesce(u.raw_app_meta_data ->> 'role', 'observer'), m.role,
         coalesce(u.banned_until > now(), false)
  from public.team_members m
  join auth.users u on u.id = m.user_id
  left join public.staff_profiles p on p.id = m.user_id
  where m.team_id = p_team_id
    and not m.deleted
    and m.role <> 'player'
    and coalesce(u.raw_app_meta_data ->> 'role', '') <> 'player'
    and public.is_staff_member(p_team_id)
  order by p.last_name, p.first_name;
$$;

revoke execute on function public.team_staff(uuid) from public, anon;
grant execute on function public.team_staff(uuid) to authenticated;
