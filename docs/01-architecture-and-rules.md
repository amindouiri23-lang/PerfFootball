# 01 — Architecture, data model and development rules

This document records the technical decisions taken during the initial brainstorm and the rules
every developer (human or AI assistant) must follow. It is the reference: if the code needs to
diverge from it, update this document and add a line to the **Decision log** (§11).

---

## 1. Context

- **User**: the team's fitness coach (préparateur physique) and, later, other staff members.
- **Goal**: capture training and match data pitchside, quickly, even without network, and make it
  available to **Power BI** dashboards.
- **Scale**: one squad (~30 players), a few staff phones. About 20,000 rows per season (~10–20 MB).

---

## 2. Architecture

```
Staff phones — Flutter app (APK), local SQLite database, works offline
        │  supabase_flutter SDK: login + sync when network is available
        ▼
Supabase (free plan): Postgres + Auth + Row Level Security (+ Edge Functions later)
        │  phase 1: Power BI Desktop connects directly to Postgres
        │  phase 2: nightly Edge Function exports CSV files
        ▼
SharePoint / OneDrive for Business folder ──► Power BI (scheduled refresh)
```

### Decisions

| # | Decision | Why |
|---|---|---|
| D1 | **Flutter** app | One codebase for Android now and **iOS later**. |
| D2 | **Android first**, distributed as an **APK** (no Play Store); **iOS-ready code** | A handful of staff devices; no store review, no fee. iOS will need TestFlight or the App Store (Apple developer account). |
| D9 | **Phones and tablets**: one responsive UI | Phone for pitchside entry, tablet for squad-wide grids. Layout switches on screen width, not on device type (§4 of the specs). |
| D10 | **No email at all (no SMTP)**: an in-app admin creates accounts, resets passwords and disables accounts, through one Supabase Edge Function | No SMTP account to manage; staff are a handful of people the admin knows. See §7.1. |
| D3 | **Supabase free plan** is the backend | Postgres + Auth + auto REST API + RLS; 500 MB is ~25 seasons of data. |
| D4 | **No custom backend** | Supabase covers API, auth and permissions. Server logic, when needed, goes into Supabase Edge Functions. |
| D5 | **Offline-first**: the app always writes locally first, then syncs | Pitchside network is unreliable. |
| D6 | **The Supabase database is the single source of truth** | CSV files are only a one-way export, never written by the app nor edited by hand. |
| D7 | **Power BI**: direct Postgres connection first, CSV export to SharePoint later | Start with zero server code; add the export for scheduled refresh and backup. |
| D8 | **Raw data only** in the database; metrics are computed in Power BI (DAX) | A formula change never requires a data migration. |

---

## 3. Tech stack (Flutter)

| Concern | Package | Note |
|---|---|---|
| State management | `flutter_riverpod` | |
| Local database | `drift` (SQLite) | Typed queries, migrations, reactive streams. |
| Backend SDK | `supabase_flutter` | Auth + REST. |
| Navigation | `go_router` | |
| IDs | `uuid` | v4 for entities, v5 for deterministic IDs (§5.3). |
| Background sync | `workmanager` (later) | v1: sync on app start, on network back, and on button press. |
| Connectivity | `connectivity_plus` | |

Keep the dependency list short. Adding a package requires a reason written in the PR.

**iOS readiness rules** (so the iOS version is a build, not a rewrite):
- Only use packages that support **both Android and iOS** (check pub.dev platform badges).
- No Android-only code (`MethodChannel` to Kotlin, Android intents) without an iOS equivalent.
- File paths through `path_provider`, never hard-coded Android paths.
- Material 3 widgets everywhere; no platform-specific UI forks.
- Test on at least one phone-sized and one tablet-sized emulator before each release.

---

## 4. Data rules (mandatory)

1. **Every row has a UUID generated on the phone** (`id uuid primary key`). Never use auto-increment IDs.
2. **Every table has** `created_at`, `updated_at`, `server_updated_at`, `deleted` (boolean).
   - Rows are **never physically deleted**: set `deleted = true` (soft delete).
   - `server_updated_at` is set by a Postgres trigger (`now()`) on insert and update; it is the
     sync cursor. The app never writes it.
3. **Store raw inputs only**: RPE, minutes, distances… Never store sRPE load, ACWR, monotony, etc.
4. **Dates**: `date` columns for calendar days (`2026-10-07`), `timestamptz` (UTC) for instants.
5. **Units in column names**: `distance_m`, `weight_kg`, `duration_min`, `max_speed_kmh`.
6. **snake_case** everywhere, table names in plural (`players`, `sessions`).
7. **Tests in long format** (v2): one row per result (`player_id, date, test_type_id, value`), so a new
   test type needs no schema change.
