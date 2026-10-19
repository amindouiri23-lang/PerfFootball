// Administration des comptes du staff, sans e-mail — docs/01-architecture-and-rules.md §7.1.
//
// POST { action: "list" }                                                     -> comptes + team_ids
// POST { action: "list_teams" }                                               -> toutes les équipes du projet
// POST { action: "list_players" }                                             -> joueurs de toutes les équipes
// POST { action: "create", email, first_name, last_name, role, player_id?, team_ids?, permissions? }
//        permissions : { "matchs.delete": false, ... } — écarts du compte par rapport à son rôle
//                                                                             -> { id, temporary_password }
// POST { action: "set_role", user_id, role, player_id? }                      -> rôle du compte
// POST { action: "set_teams", user_id, team_ids }                             -> équipes où il est « staff »
// POST { action: "reset_password", user_id }                                  -> { temporary_password }
// POST { action: "disable" | "enable", user_id }
//
// Seul un utilisateur dont app_metadata.role = "admin" peut l'appeler. La clé de service est fournie
// par Supabase (SUPABASE_SERVICE_ROLE_KEY) et ne quitte jamais cette fonction.
import { createClient, type User } from "npm:@supabase/supabase-js@2.45.4";

const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { autoRefreshToken: false, persistSession: false } },
);

// En-têtes CORS : nécessaires pour la version web de l'application (sans effet sur Android et iOS).
const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// Rôle du compte (app_metadata.role) : il fixe ses permissions (migration 20261019000001).
const ROLES = ["admin", "technical_director", "head_coach", "fitness_coach", "assistant_coach", "medical", "observer", "player"];
const BANNED = "876000h"; // ~100 ans

class HttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

// 12 caractères sans caractères ambigus (0/O, 1/l/I), au moins une lettre et un chiffre, ex. k7Rm-2xQp-9Tv4.
function temporaryPassword(): string {
  const letters = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
  const digits = "23456789";
  const all = letters + digits;
  while (true) {
    const bytes = crypto.getRandomValues(new Uint8Array(12));
    const chars = Array.from(bytes, (b) => all[b % all.length]);
    const pwd = chars.join("");
    if (/[0-9]/.test(pwd) && /[a-zA-Z]/.test(pwd)) {
      return `${pwd.slice(0, 4)}-${pwd.slice(4, 8)}-${pwd.slice(8)}`;
    }
  }
}

async function caller(req: Request): Promise<User> {
  const token = req.headers.get("Authorization")?.replace("Bearer ", "");
  if (!token) throw new HttpError(401, "Non connecté.");
  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) throw new HttpError(401, "Non connecté.");
  if (data.user.app_metadata?.role !== "admin") throw new HttpError(403, "Réservé aux administrateurs.");
  return data.user;
}

function targetId(body: Record<string, unknown>, me: User): string {
  const id = body.user_id;
  if (typeof id !== "string") throw new HttpError(400, "user_id manquant.");
  if (id === me.id) throw new HttpError(400, "Action impossible sur votre propre compte.");
  return id;
}

async function revokeSessions(userId: string) {
  const { error } = await admin.rpc("admin_revoke_sessions", { p_user_id: userId });
  if (error) throw error;
}

async function list() {
  const { data, error } = await admin.auth.admin.listUsers({ perPage: 1000 });
  if (error) throw error;
  const { data: profiles, error: pErr } = await admin.from("staff_profiles").select("id, first_name, last_name");
  if (pErr) throw pErr;
  const byId = new Map(profiles.map((p) => [p.id, p]));
  const { data: members, error: mErr } = await admin.from("team_members").select("team_id, user_id").eq("deleted", false);
  if (mErr) throw mErr;
  return data.users.map((u) => ({
    team_ids: members.filter((m) => m.user_id === u.id).map((m) => m.team_id),
    id: u.id,
    email: u.email,
    first_name: byId.get(u.id)?.first_name ?? null,
    last_name: byId.get(u.id)?.last_name ?? null,
    is_admin: u.app_metadata?.role === "admin",
    role: u.app_metadata?.role ?? "observer",
    player_id: u.app_metadata?.player_id ?? null,
    is_disabled: !!u.banned_until && new Date(u.banned_until) > new Date(),
    must_change_password: u.user_metadata?.must_change_password === true,
    last_sign_in_at: u.last_sign_in_at ?? null,
  }));
}

