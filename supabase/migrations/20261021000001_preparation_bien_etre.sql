-- v5 — préparation des séances et des matchs, bien-être indépendant des séances, comptes joueurs
-- (journal du 2026-10-21).
--   1. Match : dispositif (4-4-2…) et place de chaque titulaire dans le dispositif.
--   2. Séance : exercices (nom, description, durée, tactique) et commentaires du staff (directeur technique…).
--   3. Questionnaire de bien-être lancé seul, pour une liste de joueurs choisis ; le joueur y répond depuis
--      son compte, et donne aussi son RPE de match.

-- ---------------------------------------------------------------------------
-- 1. Composition du match
-- ---------------------------------------------------------------------------
alter table public.matches
  add column formation text check (formation in ('4-4-2', '4-3-3', '4-2-3-1', '4-1-4-1', '3-5-2', '3-4-3', '5-3-2', '5-4-1'));
-- Place du titulaire dans le dispositif (0 = gardien … 10).
alter table public.match_players add column slot int check (slot between 0 and 10);

-- ---------------------------------------------------------------------------
-- 2. Préparation et commentaires de séance
-- ---------------------------------------------------------------------------
create table public.session_exercises (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  session_id        uuid not null,
  sort_order        int not null default 0,
  name              text not null check (char_length(name) between 1 and 80),
  description       text check (char_length(description) <= 2000),
  duration_min      int check (duration_min between 1 and 240),
  tactic_id         uuid,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  foreign key (session_id, team_id) references public.sessions (id, team_id),
  foreign key (tactic_id, team_id) references public.tactics (id, team_id)
);

create table public.session_comments (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  session_id        uuid not null,
  author_id         uuid not null default auth.uid() references auth.users (id),
  author_name       text not null check (char_length(author_name) between 1 and 120),
  text              text not null check (char_length(text) between 1 and 1000),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  foreign key (session_id, team_id) references public.sessions (id, team_id)
);

-- ---------------------------------------------------------------------------
-- 3. Questionnaires de bien-être
-- ---------------------------------------------------------------------------
create table public.wellness_surveys (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  date              date not null,
  title             text check (char_length(title) <= 80),
  session_id        uuid,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  unique (id, team_id),
  foreign key (session_id, team_id) references public.sessions (id, team_id)
);

-- Joueurs appelés à répondre. id déterministe : uuidv5(NS, 'survey:player').
create table public.wellness_survey_players (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  survey_id         uuid not null,
  player_id         uuid not null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  foreign key (survey_id, team_id) references public.wellness_surveys (id, team_id),
  foreign key (player_id, team_id) references public.players (id, team_id)
);

-- Une réponse appartient à une séance (ancien parcours) ou à un questionnaire. id déterministe :
-- uuidv5(NS, 'séance ou questionnaire:joueur').
alter table public.wellness alter column session_id drop not null;
alter table public.wellness add column survey_id uuid;
alter table public.wellness add constraint wellness_survey_fk
  foreign key (survey_id, team_id) references public.wellness_surveys (id, team_id);
alter table public.wellness add constraint wellness_session_or_survey check (session_id is not null or survey_id is not null);

do $$
declare
  t text;
