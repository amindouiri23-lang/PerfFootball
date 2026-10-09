-- Support de la fonction Edge admin-users (docs/01-architecture-and-rules.md §7.1).
-- Ferme les sessions d'un utilisateur après une réinitialisation ou une désactivation :
-- ses jetons de rafraîchissement ne fonctionnent plus (le jeton d'accès en cours expire sous 1 h).
-- Exécutable uniquement avec la clé de service.

create or replace function public.admin_revoke_sessions(p_user_id uuid)
returns void
language sql
security definer
set search_path = ''
as $$
  delete from auth.sessions where user_id = p_user_id;
$$;

revoke execute on function public.admin_revoke_sessions(uuid) from public, anon, authenticated;
grant execute on function public.admin_revoke_sessions(uuid) to service_role;
