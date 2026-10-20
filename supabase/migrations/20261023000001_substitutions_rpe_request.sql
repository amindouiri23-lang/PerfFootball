-- Changements en cours de match et RPE demandé aux joueurs (journal du 2026-10-20).
--   1. Événement « substitution » : player_id = joueur qui entre, assist_player_id = joueur qui sort.
--   2. matches.rpe_requested : le staff envoie le match aux joueurs, qui donnent leur RPE depuis leur compte
--      (le staff peut toujours le saisir lui-même).
alter table public.match_events drop constraint match_events_type_check;
alter table public.match_events add constraint match_events_type_check
  check (type in ('goal', 'yellow_card', 'red_card', 'substitution'));
alter table public.match_events drop constraint match_events_check;
alter table public.match_events add constraint match_events_check
  check (assist_player_id is null or (type in ('goal', 'substitution') and assist_player_id <> player_id));
alter table public.match_events add constraint match_events_substitution_check
  check (type <> 'substitution' or assist_player_id is not null);

alter table public.matches add column rpe_requested boolean not null default false;
