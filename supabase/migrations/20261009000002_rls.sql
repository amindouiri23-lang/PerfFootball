-- Sécurité au niveau des lignes — voir docs/01-architecture-and-rules.md §7.
-- Un utilisateur ne lit et n'écrit que les données des équipes dont il est membre,
-- et uniquement son propre profil. Aucune suppression physique côté application
-- (suppression logique par la colonne deleted) : pas de politique DELETE.

create or replace function public.is_team_member(p_team_id uuid)
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
      and not m.deleted
  );
$$;

-- La clé publique (rôle anon) ne voit rien : toute l'application exige une connexion.
revoke all on all tables in schema public from anon;
revoke delete, truncate on all tables in schema public from authenticated;
-- team_members n'est écrite que par le déclencheur add_team_owner (et par les fonctions d'administration).
revoke insert, update on public.team_members from authenticated;

-- ---------------------------------------------------------------------------
-- Profil
-- ---------------------------------------------------------------------------
alter table public.staff_profiles enable row level security;

create policy "own profile: read" on public.staff_profiles
  for select to authenticated using (id = auth.uid());
create policy "own profile: create" on public.staff_profiles
  for insert to authenticated with check (id = auth.uid());
create policy "own profile: update" on public.staff_profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- ---------------------------------------------------------------------------
-- Équipes et membres
-- ---------------------------------------------------------------------------
alter table public.teams enable row level security;

-- created_by = auth.uid() : le créateur voit son équipe dès l'insertion, avant que le
-- déclencheur l'ait ajouté aux membres.
create policy "teams: read" on public.teams
  for select to authenticated using (created_by = auth.uid() or public.is_team_member(id));
create policy "teams: create" on public.teams
  for insert to authenticated with check (created_by = auth.uid());
create policy "teams: update" on public.teams
  for update to authenticated using (public.is_team_member(id)) with check (public.is_team_member(id));

alter table public.team_members enable row level security;

create policy "team members: read" on public.team_members
  for select to authenticated using (user_id = auth.uid() or public.is_team_member(team_id));

-- ---------------------------------------------------------------------------
-- Données d'équipe : même règle pour toutes les tables portant team_id
-- ---------------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['players', 'sessions', 'session_players', 'wellness', 'matches',
                           'match_players', 'match_events', 'injuries']
  loop
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
