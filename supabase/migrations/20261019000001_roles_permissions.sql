-- v4 — gestion des rôles et des permissions (journal du 2026-10-19).
--
-- Le rôle d'un compte est dans app_metadata.role (écrit par la fonction Edge admin-users avec la clé de
-- service, jamais par l'application) et arrive dans le jeton : les règles le lisent sans requête.
--   admin               : tout, et l'administration des comptes et des permissions ;
--   technical_director  : tout dans ses équipes (matrice réglable) ;
--   head_coach, fitness_coach, assistant_coach, medical, observer : selon la matrice réglable ;
--   player              : un compte joueur (app_metadata.player_id) qui ne remplit que son dossier,
--                         son RPE et son questionnaire de bien-être.
-- La matrice role_permissions donne les droits de chaque rôle ; account_permissions autorise ou interdit
-- une action pour un compte précis, au-dessus de son rôle. Un compte sans rôle est « observer ».
--
-- Contrôle côté serveur : les règles de lecture cachent le dossier médical (et tout ce qui n'est pas à
-- lui pour un joueur) ; un déclencheur refuse chaque écriture que la matrice n'autorise pas.

-- ---------------------------------------------------------------------------
-- 1. Rôle du compte connecté
-- ---------------------------------------------------------------------------
create or replace function public.app_role()
returns text
language sql
stable
as $$
  select coalesce(auth.jwt() -> 'app_metadata' ->> 'role', 'observer');
$$;

create or replace function public.my_player_id()
returns uuid
language sql
stable
as $$
  select nullif(auth.jwt() -> 'app_metadata' ->> 'player_id', '')::uuid;
$$;

-- ---------------------------------------------------------------------------
-- 2. Matrice des permissions
-- ---------------------------------------------------------------------------
create table public.role_permissions (
  role        text not null check (role in ('technical_director', 'head_coach', 'fitness_coach',
                                            'assistant_coach', 'medical', 'observer')),
  permission  text not null check (char_length(permission) between 3 and 40),
  allowed     boolean not null,
  updated_at  timestamptz not null default now(),
  primary key (role, permission)
);

-- Exception pour un compte : allowed = true l'autorise, false l'interdit, quel que soit son rôle.
create table public.account_permissions (
  user_id     uuid not null references auth.users (id) on delete cascade,
  permission  text not null check (char_length(permission) between 3 and 40),
  allowed     boolean not null,
  updated_at  timestamptz not null default now(),
  primary key (user_id, permission)
);

alter table public.role_permissions enable row level security;
alter table public.account_permissions enable row level security;
revoke all on public.role_permissions, public.account_permissions from anon;

create policy "role permissions: read" on public.role_permissions for select to authenticated using (true);
create policy "role permissions: admin" on public.role_permissions for all to authenticated
  using (public.app_role() = 'admin') with check (public.app_role() = 'admin');
create policy "account permissions: read" on public.account_permissions for select to authenticated
  using (user_id = auth.uid() or public.app_role() = 'admin');
create policy "account permissions: admin" on public.account_permissions for all to authenticated
  using (public.app_role() = 'admin') with check (public.app_role() = 'admin');

