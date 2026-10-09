-- Schéma v1 — voir docs/01-architecture-and-rules.md §4 et §5.
-- Règles : UUID générés sur l'appareil, suppression logique (deleted), données brutes uniquement,
-- server_updated_at posé par le serveur (curseur de synchronisation).

-- ---------------------------------------------------------------------------
-- Colonnes techniques communes
-- ---------------------------------------------------------------------------
create or replace function public.set_server_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.server_updated_at := now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Comptes et équipe
-- ---------------------------------------------------------------------------
create table public.staff_profiles (
  id                uuid primary key references auth.users (id) on delete cascade,
  first_name        text not null check (char_length(first_name) between 1 and 50),
  last_name         text not null check (char_length(last_name) between 1 and 50),
  job_title         text not null check (job_title in ('fitness_coach', 'head_coach', 'assistant_coach', 'physio', 'doctor', 'other')),
  phone             text,
  photo_path        text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false
);

create table public.teams (
  id                uuid primary key,
  name              text not null check (char_length(name) between 1 and 60),
  club_name         text,
  category          text not null check (category in ('seniors', 'u21', 'u19', 'u17', 'u15', 'other')),
  season            text not null check (season ~ '^\d{4}-\d{4}$'),
  logo_path         text,
  created_by        uuid not null default auth.uid() references auth.users (id),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false
);

