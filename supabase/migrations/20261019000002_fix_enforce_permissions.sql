-- Correctif de 20261019000001 : le contrôle des écritures lisait des colonnes propres à une table
-- (start_time, player_id) dans une condition évaluée pour toutes les tables, et faisait échouer toute
-- modification hors séances. Conditions désormais imbriquées par table.

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

