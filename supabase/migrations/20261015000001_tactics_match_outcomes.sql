-- v3 — issues de match et tactiques (journal du 2026-10-15) :
--   1. un match peut finir en forfait (3-0 sur tapis vert), être reporté, annulé ou arrêté ;
--   2. bibliothèque de tactiques (coups de pied arrêtés, situations personnalisées) liée aux séances et aux matchs.
-- Migration additive : aucune donnée existante n'est modifiée.

-- ---------------------------------------------------------------------------
-- 1. Issues de match
-- ---------------------------------------------------------------------------
-- forfeit   : score imposé (3-0 ou 0-3), compte au bilan, aucun temps de jeu ;
-- postponed : reporté, nouvelle date pas encore connue ; cancelled : annulé, hors statistiques ;
-- abandoned : arrêté en cours de jeu, score et minutes jouées jusqu'à l'arrêt, hors bilan.
alter table public.matches drop constraint matches_status_check;
alter table public.matches add constraint matches_status_check
  check (status in ('planned', 'in_progress', 'completed', 'forfeit', 'postponed', 'cancelled', 'abandoned'));

-- Équipe déclarée forfait : us (défaite 0-3) ou opponent (victoire 3-0).
alter table public.matches
  add column forfeit_by text check (forfeit_by in ('us', 'opponent')),
  add constraint matches_forfeit_by_check2 check ((status = 'forfeit') = (forfeit_by is not null));

-- ---------------------------------------------------------------------------
-- 2. Tactiques
-- ---------------------------------------------------------------------------
-- board : JSON du tableau (pions et flèches, positions en fraction du terrain affiché) écrit par
-- l'application ; texte et non jsonb pour passer tel quel par la synchronisation.
create table public.tactics (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  name              text not null check (char_length(name) between 1 and 60),
  kind              text not null check (kind in ('corner', 'free_kick', 'penalty', 'throw_in', 'kick_off', 'custom')),
  side              text not null check (side in ('attack', 'defense')),
  pitch             text not null default 'half' check (pitch in ('half', 'full')),
  board             text not null default '{}' check (char_length(board) <= 50000),
  notes             text check (char_length(notes) <= 1000),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  unique (id, team_id)
);

-- Tactique travaillée en séance ou prévue pour un match. id déterministe : uuidv5(NS, 'tactic:session|match').
create table public.tactic_links (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  tactic_id         uuid not null,
  session_id        uuid,
  match_id          uuid,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  check (num_nonnulls(session_id, match_id) = 1),
  foreign key (tactic_id, team_id) references public.tactics (id, team_id),
  foreign key (session_id, team_id) references public.sessions (id, team_id),
  foreign key (match_id, team_id) references public.matches (id, team_id)
);

do $$
declare
  t text;
begin
  foreach t in array array['tactics', 'tactic_links']
  loop
    execute format('create trigger set_server_updated_at before insert or update on public.%I
                    for each row execute function public.set_server_updated_at()', t);
    execute format('create index %I on public.%I (server_updated_at)', t || '_server_updated_at_idx', t);
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy "team data: read" on public.%I for select to authenticated
                    using (public.is_team_member(team_id))', t);
    execute format('create policy "team data: create" on public.%I for insert to authenticated
                    with check (public.is_team_member(team_id))', t);
    execute format('create policy "team data: update" on public.%I for update to authenticated
                    using (public.is_team_member(team_id)) with check (public.is_team_member(team_id))', t);
  end loop;
end;
$$;

create index on public.tactics (team_id);
create index on public.tactic_links (tactic_id);

revoke all on public.tactics, public.tactic_links from anon;
revoke delete, truncate on public.tactics, public.tactic_links from authenticated;

-- ---------------------------------------------------------------------------
-- Vue Power BI : le résultat ne compte que les matchs joués jusqu'au bout et les forfaits.
-- ---------------------------------------------------------------------------
create or replace view reporting.matches as
select id, team_id, date, kick_off_time, opponent, home_away, competition, duration_min,
       goals_for, goals_against,
       case when status not in ('completed', 'forfeit') then null
            when goals_for > goals_against then 'W' when goals_for < goals_against then 'L'
            when goals_for is not null and goals_against is not null then 'D' end as result,
       remarks, status, phase, matchday, forfeit_by
from public.matches
where not deleted;