8. **No photos in the database**: Supabase Storage, compressed to ~100 KB.
9. **No raw GPS streams**: only per-session summaries.

---

## 5. Data model (v1)

UI is in French; database names stay in English snake_case. Functional specs:
[02-specifications-fonctionnelles.md](02-specifications-fonctionnelles.md).

### 5.1 Accounts and team

**`staff_profiles`** — one row per Supabase Auth user
| column | type | note |
|---|---|---|
| id | uuid | = `auth.users.id` |
| first_name, last_name | text | required |
| job_title | text | e.g. "Préparateur physique" |
| phone | text | nullable |
| photo_path | text | Supabase Storage, nullable |

**`teams`**
| column | type | note |
|---|---|---|
| id | uuid | |
| name | text | required, e.g. "Seniors A" |
| club_name | text | nullable |
| category | text | `seniors`, `u19`, `u17`… |
| season | text | e.g. `2026-2027` |
| logo_path | text | nullable |

**`team_members`** — who can see a team's data (basis of RLS)
| column | type | note |
|---|---|---|
| team_id | uuid → teams | |
| user_id | uuid → auth.users | |
| role | text | `owner` (creator); `staff` reserved for invitations (backlog) |

**`players`**
| column | type | note |
|---|---|---|
| id | uuid | |
| team_id | uuid → teams | |
| first_name, last_name | text | required |
| shirt_number | int | nullable |
| position | text | `GK`, `DEF`, `MID`, `FWD` |
| birth_date | date | nullable |
| dominant_foot | text | `L`, `R`, `B`, nullable |
| height_cm | int | nullable |
| photo_path | text | nullable |

Deleting a player = soft delete (`deleted = true`): the player disappears from the app, the
history stays available to Power BI.

### 5.2 Training sessions

**`sessions`**
| column | type | note |
|---|---|---|
| id | uuid | |
| team_id | uuid → teams | |
| date | date | required |
| start_time | time | required |
| type | text | `technical`, `tactical`, `physical`, `mixed`, `recovery`, `gym`, `other` |
| planned_duration_min | int | default 90 |
| objective | text | nullable |
| remarks | text | remarks on the whole session, nullable |
| status | text | `planned` → `in_progress` (attendance confirmed) → `completed` |

**`session_players`** — one row per player of the team per session (attendance + load)
| column | type | note |
|---|---|---|
| id | uuid | deterministic (§5.5) |
| session_id, player_id | uuid | |
| present | boolean | default `true` |
| absence_reason | text | `injured`, `sick`, `national_team`, `personal`, `other`, nullable |
| duration_min | int | actual minutes, default = planned duration |
| rpe | int | 0–10 (CR-10), nullable |
| remark | text | remark on this player for this session, nullable |

**`wellness`** — questionnaire filled after a session
| column | type | note |
|---|---|---|
| id | uuid | deterministic (§5.5) |
| session_id, player_id | uuid | |
| sleep_hours | numeric | 0–14, step 0.5 |
| sleep_quality, fatigue, soreness, stress, mood | int | **1–5, 5 = best** for every item |
| remark | text | nullable |

### 5.3 Matches

**`matches`**
| column | type | note |
|---|---|---|
| id | uuid | |
| team_id | uuid → teams | |
| date | date | required |
| kick_off_time | time | required |
| opponent | text | required |
| home_away | text | `H`, `A`, `N` |
| competition | text | `league`, `cup`, `friendly`, `tournament` |
| duration_min | int | default 90 |
| goals_for, goals_against | int | final score, nullable until the match ends |
| remarks | text | nullable |
| status | text | `planned` → `in_progress` → `completed` |

**`match_players`** — one row per player of the team per match
| column | type | note |
|---|---|---|
| id | uuid | deterministic (§5.5) |
| match_id, player_id | uuid | |
| present | boolean | in the squad for the match |
| absence_reason | text | same values as sessions + `not_selected` |
| role | text | `starter`, `sub`, nullable if absent |
| minutes_played | int | 0–150 |
| rpe | int | 0–10, nullable |
| remark | text | nullable |

**`match_events`**
| column | type | note |
|---|---|---|
| id | uuid | |
| match_id, player_id | uuid | the scorer / the booked player |
| type | text | `goal`, `yellow_card`, `red_card` |
| minute | int | 1–130 |
| assist_player_id | uuid | goals only, nullable |
| remark | text | nullable |

Assists are counted from `assist_player_id` (no separate event, no double entry). Injuries are not
events: they live in `injuries` with `match_id` + `minute`, and the app merges both in the timeline.

### 5.4 Injuries