insert into public.role_permissions (role, permission, allowed) values
  ('technical_director', 'effectif.view', true),
  ('technical_director', 'effectif.add', true),
  ('technical_director', 'effectif.edit', true),
  ('technical_director', 'effectif.delete', true),
  ('technical_director', 'dossier.view', true),
  ('technical_director', 'dossier.edit', true),
  ('technical_director', 'medical.view', true),
  ('technical_director', 'medical.edit', true),
  ('technical_director', 'seances.view', true),
  ('technical_director', 'seances.add', true),
  ('technical_director', 'seances.edit', true),
  ('technical_director', 'seances.delete', true),
  ('technical_director', 'seances.appel', true),
  ('technical_director', 'bienetre.view', true),
  ('technical_director', 'bienetre.edit', true),
  ('technical_director', 'matchs.view', true),
  ('technical_director', 'matchs.add', true),
  ('technical_director', 'matchs.edit', true),
  ('technical_director', 'matchs.delete', true),
  ('technical_director', 'matchs.jouer', true),
  ('technical_director', 'matchs.issues', true),
  ('technical_director', 'blessures.view', true),
  ('technical_director', 'blessures.add', true),
  ('technical_director', 'blessures.edit', true),
  ('technical_director', 'tests.view', true),
  ('technical_director', 'tests.add', true),
  ('technical_director', 'tests.edit', true),
  ('technical_director', 'tests.delete', true),
  ('technical_director', 'tactiques.view', true),
  ('technical_director', 'tactiques.add', true),
  ('technical_director', 'tactiques.edit', true),
  ('technical_director', 'tactiques.delete', true),
  ('technical_director', 'import.use', true),
  ('technical_director', 'equipes.add', true),
  ('technical_director', 'equipes.edit', true),
  ('head_coach', 'effectif.view', true),
  ('head_coach', 'effectif.add', true),
  ('head_coach', 'effectif.edit', true),
  ('head_coach', 'effectif.delete', true),
  ('head_coach', 'dossier.view', true),
  ('head_coach', 'dossier.edit', true),
  ('head_coach', 'medical.view', true),
  ('head_coach', 'medical.edit', true),
  ('head_coach', 'seances.view', true),
  ('head_coach', 'seances.add', true),
  ('head_coach', 'seances.edit', true),
  ('head_coach', 'seances.delete', true),
  ('head_coach', 'seances.appel', true),
  ('head_coach', 'bienetre.view', true),
  ('head_coach', 'bienetre.edit', true),
  ('head_coach', 'matchs.view', true),
  ('head_coach', 'matchs.add', true),
  ('head_coach', 'matchs.edit', true),
  ('head_coach', 'matchs.delete', true),
  ('head_coach', 'matchs.jouer', true),
  ('head_coach', 'matchs.issues', true),
  ('head_coach', 'blessures.view', true),
  ('head_coach', 'blessures.add', true),
  ('head_coach', 'blessures.edit', true),
  ('head_coach', 'tests.view', true),
  ('head_coach', 'tests.add', true),
  ('head_coach', 'tests.edit', true),
  ('head_coach', 'tests.delete', true),
  ('head_coach', 'tactiques.view', true),
  ('head_coach', 'tactiques.add', true),
  ('head_coach', 'tactiques.edit', true),
  ('head_coach', 'tactiques.delete', true),
  ('head_coach', 'import.use', true),
  ('head_coach', 'equipes.add', true),
  ('head_coach', 'equipes.edit', true),
  ('fitness_coach', 'effectif.view', true),
  ('fitness_coach', 'effectif.add', true),
  ('fitness_coach', 'effectif.edit', true),
  ('fitness_coach', 'effectif.delete', false),
  ('fitness_coach', 'dossier.view', true),
  ('fitness_coach', 'dossier.edit', true),
  ('fitness_coach', 'medical.view', true),
  ('fitness_coach', 'medical.edit', false),
  ('fitness_coach', 'seances.view', true),
  ('fitness_coach', 'seances.add', true),
  ('fitness_coach', 'seances.edit', true),
  ('fitness_coach', 'seances.delete', false),
  ('fitness_coach', 'seances.appel', true),
  ('fitness_coach', 'bienetre.view', true),
  ('fitness_coach', 'bienetre.edit', true),
  ('fitness_coach', 'matchs.view', true),
  ('fitness_coach', 'matchs.add', true),
  ('fitness_coach', 'matchs.edit', true),
  ('fitness_coach', 'matchs.delete', false),
  ('fitness_coach', 'matchs.jouer', true),
  ('fitness_coach', 'matchs.issues', true),
  ('fitness_coach', 'blessures.view', true),
  ('fitness_coach', 'blessures.add', true),
  ('fitness_coach', 'blessures.edit', true),
  ('fitness_coach', 'tests.view', true),
  ('fitness_coach', 'tests.add', true),
  ('fitness_coach', 'tests.edit', true),
  ('fitness_coach', 'tests.delete', true),
  ('fitness_coach', 'tactiques.view', true),
  ('fitness_coach', 'tactiques.add', true),
  ('fitness_coach', 'tactiques.edit', true),
  ('fitness_coach', 'tactiques.delete', true),
  ('fitness_coach', 'import.use', true),
  ('fitness_coach', 'equipes.add', false),
  ('fitness_coach', 'equipes.edit', true),
  ('assistant_coach', 'effectif.view', true),
  ('assistant_coach', 'effectif.add', false),
  ('assistant_coach', 'effectif.edit', false),
  ('assistant_coach', 'effectif.delete', false),
  ('assistant_coach', 'dossier.view', true),
  ('assistant_coach', 'dossier.edit', false),
  ('assistant_coach', 'medical.view', false),
  ('assistant_coach', 'medical.edit', false),
  ('assistant_coach', 'seances.view', true),
  ('assistant_coach', 'seances.add', true),
  ('assistant_coach', 'seances.edit', true),
  ('assistant_coach', 'seances.delete', false),
  ('assistant_coach', 'seances.appel', true),
  ('assistant_coach', 'bienetre.view', true),
  ('assistant_coach', 'bienetre.edit', true),
  ('assistant_coach', 'matchs.view', true),
  ('assistant_coach', 'matchs.add', true),
  ('assistant_coach', 'matchs.edit', true),
  ('assistant_coach', 'matchs.delete', false),
  ('assistant_coach', 'matchs.jouer', true),
  ('assistant_coach', 'matchs.issues', true),
  ('assistant_coach', 'blessures.view', true),
  ('assistant_coach', 'blessures.add', true),
  ('assistant_coach', 'blessures.edit', false),
  ('assistant_coach', 'tests.view', true),
  ('assistant_coach', 'tests.add', false),
  ('assistant_coach', 'tests.edit', false),
  ('assistant_coach', 'tests.delete', false),
  ('assistant_coach', 'tactiques.view', true),
  ('assistant_coach', 'tactiques.add', true),
  ('assistant_coach', 'tactiques.edit', true),
  ('assistant_coach', 'tactiques.delete', false),
  ('assistant_coach', 'import.use', false),
  ('assistant_coach', 'equipes.add', false),
  ('assistant_coach', 'equipes.edit', false),
  ('medical', 'effectif.view', true),
  ('medical', 'effectif.add', false),
  ('medical', 'effectif.edit', false),
  ('medical', 'effectif.delete', false),
  ('medical', 'dossier.view', true),
  ('medical', 'dossier.edit', true),
  ('medical', 'medical.view', true),
  ('medical', 'medical.edit', true),
  ('medical', 'seances.view', true),
  ('medical', 'seances.add', false),
  ('medical', 'seances.edit', false),
  ('medical', 'seances.delete', false),
  ('medical', 'seances.appel', false),
  ('medical', 'bienetre.view', true),
  ('medical', 'bienetre.edit', true),
  ('medical', 'matchs.view', true),
  ('medical', 'matchs.add', false),
  ('medical', 'matchs.edit', false),
  ('medical', 'matchs.delete', false),
  ('medical', 'matchs.jouer', false),
  ('medical', 'matchs.issues', false),
  ('medical', 'blessures.view', true),
  ('medical', 'blessures.add', true),
  ('medical', 'blessures.edit', true),
  ('medical', 'tests.view', true),
  ('medical', 'tests.add', false),
  ('medical', 'tests.edit', false),
  ('medical', 'tests.delete', false),
  ('medical', 'tactiques.view', true),
  ('medical', 'tactiques.add', false),
  ('medical', 'tactiques.edit', false),
  ('medical', 'tactiques.delete', false),
  ('medical', 'import.use', false),
  ('medical', 'equipes.add', false),
  ('medical', 'equipes.edit', false),
  ('observer', 'effectif.view', true),
  ('observer', 'effectif.add', false),
  ('observer', 'effectif.edit', false),
  ('observer', 'effectif.delete', false),
  ('observer', 'dossier.view', true),
  ('observer', 'dossier.edit', false),
  ('observer', 'medical.view', false),
  ('observer', 'medical.edit', false),
  ('observer', 'seances.view', true),
  ('observer', 'seances.add', false),
  ('observer', 'seances.edit', false),
  ('observer', 'seances.delete', false),
  ('observer', 'seances.appel', false),
  ('observer', 'bienetre.view', true),
  ('observer', 'bienetre.edit', false),
  ('observer', 'matchs.view', true),
  ('observer', 'matchs.add', false),
  ('observer', 'matchs.edit', false),
  ('observer', 'matchs.delete', false),
  ('observer', 'matchs.jouer', false),
  ('observer', 'matchs.issues', false),
  ('observer', 'blessures.view', true),
  ('observer', 'blessures.add', false),
  ('observer', 'blessures.edit', false),
  ('observer', 'tests.view', true),
  ('observer', 'tests.add', false),
  ('observer', 'tests.edit', false),
  ('observer', 'tests.delete', false),
  ('observer', 'tactiques.view', true),
  ('observer', 'tactiques.add', false),
  ('observer', 'tactiques.edit', false),
  ('observer', 'tactiques.delete', false),
  ('observer', 'import.use', false),
  ('observer', 'equipes.add', false),
  ('observer', 'equipes.edit', false);

