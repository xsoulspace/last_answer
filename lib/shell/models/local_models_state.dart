/// Local model manager (docs/design/models-local-manager.md) — the
/// state half of the catalog lens's local-models section.
///
/// The panel's idiom is a small [ChangeNotifier] the lens listens to
/// (the palette candidate, the world read model); this one holds the
/// curated local catalog, each entry's install state (refreshed on
/// init and after every verb), the ONE in-flight install with its
/// latest [ProvisionProgress], and the memory lifecycle's loaded facts
/// (2026-11-18 two-stage law: DOWNLOAD = the weights sit on disk, LOAD
/// = the weights sit in RAM — two independent stages with separate
/// verbs). The consent law lives here as a boundary: [install] is
/// called ONLY from the UI's consent dialog path with `userConsent:
/// true` — the runtime/inference paths never download. Errors land in
/// [error] (named codes rendered verbatim by the lens — never
/// swallowed, never paraphrased into a fake success).
///
/// The installer rides the [LocalModelInstaller] seam so tests fake it
/// with no network; production binds the package's `MlxModelInstaller`
/// through [PackageLocalModelInstaller]. The runtime lane rides the
/// [LocalModelRuntime] seam the same way; when it is absent (the
/// default) the UI degrades honestly to disk-only rows.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lastanswer/shell/models/local_runtime_ledger.dart';
import 'package:lastanswer/shell/models/memory_budget.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

/// The installer seam (the package class is final by contract, so
/// tests implement THIS and production adapts).
abstract interface class LocalModelInstaller {
  InstalledState stateOf(final MlxModelCatalogEntry entry);

  Stream<ProvisionProgress> install(
    final MlxModelCatalogEntry entry, {
    required final bool userConsent,
  });

  Future<bool> delete(final MlxModelCatalogEntry entry);
}

/// One entry's memory lifecycle (2026-11-18 two-stage law): LOAD = the
/// weights sit in RAM, ready to use; UNLOAD = freed. Downloaded is the
/// precondition the UI checks first — the runtime lane only ever sees
/// entries the installer has on disk. Backed by the dfp package's
/// `MlxModelRuntime` in production ([PackageLocalModelRuntime]); faked
/// in tests.
abstract interface class LocalModelRuntime {
  bool isLoaded(final MlxModelCatalogEntry entry);

  Future<void> load(final MlxModelCatalogEntry entry);

  Future<void> unload(final MlxModelCatalogEntry entry);
}

/// Production binding over the package installer (the ctor's optional
/// hub root / download cap / network gate pass through verbatim).
final class PackageLocalModelInstaller implements LocalModelInstaller {
  PackageLocalModelInstaller({
    final String? hubRoot,
    final int? maxDownloadBytes,
    final bool Function()? isNetworkAllowed,
  }) : _inner = MlxModelInstaller(
         hubRoot: hubRoot,
         maxDownloadBytes: maxDownloadBytes,
         isNetworkAllowed: isNetworkAllowed,
       );

  final MlxModelInstaller _inner;

  @override
  InstalledState stateOf(final MlxModelCatalogEntry entry) =>
      _inner.stateOf(entry);

  @override
  Stream<ProvisionProgress> install(
    final MlxModelCatalogEntry entry, {
    required final bool userConsent,
  }) => _inner.install(entry, userConsent: userConsent);

  @override
  Future<bool> delete(final MlxModelCatalogEntry entry) => _inner.delete(entry);
}

/// The row/key ref name for a catalog entry: the repo basename is
/// unique across the curated catalog and stays stable in the widget
/// keys (`models.local.<refName>.row/.install/.delete/.progress`).
String localModelRefName(final MlxModelCatalogEntry entry) =>
    entry.repoId.split('/').last;

/// The entry's candidate BRAIN cast names (2026-11-18 ledger law): the
/// discovery ref the brain grammar speaks (`qwen3.5-0.8b` — lowercased,
/// quant tag stripped) plus the bare default alias when this entry IS
/// the default Qwen3 snapshot the bare `qwen` cast resolves to. The
/// generation ledger keys by cast, so the row reads its activity
/// through this list.
List<String> localCastsForEntry(final MlxModelCatalogEntry entry) {
  final lower = localModelRefName(entry).toLowerCase();
  final stripped = lower.endsWith('-4bit')
      ? lower.substring(0, lower.length - 5)
      : lower;
  final casts = <String>{lower, stripped};
  if (stripped == 'qwen3-0.6b') casts.add('qwen');
  // The LFM2.5 entry IS the bare `lfm` cast's checkpoint (the
  // lifecycle law): its generation ledger reads through this alias.
  if (stripped.contains('lfm2.5')) casts.add('lfm');
  return casts.toList(growable: false);
}

