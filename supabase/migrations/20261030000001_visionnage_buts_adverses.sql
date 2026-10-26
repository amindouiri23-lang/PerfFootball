-- Journal du 2026-10-26.
-- 1. But adverse minuté : événement « opponent_goal » sans joueur (le buteur adverse éventuel en remarque).
--    Il apparaît dans la chronologie, la feuille de match et les résultats du club ; le score adverse
--    (matches.goals_against) reste la référence, l'application les tient ensemble.
-- 2. Séance de visionnage : une présentation de diapositives (texte, tactique, vidéo par lien), réglée par
--    la fonctionnalité « Visionnage » (Voir, Ajouter, Modifier, Supprimer), même audience que « Tactiques ».

-- ---------------------------------------------------------------------------
-- 1. But adverse
-- ---------------------------------------------------------------------------
alter table public.match_events alter column player_id drop not null;
alter table public.match_events drop constraint match_events_type_check;
alter table public.match_events add constraint match_events_type_check
  check (type in ('goal', 'yellow_card', 'red_card', 'substitution', 'opponent_goal'));
alter table public.match_events add constraint match_events_player_check
  check ((type = 'opponent_goal') = (player_id is null));

-- Résultats du club : les buts adverses dans la liste des événements (jointure externe sur le joueur).
create or replace function public.club_results()
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
                    'player', coalesce(p.first_name || ' ' || p.last_name, e.remark),
                    'other', o.first_name || ' ' || o.last_name) order by e.minute)
           from public.match_events e
           left join public.players p on p.id = e.player_id
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

-- ---------------------------------------------------------------------------
-- 2. Séances de visionnage
-- ---------------------------------------------------------------------------
create table public.viewing_sessions (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  title             text not null check (char_length(title) between 1 and 100),
  date              date,
  notes             text check (char_length(notes) <= 2000),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  unique (id, team_id)
);

-- Diapositive : texte (titre et contenu), tactique (référence) ou vidéo (lien).
create table public.viewing_slides (
  id                uuid primary key,
  team_id           uuid not null references public.teams (id),
  session_id        uuid not null,
  sort_order        int not null default 0,
  kind              text not null check (kind in ('text', 'tactic', 'video')),
  title             text check (char_length(title) <= 150),
  body              text check (char_length(body) <= 5000),
  tactic_id         uuid,
  video_url         text check (char_length(video_url) <= 1000),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted           boolean not null default false,
  foreign key (session_id, team_id) references public.viewing_sessions (id, team_id),
  foreign key (tactic_id, team_id) references public.tactics (id, team_id),
  check (kind <> 'tactic' or tactic_id is not null),
  check (kind <> 'video' or video_url is not null)
);

do $$
declare
  t text;
begin
  foreach t in array array['viewing_sessions', 'viewing_slides']
  loop
    execute format('create trigger set_server_updated_at before insert or update on public.%I
                    for each row execute function public.set_server_updated_at()', t);
    execute format('create trigger enforce_permissions before insert or update on public.%I
                    for each row execute function public.enforce_permissions()', t);
    execute format('create index %I on public.%I (server_updated_at)', t || '_server_updated_at_idx', t);
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy "team data: read" on public.%I for select to authenticated
                    using (public.is_staff_member(team_id))', t);
    execute format('create policy "team data: create" on public.%I for insert to authenticated
                    with check (public.is_team_member(team_id))', t);
    execute format('create policy "team data: update" on public.%I for update to authenticated
                    using (public.is_team_member(team_id)) with check (public.is_team_member(team_id))', t);
  end loop;
end;
$$;
create index on public.viewing_sessions (team_id);
create index on public.viewing_slides (session_id);
revoke all on public.viewing_sessions, public.viewing_slides from anon;
revoke delete, truncate on public.viewing_sessions, public.viewing_slides from authenticated;

-- Permissions : chaque table se rattache à « visionnage ».
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
    when 'viewing_sessions' then 'visionnage.' || act
    when 'viewing_slides' then 'visionnage.edit'
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

-- Audience : celle des tactiques, rôle par rôle (même droits Voir / Ajouter / Modifier / Supprimer).
insert into public.role_permissions (role, permission, allowed)
select role, 'visionnage.' || split_part(permission, '.', 2), allowed
from public.role_permissions
where permission in ('tactiques.view', 'tactiques.add', 'tactiques.edit', 'tactiques.delete')
on conflict (role, permission) do nothing;
insert into public.account_permissions (user_id, permission, allowed)
select user_id, 'visionnage.' || split_part(permission, '.', 2), allowed
from public.account_permissions
where permission in ('tactiques.view', 'tactiques.add', 'tactiques.edit', 'tactiques.delete')
on conflict (user_id, permission) do nothing;
