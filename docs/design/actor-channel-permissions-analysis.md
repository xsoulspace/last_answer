# Actor & channel permission management — analysis

**Date:** 2026-11-18 · **Status:** IMPLEMENTED (waves W1–W4 landed 2026-11-18,
uncommitted; harness ADR 0147 is the decision record; W5 sub-delegation landed
INSIDE the grant verb — monotonic, no expiry, per the owner's same-day decisions)
**Ask:** manage permissions per channel and per actor — add/remove any folder/project
permission and other permissions, large and small, so any local work can be delegated.

> **Implementation notes (deltas from the original analysis, all owner-decided):**
> the manage policy DEFAULT is `realm` (today's ungated law — `members`/`owners`
> are opt-in narrowings; the CV-8 test forced this correction over the analysis's
> `members` default); channel-conferred scope landed (derived from membership, the
> Discord-side model — nothing to chase on eviction); sub-delegation landed inside
> `grantActorScope` (monotonic: caps ⊆ held, scope covered; no expiry; the channel
> OPENER is exempt when binding a channel work scope — the server-owner model);
> the image-spend budget folded into the ledger (`image.spend:<usd>`, narrowest
> wins, global config fallback); argv run-lists stay global (per-grant later).
> `close` switched from exact-project equality to the shared visibility read so a
> project-bound actor can reach a realm-sealed channel's owners gate.

---

## 1. Current state (verified against source, 2026-11-18)

### What already exists

| Mechanism | Where it lives | Granularity | Enforcement |
|---|---|---|---|
| **Project grants** (ADR 0121/0129) | `realm_actors.projects` ∪ `participants.projects` in the realm journal; canonical project-root paths | Per actor × project root | Thread seal `project_not_granted` (`durable_conversation.dart:103-123`); read visibility `_actorCanSee` (`durable_conversation.dart:857`); seat project binding (`durable_realm_authority.dart:189-213`) |
| **Access-request plane** (ADR 0124) | `project_access_requests` rows, state `pending` | Project only, human approves | `durable_realm_tools.dart:1176-1241`; no self-grant |
| **Internal-actor tool posture** | ONE global `realm_actor_tools` config key (`realm_actor_tool_loop.dart:122-163`) | Global for ALL internal actors: `write/run/world/commit` + `run_allow` argv prefixes + `run_exact` argv | Deny-by-default read-only floor; armed run bounded by argv lists |
| **Seat capability tiers** | `SeatGrantProfile.resolve` (`seat_grant_profile.dart:42-103`) | Two tiers keyed by client family: `coding` (tool allowlist) vs `thin` (chat only); `palette_apply` operator-minted only | `harness_agent_tools.dart:253-357` |
| **Per-actor model policy** (ADR 0143) | `realm_actors.brainSet`, `selfBind` | Per actor, models only | `updateActor` verb |
| **Per-actor image spend ceiling** (LA ADR 0029) | `realm_actor_image_budget_usd` | Per actor, numeric | `image_budget_exhausted` refusal |
| **Path-scoped task consent** | `conventional_task_consent` config (`task_consent.dart:26-80`) | Per-workspace CONFIG, not per-actor: `writablePaths`, authorizers, lifetime | Fail-closed against `writablePaths` |
| **Per-chat ACP stance** | `ChatPermissionPolicy` (`lib/doc/chat_permission_policy.dart:17-113`, fresh, no other callers) | Per chat: `ask`/`workspaceEdits`/`fullAccess` | Client-side policy decides ACP `request_permission` |
| **Permission inbox** | `world_state_service.dart:1040-1088` + landing/status-edge render | Session permission requests with `answer(allow)` | Reject-first for ACP bridges |

### What does NOT exist (the gaps this work fills)

1. **Per-channel permissions.** Channels are realm-sealed threads (`kind:'channel'`, ADR 0146:
   the thread row is the sole authority). Every agent can read and `say` auto-joins; `memberIds`/`participants`
   are fan-out and addressing only. No read/say/manage ACL, no roles, no owners.
2. **Folder (sub-project) grants.** Grants are canonical project roots only. Nothing below the
   root is grantable, and FS containment for internal actors rides the thread's `projectId`
   workRoot, not a per-actor path set.
3. **Per-actor work capabilities.** All internal actors share the one global
   `realm_actor_tools` posture. No per-actor write/run/commit caps.
4. **Member management.** `participants` only ever grows (`say` auto-joins; invitees named at
   `open`). No invite/remove verbs; `_ChannelMembersDialog` (`world_chat_surface.dart:4703`) is read-only.
5. **Delegation of authority between actors.** The only widening act is ADR 0129's thread seal
   bounded by grants the caller already holds ("no new authority exists"). An actor cannot grant
   another actor anything; everything else is the operator (`ecsai --grant`, LA twin
   `RealmChatService.grantAccess` at `realm_chat_service.dart:1801-1885`).
6. **Revocation granularity / expiry.** Grants are additive sets; revoke is operator-only and
   retires grant+identity together. No expiry on grants.

## 2. Design laws to respect (existing, not new)

- **Deny-by-default.** Every posture parser here starts at a read-only floor; a new cap
  vocabulary must too (absent key = current floor, never = "everything").
- **The seal IS the sandbox** (ADR 0129). Work scope is conferred by the thread's `projectId`,
  read by the daemon dispatch as the actor's filesystem workRoot. Any folder work should ride
  the same seam, not a parallel one.
- **No new authority / monotonic delegation.** A grant a caller mints is bounded by grants it
  already holds. Sub-delegation (if approved) must inherit this law structurally, not by convention.
- **Conversation never widens work scope** (ADR 0124). A realm-sealed channel must stay unable
  to confer project membership; visibility and work authority are enforced independently (ADR 0090).
- **Absorb-not-rename** (ADR 0028 / LA ADR 0028). New facts land as additive row keys with
  row-preferred reads; derived reads (`agentProjectGrants`) keep their contract; legacy
  collections are retained.
- **Honest refusals carry evidence.** `project_not_granted` returns current grants; new
  refusals (`path_not_granted`, `channel_members_only`) must carry the same shape of evidence.
- **The journal is the one authority** (ADR 0118). All new grant/policy records go through
  `RealmControlStore.transact`; LA consumes via thin verbs, never side-channel writes.

## 3. Proposed model

### 3.1 Grant ledger (`actor_grants` collection)

One new journal collection replaces nothing; the legacy `projects` fields keep working and the
derived read unions over both (absorb-not-rename):

```
actor_grants / <grantId>:
  actorId      String           // grantee
  scope        { kind: 'project' | 'folder',
                 root: String,   // canonical absolute project root
                 subpath: String? // workspace-relative, no '..', for kind:'folder'
               }
  caps         Set<String>?     // null = membership only (today's behavior exactly)
  grantedBy    String           // actorId or 'operator'
  grantedAt    DateTime
  expiresAt    DateTime?        // null = operator-granted, no expiry (today's behavior)
  revokedAt    DateTime?
  via          String?          // 'channel:<threadId>' when channel-conferred (phase-gated)
```

**Derived authority read** (replaces direct `grantsOf` consumption over time; contract
preserved): `agentProjectGrants(actor)` = legacy `realm_actors.projects` ∪ `participants.projects`
∪ ledger grants with `scope.kind == 'project'` (unrevoked, unexpired). Folder grants do NOT
appear in the project-grant set; they feed the FS containment check instead.

**Cap vocabulary** (flat set, deliberately no roles/hierarchy):

| Cap | Meaning | Today's equivalent |
|---|---|---|
| `fs.read` | read files under scope | implicit with any grant |
| `fs.write` | write/edit files under scope | global `realm_actor_tools.write` |
| `fs.run` | run commands (argv lists per grant or global posture) | global `run` + `run_allow`/`run_exact` |
| `vcs.commit` | commit under scope | global `commit` |
| `world.verbs` | task/thread durable verbs | global `world` |
| `models.selfbind` | rebind own brain | per-actor `selfBind` (stays where it is) |
| `palette.apply` | apply palette edits | owner-only gate (`palette_apply_not_owner`) |
| `image.spend:<usd>` | generative image budget | `realm_actor_image_budget_usd` (may stay separate — open question) |
| `channel.manage` | rename/archive/icon/invite on channels where holder is member | nobody but implicit participants today |

A grant with `caps: null` is byte-compatible with today's project grants: visibility + seal +
workRoot, full default caps. Nothing changes for existing actors until a ledger row says otherwise.

### 3.2 Per-actor effective posture (small permissions, resolved)

```
effectiveCaps(actor, scope) =
    global realm_actor_tools floor            (operator config, unchanged)
  ∩ ledger caps for the narrowest matching grant (folder ⊃ project)
  ∩ brainSet/selfBind/model policy             (unchanged, ADR 0143)
```

Resolution order per FS operation in the daemon tool loop: match the operation path against
grants, narrowest scope wins; a folder grant cannot widen what a project grant narrows unless it
explicitly re-arms (intersection semantics, deny-by-default preserved). Absent any ledger row →
exactly today's global posture, so W1/W2 are behavior-neutral for existing setups.

### 3.3 Channel policy (additive thread-row keys, ADR 0146 absorb pattern)

```
threads / <threadId>  additive keys:
  access: { read:  'realm' | 'members',     // default 'realm'  (today)
            say:  'realm' | 'members',     // default 'realm'  (today)
            manage: 'members' | 'owners' } // default 'members'(today: all participants)
  owners: [actorId]?                        // default absent = opener is owner
```

- **read = members**: `_actorCanSee` gains a channel-policy branch for realm-sealed threads
  (`projectId == null`): members (or owners) only, refusal `thread_not_visible` with evidence.
- **say = members**: `say` stops auto-joining for non-participants when policy is `members`;
  refusal `channel_members_only` + the existing join-request plane (ADR 0124) becomes the entry
  (channel join grants presence, never work scope — law preserved).
- **manage**: rename/archive/icon/close/invite gated by `access.manage` + `channel.manage` cap.
  **Law change to name explicitly:** today `close` "belongs to its participants, not its opener
  alone" (`durable_conversation.dart:~509`) — with owners set, manage may narrow to owners.
- **Member verbs:** new `inviteParticipants` / `removeParticipants` (participants may shrink for
  the first time); gate by manage policy; removal never deletes beats (history belongs to the
  thread, not the member).

### 3.4 Channel work scope (delegation convenience, phase-gated)

Additive channel key `workScope?: {kind, root}`: a channel can be bound to a project or folder.
- Spawning work from the channel (`spawnWorkThread`, `realm_chat_service.dart:1527`) prefills
  the seal from `workScope` — the seal remains the sandbox, and the HUMAN's grant check still
  applies exactly as today (ADR 0129 unchanged).
- Channel-conferred grants (`via: 'channel:<id>'` ledger rows auto-granted to members, auto-
  revoked on removal) are the true "join a channel → get folder access" experience. This is the
  one mechanism that widens work authority via conversation, so it needs an explicit owner
  decision + ADR before landing (default plan: NOT in W1–W4).

### 3.5 Sub-delegation (actors granting actors) — owner decision required

- **Option A (recommended default, W1–W4):** granting stays human-only (operator CLI + LA UI +
  inbox). Actors can only *request* (existing `project_access_requests` plane, extended to
  folders/caps). No law change.
- **Option B (W5, gated):** an actor may grant a **subset** of a grant it holds: caps ⊆ held,
  scope ⊆ held (folder within granted project), mandatory `expiresAt`, `grantedBy` chain recorded,
  depth-limited (e.g. 2). Monotonicity enforced inside the grant verb itself (capability algebra),
  not by convention. Revoke of the parent cascades or orphans-expire (pick one, write it down).
  Requires an ADR in the harness repo; `ecsai --grant` remains the operator plane.

## 4. Enforcement points to touch

| # | Site | Change |
|---|---|---|
| 1 | `durable_conversation.dart:103-123` (seal check) | accept folder scopes: sealing to a folder requires a folder grant or containing project grant; refusal evidence unchanged |
| 2 | `_actorCanSee` (`durable_conversation.dart:857`) | channel-policy branch for realm-sealed threads (read=members) |
| 3 | `say` (~`:206-243`) | say-policy gate + conditional auto-join + `channel_members_only` |
| 4 | thread management verbs (rename/archive/icon/close) | manage gate |
| 5 | new `inviteParticipants`/`removeParticipants` | manage gate; participants may shrink |
| 6 | `realm_actor_tool_loop.dart` posture resolution | per-actor overlay: ledger caps ∩ global floor; FS containment extended from thread `projectId` workRoot to per-actor grant roots (canonicalize + prefix, symlink law as in `headless_product_cli.dart:196-199`); new refusal `path_not_granted` |
| 7 | `realm_bot_host.dart` wake loop (`_WakeLoop`) | check channel read policy/membership before waking a bot on an addressed beat — otherwise members-only channels leak beats to non-member bots |
| 8 | `durable_realm_tools.dart` grant verbs | extend `project_access` → scope+caps+expiry; list/pending/request/grant/revoke |
| 9 | LA `RealmChatService` thin verbs (~`:1801-1885`) | wrap the extended verbs; keep VERIFY re-read pattern |
| 10 | LA MCP `realm_project_access` / `realm_chat_spawn_work` (`realm_chat_mcp_tools.dart:309,407`) | scope+caps args; honest refusals unchanged |
| 11 | `world_state_service.dart` inbox | render folder/cap/expiry requests; danger styling preserved |

Seat tiers (`SeatGrantProfile`, `harness_agent_tools.dart`) are deliberately out of scope for
W1–W4: seats are client-family-derived today and per-actor seat caps are a separate harness ADR.

## 5. UI plan (LA)

- **Channel** — `_ChannelPermissionsDialog` (`world_chat_surface.dart:4496`) finally earns its
  name: three sections — Access policy (read/say/manage pickers), Members (add/remove, replacing
  read-only `_ChannelMembersDialog`), Work scope & grants (per-member project/folder grants +
  pending requests, the existing rows verbatim). Rooms-column context menu (`rooms_column.dart`
  keys `rooms.menu.*`) gains "Permissions". Widget keys per DESIGN.md (`worldchat.perms.*`).
- **Actor** — `ActorInfoSurface` gains a **Permissions** section under the existing
  `ProjectAccessSection` (`view_people.dart:809-950` pattern): grant list by scope with cap
  chips, add/remove with folder picker (relative to a known workspace root), optional expiry.
  `actors_panel.dart` row editor gains caps summary; keep editors thin (proposal surfaces, not
  raw JSON).
- **Scope picker** (`project_scope_picker.dart`) — folders appear as children of granted roots;
  `granted` stays a fact tag, ungranted spawn still refuses honestly with one-tap grant.
- **Inbox** — extended request rows (folder/caps/expiry) render in landing inbox + status edge.
- **l10n** — all new user-facing strings in EN/IT/RU (`intl_*.arb` + `just gen`).

## 6. Rollout (absorb-not-rename phases)

- **W1 — grant ledger (harness):** `actor_grants` collection + typed verbs (grant/revoke/list
  with scope+caps+expiry) + derived authority union. Store tests. Zero behavior change for
  existing actors (no rows = today).
- **W2 — enforcement (harness):** folder-aware seal check; per-actor posture overlay + FS
  containment in the daemon tool loop; `path_not_granted`. Harness tool-loop tests incl.
  traversal/symlink escapes.
- **W3 — channel ACL (harness + LA wiring):** additive `access`/`owners` keys, member verbs,
  read/say/manage gates, bot-host wake filter. Default keys absent = today's behavior.
- **W4 — LA UI:** channel permissions editor, actor permissions section, scope picker, inbox,
  MCP verbs, l10n. Tests: `test/shell/*`, `test/coding_agent/*` per existing patterns;
  `fvm flutter analyze` + `fvm flutter test` green.
- **W5 — owner-gated:** sub-delegation (Option B), channel-conferred grants (3.4 second bullet),
  optional consolidation of image budget into the ledger.

## 7. Risks & non-goals

**Risks.** Folder grants widen blast radius below the project root — containment must be
airtight (canonicalize, reject `..`/absolute escapes, symlink resolution at every boundary, the
`conventional_task_consent` path laws are the precedent). The read-policy change touches the
visibility law every projection reads (People view `view_people.dart:~206`, actor info
memberships, wake loops) — W3 must sweep all `memberIds ?? participants` readers. Bot hosts
must not wake on beats from channels they cannot read (§4.7). Revocation must reach live bot
loops: posture is resolved per dispatch already; keep it that way (no cached capability objects).

**Non-goals.** Role ladders (owner/admin/mod hierarchies) — flat caps + owners list cover the
need; deny lists — additive grants + revoke only (deny lists are a known trap); per-beat ACLs;
cross-device grant sync — the journal is device-local by design (only task boards mesh-sync);
per-actor seat-tier rework.

## 8. Open questions for the owner

1. Channel `say` default: keep realm-wide (`realm`) as default, with `members` opt-in per
   channel? (Recommended: yes — no behavior change until a channel sets policy.)
2. Should auto-join survive for `members` channels, or should joining require the request plane?
   (Recommended: request plane; auto-join is what makes membership non-restrictive today.)
3. Sub-delegation (§3.5 Option B): wanted at all? Defaults for depth and expiry?
4. Channel-conferred grants (`via:` rows): yes eventually, or keep scope conferral strictly
   thread-seal-based? (Recommended: thread-seal only for now.)
5. Move `realm_actor_image_budget_usd` into the ledger as `image.spend`, or leave it?
6. Are `run_allow`/`run_exact` argv lists per-grant worth the surface, or keep them global-only
   in W1–W4? (Recommended: global-only first; per-grant argv in W5 if needed.)
