-- v2 — données des fichiers Excel du club (docs/01-architecture-and-rules.md §5.7 et journal du 2026-10-14) :
--   1. charge prévue, motifs d'absence, postes détaillés, phase et journée de championnat ;
--   2. tests physiques et mesures corporelles (format long : un résultat par ligne et par essai) ;
--   3. dossier du joueur (administratif) et dossier médical (lecture réservée au propriétaire de l'équipe).
-- Migration additive : aucune donnée existante n'est modifiée.

-- ---------------------------------------------------------------------------
-- 1. Séances, présence, joueurs, matchs
-- ---------------------------------------------------------------------------
-- RPE visé par l'entraîneur : charge prévue = planned_duration_min × planned_rpe (calculée, jamais stockée).
alter table public.sessions add column planned_rpe int check (planned_rpe between 0 and 10);

-- rest : repos prescrit ; other_team : présent avec une autre équipe du club (ex. séance avec les seniors).
alter table public.session_players drop constraint session_players_absence_reason_check;
alter table public.session_players add constraint session_players_absence_reason_check
  check (absence_reason in ('injured', 'sick', 'national_team', 'personal', 'rest', 'other_team', 'other'));
alter table public.match_players drop constraint match_players_absence_reason_check;
alter table public.match_players add constraint match_players_absence_reason_check
  check (absence_reason in ('not_selected', 'injured', 'sick', 'suspended', 'national_team', 'rest', 'other_team', 'other'));

-- Poste précis (le poste large GK/DEF/MID/FWD reste obligatoire et sert aux regroupements).
alter table public.players
  add column detailed_position text check (detailed_position in ('GK', 'CB', 'RB', 'LB', 'DM', 'CM', 'AM', 'RW', 'LW', 'ST')),
  add column secondary_position text check (secondary_position in ('GK', 'CB', 'RB', 'LB', 'DM', 'CM', 'AM', 'RW', 'LW', 'ST'));

alter table public.matches
  add column phase text check (phase in ('first_leg', 'second_leg')),
  add column matchday int check (matchday between 1 and 60);

-- ---------------------------------------------------------------------------
-- 2. Tests physiques et mesures corporelles
-- ---------------------------------------------------------------------------
-- Catalogue : team_id null = test commun à toutes les équipes (écrit ici, lecture seule pour l'application) ;
-- team_id renseigné = test ajouté par une équipe.
create table public.test_types (
  id                uuid primary key,
  team_id           uuid references public.teams (id),
  code              text check (char_length(code) between 1 and 40),
  name              text not null check (char_length(name) between 1 and 60),
  unit              text check (char_length(unit) <= 10),
  category          text not null check (category in ('anthropometry', 'endurance', 'speed', 'agility', 'power', 'strength', 'other')),
  better            text not null check (better in ('higher', 'lower', 'none')),
  attempts          int not null default 1 check (attempts between 1 and 5),
  sort_order        int not null default 100,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false
);

-- Un résultat par joueur, test, jour et essai. id déterministe : uuidv5(NS, 'player:test_type:date:attempt').
create table public.test_results (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  player_id         uuid not null,
  test_type_id      uuid not null references public.test_types (id),
  date              date not null,
  attempt           int not null default 1 check (attempt between 1 and 5),
  value             numeric(8, 2) not null check (value >= 0),
  remark            text check (char_length(remark) <= 200),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  unique (player_id, test_type_id, date, attempt),
  foreign key (player_id, team_id) references public.players (id, team_id)
);

-- Tests du fichier de tests des Juniors du club. Identifiants fixes : uuidv5(NS, 'test_type:<code>').
insert into public.test_types (id, code, name, unit, category, better, attempts, sort_order) values
  ('e381c526-72ae-5e74-90ab-0da3c3ff9b3c', 'height_cm',        'Taille',                   'cm',   'anthropometry', 'none',   1, 10),
  ('87cd6fc0-da33-5b95-ba54-35b9e4ee80aa', 'weight_kg',        'Poids',                    'kg',   'anthropometry', 'none',   1, 20),
  ('6fc5ce6e-0764-5a21-8d5b-fbda7e4ef34d', 'lean_mass_kg',     'Masse maigre',             'kg',   'anthropometry', 'higher', 1, 30),
  ('f1cc60c1-87b3-5400-8820-196f100623d4', 'fat_mass_kg',      'Masse grasse',             'kg',   'anthropometry', 'lower',  1, 40),
  ('a2de4490-b2f7-5cc5-9dd7-347aa49389c8', 'yoyo_distance_m',  'Yo-Yo test (distance)',    'm',    'endurance',     'higher', 1, 50),
  ('d21c6e00-7b01-58d3-8286-4486015219bf', 'vma_kmh',          'VMA',                      'km/h', 'endurance',     'higher', 1, 60),
  ('9d447547-a4be-529f-907a-8ab003a3431a', 'sprint_5m_s',      'Sprint 5 m',               's',    'speed',         'lower',  2, 70),
  ('3cb19baf-40f7-52d3-bddd-a1dd7f1e20e4', 'sprint_20m_s',     'Sprint 20 m',              's',    'speed',         'lower',  2, 80),
  ('b5443575-01fa-594a-a141-bf885d590e17', 'sprint_30m_s',     'Sprint 30 m',              's',    'speed',         'lower',  2, 90),
  ('7bac95cb-ad29-5d92-be8b-9d15adf44184', 'mujika_s',         'Mujika sans ballon',       's',    'agility',       'lower',  2, 100),
  ('d48d4bf3-8275-59f1-821a-8964c7a4eca9', 'mujika_ball_s',    'Mujika avec ballon',       's',    'agility',       'lower',  2, 110),
  ('6862b990-6091-5ab5-bb9f-339b3fae999f', 'mujika_ball_goal', 'Mujika avec ballon (but)', '0/1',  'agility',       'higher', 2, 120),
  ('e12c6b99-f925-5d77-b5a5-636ffa11989a', 'cmj_cm',           'CMJ',                      'cm',   'power',         'higher', 2, 130),
  ('2845ef44-d325-5b8d-96c4-63cd79d4d520', 'five_jump_m',      '5 bonds (5JT)',            'm',    'power',         'higher', 2, 140),
  ('1f3ea9ff-8cb1-5614-977c-4c29bb5d6aa7', 'lumbar_strength',  'Force lombaire',           null,   'strength',      'higher', 2, 150);

-- ---------------------------------------------------------------------------
-- 3. Dossier du joueur : administratif et médical (une ligne par joueur, id = player_id)
-- ---------------------------------------------------------------------------
create table public.player_profiles (
  id                     uuid primary key,
  team_id                uuid not null references public.teams (id),
  player_id              uuid not null unique,
  nationality            text check (char_length(nationality) <= 60),
  birth_place            text check (char_length(birth_place) <= 80),
  phone                  text check (char_length(phone) <= 30),
  email                  text check (char_length(email) <= 120),
  address                text check (char_length(address) <= 200),
  school                 text check (char_length(school) <= 120),
  school_year            text check (char_length(school_year) <= 80),
  father_name            text check (char_length(father_name) <= 80),
  father_nationality     text check (char_length(father_nationality) <= 60),
  father_occupation      text check (char_length(father_occupation) <= 80),
  father_marital_status  text check (char_length(father_marital_status) <= 40),
  mother_name            text check (char_length(mother_name) <= 80),
  mother_nationality     text check (char_length(mother_nationality) <= 60),
  mother_marital_status  text check (char_length(mother_marital_status) <= 40),
  previous_club          text check (char_length(previous_club) <= 80),
  previous_club_city     text check (char_length(previous_club_city) <= 80),
  years_training         int check (years_training between 0 and 40),
  preferred_role         text check (char_length(preferred_role) <= 80),
  remarks                text check (char_length(remarks) <= 1000),
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  server_updated_at      timestamptz not null default now(),
  deleted                boolean not null default false,
  check (id = player_id),
  foreign key (player_id, team_id) references public.players (id, team_id)
);

-- Données de santé : saisie seulement avec le consentement du joueur (ou d'un parent s'il est mineur).
create table public.player_medical (
  id                   uuid primary key,
  team_id              uuid not null references public.teams (id),
  player_id            uuid not null unique,
  consent_date         date not null,
  consent_by           text not null check (consent_by in ('player', 'guardian')),
  allergies            text check (char_length(allergies) <= 500),
  conditions           text check (char_length(conditions) <= 500),
  low_bp_anxiety       text check (char_length(low_bp_anxiety) <= 500),
  surgeries            text check (char_length(surgeries) <= 500),
  recent_injuries      text check (char_length(recent_injuries) <= 1000),
  remarks              text check (char_length(remarks) <= 1000),
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  server_updated_at    timestamptz not null default now(),
  deleted              boolean not null default false,
  check (id = player_id),
  foreign key (player_id, team_id) references public.players (id, team_id)
);

-- ---------------------------------------------------------------------------
-- Déclencheurs, index, sécurité
-- ---------------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['test_types', 'test_results', 'player_profiles', 'player_medical']
  loop
    execute format('create trigger set_server_updated_at before insert or update on public.%I
                    for each row execute function public.set_server_updated_at()', t);
    execute format('create index %I on public.%I (server_updated_at)', t || '_server_updated_at_idx', t);
    execute format('alter table public.%I enable row level security', t);
  end loop;
end;
$$;

create index on public.test_types (team_id);
create index on public.test_results (team_id, date);
create index on public.player_profiles (team_id);
create index on public.player_medical (team_id);

revoke all on public.test_types, public.test_results, public.player_profiles, public.player_medical from anon;
revoke delete, truncate on public.test_types, public.test_results, public.player_profiles, public.player_medical from authenticated;

-- Catalogue : tests communs lisibles par tous ; tests d'équipe lisibles et modifiables par ses membres.
create policy "test types: read" on public.test_types for select to authenticated
  using (team_id is null or public.is_team_member(team_id));
create policy "test types: create" on public.test_types for insert to authenticated
  with check (team_id is not null and public.is_team_member(team_id));
create policy "test types: update" on public.test_types for update to authenticated
  using (team_id is not null and public.is_team_member(team_id))
  with check (team_id is not null and public.is_team_member(team_id));

do $$
declare
  t text;
begin
  foreach t in array array['test_results', 'player_profiles']
  loop
    execute format('create policy "team data: read" on public.%I for select to authenticated
                    using (public.is_team_member(team_id))', t);
    execute format('create policy "team data: create" on public.%I for insert to authenticated
                    with check (public.is_team_member(team_id))', t);
    execute format('create policy "team data: update" on public.%I for update to authenticated
                    using (public.is_team_member(team_id)) with check (public.is_team_member(team_id))', t);
  end loop;
end;
$$;

-- Dossier médical : propriétaire de l'équipe uniquement. Quand les invitations du staff existeront,
-- un rôle « médical » s'ajoutera ici — jamais un accès ouvert à tous les membres.
create or replace function public.is_team_owner(p_team_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members m
    where m.team_id = p_team_id
      and m.user_id = auth.uid()
      and m.role = 'owner'
      and not m.deleted
  );
$$;

create policy "medical: read" on public.player_medical for select to authenticated
  using (public.is_team_owner(team_id));
create policy "medical: create" on public.player_medical for insert to authenticated
  with check (public.is_team_owner(team_id));
create policy "medical: update" on public.player_medical for update to authenticated
  using (public.is_team_owner(team_id)) with check (public.is_team_owner(team_id));

-- ---------------------------------------------------------------------------
-- Vues Power BI : nouvelles colonnes ajoutées en fin de vue ; dossiers administratif et médical exclus.
-- ---------------------------------------------------------------------------
create or replace view reporting.players as
select p.id, p.team_id, p.first_name, p.last_name, p.first_name || ' ' || p.last_name as full_name,
       p.shirt_number, p.position, p.birth_date, p.dominant_foot, p.height_cm, p.deleted as is_deleted,
       p.detailed_position, p.secondary_position
from public.players p;

create or replace view reporting.sessions as
select id, team_id, date, start_time, type, planned_duration_min, objective, remarks, status, planned_rpe
from public.sessions
where not deleted;

create or replace view reporting.matches as
select id, team_id, date, kick_off_time, opponent, home_away, competition, duration_min,
       goals_for, goals_against,
       case when goals_for > goals_against then 'W' when goals_for < goals_against then 'L'
            when goals_for is not null and goals_against is not null then 'D' end as result,
       remarks, status, phase, matchday
from public.matches
where not deleted;

create view reporting.test_results as
select r.id, r.team_id, r.player_id, r.date, r.attempt, r.value, r.remark,
       t.id as test_type_id, t.code as test_code, t.name as test_name, t.unit, t.category, t.better
from public.test_results r
join public.test_types t on t.id = r.test_type_id
where not r.deleted and not t.deleted;

grant select on all tables in schema reporting to powerbi_reader;