/// The entry's generation record off the ledger, over its candidate
/// casts (the bare `qwen` alias matches the default snapshot's row).
LocalModelRun? localRunForEntry(final MlxModelCatalogEntry entry) =>
    LocalRuntimeLedger.instance.runForAny(localCastsForEntry(entry));

/// Readable download size: GB with one decimal at a gigabyte and up,
/// whole MB below (the consent dialog names the size in this shape).
String formatModelBytes(final int bytes) {
  final mib = bytes / (1024 * 1024);
  if (mib >= 1024) {
    final gib = mib / 1024;
    return '${gib.toStringAsFixed(gib >= 10 ? 0 : 1)} GB';
  }
  return '${mib.round()} MB';
}

/// The catalog lens's local-models state: the static catalog, the
/// per-entry install states, the in-flight install + progress, and the
/// last error (a named code, rendered verbatim).
final class LocalModelsState extends ChangeNotifier {
  LocalModelsState({
    final LocalModelInstaller? installer,
    final LocalModelRuntime? runtime,
    final Future<MemoryFacts?> Function()? readMemoryFacts,
  }) : _installer = installer ?? PackageLocalModelInstaller(),
       // The public parameter name stays `runtime:`; the field is
       // private so only the state class drives the lane.
       // ignore: prefer_initializing_formals
       _runtime = runtime,
       _readMemoryFacts = readMemoryFacts ?? _defaultReadMemoryFacts;

  final LocalModelInstaller _installer;

  /// The runtime lane (2026-11-18): null = the lane is absent — the
  /// rows render disk-only (no memory chip, no Load/Unload verbs), the
  /// today shape. Production wires the dfp-backed
  /// [PackageLocalModelRuntime]; tests inject a fake.
  final LocalModelRuntime? _runtime;

  /// Whether the runtime lane exists (the row's memory chip and its
  /// Load/Unload verbs render only when it does).
  bool get hasRuntime => _runtime != null;

  /// The memory-facts seam (2026-11-18 budget law): production senses
  /// fresh via [MemoryFacts.current]; tests inject canned facts so the
  /// fit verdicts stay hermetic.
  final Future<MemoryFacts?> Function() _readMemoryFacts;

