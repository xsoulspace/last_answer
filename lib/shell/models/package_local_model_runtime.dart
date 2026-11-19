/// Production binding of the [LocalModelRuntime] seam (2026-11-18
/// two-stage law) over the dfp package's `MlxModelRuntime` — the LOAD
/// half of the catalog rows (the weights in RAM). This file lands
/// TOGETHER with the dfp runtime (orchestrator lane): until that lands,
/// the `MlxModelRuntime` import member below does not resolve and the
/// Models surface runs runtime-absent (disk-only rows), the honest
/// degraded shape.
library;

import 'package:lastanswer/shell/models/local_models_state.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

/// Maps a catalog entry to its resolved snapshot dir (the dfp
/// `InstalledState` carries it) and forwards the memory verbs to
/// `MlxModelRuntime.instance`. A not-downloaded entry has no snapshot
/// dir: it answers not-loaded and refuses the verbs — the runtime must
/// never see a guessed dir.
final class PackageLocalModelRuntime implements LocalModelRuntime {
  PackageLocalModelRuntime({final LocalModelInstaller? installer})
    : _installer = installer ?? PackageLocalModelInstaller();

  final LocalModelInstaller _installer;

  /// The entry's resolved snapshot dir, or null when the installer
  /// holds nothing on disk for it.
  String? _dirOf(final MlxModelCatalogEntry entry) =>
      _installer.stateOf(entry).snapshotDir;

  /// The engine family a catalog entry rides (2026-11-18: the
  /// `local:lfm` cast joined the lifecycle — the LFM2.5 entry dispatches
  /// to the lfm engine family, everything else stays qwen).
  bool _isLfm(final MlxModelCatalogEntry entry) => entry.family == 'lfm2.5';

  /// The disk-only families (2026-11-19, the laya row): a decision
  /// checkpoint serves out-of-process through the laya-serve sidecar —
  /// it must never reach the in-app engine registry.
  bool _isDiskOnly(final MlxModelCatalogEntry entry) =>
      localModelDiskOnly(entry);

  @override
  bool isLoaded(final MlxModelCatalogEntry entry) {
    // The disk-only law: no in-app residency, ever (a decision
    // checkpoint routed into the qwen engine would be a type error the
    // native layer would answer obscurely — answer honestly instead).
    if (_isDiskOnly(entry)) return false;
    final dir = _dirOf(entry);
    if (dir == null) return false;
    final runtime = MlxModelRuntime.instance;
    return _isLfm(entry) ? runtime.isLfmLoaded(dir) : runtime.isQwenLoaded(dir);
  }

  @override
  Future<void> load(final MlxModelCatalogEntry entry) async {
    if (_isDiskOnly(entry)) return;
    final dir = _dirOf(entry);
    if (dir == null) return;
    final runtime = MlxModelRuntime.instance;
    await (_isLfm(entry) ? runtime.loadLfm(dir) : runtime.loadQwen(dir));
  }

  @override
  Future<void> unload(final MlxModelCatalogEntry entry) async {
    if (_isDiskOnly(entry)) return;
    final dir = _dirOf(entry);
    if (dir == null) return;
    // The dfp unload is synchronous.
    final runtime = MlxModelRuntime.instance;
    if (_isLfm(entry)) {
      runtime.unloadLfm(dir);
    } else {
      runtime.unloadQwen(dir);
    }
  }
}