**`injuries`**
| column | type | note |
|---|---|---|
| id | uuid | |
| team_id, player_id | uuid | |
| session_id / match_id | uuid | where it happened, both nullable (injury outside the club) |
| minute | int | matches only, nullable |
| date | date | |
| body_area | text | `head`, `neck`, `shoulder`, `arm`, `back`, `hip_groin`, `thigh_front`, `thigh_back`, `knee`, `calf`, `ankle`, `foot`, `other` |
| side | text | `left`, `right`, `both`, nullable |
| type | text | `muscle`, `ligament`, `bone`, `contusion`, `tendon`, `other` |
| mechanism | text | `contact`, `non_contact`, `overuse` |
| severity | text | `minor` (≤ 3 days), `moderate` (4–28 days), `severe` (> 28 days), estimate |
| description | text | nullable |
| expected_return_date, return_date | date | the injury is **open** while `return_date` is empty |

### 5.5 Deterministic IDs (avoid duplicates between devices)

For tables with a natural key, the ID is a **UUID v5** computed from that key, so two devices
produce the same ID and the second write becomes an update, not a duplicate:

| table | natural key |
|---|---|
| `session_players` | `session_id + player_id` |
| `match_players` | `match_id + player_id` |
| `wellness` | `session_id + player_id` |

A `unique` constraint on the natural key is also added in Postgres as a safety net.

**Namespace** (fixed forever — changing it would create duplicates): `71d5779a-5c07-404c-8757-26e95c0f8b4a`.
Name = the two UUIDs joined with `:`, e.g. `uuidv5(NS, '<session_id>:<player_id>')`.

### 5.6 Implementation notes (as built in `supabase/migrations/`)

- **Every team-scoped table carries `team_id`** (also `session_players`, `wellness`, `match_players`,
  `match_events`, `injuries`), so all security rules are the same one-liner. Composite foreign keys
  `(player_id, team_id)`, `(session_id, team_id)`, `(match_id, team_id)` guarantee a row can never mix
  two teams.
- `teams.created_by` defaults to the caller; a trigger then inserts the `owner` row in `team_members`.
  **`team_members` is pull-only** for the app (no client writes).
- Enum-like columns are `text` + `check` constraints (values in English, labels in French in the app).
- No `DELETE` permission for the app, and the `anon` role has no access to any table.
- Power BI reads the **`reporting` schema** (views with names and dates joined, deleted rows excluded
  except players) as the read-only role `powerbi_reader`.
- Photos: private bucket `photos`, paths `teams/<team_id>/…` and `profiles/<user_id>.jpg`, 512 KB max.

### 5.7 Later (v2, not built in v1)

`test_types` / `test_results` (physical tests, long format), `body_measurements` (weight, body fat),
GPS summary columns on `session_players` and `match_players` (`distance_m`, `hsr_m`, `sprints`,
`accelerations`, `decelerations`, `max_speed_kmh`).

---

## 6. Synchronisation

- Each local table has an extra column `is_dirty` (not synced).
- **Write**: the app writes locally, sets `updated_at = now()` and `is_dirty = true`. The UI never
  waits for the network.
- **Push**: upsert all dirty rows to Supabase, in dependency order (`staff_profiles`, `teams`,
  `players`, `sessions`, `matches`, then the other tables), then set `is_dirty = false`.
- **Pull**: for each table, fetch rows with `server_updated_at > last_pull_cursor`, upsert them
  locally, store the new cursor.
- **Conflicts**: last write wins (the last push received by the server). Acceptable for a small
  staff; revisit if it causes problems.
- **When**: app start, network back online, after each save (debounced), and "Sync now" button.
- The UI always shows the number of unsynced rows and the last successful sync time.

---

## 7. Security

- **Login required**: one Supabase Auth account (email + password) per staff member. No public
  sign-up (disabled in the Supabase dashboard) — accounts are created by an in-app admin (§7.1).
- **Row Level Security enabled on every table**; v1 policy: a user reads and writes only the rows
  of the teams they belong to (`team_members`), and only their own `staff_profiles` row.
- **The `anon` key is in the APK and must be considered public**: RLS is what protects data.
- **Never put the `service_role` key in the app** or in the repository.
- Wellness, injury and body data are **sensitive health data**: access limited to staff, a player's
  data must be deletable on request (hard delete by the admin, outside the app).
- **Forgotten password**: no email. The user asks an admin, who resets it in the app (§7.1).
- Lost phone: an admin disables the staff member's account in the app (§7.1).
- Secrets (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) passed with `--dart-define`, never committed.


### 7.1 Account administration (no email)

The `anon` key cannot create users or change someone else's password: that needs the
**service-role key**, which must never be in the app. So admin actions go through **one Supabase
Edge Function, `admin-users`**, where the service-role key is available as an environment variable
(`SUPABASE_SERVICE_ROLE_KEY`, injected by Supabase).