begin
  foreach t in array array['session_exercises', 'session_comments', 'wellness_surveys', 'wellness_survey_players']
  loop
    execute format('create trigger set_server_updated_at before insert or update on public.%I
                    for each row execute function public.set_server_updated_at()', t);
    execute format('create trigger enforce_permissions before insert or update on public.%I
                    for each row execute function public.enforce_permissions()', t);
    execute format('create index %I on public.%I (server_updated_at)', t || '_server_updated_at_idx', t);
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy "team data: create" on public.%I for insert to authenticated
                    with check (public.is_team_member(team_id))', t);
    execute format('create policy "team data: update" on public.%I for update to authenticated
                    using (public.is_team_member(team_id)) with check (public.is_team_member(team_id))', t);
  end loop;
end;
$$;
revoke all on public.session_exercises, public.session_comments, public.wellness_surveys, public.wellness_survey_players from anon;
revoke delete, truncate on public.session_exercises, public.session_comments, public.wellness_surveys,
  public.wellness_survey_players from authenticated;

create policy "team data: read" on public.session_exercises for select to authenticated
  using (public.is_staff_member(team_id));
create policy "team data: read" on public.session_comments for select to authenticated
  using (public.is_staff_member(team_id));
-- Un joueur voit les questionnaires qui lui sont adressés.
create policy "team data: read" on public.wellness_survey_players for select to authenticated
  using (public.is_staff_member(team_id) or player_id = public.my_player_id());
create policy "team data: read" on public.wellness_surveys for select to authenticated
  using (public.is_staff_member(team_id) or exists (
    select 1 from public.wellness_survey_players p
    where p.survey_id = wellness_surveys.id and p.player_id = public.my_player_id() and not p.deleted));

-- Un joueur voit les matchs où il est sur la feuille, et sa ligne (pour donner son RPE).
drop policy "team data: read" on public.matches;
create policy "team data: read" on public.matches for select to authenticated
  using (public.is_staff_member(team_id) or exists (
    select 1 from public.match_players p
    where p.match_id = matches.id and p.player_id = public.my_player_id() and p.present and not p.deleted));
drop policy "team data: read" on public.match_players;
create policy "team data: read" on public.match_players for select to authenticated
  using (public.is_staff_member(team_id) or player_id = public.my_player_id());

-- Nouvelle permission : commenter une séance (directeur technique, entraîneurs, médical).
insert into public.role_permissions (role, permission, allowed) values
  ('technical_director', 'seances.commenter', true),
  ('head_coach', 'seances.commenter', true),
  ('fitness_coach', 'seances.commenter', true),
  ('assistant_coach', 'seances.commenter', true),
  ('medical', 'seances.commenter', true),
  ('observer', 'seances.commenter', false);

-- Contrôle des écritures : tables nouvelles, RPE de match du joueur, commentaire modifié par son auteur.
create or replace function public.enforce_permissions()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  act text;
  perm text;
  team uuid;
  existing boolean;
  me uuid := public.my_player_id();
begin
  if auth.uid() is null then
    return new;
  end if;

  if tg_op = 'INSERT' then
    execute format('select exists (select 1 from public.%I where id = $1)', tg_table_name) using new.id into existing;
    if existing then
      return new;
    end if;
    act := 'add';
  elsif new.deleted and not old.deleted then
    act := 'delete';
  else
    act := 'edit';
  end if;

  -- Compte joueur : son dossier, son questionnaire de bien-être, son RPE (rien d'autre sur sa ligne de séance).
  if public.app_role() = 'player' then
    if tg_table_name in ('player_profiles', 'wellness') then
      if new.player_id = me and act <> 'delete' then
        return new;
      end if;
    elsif tg_table_name = 'session_players' and tg_op = 'UPDATE' then
      if new.player_id = me and act = 'edit' and new.present = old.present
          and new.absence_reason is not distinct from old.absence_reason
          and new.duration_min is not distinct from old.duration_min then
        return new;
      end if;
    elsif tg_table_name = 'match_players' and tg_op = 'UPDATE' then
      -- RPE du match : sa ligne, sans toucher à la feuille (présence, rôle, place, minutes).
      if new.player_id = me and act = 'edit' and new.present = old.present
          and new.role is not distinct from old.role and new.slot is not distinct from old.slot
          and new.minutes_played is not distinct from old.minutes_played then
        return new;
      end if;
    end if;
    raise exception 'Action réservée au staff.' using errcode = '42501';
  end if;

  perm := case tg_table_name
    when 'players' then 'effectif.' || act
    when 'player_profiles' then 'dossier.edit'
    when 'player_medical' then 'medical.edit'
    when 'sessions' then 'seances.' || act
    when 'session_players' then 'seances.appel'
    when 'wellness' then 'bienetre.edit'
    when 'matches' then 'matchs.' || act
    when 'match_players' then 'matchs.jouer'
    when 'match_events' then 'matchs.jouer'
    when 'injuries' then case act when 'delete' then 'blessures.edit' else 'blessures.' || act end
    when 'test_results' then 'tests.' || act
    when 'test_types' then 'tests.edit'
    when 'tactics' then 'tactiques.' || act
    when 'tactic_links' then 'tactiques.view'
    when 'teams' then 'equipes.' || case act when 'add' then 'add' else 'edit' end
    when 'session_exercises' then 'seances.edit'
    when 'session_comments' then 'seances.commenter'
    when 'wellness_surveys' then 'bienetre.edit'
    when 'wellness_survey_players' then 'bienetre.edit'
  end;

  -- Un commentaire ne se modifie ou ne se supprime que par son auteur.
  if tg_table_name = 'session_comments' and act <> 'add' then
    if new.author_id is distinct from auth.uid() then
      raise exception 'Seul l''auteur peut modifier son commentaire.' using errcode = '42501';
    end if;
  end if;

  -- Séance modifiée sans toucher à sa planification : appel, clôture, remarque.
  -- Conditions imbriquées : PL/pgSQL n'évalue pas « and » dans l'ordre, et les colonnes d'une table
  -- n'existent pas dans les autres.
  if tg_table_name = 'sessions' and act = 'edit' then
    if (new.date, new.start_time, new.type, new.planned_duration_min, new.objective, new.planned_rpe)
        is not distinct from (old.date, old.start_time, old.type, old.planned_duration_min, old.objective, old.planned_rpe) then
      perm := 'seances.appel';
    end if;
  end if;

  -- Match : forfait, report, annulation (ou leur retour) ; sinon déroulement du match si ses informations
  -- ne changent pas.
  if tg_table_name = 'matches' and act = 'edit' then
    if new.status is distinct from old.status
        and (new.status in ('forfeit', 'postponed', 'cancelled') or old.status in ('forfeit', 'postponed', 'cancelled')) then
      perm := 'matchs.issues';
    elsif (new.date, new.kick_off_time, new.opponent, new.home_away, new.competition, new.duration_min, new.phase, new.matchday)
        is not distinct from (old.date, old.kick_off_time, old.opponent, old.home_away, old.competition, old.duration_min, old.phase, old.matchday) then
      perm := 'matchs.jouer';
    end if;
  end if;

  if tg_table_name = 'teams' then
    if (act = 'add' and public.has_perm(perm)) or (act <> 'add' and public.can(new.id, perm)) then
      return new;
    end if;
  else
    team := new.team_id;
    if public.can(team, perm) then
      return new;
    end if;
  end if;
  raise exception 'Action non autorisée (%).', perm using errcode = '42501';
end;
$$;

