-- Chronomètre du match (journal du 2026-10-21) : période en cours, coup d'envoi de chaque mi-temps et temps
-- additionnel, pour afficher la minute du match en cours et le temps additionnel dans les résultats du club.
-- Les heures viennent de l'appareil qui lance le chrono ; chaque appareil calcule la minute à partir d'elles.
alter table public.matches
  add column period text check (period in ('first_half', 'half_time', 'second_half', 'finished')),
  add column first_half_started_at timestamptz,
  add column second_half_started_at timestamptz,
  add column added_time_1 int check (added_time_1 between 0 and 30),
  add column added_time_2 int check (added_time_2 between 0 and 30);

-- Résultats du club : les mêmes champs, pour la minute en direct et le temps additionnel.
drop function public.club_results();
create function public.club_results()
returns table (match_id uuid, team_name text, category text, club_name text, date date, kick_off_time time,
               opponent text, home_away text, competition text, phase text, matchday int, status text,
               goals_for int, goals_against int, forfeit_by text, events jsonb,
               duration_min int, period text, first_half_started_at timestamptz,
               second_half_started_at timestamptz, added_time_1 int, added_time_2 int)
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
           where e.match_id = mt.id and not e.deleted), '[]'::jsonb),
         mt.duration_min, mt.period, mt.first_half_started_at, mt.second_half_started_at,
         mt.added_time_1, mt.added_time_2
  from public.matches mt
  join public.teams t on t.id = mt.team_id and not t.deleted
  where not mt.deleted
    and lower(trim(t.club_name)) in (select club from my_clubs)
    and mt.date between current_date - 90 and current_date + 30
  order by mt.date desc, mt.kick_off_time desc;
$$;
revoke execute on function public.club_results() from public, anon;
grant execute on function public.club_results() to authenticated;