  /// The production sensor, EXCEPT under the flutter test VM: a real
  /// `vm_stat` spawn there leaves a pending process timer behind every
  /// widget test that mounts the view (the 2026-11-18 sweep finding —
  /// surfaces like app_shell mount Models without injecting), so an
  /// uninjected test runs sensor-absent — the same honest degraded line
  /// an absent sensor gets in production, never a hidden process.
  static Future<MemoryFacts?> _defaultReadMemoryFacts() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return null;
    return MemoryFacts.current();
  }

  bool _disposed = false;

  /// The curated v1 catalog (static; no network to browse).
  List<MlxModelCatalogEntry> get catalog => mlxModelCatalog;

  final Map<String, InstalledState> _states = <String, InstalledState>{};

  /// An entry's known install state; an unrefreshed entry answers
  /// not-installed honestly (the row's initial shape before refresh).
  InstalledState stateOf(final MlxModelCatalogEntry entry) =>
      _states[localModelRefName(entry)] ??
      const InstalledState(installed: false);

  /// The known loaded facts, keyed by ref name (the runtime lane's
  /// answers, re-read at every refresh and after every load/unload —
  /// the state never guesses a transition, the runtime answers).
  final Map<String, bool> _loaded = <String, bool>{};

  /// An entry's memory state: are the weights resident (LOAD done)?
  /// A runtime-absent lane or an unrefreshed entry answers false — the
  /// disk-only honest shape, never a guessed "loaded".
  bool isLoaded(final MlxModelCatalogEntry entry) =>
      _loaded[localModelRefName(entry)] ?? false;

  /// The refs with a load/unload in flight (the row spinner — one
  /// operation at a time per row, like the install busy path).
  final Set<String> _busyRefs = <String>{};

  /// Whether the entry has a load or unload in flight.
  bool isBusy(final MlxModelCatalogEntry entry) =>
      _busyRefs.contains(localModelRefName(entry));

  /// The in-flight install's entry ref, or null when idle. ONE install
  /// at a time (a second verb during a download is a no-op, not a
  /// queue — the row IS the progress).
  String? get installingRef => _installingRef;
  String? _installingRef;

  /// The in-flight install's latest progress; null when idle.
  ProvisionProgress? get progress => _progress;
  ProvisionProgress? _progress;

  /// The last failed verb's named code (`user_consent_required`,
  /// `network_blocked`, `max_download_exceeded`, `install_failed:*`,
  /// or `delete_refused`) — rendered verbatim by the lens until the
  /// next verb clears it.
  String? get error => _error;
  String? _error;

  /// The freshest sensed memory facts (2026-11-18 budget law): read at
  /// the last refresh, never carried past one refresh cycle — available
  /// memory is exactly the fact that changes between a refused load and
  /// the one that passes, so the bar re-senses on every refresh.
  MemoryFacts? get memoryFacts => _memoryFacts;
  MemoryFacts? _memoryFacts;

  /// The per-entry fit verdicts over [memoryFacts], keyed by ref name;
  /// recomputed together with the facts on every refresh.
  final Map<String, LocalModelFit> _fits = <String, LocalModelFit>{};

  /// An entry's fit verdict — whether a LOAD would pass the gate on
  /// today's memory (installing is a disk verb and stays unconditional).
  /// Before the first budget refresh this answers the unknown verdict:
  /// the row renders NO fit chip, never a guessed fit. The weights ride
  /// the catalog's approximate download bytes ([InstalledState] carries
  /// no on-disk size) — approximate residency, not sensed.
  LocalModelFit fitOf(final MlxModelCatalogEntry entry) =>
      _fits[localModelRefName(entry)] ?? const LocalModelFit.unknown();

  @override
  void dispose() {
    _disposed = true;
    _budgetTimer?.cancel();
    _budgetTimer = null;
    super.dispose();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  /// Re-probe every entry's install state AND its loaded fact, then
  /// re-sense the memory budget (init + after install and delete — the
  /// state never guesses a transition, the installer, the runtime and
  /// the sensor answer).
  Future<void> refresh() async {
    for (final entry in catalog) {
      _states[localModelRefName(entry)] = _installer.stateOf(entry);
      _readLoaded(entry);
    }
    await refreshBudget();
  }

  /// Re-read one entry's loaded fact off the runtime lane (absent lane
  /// leaves the disk-only false — never a guessed residency).
  void _readLoaded(final MlxModelCatalogEntry entry) {
    final runtime = _runtime;
    if (runtime == null) return;
    _loaded[localModelRefName(entry)] = runtime.isLoaded(entry);
  }

  /// The budget half of a refresh: read [MemoryFacts] fresh and
  /// recompute every entry's fit verdict over it. Fresh EVERY call —
  /// the facts never outlive one refresh cycle (the sensor-absent case
  /// lands as the unknown verdict, the UI's honest degraded line).
  /// Re-entrant calls coalesce (the poller and a verb's refresh may
  /// race; the sensor never runs twice concurrently).
  Future<void> refreshBudget() async {
    if (_budgetRefreshing) return;
    _budgetRefreshing = true;
    try {
      await _refreshBudgetUnchecked();
    } finally {
      _budgetRefreshing = false;
    }
  }

  Future<void> _refreshBudgetUnchecked() async {
    final facts = await _readMemoryFacts();
    _memoryFacts = facts;
    for (final entry in catalog) {
      _fits[localModelRefName(entry)] = evaluateLocalModelFit(
        availableMegabytes: facts?.availableMegabytes,
        totalMegabytes: facts?.totalMegabytes,
        weightsBytes: entry.approxDownloadBytes,
      );
    }
    _notify();
  }

  /// The periodic budget re-sense (2026-11-18 v3 realtime law): the
  /// pane-visible cadence that keeps the bar honest WHILE a chat runs —
  /// available memory is exactly the fact that changes under a live
  /// model, and the verb-triggered refresh alone let the bar go stale
  /// minutes into a session. Coalesced through [refreshBudget]; no-op
  /// under the flutter test VM (the same law as the sensor — no hidden
  /// timers in the test lane).
  static const Duration kBudgetPollInterval = Duration(seconds: 2);
  Timer? _budgetTimer;
  bool _budgetRefreshing = false;

  void startBudgetPolling({final Duration interval = kBudgetPollInterval}) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _budgetTimer?.cancel();
    _budgetTimer = Timer.periodic(interval, (_) {
      unawaited(refreshBudget());
    });
  }

  void stopBudgetPolling() {
    _budgetTimer?.cancel();
    _budgetTimer = null;
  }

  /// The row the budget bar's model segment tap highlights (the
  /// Apple-storage-bar click-through: segment → row). The pane owns
  /// the semantics; the state just carries the fact so both surfaces
  /// read one truth.
  String? get selectedRef => _selectedRef;
  String? _selectedRef;

  set selectedRef(final String? ref) {
    if (_selectedRef == ref) return;
    _selectedRef = ref;
    _notify();
  }

  /// The entry's SENSED size on disk (the detail sheet's fact, replacing
  /// the approximation once weights exist): a recursive walk of the
  /// snapshot dir. Null when the entry is not installed or the walk
  /// fails — never a guessed size.
  Future<int?> diskBytesOf(final MlxModelCatalogEntry entry) async {
    final dir = stateOf(entry).snapshotDir;
    if (dir == null || dir.isEmpty) return null;
    return _walkBytes(Directory(dir));
  }

  Future<int?> _walkBytes(final Directory dir) async {
    var total = 0;
    try {
      await for (final entry in dir.list(recursive: true, followLinks: false)) {
        if (entry is File) {
          total += entry.lengthSync();
        } else if (entry is Link) {
          // The hub cache shares blobs through symlinks; resolve the
          // TARGET's size or the sensed number is a bare lie.
          final target = File(await entry.target());
          if (target.existsSync()) total += target.lengthSync();
        }
      }
    } on Object {
      return null;
    }
    return total;
  }

  /// The consented install: called from the UI's consent dialog
  /// confirm ONLY (the dialog named the size; this call is the consent
  /// fact). Streams the progress into [progress], then re-probes the
  /// entry's state — a failed install ends in [error] with the named
  /// code, never a swallowed failure.
  Future<void> install(final MlxModelCatalogEntry entry) async {
    if (_installingRef != null) return;
    final ref = localModelRefName(entry);
    _error = null;
    _installingRef = ref;
    _progress = null;
    _notify();
    try {
      await for (final update in _installer.install(entry, userConsent: true)) {
        _progress = update;
        _notify();
      }
    } on Object catch (e) {
      _error = _namedCode(e);
    } finally {
      _installingRef = null;
      _progress = null;
      // The installer owns the truth about what landed; re-probe even
      // after a failure (a partial cache entry is a fact, not a guess).
      _states[ref] = _installer.stateOf(entry);
      // The freshly landed entry's residency is a runtime fact, not a
      // guess (a just-downloaded entry is normally not loaded).
      _readLoaded(entry);
      _notify();
    }
  }

  /// The delete verb: honest false when the entry was not
  /// manager-installed (the marker-file law) — the refusal lands in
  /// [error] as `delete_refused`, the row stays as it is. The state is
  /// re-probed either way: the installer owns the truth about what
  /// landed, never a guessed transition. A loaded entry unloads FIRST
  /// (the two-stage law's loose end): weights sitting in RAM must not
  /// outlive their disk delete — a Delete frees both storages.
  Future<void> delete(final MlxModelCatalogEntry entry) async {
    final ref = localModelRefName(entry);
    _error = null;
    if (_runtime?.isLoaded(entry) ?? false) {
      await _runtime!.unload(entry);
    }
    final ok = await _installer.delete(entry);
    _states[ref] = _installer.stateOf(entry);
    if (!ok) {
      _error = 'delete_refused';
    }
    _notify();
  }

  /// The LOAD verb (2026-11-18 two-stage law): put the downloaded
  /// weights in RAM through the runtime lane. One operation at a time
  /// per row (the busy ref renders the row spinner); a refusal (the
  /// load gate's floor, a stale fit) lands in [error] verbatim, never
  /// swallowed. After it completes the entry's install state is
  /// re-probed and the row notified — nothing else is re-probed on
  /// disk (a load writes nothing).
  Future<void> loadEntry(final MlxModelCatalogEntry entry) async {
    final runtime = _runtime;
    if (runtime == null) return;
    final ref = localModelRefName(entry);
    if (_busyRefs.contains(ref)) return;
    _error = null;
    _busyRefs.add(ref);
    _notify();
    try {
      await runtime.load(entry);
      _loaded[ref] = true;
    } on Object catch (e) {
      _error = _namedCode(e);
    } finally {
      _busyRefs.remove(ref);
      _states[ref] = _installer.stateOf(entry);
      _notify();
    }
  }

  /// The UNLOAD verb: free the resident weights. Symmetric with
  /// [loadEntry] — same busy law, same honest error line, and the
  /// install-state re-probe is the only disk touch (an unload writes
  /// nothing, deletes nothing).
  Future<void> unloadEntry(final MlxModelCatalogEntry entry) async {
    final runtime = _runtime;
    if (runtime == null) return;
    final ref = localModelRefName(entry);
    if (_busyRefs.contains(ref)) return;
    _error = null;
    _busyRefs.add(ref);
    _notify();
    try {
      await runtime.unload(entry);
      _loaded[ref] = false;
    } on Object catch (e) {
      _error = _namedCode(e);
    } finally {
      _busyRefs.remove(ref);
      _states[ref] = _installer.stateOf(entry);
      _notify();
    }
  }

  /// The host's named code out of a stream error: the bare message
  /// when it names a code, else the error's own text (honest verbatim,
  /// minus the `Exception:` wrapper).
  String _namedCode(final Object e) {
    final text = e.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}
