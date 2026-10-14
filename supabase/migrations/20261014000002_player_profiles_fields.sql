-- Dossier du joueur : champs du formulaire du club qui n'avaient pas de place (journal du 2026-10-14).
-- Migration additive.
alter table public.player_profiles
  add column other_position text check (char_length(other_position) <= 80),
  add column school_address text check (char_length(school_address) <= 200),
  add column coach_name     text check (char_length(coach_name) <= 80),
  add column manager_name   text check (char_length(manager_name) <= 160);
