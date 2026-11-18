/// The LFM2.5 runtime-cycle probe (2026-11-18: the `local:lfm` cast
/// joined the manager's lifecycle) — the live-GPU proof that the
/// one-engine-per-snapshot law holds for the lfm2 family exactly as it
/// does for qwen: load → generate → isLoaded true → unload → false →
/// reload, plus the sampled rung (the -971 class) and the adopt path.
///
/// Run from the last_answer workspace: `fvm dart run tool/lfm25_runtime_probe.dart`.
library;

import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

Future<void> main() async {
  final dir = resolveLfm2SnapshotDir(null);
  if (dir == null) {
    print('PROBE: no LFM2.5 snapshot under the hub cache — nothing to prove');
    return;
  }
  print('PROBE: snapshot $dir');

  // Load (off the caller isolate) + the registry answers.
  final engine = await NativeLfm2TextEngine.loadAsync(snapshotDir: dir);
  print('PROBE: isLoaded after load = ${NativeLfm2TextEngine.isLoaded(dir)}');

  // Greedy completion through the handle.
  final completion = engine.generate(
    prompt: 'The capital of France is',
    maxTokens: 16,
  );
  print('PROBE: greedy → ${completion.text.trim()}');

  // The idempotent load: a second call adopts the SAME registry entry
  // (the native load scans model_dir first — no second weight load),
  // so the twin drives the live engine instead of refusing.
  final twin = await NativeLfm2TextEngine.loadAsync(snapshotDir: dir);
  print(
    'PROBE: twin generates → '
    '${twin.generate(prompt: 'The capital of France is', maxTokens: 4).text.trim()}',
  );
  twin.dispose();

  // Unload frees; the registry answers honestly.
  engine.dispose();
  print('PROBE: isLoaded after unload = ${NativeLfm2TextEngine.isLoaded(dir)}');

  // Reload + the sampled rung (the -971 class must stay served).
  final again = await NativeLfm2TextEngine.loadAsync(snapshotDir: dir);
  print('PROBE: isLoaded after reload = ${NativeLfm2TextEngine.isLoaded(dir)}');
  final sampled = again.generate(
    prompt: 'Say hello in exactly one word.',
    maxTokens: 12,
    temperature: 0.7,
    repetitionPenalty: 1.1,
  );
  print('PROBE: sampled → ${sampled.text.trim()}');
  again.dispose();
  print('PROBE: final isLoaded = ${NativeLfm2TextEngine.isLoaded(dir)}');
  print('PROBE: OK');
}