-- Droit du compte connecté : exception du compte, sinon matrice du rôle. Administrateur : tout ;
-- joueur : rien par la matrice (ses écritures sont traitées à part).
create or replace function public.has_perm(p text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case public.app_role()
    when 'admin' then true
    when 'player' then false
    else coalesce(
      (select a.allowed from public.account_permissions a where a.user_id = auth.uid() and a.permission = p),
      (select r.allowed from public.role_permissions r where r.role = public.app_role() and r.permission = p),
      false)
  end;
$$;

-- Droit dans une équipe : être membre de l'équipe et avoir la permission.
create or replace function public.can(p_team_id uuid, p text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.is_team_member(p_team_id) and public.has_perm(p);
$$;

-- Membre de l'équipe qui n'est pas un compte joueur.
create or replace function public.is_staff_member(p_team_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.is_team_member(p_team_id) and public.app_role() <> 'player';
$$;

-- Un compte joueur est membre de l'équipe de son joueur.
alter table public.team_members drop constraint team_members_role_check;
alter table public.team_members add constraint team_members_role_check check (role in ('owner', 'staff', 'player'));

-- ---------------------------------------------------------------------------
-- 3. Lecture : dossier médical selon la matrice, et un joueur ne voit que ce qui le concerne
-- ---------------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['matches', 'match_players', 'match_events', 'injuries', 'test_results', 'tactics', 'tactic_links']
  loop
    execute format('drop policy "team data: read" on public.%I', t);
    execute format('create policy "team data: read" on public.%I for select to authenticated
                    using (public.is_staff_member(team_id))', t);
  end loop;
end;
$$;

drop policy "team data: read" on public.players;
create policy "team data: read" on public.players for select to authenticated
  using (public.is_staff_member(team_id) or id = public.my_player_id());

drop policy "team data: read" on public.player_profiles;
create policy "team data: read" on public.player_profiles for select to authenticated
  using (public.can(team_id, 'dossier.view') or player_id = public.my_player_id());

drop policy "team data: read" on public.session_players;
create policy "team data: read" on public.session_players for select to authenticated
  using (public.is_staff_member(team_id) or player_id = public.my_player_id());

drop policy "team data: read" on public.wellness;
create policy "team data: read" on public.wellness for select to authenticated
  using (public.is_staff_member(team_id) or player_id = public.my_player_id());

drop policy "test types: read" on public.test_types;
create policy "test types: read" on public.test_types for select to authenticated
  using (team_id is null or public.is_staff_member(team_id));

-- Dossier médical : la permission medical.view remplace « propriétaire de l'équipe » ; l'écriture est
-- contrôlée par le déclencheur (medical.edit).
drop policy "medical: read" on public.player_medical;
drop policy "medical: create" on public.player_medical;
drop policy "medical: update" on public.player_medical;
create policy "medical: read" on public.player_medical for select to authenticated
  using (public.can(team_id, 'medical.view'));
create policy "medical: create" on public.player_medical for insert to authenticated
  with check (public.is_team_member(team_id));
create policy "medical: update" on public.player_medical for update to authenticated
  using (public.is_team_member(team_id)) with check (public.is_team_member(team_id));

-- ---------------------------------------------------------------------------
-- 4. Écriture : chaque ajout, modification ou suppression passe par la matrice
-- ---------------------------------------------------------------------------
-- La synchronisation envoie des « upsert » : pour une ligne existante, c'est le déclencheur UPDATE qui
-- décide (le déclencheur INSERT, qui s'exécute d'abord, la laisse passer). Une suppression est logique
-- (deleted passe à vrai). Clé de service (fonctions Edge) : aucun contrôle.
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
    if tg_table_name = 'player_profiles' and new.player_id = me and act <> 'delete' then
      return new;
    elsif tg_table_name = 'wellness' and new.player_id = me and act <> 'delete' then
      return new;
    elsif tg_table_name = 'session_players' and tg_op = 'UPDATE' and new.player_id = me and act = 'edit'
        and new.present = old.present and new.absence_reason is not distinct from old.absence_reason
        and new.duration_min is not distinct from old.duration_min then
      return new;
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
  end;

  -- Séance modifiée sans toucher à sa planification : appel, clôture, remarque.
  if tg_table_name = 'sessions' and act = 'edit'
      and (new.date, new.start_time, new.type, new.planned_duration_min, new.objective, new.planned_rpe)
          is not distinct from (old.date, old.start_time, old.type, old.planned_duration_min, old.objective, old.planned_rpe) then
    perm := 'seances.appel';
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

do $$
declare
  t text;
begin
  foreach t in array array['players', 'player_profiles', 'player_medical', 'sessions', 'session_players', 'wellness',
                           'matches', 'match_players', 'match_events', 'injuries', 'test_results', 'test_types',
                           'tactics', 'tactic_links', 'teams']
  loop
    execute format('create trigger enforce_permissions before insert or update on public.%I
                    for each row execute function public.enforce_permissions()', t);
  end loop;
end;
$$;
