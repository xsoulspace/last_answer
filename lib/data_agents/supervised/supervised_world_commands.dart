/// Pure command construction for the supervised world's components —
/// shared by the `io` adapter and its web stub (the conditional-import
/// law: the argv grammar has no platform dependency, so both variants
/// serve the same shapes and tests assert the built argv without
/// spawning anything).
///
/// The world is TWO declared components now (leg B gap G1,
/// docs/design/ecsai-modelscope-first-priority-2026-11-05.md §3): the
/// daemon (the world's owner/serve loop) AND the realm scheduler (the
/// durable delegation lane's claimant pump — without it a `task
/// op:create` sits `queued` forever).
library;

/// The daemon's declared component id (the machine's ONE daemon).
const String ecsaiDaemonComponentId = 'ecsai-daemon';

/// The scheduler's declared component id (harness ADR 0114 lane C,
/// `realm_scheduler` — the replaceable scheduler that keeps actor
/// processes alive against the realm's durable queue).
const String ecsaiSchedulerComponentId = 'ecsai-scheduler';

/// Both world components in converge order: the daemon first (it owns
/// and creates the realm store the scheduler's queue reads), the
/// scheduler second.
const List<String> supervisedWorldComponentIds = [
  ecsaiDaemonComponentId,
  ecsaiSchedulerComponentId,
];

/// The stop order: the scheduler stops FIRST (stop stops spawning — no
/// further actor is claimed against a world that is going away), then
/// the daemon. Live actors keep their leases and settle on their own;
/// that is the scheduler's own survival semantics.
const List<String> supervisedWorldStopOrder = [
  ecsaiSchedulerComponentId,
  ecsaiDaemonComponentId,
];

/// The scheduler entrypoint, relative to the harness checkout root.
/// SCRIPT-ONLY: the harness builds AOT artifacts for the daemon
/// (`build/ecsai_daemon.exe`) and the seat, NOT for the scheduler, so
/// the component command is `dart run <script>` and a missing harness
/// root refuses BY NAME, never spawning a guess.
const String realmSchedulerEntrypointRelative =
    'pkgs/xsoulspace_agentic_afm/bin/realm_scheduler.dart';

/// The scheduler entrypoint's absolute path under [harnessRoot].
String schedulerEntrypointPath(final String harnessRoot) =>
    '$harnessRoot/$realmSchedulerEntrypointRelative';

/// The realm's ONE durable control store directory under [worldHome] —
/// the scheduler's `--store` (the same `<world>/coordination` layout
/// `RealmWorld.realmControlStorePath()` and the harness doctor serve).
String realmStorePath(final String worldHome) => '$worldHome/coordination';

/// The default actor-process width the app arms. The scheduler's own
/// ceiling is 32 (`kRealmSchedulerMaxActorsCeiling`); the app stays
/// conservative — bounded width on a small machine, operator-tunable.
const int kDefaultSchedulerMaxActors = 2;

/// The default scheduler identity (actor ids derive from it:
/// `<schedulerId>-w<n>-<token>`).
const String kDefaultSchedulerId = 'lastanswer';

/// The scheduler's default settle window: the leased record's pid must
/// STAY alive across it (probed every 300 ms) before the start counts as
/// ready — a scheduler that refuses its argv or loses its store exits
/// inside milliseconds, and that death must fail the start with a typed
/// fact, never converge to a dead record. Shared by BOTH conditional
/// variants so their mirrored signatures are byte-identical.
const Duration kSchedulerSettleWindow = Duration(milliseconds: 1200);

/// The scheduler argv (pure): `dart run SCRIPT --store STORE
/// --scheduler-id ID --max-actors N` — EXACTLY the contract
/// `parseRealmSchedulerOptions` admits (harness
/// `pkgs/xsoulspace_agentic_afm/bin/realm_scheduler.dart`:227-279 —
/// `--store` must be ABSOLUTE, `--max-actors` is 1..32; a violation is
/// the script's own named refusal and exit 2). No `--once`: the
/// supervised scheduler is a resident service, not one round.
List<String> schedulerCommand({
  required final String dartExecutable,
  required final String schedulerScript,
  required final String storePath,
  required final String schedulerId,
  required final int maxActors,
}) => <String>[
  dartExecutable,
  'run',
  schedulerScript,
  '--store',
  storePath,
  '--scheduler-id',
  schedulerId,
  '--max-actors',
  '$maxActors',
];

/// The POSIX `exec`-redirection log wrap shared by both components: an
/// appending stdout/stderr redirection where the shell REPLACES itself,
/// so the recorded pid stays the real process's. POSIX-only by design;
/// the `io` adapter guards with `Platform.isWindows` (on Windows the log
/// is a named gap, exactly like the daemon's).
List<String> execWithLogWrap(final List<String> argv, final String logPath) {
  final q = String.fromCharCode(92) + String.fromCharCode(39);
  String quote(final String part) => "'${part.replaceAll("'", q)}'";
  final wrapped = argv.map(quote).join(' ');
  return <String>['/bin/sh', '-c', 'exec $wrapped >> ${quote(logPath)} 2>&1'];
}