// Rôle et joueur lié, vérifiés : un compte joueur doit désigner un joueur existant.
async function roleOf(body: Record<string, unknown>): Promise<{ role: string; player?: { id: string; team_id: string } }> {
  const role = String(body.role ?? "");
  if (!ROLES.includes(role)) throw new HttpError(400, "Rôle invalide.");
  if (role !== "player") return { role };
  if (typeof body.player_id !== "string") throw new HttpError(400, "Choisissez le joueur du compte.");
  const { data, error } = await admin.from("players").select("id, team_id").eq("id", body.player_id).eq("deleted", false)
    .maybeSingle();
  if (error) throw error;
  if (!data) throw new HttpError(400, "Joueur introuvable.");
  return { role, player: data };
}

function roleMetadata(r: { role: string; player?: { id: string } }) {
  return r.player ? { role: r.role, player_id: r.player.id } : { role: r.role };
}

// Compte joueur : membre « player » de l'équipe de son joueur et d'aucune autre (ses appartenances
// « staff » sont retirées). Sans joueur (teamId null), ses appartenances « player » sont retirées.
// Une seule ligne par équipe et par compte : une appartenance existante change de rôle.
async function setPlayerTeam(userId: string, teamId: string | null) {
  const { data: current, error } = await admin.from("team_members").select("id, team_id, role, deleted").eq("user_id", userId);
  if (error) throw error;
  const now = new Date().toISOString();
  for (const m of current) {
    if (m.role === "owner") continue;
    const update = m.team_id === teamId
      ? (m.role !== "player" || m.deleted ? { role: "player", deleted: false } : null)
      : ((teamId !== null || m.role === "player") && !m.deleted ? { deleted: true } : null);
    if (!update) continue;
    const { error: uErr } = await admin.from("team_members").update({ ...update, updated_at: now }).eq("id", m.id);
    if (uErr) throw uErr;
  }
  if (teamId && !current.some((m) => m.team_id === teamId)) {
    const { error: iErr } = await admin.from("team_members").insert({ team_id: teamId, user_id: userId, role: "player" });
    if (iErr) throw iErr;
  }
}

async function setRole(userId: string, body: Record<string, unknown>) {
  const r = await roleOf(body);
  const { data: existing, error: gErr } = await admin.auth.admin.getUserById(userId);
  if (gErr) throw new HttpError(404, "Compte introuvable.");
  const { player_id: _old, ...rest } = existing.user.app_metadata ?? {};
  const { error } = await admin.auth.admin.updateUserById(userId, { app_metadata: { ...rest, ...roleMetadata(r) } });
  if (error) throw error;
  await setPlayerTeam(userId, r.player?.team_id ?? null);
  return { ok: true };
}

async function listPlayers() {
  const { data, error } = await admin.from("players").select("id, team_id, first_name, last_name, shirt_number")
    .eq("deleted", false).order("last_name");
  if (error) throw error;
  return data;
}

// Écarts aux droits du rôle choisis à la création : { "feature.action": true | false }.
function permissionsOf(raw: unknown): [string, boolean][] {
  if (raw === undefined || raw === null) return [];
  if (typeof raw !== "object" || Array.isArray(raw)) throw new HttpError(400, "permissions invalide.");
  const entries = Object.entries(raw as Record<string, unknown>);
  if (entries.some(([k, v]) => !/^[a-z]+\.[a-z]+$/.test(k) || typeof v !== "boolean")) {
    throw new HttpError(400, "permissions invalide.");
  }
  return entries as [string, boolean][];
}

async function create(body: Record<string, unknown>) {
  const email = String(body.email ?? "").trim().toLowerCase();
  const firstName = String(body.first_name ?? "").trim();
  const lastName = String(body.last_name ?? "").trim();
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) throw new HttpError(400, "Adresse e-mail invalide.");
  if (!firstName || !lastName) throw new HttpError(400, "Prénom et nom obligatoires.");
  const permissions = permissionsOf(body.permissions);
  const role = await roleOf(body);

  const password = temporaryPassword();
  const { data, error } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true, // aucun e-mail de confirmation
    app_metadata: roleMetadata(role),
    user_metadata: { must_change_password: true },
  });
  if (error) {
    if (error.message.toLowerCase().includes("already")) throw new HttpError(409, "Un compte existe déjà avec cette adresse.");
    throw error;
  }
  const { error: pErr } = await admin.from("staff_profiles").insert({
    id: data.user.id, first_name: firstName, last_name: lastName,
  });
  if (pErr) {
    await admin.auth.admin.deleteUser(data.user.id); // pas de compte sans profil
    throw pErr;
  }
  if (permissions.length > 0) {
    const { error: aErr } = await admin.from("account_permissions")
      .insert(permissions.map(([permission, allowed]) => ({ user_id: data.user.id, permission, allowed })));
    if (aErr) throw aErr;
  }
  if (role.player) {
    await setPlayerTeam(data.user.id, role.player.team_id);
  } else if (Array.isArray(body.team_ids) && body.team_ids.length > 0) {
    await setTeams(data.user.id, body.team_ids);
  }
  return { id: data.user.id, temporary_password: password };
}

