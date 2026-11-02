/// The supervised ecsai daemon adapter — the SDK piece of the
/// supervisor-managed daemon design. Last Answer launches and stops the
/// machine's ONE harness daemon through the oka_supervisor LIBRARY
/// (`DesiredState` + `Supervisor.converge`), never through the oka exe
/// and never through plan files.
///
/// One service spec (`ecsai-daemon`): the daemon executable with
/// `--mcp --local-mcp-seats --idle-exit-minutes 0`, a budgeted restart
/// policy (3 restarts / 300 s window), and a provider-owned readiness
/// gate on the daemon's OWN liveness truth — the owner pointer file with
/// a live recorded pid, read through the host doctor's probe (the same
/// truth `ecsai --status` serves). Stop is declarative too: the
/// supervisor record's identity drives a verified stop ladder, with a
/// pointer-pid SIGTERM fallback for daemons started outside the
/// supervisor (the converge API has no absent verb).
///
/// Conditional-import law: `oka_supervisor` imports `dart:io`
/// transitively (through `oka_core`'s process machinery), so it can
/// never compile into a web build. The `io` variant serves mobile and
/// desktop; the web stub answers with named `unsupported` reports
/// instead of pretending.
library;

export 'supervised_world_none.dart'
    if (dart.library.io) 'supervised_world_io.dart';
