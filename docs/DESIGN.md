# DESIGN — principles for last_answer surfaces

> Binding design law for product UI. The **agent-doc surface**
> (`lib/coding_agent/agent_doc_surface.dart`) is the reference
> implementation — when a new surface is built, copy its discipline, not
> its pixels. Principles: Edward Tufte (ink, data, annotation) × Josef
> Müller-Brockmann (grid, typography, whitespace). Companion docs:
> [North Star](NORTH_STAR.mdx), [Agents in Docs](product/agents-in-docs.md),
> [ADR 0003](decisions/0003-agents-live-in-docs.md).

## 1. Text is the interface

The working surface is text and conversation. Documents read and are
written like messages: newest at the **bottom**, composer anchored at the
bottom (note-UI heritage), ⏎ commits. Structured data (tool beats,
verdicts, permissions) renders *inside* the conversation — never as a
parallel form-driven app. If a feature needs a form, it is a pane the user
opens, not a page they land on.

## 2. Ink is data (Tufte)

- No decorative chrome: no Cards, Chips, SegmentedButtons, filled icon
  buttons, or bubbles in doc surfaces. Boxes only where a rule carries
  meaning (e.g. the 2px verdict rule).
- Every pixel must carry state. Color is annotation, not decoration:
  error red, verdict green, everything else foreground/variant.
- Chartjunk is a bug: an icon that repeats its label's meaning gets
  deleted. Labels are small caps with letter-spacing, not icons.
- Numbers are tabular monospace and always state their source
  (`tokens` come from the backend verdict chunk, never a guess).

## 3. One grid (Müller-Brockmann)

- A fixed role gutter (reference: 52px) aligns every line: `YOU`,
  `AFM`/`OR`, `SYS`, `PERM`, `···` (live). The grid is the hierarchy;
  size/weight/case differentiate, color rarely does.
- Turns are **small multiples**: identical layout per turn, scannable as
  a column. Tool beats are single dim mono rows; long payloads expand on
  tap, never auto-wrap the grid.
- Hairlines (0.6px, divider color) separate regions; whitespace separates
  items. Whitespace is cheaper than a rule; a rule is cheaper than a box.
- Reference constants: gutter 52, label 9.5pt / +1.2 tracking, mono 11pt,
  body 14pt, hairline 0.6.

## 4. The human is sovereign

- The user decides what is visible: PROFILE and SETUP are toggles on the
  status rule — one simple place, always reachable, never forced.
- Deny-by-default is *shown*, not assumed: pending permissions render
  in-flow with reject-first ordering; rejections are recorded as data on
  the turn (`PERM → reject`), never dropped.
- Setup auto-opens only until the doc is bound (onboarding), then it
  collapses. Binding state is visible at all times on the status rule.
- A stuck turn must be stoppable from the same place (stop / cancel
  rejects a pending permission first).

## 5. One state, many projections

The UI, the agent intents (`agent_doc_state`,
`agent_task_delegate`, `agent_permission_answer`), and the transcript
read the **same typed state** (`AgentDocDebugState`, `HarnessTurn`). A
new UI capability must be projected to the agent surface (and vice
versa) in the same change — the human and the agent are two readers of
one document, and both work on text nodes natively.

## 6. Honest surfaces

