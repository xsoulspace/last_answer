/// The supervised ecsai world adapter — the SDK piece of the
/// supervisor-managed world design. Last Answer launches and stops the
/// machine's ONE harness world through the oka_supervisor LIBRARY
/// (`DesiredState` + `Supervisor.converge`), never through the oka exe
/// and never through plan files.
///
/// TWO declared service specs (leg B gap G1): `ecsai-daemon` — the
/// daemon executable with `--mcp --local-mcp-seats --idle-exit-minutes
/// 0`, readiness gated on the daemon's OWN liveness truth (the owner
/// pointer file with a live recorded pid, read through the host
/// doctor's probe) — and `ecsai-scheduler` — the realm scheduler
/// (`dart run HARNESS/pkgs/xsoulspace_agentic_afm/bin/realm_scheduler.dart`
/// with `--store WORLD/coordination --scheduler-id … --max-actors …`),
/// the durable delegation lane's claimant pump, readiness gated on the
/// leased record's pid staying alive across a bounded settle window (an
/// early-exiting child fails the start with a typed fact). Both share
/// the budgeted restart policy (3 restarts / 300 s window), and
/// `startSupervisedWorld` converges them in ONE pass — a missing
/// scheduler entrypoint or Dart runtime refuses the WHOLE arm by name
/// before anything spawns. Stop is declarative too: the supervisor
/// record's identity drives a verified stop ladder (scheduler first —
/// stop stops spawning — then the daemon, with a pointer-pid SIGTERM
/// fallback for daemons started outside the supervisor; the converge
/// API has no absent verb).
///
/// Conditional-import law: `oka_supervisor` imports `dart:io`
/// transitively (through `oka_core`'s process machinery), so it can
/// never compile into a web build. The `io` variant serves mobile and
/// desktop; the web stub answers with named `unsupported` reports
/// instead of pretending. The pure argv grammar lives in
/// `supervised_world_commands.dart`, which BOTH variants export.
library;

export 'supervised_world_none.dart'
    if (dart.library.io) 'supervised_world_io.dart';