// Toutes les équipes du projet (l'administrateur n'en est pas forcément membre), avec leur propriétaire.
async function listTeams() {
  const { data, error } = await admin.from("teams")
    .select("id, name, club_name, category, season, created_by").eq("deleted", false).order("club_name").order("name");
  if (error) throw error;
  return data;
}

// Rend l'utilisateur « staff » exactement des équipes données. Les équipes dont il est propriétaire ne
// sont jamais touchées ; un retrait est une suppression logique (l'appareil l'apprend à la synchronisation).
async function setTeams(userId: string, rawIds: unknown) {
  if (!Array.isArray(rawIds) || rawIds.some((x) => typeof x !== "string")) throw new HttpError(400, "team_ids invalide.");
  const wanted = new Set(rawIds as string[]);
  if (wanted.size > 0) {
    const { data: teams, error } = await admin.from("teams").select("id").in("id", [...wanted]).eq("deleted", false);
    if (error) throw error;
    if (teams.length !== wanted.size) throw new HttpError(400, "Équipe introuvable.");
  }
  const { data: current, error: cErr } = await admin.from("team_members").select("id, team_id, role, deleted").eq("user_id", userId);
  if (cErr) throw cErr;
  const now = new Date().toISOString();
  for (const m of current) {
    if (m.role !== "staff") continue;
    const keep = wanted.has(m.team_id);
    if (keep === !m.deleted) continue;
    const { error } = await admin.from("team_members").update({ deleted: !keep, updated_at: now }).eq("id", m.id);
    if (error) throw error;
  }
  const known = new Set(current.map((m) => m.team_id));
  const added = [...wanted].filter((t) => !known.has(t)).map((t) => ({ team_id: t, user_id: userId, role: "staff" }));
  if (added.length > 0) {
    const { error } = await admin.from("team_members").insert(added);
    if (error) throw error;
  }
  return { ok: true };
}

async function resetPassword(userId: string) {
  const password = temporaryPassword();
  const { data: existing, error: gErr } = await admin.auth.admin.getUserById(userId);
  if (gErr) throw new HttpError(404, "Compte introuvable.");
  const { error } = await admin.auth.admin.updateUserById(userId, {
    password,
    user_metadata: { ...existing.user.user_metadata, must_change_password: true },
  });
  if (error) throw error;
  await revokeSessions(userId);
  return { temporary_password: password };
}

async function setDisabled(userId: string, disabled: boolean) {
  const { error } = await admin.auth.admin.updateUserById(userId, { ban_duration: disabled ? BANNED : "none" });
  if (error) throw error;
  if (disabled) await revokeSessions(userId);
  return { ok: true };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  try {
    if (req.method !== "POST") throw new HttpError(405, "POST uniquement.");
    const me = await caller(req);
    const body = await req.json().catch(() => ({})) as Record<string, unknown>;

    let result: unknown;
    switch (body.action) {
      case "list": result = await list(); break;
      case "create": result = await create(body); break;
      case "list_teams": result = await listTeams(); break;
      case "list_players": result = await listPlayers(); break;
      case "set_role": result = await setRole(targetId(body, me), body); break;
      case "set_teams": result = await setTeams(targetId(body, me), body.team_ids); break;
      case "reset_password": result = await resetPassword(targetId(body, me)); break;
      case "disable": result = await setDisabled(targetId(body, me), true); break;
      case "enable": result = await setDisabled(targetId(body, me), false); break;
      default: throw new HttpError(400, "Action inconnue.");
    }
    return Response.json(result, { headers: CORS });
  } catch (e) {
    const status = e instanceof HttpError ? e.status : 500;
    // Ne jamais journaliser le corps de la requête ni un mot de passe.
    if (status === 500) console.error("admin-users:", e instanceof Error ? e.message : e);
    return Response.json({ error: e instanceof HttpError ? e.message : "Erreur interne." }, { status, headers: CORS });
  }
});
