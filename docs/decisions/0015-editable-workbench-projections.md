# ADR 0015 — Editable workbench projections

- Status: Accepted for implementation
- Date: 2026-10-12
- Amends: ADR 0012, North Star, DESIGN sections 1 and 5

Coding projections are clarified by
[ADR 0016](0016-reversible-code-candidates-over-native-owners.md): semantic and
conventional candidates share native promotion and recovery; the workbench and
document repository do not become a second filesystem executor.

## Decision

Project work is authoritative. Documents, spatial views, conversations and runtime
views are editable projections of that work. A workbench may address multiple
projects; it does not copy their authority into a new database. Personal view
arrangements are distinct from project changes.

Existing DocumentRepository owns article content and stable block identities.
Metadata nodes hold scoped proposals, typed evidence links, knowledge provenance,
personal bookmarks and recovery history. Domain adapters expose supported operations.
Harness owns collaboration, claims and canonical task acceptance. A local content
write alone is not harness acceptance. No second agent scheduler is introduced.

Interaction sessions distinguish physical human input, synthesized delivery and
semantic agent actions. All project operations use the same owner path. Human
motion is observed rather than synthesized through a human-like profile.

## Delivery and evidence

Complete article editing and declarative return behaviour, then real gesture input,
harness collaboration, bounded Dart rewriting and measured scale. UI manipulation
must change real supported state. Inferred links are read-only. Candidate adoption
retains a recovery record; unknown results reconcile before retry.

Implementation, automated qualification, rendered Computer acceptance, physical
trackpad/Vosges validation and 512 in-flight actor proof are separate states.
