# Conversation spaces consolidation — kind + attributes into the thread row

Status: PROPOSAL (owner review). Precedents: LA ADR 0024 (channel registry),
ADR 0129 (work threads), harness ADR 0144 (spaces layer), ADR 0145 (declared
thread kind), ADR 0028 (absorb-not-rename). Companion to
`docs/design/ecsly-boards-extraction.md`.

## The law this serves

**One authority per fact.** After ADR 0145 the thread row already declares
WHAT a conversation is (`kind`). The two LA-owned registries are the last
place a conversation fact lives OUTSIDE its thread row:

| Fact | Registry today | Thread row today | Consolidation |
|---|---|---|---|
| what it is | — (`kind: channel` pairing) | `kind` ✅ | done (ADR 0145) |
| which project | — | `projectId`/`projectRoot` ✅ | done (the seal) |
| display name | `channels.name` | `topic` | **topic IS the name** |
| membership | `channels.memberIds` | `participants` | **participants IS the membership** |
| identity mark | `channels.icon` | — | **new row key `icon`** |
| archive lifecycle | `channels.archived` | — | **new row key `archived`** |
| which room spawned work | `work_threads.parentThreadId` | — | **new row key `parentThreadId`** |
| secondary id | `channels.channelId` | `threadId` | **retired — threadId IS the id** |

Every row in the "consolidation" column removes a duplicate, never a fact.
`closed` (says refuse) and `archived` (leaves the live lists) stay TWO keys:
a channel can be archived while its thread stays open — different facts.

## Target row schema (additive only)

```
threads/<threadId> = {
  threadId, topic, createdBy, createdAt, closed, participants,
  projectId?, projectRoot?,          // work seal (existing)
  kind?,                             // dm | channel | session (ADR 0145)
  icon?,                             // channel mark; absent = '#' default
  archived?,                         // channel lifecycle; absent = live
  parentThreadId?,                   // work rows: the spawning room
  lastBeat,
}
```

Tolerant-decode law everywhere: absent key = the documented default; a wrong
type reads as the default. Never write `null` for an absent-means-default
key (the ADR 0145 rule generalizes).

## Absorption (three phases, absorb-not-rename)

**W1 — dual-write, row-preferred reads.** `openChannel`/`createChannel`
write the row keys AND the registry row (unchanged pairing, one more
destination); `archiveChannel` flips BOTH. Readers prefer the row field and
fall back to the registry scan when the row lacks it. Nothing breaks; old
rows keep working through the fallback forever.

**W2 — the idempotent heal.** One function in the owning package
(`ChannelRegistry.migrateIntoRows()` in `ecsly_conversation`), called at
boot (LA `ensureReady`; daemon start may call the same — idempotent, so a
double call is a no-op): for each registry row whose thread row lacks the
field, `tx.put` the row with `icon`/`archived`/`kind: 'channel'` backfilled.
Guarded per-field (write only what's missing), so W1-era rows are untouched.
The `healHumanIdentity` precedent — a heal lane, not a migration ceremony.

**W3 — retirement = operator constant flip** (the `kTaskBoardLegacyMirror`
pattern): fallback reads stop consulting the registry; verbs stop dual-
writing; the `channels`/`work_threads` collections are retained FOREVER
(the journal is authority — closing never destroys). Flip doubles nothing;
it only removes reads.

## Verb + policy changes

- `openChannel` (harness) / `createChannel` (LA): same open, row keys
  written; registry write kept until W3.
- `archiveChannel`: flips `row.archived` (+ registry until W3). Re-archive
  stays idempotent; `channel_not_found` becomes `thread_not_kind_channel`
  honesty (named refusal, same shape).
- `renameChannel` = topic edit (one fact, one write). Empty/duplicate-name
  policy (`ChannelNaming`) is UNCHANGED — the taken-set source becomes live
  channel topics from the thread projection (same single scan).
- `listChannels` = a projection over thread rows (`kind == 'channel' &&
  !archived`), not a collection scan.

## Surface-id absorption (the one contract risk)

`channel:<channelId>` today keys LA panes, `rooms.row.channel.<id>`,
`ShellDebugBridge.selectRoom`, and linkified tokens; `channelId ≠ threadId`
for legacy rows. Absorption:

- New channels: no `channelId` is minted — surface ids and keys use the
  threadId (`channel:thread-…`).
- Resolvers accept BOTH during the window: exact `channelId` match first
  (legacy), then `threadId` equality. The registry fallback (W1 law) makes
  legacy ids resolve exactly as today.
- After W3 the legacy branch remains as a read of the retained collection —
  legacy tabs and references never die (ADR 0028 lesson: the absorption
  window is versioned, never a rename).

## Consumer changes

- **LA `RealmChatService`**: `_refreshChannels` merges into
  `refreshThreads` — one `threadRows()` projection feeds the rail, the
  channel list, `roomThreads`, and sessions. `ChannelInfo` becomes a
  view-model built from the row (or dies; the UI consumes rows). `scanIndex`
  retires with W3 (its consumers read rows directly).
- **Harness verbs + `classifyThread`**: classifier is UNCHANGED (kind is
  already first in its chain; `icon`/`archived` are attributes, not kind).
- **Linkifier, mention grammar, bot host**: untouched (they speak
  threadIds and surface ids, both absorbed above).
- **Mesh**: nothing syncs the `channels` collection separately today
  (verified — only planning boards ride the mesh lane); thread rows ride the
  same store. No new sync surface, no delta.

## Efficiency payoff (the owner's ask)

One store scan serves everything the UI shows about conversations. The
second collection read disappears from every boot/refresh path; `scanIndex`
and its multi-projection build retire; the classifier's inferred path
(shapes + registry sets) becomes rare because every room is typed at birth.
Unread badges and previews fold from the same projection instead of two.

## Work-thread link (phase 2, small)

`WorkThreadLink` reduces to `parentThreadId` on the work row (`projectRoot`
already rides `projectId`/`projectRoot`; `createdBy` already rides the row;
`name` is presentation = topic). Same three phases; the reuse-key lookup
(parent × project) becomes a row read. The `work_threads` collection is
retained as legacy under the same W3 law.

## Risks

- **Two writers during W1** (LA service + harness verbs): both dual-write;
  the heal is idempotent and per-field; a double call cannot corrupt (last
  write is the same fact).
- **Uniqueness scan cost**: identical to today — one scan, in-memory set.
- **Broken mid-window reads**: impossible by construction — row-preferred +
  registry fallback means a missing field degrades to today's behavior,
  never to an empty list.
- **Key collision** (`rooms.row.channel.<id>` semantics change as ids
  become threadIds): keys are opaque to agents; the resolver absorbs both
  spellings; contract tests pin the legacy spelling still resolves.

## Test plan

Truth-table extensions (icon/archived defaults; topic-as-name uniqueness
across live channels; archived-not-closed says still succeed);
migration tests (pre-window backfill idempotency; W1 dual-write; W3 flip);
verb tests (archive flips row+registry, rename edits topic once); LA service
tests (one-projection rail; legacy `channel:<channelId>` tab reopens after
restart); wire pins for the absorbed surface ids.

## Implementation shape (when approved)

Harness ADR 0146 (the row schema + absorption law) → harness lane (row keys,
verb changes, heal function, W1 dual-write) → LA lane (projection merge,
ChannelInfo view-model, resolver absorption) → smoke/janitor sweep. Two
parallel subagent lanes after the harness lane, the established pattern.
