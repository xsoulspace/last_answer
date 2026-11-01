# ADR 0026 — Workspaces: multi-root containers, nesting as a graph, file types inside

- Status: Accepted (owner-approved design direction; recorded 2026-10-30)
- Date: 2026-10-30
- North Star impact: `refines` — the writable shared workspace of the
  North Star gets its primary container: a workspace is the durable
  object a human and agents sit inside, and the rail names it.
- Builds on: [0024](0024-actors-channels-and-panes.md) (actors and
  channels; the rail lists identities; panes, not a fixed center —
  this ADR replaces 0024 §4's "Projects section of the rail" with the
  WORKSPACES section),
  [0012](0012-writable-agent-doc-and-acp-client-first.md) (the writable
  shared document/workspace), [0023](0023-chat-first-product-and-retire-materialization.md)
  (projects are content, never the app's face).
- Harness dependencies (referenced, never imported): ecsai ADR 0107
  (one world per realm, one control store, durable state out of
  `.dart_tool`), ADR 0116 (actors, not workers — the same
  participant vocabulary applies to what agents work ON).

## Context

ADR 0024 fixed the rail as a conversation list and kept a quiet
PROJECTS section — "content in the tree, not navigation chrome". Two
facts outgrew it:

- The product's unit of shared work is bigger than one project. A
  user works across several folders at once (the VSCode multi-root
  shape), with notes, ideas and docs as CONTENT inside that working
  set — not as three parallel rails. "Project" is a file type's
  record; the container above it had no name and no home in the
  shell.
- The owner's model: workspaces are the shared world humans and
  agents work in — many user-selected folders per workspace, at least
  one project per workspace, and workspaces NEST, with overlap (the
  same folder or sub-workspace legitimately appears under more than
  one parent — a graph, not a tree). Zed/VSCode supply the principle
  (one workspace, typed files inside), Last Answer customizes the
  editor surface per type.

The rail's PROJECTS section (fed by the legacy `ProjectsNotifier`
paged list) carried none of this: no folders, no nesting, no
selection, no future surface to host.

## Decision

1. **The workspace is the primary container object.** A workspace
   has: a stable minted id (`workspace-<24hex>`, the same id
   vocabulary as channels); a user-facing name; a list of
   user-selected absolute, normalized folder paths (multi-root —
   possibly empty until folders are chosen); a set of parent
   workspace ids; a set of project ids; a creation instant.

2. **Projects live inside workspaces.** A workspace carries at least
   one project (recommended, not enforced at rest — the model never
   invents projects, and the rail must render honestly before any
   exist). Notes, ideas and docs are FILE TYPES inside the
   workspace's folders; each type gets its own customized editor
   surface in a later wave (the agent-doc surface remains the
   reference implementation). The workspace model itself is
   type-blind.

3. **Nesting is a graph with overlap, not a tree.** A workspace may
   name MANY parents — the same workspace renders under each parent
   that claims it, and `workspacesContainingFolder(path)` is the
   overlap query for folders (one folder, several workspaces). Two
   shape laws keep the graph total and renderable: a workspace with
   zero parents is a root (the rail renders roots); parent edges may
   never close a cycle (the registry refuses any edge whose ancestor
   walk would reach back — a cycle would orphan every member from the
   roots query). Equality is by id: two records naming the same id
   are the same workspace wherever they appear.

4. **Storage is the world's one control store** — the LA-owned
   `workspaces` collection beside `channels` (ADR 0024 store law):
   one JSON record per workspace keyed by id, mutations as single
   read-modify-write transactions over `RealmControlStore`, deletes
   that detach child links and never recurse. The registry is dumb
   and takes the store as a constructor argument (the service layer
   wires the world's store in production; tests wire a plain
   directory store — durable state never lands in `.dart_tool` or
   app-private directories).

5. **The rail section swaps, the product features stay.** PROJECTS →
   WORKSPACES: root workspaces render as rows (folder-stack mark,
   name, muted folder count), expandable into child workspaces
   (rendered under EVERY parent that names them), tap selects
   (selection stays rail-local for this slice), and a selected row
   carries the quiet empty-state note where its file tree will land.
   Workspaces are searchable like actors and channels, and "+ new
   workspace" joins the rail's add menu (name + optional folder
   picks). The legacy projects list disappears from the rail only —
   ideas/notes/doc flows, routes and repository are untouched.

## Non-goals (this slice)

- No file-tree surface yet — the selected workspace shows a quiet
  empty-state note; the tree is the next wave.
- No per-type editors yet — the customized-editor direction is named
  here, not built.
- No durable selection, no cross-device workspace sync, no
  workspace-level permissions — selection is local; the store
  records are device-local like channels.
- No enforced project count at rest, no folder existence checks on
  write (a folder may be a removable drive that returns) — the rail
  renders the record, and honest absence is handled at the surface.

## Falsifier

This decision is being violated — revise rather than layer — if a
second container concept appears beside `workspaces` (e.g. a
"project group" table), if nesting silently becomes a tree
(single-parent) or a raw cyclic graph (workspaces unreachable from
roots), or if workspace records land outside the realm control
store. The same violation wearing UI clothes: a rail section that
duplicates the workspace list from another source.