Render only what the host truly observes. Live state shows beats and
elapsed wall; spend appears only when the verdict lands. Anything not
observable from the product side is labeled as such ("what the host
sees") — no fabricated meaning-node counts, no fake progress bars.

## 7. Progressive disclosure, no dead ends

Empty states instruct (numbered, quiet, on the grid) and vanish on
action. Errors surface in-flow with the fix named ("enter a key"),
never as modal dead ends. Every pane is reachable from one toggle; no
buried navigation.

## 8. Widget-key contract (testability = agentability)

Every actionable element carries a stable surface key
(`coding_agent.*`). Widget tests drive the REAL keys — a change that
renames a key without migrating its tests is a bug. The keys ARE the
agent's UI contract.

## 9. Multiplayer presence is annotation

Presence extends the existing grid vocabulary; it adds no visual
machinery.

- Peer identities are **gutter labels**: the role gutter's small-caps
  vocabulary (`YOU`, `AFM`, `OR`, `SYS`, `PERM`) extends with peer/actor
  labels (device name, agent name). Same size, same tracking, same
  rules. No avatars, no colored dots, no presence bars, no toasts.
- Joins and leaves are **SYS rows on a hairline**, like any system beat.
  A peer going offline is data, not an alarm.
- A remote permission request renders **exactly like a local one** — same
  `PERM` row, same reject-first ordering — plus an origin label in the
  gutter. Recorded as data on the turn, never dropped (ADR 0005 §5).
- Connection truth lives on the **status rule** in tabular mono:
  hosting / connected / peers / last-sync. The status rule remains the
  one simple place.
- Live activity (streaming, typing) is a `···` row under the acting
  peer's gutter label — the existing live-state row, attributed. Nothing
  that is not observable from the product side is shown (§6 applies to
  peers as it does to agents).

## 10. Attention is a budget (ADHD-first, human-true)

Attention is spent like money: monotonic, visible, never spent without
consent. This section is written for ADHD users **literally, not as a
metaphor** — the primary tuning instrument is an ADHD person, and the
rules below are therapeutic before they are aesthetic.

- **One decision per screen.** A creation flow never asks "which of
  these am I?". Any surface offering N simultaneous choices where one
  default would do is an attention overdraft — flag it.
- **Externalize working memory.** Every state renders; nothing lives
  only in the user's head. Queued messages are visible and editable,
  not "trusted to send". Breadcrumbs, queue positions, binding state,
  spend — all on screen, always.
- **No state is only visible live.** Navigating away and back must
  reconstruct everything (`···` rows, live beats included — resumed as
  their durable residue). A state that vanishes on return is a bug.
- **Collapsible, never absent.** Observability is layered, and every
  layer is one tap away:
  - **L0 — status rule**: one line (running/idle, spend, pending perm).
  - **L1 — progress**: the `···` row + current activity in words
    ("thinking" collapses here).
  - **L2 — beats**: dim mono rows per tool/decision/thought.
  - **L3 — full**: payloads, context assembly, the meaning cut, loop
    warnings — expanded on tap only.
  Capability flags gate which layers **exist** (per doc/user:
  `inspector: none | summary | full`); view toggles gate which are
  **open**. Transparency is always available, never mandatory.
- **Latency to first action under the friction of starting.** Cold
  start → typing in one gesture; Select→Do < 300 ms (pillars doc).
- **Invariant geometry.** Fixed positions are motor memory: the rail
  never rearranges; the composer never moves. Labels are verb-first,
  concrete words — tested for cognitive load in EN/IT/RU, not just
  correctness ("GDD" fails; "New" passes).
- **Forgiveness is a feature.** The user abandons and returns
  constantly; the system rewards return: queued messages editable,
  denials recorded, children archived not deleted, per-turn edit
  history.
- **Time made visible.** Wall-clock on live turns, spend on verdicts,
  queue position and age on queued rows. Honest surfaces (§6) are
  directly therapeutic here: never remove them, extend them to
  everything new.
- **The doc renders as text first.** Harness layers are the ONLY
  things allowed to be collapsed or gated. If a harness concept (beat,
  verdict, projection) becomes mandatory reading for writing a note,
  the product has become an abstract agentic harness — flag as review
  blocker.
- **Attention dials, not a mode.** Verbosity, motion, queue defaults
  live in PROFILE (§4 — one simple place). No "ADHD mode" label: these
  are ordinary attention settings anyone may use.

## Forbidden (flag as review blockers)

- Material chrome in doc surfaces (cards/chips/segmented controls/
  filled buttons) where a hairline + typography suffices.
- Bubble chat layouts (left/right alignment); the grid replaces them.
- Build-time button guards derived from text fields (text edits never
  rebuild the widget — validation happens in the action path; measured).
- Untranslatable visuals: anything the debugState projection cannot
  express is invisible to the agent — split it or drop it.
