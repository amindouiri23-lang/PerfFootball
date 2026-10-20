-- Résultats du club et photos du staff (journal du 2026-10-20).
--   1. Liste du staff : avec la photo de profil.
--   2. Photo de profil d'un membre du staff lisible par ceux qui partagent une équipe avec lui
--      (l'envoi et la suppression restent réservés à son propriétaire).
--   3. Résultats du club : matchs de toutes les équipes des clubs du compte, en lecture seule, même
--      pour une équipe à laquelle il n'est pas affecté (score, état, buteurs, cartons, changements).

-- ---------------------------------------------------------------------------
-- 1. Staff avec photo
-- ---------------------------------------------------------------------------
drop function public.team_staff(uuid);
create function public.team_staff(p_team_id uuid)
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
    and public.is_staff_member(p_team_id)
  order by p.last_name, p.first_name;
$$;
revoke execute on function public.team_staff(uuid) from public, anon;
grant execute on function public.team_staff(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 2. Lecture des photos de profil entre membres d'une même équipe
-- ---------------------------------------------------------------------------
create or replace function public.can_read_photo(p_name text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.can_access_photo(p_name) or (
    split_part(p_name, '/', 1) = 'profiles' and exists (
      select 1
      from public.team_members mine
      join public.team_members theirs on theirs.team_id = mine.team_id and not theirs.deleted
      where mine.user_id = auth.uid() and not mine.deleted
        and theirs.user_id::text || '.jpg' = split_part(p_name, '/', 2)));
$$;

drop policy "photos: read" on storage.objects;
create policy "photos: read" on storage.objects
  for select to authenticated using (bucket_id = 'photos' and public.can_read_photo(name));

-- ---------------------------------------------------------------------------
-- 3. Résultats du club
-- ---------------------------------------------------------------------------
-- Matchs des 90 derniers jours et des 30 prochains, pour les équipes dont le club est celui d'une équipe
-- du compte. Score en direct pendant le match : buts saisis (le score final est posé à la fin du match).
create or replace function public.club_results()
returns table (match_id uuid, team_name text, category text, club_name text, date date, kick_off_time time,
               opponent text, home_away text, competition text, phase text, matchday int, status text,
               goals_for int, goals_against int, forfeit_by text, events jsonb)
language sql
stable
security definer
set search_path = ''
as $$
  with my_clubs as (
    select distinct lower(trim(t.club_name)) as club
    from public.team_members m
    join public.teams t on t.id = m.team_id and not t.deleted
    where m.user_id = auth.uid() and not m.deleted and t.club_name is not null
  )
  select mt.id, t.name, t.category, t.club_name, mt.date, mt.kick_off_time, mt.opponent, mt.home_away,
         mt.competition, mt.phase, mt.matchday, mt.status,
         case when mt.status = 'in_progress'
              then (select count(*)::int from public.match_events e
                    where e.match_id = mt.id and e.type = 'goal' and not e.deleted)
              else mt.goals_for end,
         mt.goals_against, mt.forfeit_by,
         coalesce((
           select jsonb_agg(jsonb_build_object(
                    'minute', e.minute, 'type', e.type,
                    'player', p.first_name || ' ' || p.last_name,
                    'other', o.first_name || ' ' || o.last_name) order by e.minute)
           from public.match_events e
           join public.players p on p.id = e.player_id
           left join public.players o on o.id = e.assist_player_id
           where e.match_id = mt.id and not e.deleted), '[]'::jsonb)
  from public.matches mt
  join public.teams t on t.id = mt.team_id and not t.deleted
  where not mt.deleted
    and lower(trim(t.club_name)) in (select club from my_clubs)
    and mt.date between current_date - 90 and current_date + 30
  order by mt.date desc, mt.kick_off_time desc;
$$;
revoke execute on function public.club_results() from public, anon;
grant execute on function public.club_results() to authenticated;