-- Écrite uniquement par le serveur (déclencheur à la création d'une équipe) : lecture seule pour l'app.
create table public.team_members (
  id                uuid primary key default gen_random_uuid(),
  team_id           uuid not null references public.teams (id),
  user_id           uuid not null references auth.users (id) on delete cascade,
  role              text not null check (role in ('owner', 'staff')),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  unique (team_id, user_id)
);

create table public.players (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  first_name        text not null check (char_length(first_name) between 1 and 50),
  last_name         text not null check (char_length(last_name) between 1 and 50),
  shirt_number      int check (shirt_number between 1 and 99),
  position          text not null check (position in ('GK', 'DEF', 'MID', 'FWD')),
  birth_date        date,
  dominant_foot     text check (dominant_foot in ('L', 'R', 'B')),
  height_cm         int check (height_cm between 140 and 220),
  photo_path        text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  unique (id, team_id)          -- cible des clés étrangères composées : un joueur reste dans son équipe
);

-- ---------------------------------------------------------------------------
-- Séances
-- ---------------------------------------------------------------------------
create table public.sessions (
  id                   uuid primary key,
  team_id              uuid not null references public.teams (id),
  date                 date not null,
  start_time           time not null,
  type                 text not null check (type in ('technical', 'tactical', 'physical', 'mixed', 'recovery', 'gym', 'other')),
  planned_duration_min int not null default 90 check (planned_duration_min between 10 and 240),
  objective            text,
  remarks              text check (char_length(remarks) <= 1000),
  status               text not null default 'planned' check (status in ('planned', 'in_progress', 'completed')),
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  server_updated_at    timestamptz not null default now(),
  deleted              boolean not null default false,
  unique (id, team_id)
);

create table public.session_players (
  id                uuid primary key,                 -- UUID v5(session_id + player_id)
  team_id           uuid not null references public.teams (id),
  session_id        uuid not null,
  player_id         uuid not null,
  present           boolean not null default true,
  absence_reason    text check (absence_reason in ('injured', 'sick', 'national_team', 'personal', 'other')),
  duration_min      int check (duration_min between 0 and 240),
  rpe               int check (rpe between 0 and 10),
  remark            text check (char_length(remark) <= 1000),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  unique (session_id, player_id),
  foreign key (session_id, team_id) references public.sessions (id, team_id),
  foreign key (player_id, team_id) references public.players (id, team_id),
  check (not present or absence_reason is null)
);

create table public.wellness (
  id                uuid primary key,                 -- UUID v5(session_id + player_id)
  team_id           uuid not null references public.teams (id),
  session_id        uuid not null,
  player_id         uuid not null,
  sleep_hours       numeric(3, 1) not null check (sleep_hours between 0 and 14 and sleep_hours * 2 = trunc(sleep_hours * 2)),
  sleep_quality     int not null check (sleep_quality between 1 and 5),
  fatigue           int not null check (fatigue between 1 and 5),
  soreness          int not null check (soreness between 1 and 5),
  stress            int not null check (stress between 1 and 5),
  mood              int not null check (mood between 1 and 5),
  remark            text check (char_length(remark) <= 1000),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  unique (session_id, player_id),
  foreign key (session_id, team_id) references public.sessions (id, team_id),
  foreign key (player_id, team_id) references public.players (id, team_id)
);

-- ---------------------------------------------------------------------------
-- Matchs
-- ---------------------------------------------------------------------------
create table public.matches (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  date              date not null,
  kick_off_time     time not null,
  opponent          text not null check (char_length(opponent) between 1 and 80),
  home_away         text not null check (home_away in ('H', 'A', 'N')),
  competition       text not null check (competition in ('league', 'cup', 'friendly', 'tournament')),
  duration_min      int not null default 90 check (duration_min between 20 and 130),
  goals_for         int check (goals_for >= 0),
  goals_against     int check (goals_against >= 0),
  remarks           text check (char_length(remarks) <= 1000),
  status            text not null default 'planned' check (status in ('planned', 'in_progress', 'completed')),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  unique (id, team_id)
);

create table public.match_players (
  id                uuid primary key,                 -- UUID v5(match_id + player_id)
  team_id           uuid not null references public.teams (id),
  match_id          uuid not null,
  player_id         uuid not null,
  present           boolean not null default true,
  absence_reason    text check (absence_reason in ('not_selected', 'injured', 'sick', 'suspended', 'national_team', 'other')),
  role              text check (role in ('starter', 'sub')),
  minutes_played    int check (minutes_played between 0 and 160),
  rpe               int check (rpe between 0 and 10),
  remark            text check (char_length(remark) <= 1000),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  unique (match_id, player_id),
  foreign key (match_id, team_id) references public.matches (id, team_id),
  foreign key (player_id, team_id) references public.players (id, team_id),
  check (not present or absence_reason is null)
);

create table public.match_events (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  match_id          uuid not null,
  player_id         uuid not null,
  type              text not null check (type in ('goal', 'yellow_card', 'red_card')),
  minute            int not null check (minute between 1 and 130),
  assist_player_id  uuid,
  remark            text check (char_length(remark) <= 200),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  foreign key (match_id, team_id) references public.matches (id, team_id),
  foreign key (player_id, team_id) references public.players (id, team_id),
  foreign key (assist_player_id, team_id) references public.players (id, team_id),
  check (assist_player_id is null or (type = 'goal' and assist_player_id <> player_id))
);

-- ---------------------------------------------------------------------------
-- Blessures
-- ---------------------------------------------------------------------------
create table public.injuries (
  id                   uuid primary key,
  team_id              uuid not null references public.teams (id),
  player_id            uuid not null,
  session_id           uuid,
  match_id             uuid,
  minute               int check (minute between 1 and 130),
  date                 date not null,
  body_area            text not null check (body_area in ('head', 'neck', 'shoulder', 'arm', 'back', 'hip_groin', 'thigh_front', 'thigh_back', 'knee', 'calf', 'ankle', 'foot', 'other')),
  side                 text check (side in ('left', 'right', 'both')),
  type                 text not null check (type in ('muscle', 'ligament', 'bone', 'contusion', 'tendon', 'other')),
  mechanism            text not null check (mechanism in ('contact', 'non_contact', 'overuse')),
  severity             text not null check (severity in ('minor', 'moderate', 'severe')),
  description          text check (char_length(description) <= 1000),
  expected_return_date date,
  return_date          date,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  server_updated_at    timestamptz not null default now(),
  deleted              boolean not null default false,
  foreign key (player_id, team_id) references public.players (id, team_id),
  foreign key (session_id, team_id) references public.sessions (id, team_id),
  foreign key (match_id, team_id) references public.matches (id, team_id),
  check (session_id is null or match_id is null),
  check (minute is null or match_id is not null),
  check (return_date is null or return_date >= date)
);

-- ---------------------------------------------------------------------------
-- Déclencheurs server_updated_at + index de synchronisation
-- ---------------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['staff_profiles', 'teams', 'team_members', 'players', 'sessions', 'session_players',
                           'wellness', 'matches', 'match_players', 'match_events', 'injuries']
  loop
    execute format('create trigger set_server_updated_at before insert or update on public.%I
                    for each row execute function public.set_server_updated_at()', t);
    execute format('create index %I on public.%I (server_updated_at)', t || '_server_updated_at_idx', t);
  end loop;
end;
$$;

create index on public.team_members (user_id);
create index on public.players (team_id);
create index on public.sessions (team_id, date);
create index on public.matches (team_id, date);
create index on public.session_players (team_id);
create index on public.wellness (team_id);
create index on public.match_players (team_id);
create index on public.match_events (team_id, match_id);
create index on public.injuries (team_id, player_id);

-- ---------------------------------------------------------------------------
-- Le créateur d'une équipe en devient propriétaire
-- ---------------------------------------------------------------------------
create or replace function public.add_team_owner()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.team_members (team_id, user_id, role)
  values (new.id, new.created_by, 'owner')
  on conflict (team_id, user_id) do nothing;
  return new;
end;
$$;

create trigger add_team_owner after insert on public.teams
for each row execute function public.add_team_owner();
