-- Le rôle (app_metadata.role, migration 20261019000001) remplace la « fonction » : un seul champ à choisir.
-- La colonne est gardée pour l'historique des comptes existants mais n'est plus obligatoire ni saisie.
alter table public.staff_profiles alter column job_title drop not null;