| Element | Rule |
|---|---|
| **Admin flag** | `auth.users.app_metadata.role = 'admin'`. `app_metadata` can only be written with the service-role key, so a user cannot make themselves admin. The **first admin** is set once by the developer in the SQL editor: `update auth.users set raw_app_meta_data = raw_app_meta_data \|\| '{"role":"admin"}' where email = '…';` |
| **Caller check** | The function reads the caller's JWT, rejects with 403 unless `app_metadata.role = 'admin'`. |
| **Actions** | `list` (staff accounts + status) · `create` (email, names, job title, admin flag) · `reset_password` · `disable` / `enable`. |
| **Create** | `auth.admin.createUser({ email, password: temp, email_confirm: true, user_metadata: { must_change_password: true } })` + insert `staff_profiles` row. `email_confirm: true` means no confirmation email. |
| **Reset** | `auth.admin.updateUserById(id, { password: temp, user_metadata: { must_change_password: true } })` and sign the user out of existing sessions. |
| **Disable / enable** | `ban_duration: '876000h'` / `'none'`. Data is kept. |
| **Temporary password** | 12 random characters generated **in the function**, returned once in the response, never stored or logged. |
| **Forced change** | After login, if `user_metadata.must_change_password` is true, the app shows only the "new password" screen. `updateUser({ password, data: { must_change_password: false } })` clears it. |
| **Guard rails** | An admin cannot disable or reset their own account through the function. All admin actions require network. |

Supabase Auth settings: **disable sign-ups**, keep **"Secure password change" off** (it would send a
reauthentication email). Edge Functions are free up to ~500,000 calls/month — this is not a backend
to host.

---

## 8. Supabase free-plan constraints

| Constraint | Consequence |
|---|---|
| 500 MB database | Enough for ~25 seasons; no photos or GPS streams in the DB. |
| **Project paused after 7 days without activity** | Off-season / international breaks: restore from the dashboard. Phase 2 nightly job may keep it awake (to verify). |
| **No automatic backups** | Phase 2 CSV export doubles as backup. Until then, export manually once a month. |
| 1 GB file storage | Player photos only, compressed. |

Re-check limits on supabase.com/pricing before relying on them; they change.

---

## 9. Distribution (APK)

- **Release keystore**: create once, store it and its password **outside** the dev machine
  (password manager). Losing it = staff must uninstall/reinstall (local unsynced data lost).
- **Increase `versionCode`** (`version: x.y.z+N` in `pubspec.yaml`) on every release.
- Distribute with **Firebase App Distribution** (free) or a shared link.
- Staff phones: allow "Install unknown apps" once.
- Before releasing a version that changes the local schema, write and test the Drift migration.

---

## 10. Power BI metrics (for reference)

Computed in DAX, never stored:
- **sRPE load** = `rpe × duration_min` (session) / `rpe × minutes_played` (match)
- **Acute load** (7 days), **chronic load** (28 days), **ACWR** = acute / chronic
- **Monotony** = weekly mean daily load / standard deviation; **strain** = weekly load × monotony
- **Wellness score** = sum of the five 1–5 items (5–25)

---

## 11. Development rules

1. **Read this document and the specs before coding.** State assumptions, flag ambiguities.
2. **Simplest solution first.** No abstraction, option or feature that the specs don't ask for.
3. **Surgical changes**: touch only what the task needs; no unrelated refactoring or reformatting.
4. **Every schema change** = a Supabase SQL migration (versioned in `supabase/migrations/`)
   **and** a Drift migration. Never edit an applied migration.
5. **Offline must always work**: no screen may block on the network.
6. **Fast entry is the priority**: any data entry flow must be doable pitchside with one hand.
7. **One branch + one PR per change**; no direct commit on `main`.
8. Any decision that diverges from this document is written in the Decision log below.

### Decision log

| Date | Decision |
|---|---|
| 2026-10-07 | Initial decisions D1–D9 (brainstorm). |
| 2026-10-09 | Web build (used for testing only): Drift runs SQLite WebAssembly on the main thread with IndexedDB (`lib/data/connection_web.dart`) instead of drift_flutter's SharedWorker, which some embedded browsers cannot use. `web/sqlite3.wasm` must match the `sqlite3` package version. Android/iOS keep native SQLite. |
| 2026-10-08 | D10: no SMTP. Password reset and account creation by an in-app admin via the `admin-users` Edge Function; email recovery flow removed. |
| 2026-10-07 | v1 scope redefined by the coach's workflow: teams, attendance, session/player remarks, injuries, post-session wellness, match events. Physical tests and body measurements moved to v2. **App UI in French.** |
