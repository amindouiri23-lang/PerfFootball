// Administration des comptes du staff, sans e-mail — docs/01-architecture-and-rules.md §7.1.
//
// POST { action: "list" }
// POST { action: "create", email, first_name, last_name, job_title, is_admin? }  -> { id, temporary_password }
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

const JOB_TITLES = ["fitness_coach", "head_coach", "assistant_coach", "physio", "doctor", "other"];
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
  const { data: profiles, error: pErr } = await admin.from("staff_profiles").select("id, first_name, last_name, job_title");
  if (pErr) throw pErr;
  const byId = new Map(profiles.map((p) => [p.id, p]));
  return data.users.map((u) => ({
    id: u.id,
    email: u.email,
    first_name: byId.get(u.id)?.first_name ?? null,
    last_name: byId.get(u.id)?.last_name ?? null,
    job_title: byId.get(u.id)?.job_title ?? null,
    is_admin: u.app_metadata?.role === "admin",
    is_disabled: !!u.banned_until && new Date(u.banned_until) > new Date(),
    must_change_password: u.user_metadata?.must_change_password === true,
    last_sign_in_at: u.last_sign_in_at ?? null,
  }));
}

async function create(body: Record<string, unknown>) {
  const email = String(body.email ?? "").trim().toLowerCase();
  const firstName = String(body.first_name ?? "").trim();
  const lastName = String(body.last_name ?? "").trim();
  const jobTitle = String(body.job_title ?? "");
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) throw new HttpError(400, "Adresse e-mail invalide.");
  if (!firstName || !lastName) throw new HttpError(400, "Prénom et nom obligatoires.");
  if (!JOB_TITLES.includes(jobTitle)) throw new HttpError(400, "Fonction invalide.");

  const password = temporaryPassword();
  const { data, error } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true, // aucun e-mail de confirmation
    app_metadata: body.is_admin === true ? { role: "admin" } : {},
    user_metadata: { must_change_password: true },
  });
  if (error) {
    if (error.message.toLowerCase().includes("already")) throw new HttpError(409, "Un compte existe déjà avec cette adresse.");
    throw error;
  }
  const { error: pErr } = await admin.from("staff_profiles").insert({
    id: data.user.id, first_name: firstName, last_name: lastName, job_title: jobTitle,
  });
  if (pErr) {
    await admin.auth.admin.deleteUser(data.user.id); // pas de compte sans profil
    throw pErr;
  }
  return { id: data.user.id, temporary_password: password };
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
