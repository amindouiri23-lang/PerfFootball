-- Vues de lecture pour Power BI — schéma reporting, rôle en lecture seule powerbi_reader.
-- Les vues excluent les lignes supprimées, sauf les joueurs (un joueur supprimé garde son
-- historique : la colonne is_deleted permet de le filtrer dans les rapports).
-- Les vues appartiennent au propriétaire du schéma et ne passent donc pas par la RLS :
-- powerbi_reader voit toutes les équipes du projet (un seul club).
--
-- Activer la connexion (une fois, dans l'éditeur SQL de Supabase, jamais dans une migration) :
--   alter role powerbi_reader with login password '<mot de passe de POWERBI_DB_PASSWORD>';

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'powerbi_reader') then
    create role powerbi_reader nologin;
  end if;
end;
$$;

create schema reporting;

create view reporting.teams as
select id, name, club_name, category, season
from public.teams
where not deleted;

create view reporting.players as
select p.id, p.team_id, p.first_name, p.last_name, p.first_name || ' ' || p.last_name as full_name,
       p.shirt_number, p.position, p.birth_date, p.dominant_foot, p.height_cm, p.deleted as is_deleted
from public.players p;

create view reporting.sessions as
select id, team_id, date, start_time, type, planned_duration_min, objective, remarks, status
from public.sessions
where not deleted;

create view reporting.session_players as
select sp.id, sp.team_id, sp.session_id, sp.player_id, s.date, s.type as session_type, s.status as session_status,
       sp.present, sp.absence_reason, sp.duration_min, sp.rpe, sp.remark
from public.session_players sp
join public.sessions s on s.id = sp.session_id
where not sp.deleted and not s.deleted;

create view reporting.wellness as
select w.id, w.team_id, w.session_id, w.player_id, s.date,
       w.sleep_hours, w.sleep_quality, w.fatigue, w.soreness, w.stress, w.mood,
       w.sleep_quality + w.fatigue + w.soreness + w.stress + w.mood as total_score,
       w.remark
from public.wellness w
join public.sessions s on s.id = w.session_id
where not w.deleted and not s.deleted;

create view reporting.matches as
select id, team_id, date, kick_off_time, opponent, home_away, competition, duration_min,
       goals_for, goals_against,
       case when goals_for > goals_against then 'W' when goals_for < goals_against then 'L'
            when goals_for is not null and goals_against is not null then 'D' end as result,
       remarks, status
from public.matches
where not deleted;

create view reporting.match_players as
select mp.id, mp.team_id, mp.match_id, mp.player_id, m.date, m.opponent, m.competition,
       mp.present, mp.absence_reason, mp.role, mp.minutes_played, mp.rpe, mp.remark
from public.match_players mp
join public.matches m on m.id = mp.match_id
where not mp.deleted and not m.deleted;

create view reporting.match_events as
select e.id, e.team_id, e.match_id, m.date, e.player_id, e.type, e.minute, e.assist_player_id, e.remark
from public.match_events e
join public.matches m on m.id = e.match_id
where not e.deleted and not m.deleted;

create view reporting.injuries as
select i.id, i.team_id, i.player_id, i.session_id, i.match_id, i.minute, i.date,
       i.body_area, i.side, i.type, i.mechanism, i.severity, i.description,
       i.expected_return_date, i.return_date,
       i.return_date is null as is_open,
       coalesce(i.return_date, current_date) - i.date as days_out
from public.injuries i
where not i.deleted;

grant usage on schema reporting to powerbi_reader;
grant select on all tables in schema reporting to powerbi_reader;
