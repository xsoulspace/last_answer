/// Local model manager (2026-11-18 v3, docs/design/models-local-manager.md)
/// — the catalog lens's merged local-models section over a FAKE
/// installer + a FAKE runtime (the shell test-lane laws: hermetic
/// machine, no network, settle before taps, the state's MAP is the
/// assertion — never UI pixels).
///
/// Under test:
/// * the merged section: ONE header — the budget bar LEADS (the map:
///   system + floor + available segments), the curated catalog rows
///   follow in lifecycle order (loaded → downloaded → not installed),
///   the built-in lane FOOTER closes it; the standalone `qwen` lane
///   row does not exist;
/// * the rows are ONE quiet line (v3): dot + STATUS WORD (generating /
///   ≈tok/s / Downloaded / Not downloaded), metadata
///   (`params · quant · size`), ONE primary verb + the `⋯` overflow —
///   the two-stage chips are gone, the state is the word;
/// * fit AT THE VERB (v3): the machine verdict is said once above the
///   rows; a Load the arithmetic refuses renders disabled with the
///   quiet reason line — never a standing orange chip per row;
/// * the consent law: Download opens the dialog that names the model
///   and the size; Confirm installs with `userConsent: true`, streams
///   the progress INTO the row (phase word + percent, then
///   downloaded/total bytes), and lands the Downloaded status; Cancel
///   installs nothing;
/// * the load/unload verbs drive the faked runtime and flip the
///   status (one operation at a time per row, the row spinner
///   mid-flight, a refusal named verbatim);
/// * the `⋯` menu: Delete (confirm → honest flip back) and Details
///   (the sheet with the sensed rows);
/// * a failed install ends in the named-code error line, never
///   swallowed, and the row's verb returns.
library;

// ignore_for_file: close_sinks
// The fake installer's pipes are test-driven handles: each is closed
// by finish()/fail() on the path that opened it.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/models/local_models_state.dart';
import 'package:lastanswer/shell/models/models_view.dart';
import 'package:lastanswer/shell/models/models_widgets.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

/// One fake installer: no network, no filesystem — installs stream
/// through a controller the test drives, installs and deletes mutate
/// an in-memory set (the marker-file stand-in).
final class _FakeInstaller implements LocalModelInstaller {
  final Set<String> installedIds = <String>{};
  final Map<String, StreamController<ProvisionProgress>> _pipes =
      <String, StreamController<ProvisionProgress>>{};
  bool consentSeen = false;

  @override
  InstalledState stateOf(final MlxModelCatalogEntry entry) => InstalledState(
    installed: installedIds.contains(entry.repoId),
    snapshotDir: installedIds.contains(entry.repoId)
        ? '/hub/${entry.repoId}'
        : null,
  );

  @override
  Stream<ProvisionProgress> install(
    final MlxModelCatalogEntry entry, {
    required final bool userConsent,
  }) {
    consentSeen = userConsent;
    final pipe = StreamController<ProvisionProgress>();
    _pipes[entry.repoId] = pipe;
    return pipe.stream;
  }

  void emit(final String repoId, final ProvisionProgress progress) {
    _pipes[repoId]!.add(progress);
  }

  Future<void> finish(final String repoId) async {
    installedIds.add(repoId);
    await _pipes.remove(repoId)!.close();
  }

  Future<void> fail(final String repoId, final String code) async {
    final pipe = _pipes.remove(repoId)?..addError(Exception(code));
    await pipe!.close();
  }

  @override
  Future<bool> delete(final MlxModelCatalogEntry entry) async =>
      installedIds.remove(entry.repoId);
}

/// One fake runtime lane (the [LocalModelRuntime] seam): an in-memory
/// loaded map, call counters, an optional load gate (to hold a load
/// mid-flight and assert the row spinner), and an optional load error
/// (the refusal path). No RAM, no engine.
final class _FakeRuntime implements LocalModelRuntime {
  final Map<String, bool> loaded = <String, bool>{};
  int loadCalls = 0;
  int unloadCalls = 0;
  Completer<void>? loadGate;
  Exception? loadError;

  @override
  bool isLoaded(final MlxModelCatalogEntry entry) =>
      loaded[entry.repoId] ?? false;

  @override
  Future<void> load(final MlxModelCatalogEntry entry) async {
    loadCalls++;
    if (loadGate case final gate?) await gate.future;
    if (loadError case final error?) throw error;
    loaded[entry.repoId] = true;
  }

  @override
  Future<void> unload(final MlxModelCatalogEntry entry) async {
    unloadCalls++;
    loaded.remove(entry.repoId);
  }
}

Widget _wrap(final Widget child) => MaterialApp(
  // The kit overlay host (same shape as models_lenses_test): the
  // dialog route needs the Portal ancestor.
  builder: (final context, final child) =>
      Portal(child: child ?? const SizedBox.shrink()),
  locale: const Locale('en'),
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  home: Scaffold(body: child),
);

/// The fixture palette document (the models lenses' fixture shape):
/// its builtin cast rows make the world rungs non-empty, so the
/// catalog table renders its class sections — with the merged local
/// section carrying the `laya` service row (2026-11-18: the standalone
/// `qwen` lane row is absorbed into the checkpoints, so the fixture
/// rides `laya` as the visible service row).
Map<String, Object?> _paletteDoc() => {
  'model_palette': {
    'providers': <String, Object?>{},
    'cast': <Object?>[
      {'id': 'qwen', 'builtin': true, 'role': 'generative'},
      {'id': 'jev', 'builtin': true, 'role': 'decision'},
      {'id': 'laya', 'builtin': true, 'role': 'decision'},
    ],
  },
};

void main() {
  late Directory temp;
  late WorldStateService world;
  late _FakeInstaller fake;
  late _FakeRuntime fakeRuntime;
  late LocalModelsState local;

  /// The canned memory sensor (the budget law's seam, 2026-11-18): a
  /// healthy 16 GB machine by default — every catalog entry fits; a
  /// test rewrites this before `local.refreshBudget()` to stage a
  /// tighter machine or a sensor-absent one. Never `vm_stat` in the
  /// test lane.
  MemoryFacts? Function() memorySensor = () => const MemoryFacts(
    availableMegabytes: 12288,
    freeMegabytes: 512,
    totalMegabytes: 16384,
  );

  /// One hermetic machine: the world read model over a fixture config
  /// (a disposable world home, no doctor, no timers) and the local
  /// models state over the fake installer + the fake runtime lane +
  /// the canned sensor. `withRuntime: false` stages the degraded
  /// disk-only shape.
  Future<void> mount(
    final WidgetTester tester, {
    final bool withRuntime = true,
  }) async {
    temp = Directory.systemTemp.createTempSync('models_local_');
    final worldHome = '${temp.path}/worlds/local';
    Directory('$worldHome/.xsoulspace').createSync(recursive: true);
    File(
      '$worldHome/.xsoulspace/config.json',
    ).writeAsStringSync(jsonEncode(_paletteDoc()));
    world = WorldStateService(
      debugDoctor: (_) => <String, Object?>{
        'daemon': <String, Object?>{'live': false, 'worldHome': worldHome},
        'artifacts': <String, Object?>{
          'daemon': <Object?, Object?>{'present': false, 'path': ''},
        },
      },
      debugWorldHome: worldHome,
    );
    addTearDown(world.dispose);
    await world.refresh();

    fake = _FakeInstaller();
    fakeRuntime = _FakeRuntime();
    local = LocalModelsState(
      installer: fake,
      runtime: withRuntime ? fakeRuntime : null,
      readMemoryFacts: () async => memorySensor(),
    );
    addTearDown(local.dispose);
    await local.refresh();

    await tester.pumpWidget(
      _wrap(ModelsView(world: world, localModels: local)),
    );
    await tester.pump();
    addTearDown(() => temp.deleteSync(recursive: true));
  }

  /// Unfocus first (a blinking caret poisons pumpAndSettle), bring the
  /// key into view (the catalog table is a lazy ListView), then tap.
  /// `settle: false` skips the pumpAndSettle for taps that mount an
  /// animating spinner (the in-flight install row) — plain pumps only.
  Future<void> settleTap(
    final WidgetTester tester,
    final String keyName, {
    final bool settle = true,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    final finder = find.byKey(ValueKey(keyName));
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        240,
        scrollable: find.byType(Scrollable).last,
      );
    } else {
      await tester.ensureVisible(finder);
    }
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  const repo06 = 'mlx-community/Qwen3-0.6B-4bit';
  const ref06 = 'Qwen3-0.6B-4bit';

  group('the local model catalog', () {
    testWidgets('the merged section leads with the budget bar, holds '
        'the curated rows and closes with the service rows; the '
        'standalone qwen lane row does not exist', (final tester) async {
      await mount(tester);

      expect(find.text('Local models'), findsOneWidget);
      expect(find.byKey(const ValueKey('models.class.onDevice')), findsNothing);
      expect(find.byKey(const ValueKey('models.onDevice.qwen')), findsNothing);
      // The exact standalone lane label is gone; the checkpoints keep
      // their own display names.
      expect(find.text('Qwen3'), findsNothing);

      final section = find.byKey(const ValueKey('models.class.localModels'));
      // The budget bar leads the section, a REAL bar: 12px tall with
      // its keyed segments inside the section (v3: the dark SYSTEM
      // rest, not the old "used" label).
      final bar = find.descendant(
        of: section,
        matching: find.byKey(const ValueKey('models.local.budget.bar')),
      );
      await tester.scrollUntilVisible(
        bar,
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(bar).height, 12);
      expect(
        find.descendant(
          of: section,
          matching: find.byKey(
            const ValueKey('models.local.budget.seg.system'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: section,
          matching: find.byKey(const ValueKey('models.local.budget.seg.floor')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: section,
          matching: find.byKey(
            const ValueKey('models.local.budget.seg.available'),
          ),
        ),
        findsOneWidget,
      );

      // The built-in lane chip rides INSIDE the merged section's
      // footer, after the checkpoints (the fixture's `laya` cast).
      final layaRow = find.descendant(
        of: section,
        matching: find.byKey(const ValueKey('models.onDevice.laya')),
      );
      await tester.scrollUntilVisible(
        layaRow,
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(layaRow, findsOneWidget);
      expect(find.text('Laya'), findsOneWidget);
    });

    testWidgets('the curated rows render the one-line anatomy: name, '
        'metadata, status word, primary verb', (final tester) async {
      await mount(tester);

      expect(find.text('Local models'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('models.local.$ref06.row')),
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text('Qwen3 0.6B'), findsOneWidget);
      // The metadata is one quiet mono line (params · quant · size).
      expect(find.textContaining('0.6B · 4bit ·'), findsOneWidget);
      // Nothing downloaded yet: every row reads the quiet status word,
      // and no fit warning exists (the verdict lives at the verb).
      expect(find.text('Not downloaded'), findsNWidgets(5));
      expect(find.text('Downloaded'), findsNothing);
      expect(find.textContaining('needs'), findsNothing);
      expect(
        find.byKey(const ValueKey('models.local.$ref06.download')),
        findsOneWidget,
      );
    });

    testWidgets('the consent law: the Download tap opens the dialog '
        'naming model + size + network; confirm streams the progress '
        'into the row and lands the Downloaded chip (with the runtime '
        'lane, the fresh row reads Unloaded)', (final tester) async {
      await mount(tester);

      await settleTap(tester, 'models.local.$ref06.download');
      // The dialog names the model and the approximate size.
      expect(find.text('Download local model?'), findsOneWidget);
      expect(find.textContaining('Qwen3 0.6B'), findsWidgets);
      expect(find.textContaining('network'), findsOneWidget);

      // The confirm mounts the in-flight spinner — plain pumps.
      await settleTap(
        tester,
        'models.local.$ref06.consent.confirm',
        settle: false,
      );
      expect(fake.consentSeen, isTrue);

      // Percent progress renders the phase word + percent, and the
      // keyed progress bar rides the row.
      fake.emit(
        repo06,
        const ProvisionProgress(phase: ProvisionPhase.downloading, percent: 40),
      );
      await tester.pump();
      expect(find.text('downloading 40%'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.local.$ref06.progress')),
        findsOneWidget,
      );

      // A byte-only update (no percent) renders downloaded/total.
      fake.emit(
        repo06,
        const ProvisionProgress(
          phase: ProvisionPhase.downloading,
          downloadedBytes: 200 * 1024 * 1024,
          totalBytes: 400 * 1024 * 1024,
        ),
      );
      await tester.pump();
      expect(find.text('downloading 200 MB / 400 MB'), findsOneWidget);

      await fake.finish(repo06);
      await tester.pumpAndSettle();
      expect(find.text('Downloaded'), findsOneWidget);
      expect(find.text('Not downloaded'), findsNWidgets(4));
      expect(
        find.byKey(const ValueKey('models.local.$ref06.download')),
        findsNothing,
      );
      // The MEMORY stage answers honestly for the fresh entry: the
      // row offers Load (it is NOT loaded) and the status word stays
      // the disk truth.
      expect(
        find.byKey(const ValueKey('models.local.$ref06.load')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.unload')),
        findsNothing,
      );
    });

    testWidgets('the consent cancel installs nothing', (final tester) async {
      await mount(tester);

      await settleTap(tester, 'models.local.$ref06.download');
      expect(find.text('Download local model?'), findsOneWidget);
      await settleTap(tester, 'models.local.$ref06.consent.cancel');

      expect(fake.consentSeen, isFalse);
      expect(find.text('Not downloaded'), findsNWidgets(5));
      expect(
        find.byKey(const ValueKey('models.local.$ref06.progress')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('models.local.error')), findsNothing);
    });

    testWidgets('delete through the ⋯ menu confirms and flips the '
        'row honestly back to not downloaded', (final tester) async {
      await mount(tester);
      fake.installedIds.add(repo06);
      await local.refresh();
      await tester.pumpAndSettle();

      expect(find.text('Downloaded'), findsOneWidget);
      // Delete lives in the ⋯ overflow (v3: one primary verb on the
      // row, the destructive verb behind the menu).
      await settleTap(tester, 'models.local.$ref06.menu');
      await settleTap(tester, 'models.local.$ref06.delete');
      expect(find.text('Delete local model?'), findsOneWidget);
      await settleTap(tester, 'models.local.$ref06.delete.confirm');

      expect(find.text('Downloaded'), findsNothing);
      expect(find.text('Not downloaded'), findsNWidgets(5));
      expect(
        find.byKey(const ValueKey('models.local.$ref06.download')),
        findsOneWidget,
      );
    });

    testWidgets('a failed install lands its named code in the error '
        'line and returns the row verb (never swallowed)', (
      final tester,
    ) async {
      await mount(tester);

      await settleTap(tester, 'models.local.$ref06.download');
      await settleTap(
        tester,
        'models.local.$ref06.consent.confirm',
        settle: false,
      );
      await fake.fail(repo06, 'install_failed:disk_full');
      await tester.pumpAndSettle();

      expect(find.text('failed: install_failed:disk_full'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.local.$ref06.download')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.progress')),
        findsNothing,
      );
    });

    testWidgets('the budget bar leads; the fit verdict lives AT the '
        'Load verb (disabled with its quiet reason), never as a '
        'standing chip', (final tester) async {
      await mount(tester);

      // The healthy machine's bar: system / floor / available segments
      // with the legend values verbatim — and NO fit warnings at all
      // (every row fits; nothing to say).
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('models.local.budget.bar')),
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text('kept free (headroom) 4.0 GB'), findsOneWidget);
      expect(find.text('available for local loads 8.0 GB'), findsOneWidget);
      expect(find.textContaining('needs'), findsNothing);
      expect(
        find.byKey(const ValueKey('models.local.budget.noFit')),
        findsNothing,
      );

      // The tight machine (5 GB available), with the 1.7B DOWNLOADED:
      // its Load disables and the quiet reason line names the gap
      // (256 MB short of the required+floor budget) — the aggregate
      // verdict is said once above the rows.
      memorySensor = () => const MemoryFacts(
        availableMegabytes: 5120,
        freeMegabytes: 256,
        totalMegabytes: 16384,
      );
      fake.installedIds.add('mlx-community/Qwen3-1.7B-4bit');
      await local.refresh();
      await tester.pumpAndSettle();

      final load17 = find.byKey(
        const ValueKey('models.local.Qwen3-1.7B-4bit.load'),
      );
      await tester.scrollUntilVisible(
        load17,
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      // The machine verdict, said ONCE and ACTIONABLE: it names the
      // next runnable step (the entry closest to fitting).
      expect(
        find.byKey(const ValueKey('models.local.budget.noFit')),
        findsOneWidget,
      );
      expect(
        find.textContaining('free 256 MB more to run Qwen3 1.7B'),
        findsOneWidget,
      );
      // The verb is visible but disabled; the reason names the gap.
      expect(load17, findsOneWidget);
      final button = tester.widget<ModelsButton>(
        find.ancestor(of: load17, matching: find.byType(ModelsButton)),
      );
      expect(button.disabled, isTrue);
      expect(
        find.byKey(const ValueKey('models.local.Qwen3-1.7B-4bit.fitReason')),
        findsOneWidget,
      );
      expect(find.textContaining('needs 256 MB more'), findsOneWidget);
      // A disabled verb does not drive the runtime.
      await tester.tap(load17, warnIfMissed: false);
      await tester.pump();
      expect(fakeRuntime.loadCalls, 0);

      // The sensor-absent machine: no bar, no reasons — the honest
      // degraded line instead (never a guessed verdict).
      memorySensor = () => null;
      await local.refreshBudget();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('models.local.Qwen3-1.7B-4bit.fitReason')),
        findsNothing,
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('models.local.budget.unknown')),
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'memory facts unavailable — the load gate runs sensor-absent',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the status word and verb sets follow the disk/memory '
        'state combination', (final tester) async {
      await mount(tester);
      Future<void> showRow() async {
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('models.local.$ref06.row')),
          240,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
      }

      // NOT DOWNLOADED: quiet status word, ONE verb (Download) — no
      // Load/Unload.
      await showRow();
      final row06 = find.byKey(const ValueKey('models.local.$ref06.row'));
      expect(
        find.descendant(of: row06, matching: find.text('Not downloaded')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.download')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.load')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.unload')),
        findsNothing,
      );

      // DOWNLOADED + UNLOADED: the status word says so and the verb
      // flips to Load — the Download verb is gone.
      fake.installedIds.add(repo06);
      await local.refresh();
      await tester.pumpAndSettle();
      await showRow();
      expect(
        find.descendant(of: row06, matching: find.text('Downloaded')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.load')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.unload')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.download')),
        findsNothing,
      );

      // DOWNLOADED + LOADED: the status word flips to Loaded and the
      // memory verb flips to Unload.
      fakeRuntime.loaded[repo06] = true;
      await local.refresh();
      await tester.pumpAndSettle();
      await showRow();
      expect(
        find.descendant(of: row06, matching: find.text('Loaded')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.unload')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.load')),
        findsNothing,
      );
    });

    testWidgets('a runtime-absent lane degrades to disk-only rows (no '
        'Load/Unload verbs, Delete through the menu)', (final tester) async {
      await mount(tester, withRuntime: false);
      fake.installedIds.add(repo06);
      await local.refresh();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('models.local.$ref06.row')),
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text('Downloaded'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.local.$ref06.load')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.unload')),
        findsNothing,
      );
      // Disk verbs keep working: Delete (through the ⋯ menu) is the
      // only verb a runtime-absent downloaded row offers.
      await settleTap(tester, 'models.local.$ref06.menu');
      await settleTap(tester, 'models.local.$ref06.delete');
      expect(find.text('Delete local model?'), findsOneWidget);
      await settleTap(tester, 'models.local.$ref06.delete.confirm');
      expect(find.text('Downloaded'), findsNothing);
    });

    testWidgets('Load and Unload drive the runtime and flip the '
        'memory chip; a refused load names its code verbatim', (
      final tester,
    ) async {
      await mount(tester);
      fake.installedIds.add(repo06);
      await local.refresh();
      await tester.pumpAndSettle();

      // Hold the load mid-flight: the verbs step aside for the row
      // spinner (the install busy law), and the chip does not guess.
      final gate = Completer<void>();
      fakeRuntime.loadGate = gate;
      await settleTap(tester, 'models.local.$ref06.load', settle: false);
      await tester.pump();
      // The v3 verb crossfade (200ms) keeps the outgoing set mounted —
      // advance the clock past it; the spinner itself never settles.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LaSpinner), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.local.$ref06.load')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.delete')),
        findsNothing,
      );
      gate.complete();
      await tester.pumpAndSettle();
      expect(fakeRuntime.loadCalls, 1);
      expect(find.text('Loaded'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.local.$ref06.unload')),
        findsOneWidget,
      );

      // Unload flips the row back through the same verbs.
      await settleTap(tester, 'models.local.$ref06.unload');
      expect(fakeRuntime.unloadCalls, 1);
      expect(find.text('Downloaded'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.local.$ref06.load')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.$ref06.unload')),
        findsNothing,
      );

      // A refused load lands in the error line verbatim; the status
      // stays honest and the verbs return.
      fakeRuntime
        ..loadGate = null
        ..loadError = Exception('gate_refused');
      await settleTap(tester, 'models.local.$ref06.load', settle: false);
      await tester.pumpAndSettle();
      expect(find.text('failed: gate_refused'), findsOneWidget);
      expect(find.text('Downloaded'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.local.$ref06.load')),
        findsOneWidget,
      );
    });

    testWidgets('the ⋯ menu opens the Details sheet with the sensed '
        'rows', (final tester) async {
      await mount(tester);
      fake.installedIds.add(repo06);
      await local.refresh();
      await tester.pumpAndSettle();

      await settleTap(tester, 'models.local.$ref06.menu');
      await settleTap(tester, 'models.local.$ref06.details');
      expect(
        find.byKey(const ValueKey('models.local.$ref06.details.sheet')),
        findsOneWidget,
      );
      // The sheet names the sensed facts: disk truth, memory truth,
      // the size-on-disk row (the fake's snapshot dir does not exist —
      // the honest '—', never a guessed size), and the path row.
      expect(find.text('disk'), findsOneWidget);
      expect(find.text('memory'), findsOneWidget);
      expect(find.text('size on disk'), findsOneWidget);
      expect(find.text('snapshot path'), findsOneWidget);
      expect(find.text('/hub/$repo06'), findsOneWidget);
      expect(find.text('last generation'), findsOneWidget);
      // The bound-actors row (phase 3): no actor binds this cast in the
      // hermetic world — the honest em dash, never a guess.
      expect(find.text('used by'), findsOneWidget);
    });
  });

  group('the state layer (no widgets)', () {
    test('loadEntry serializes per row: a second call mid-flight is a '
        'no-op, and the loaded fact lands when the runtime answers', () async {
      final installer = _FakeInstaller();
      installer.installedIds.add(repo06);
      final runtime = _FakeRuntime();
      final gate = Completer<void>();
      runtime.loadGate = gate;
      final state = LocalModelsState(
        installer: installer,
        runtime: runtime,
        readMemoryFacts: () async => null,
      );
      addTearDown(state.dispose);
      await state.refresh();

      final entry = state.catalog.first;
      expect(state.hasRuntime, isTrue);
      expect(state.isLoaded(entry), isFalse);

      final first = state.loadEntry(entry);
      await Future<void>.delayed(Duration.zero);
      expect(state.isBusy(entry), isTrue);
      // The second call refuses on the busy ref — the runtime never
      // sees it.
      await state.loadEntry(entry);
      expect(runtime.loadCalls, 1);

      gate.complete();
      await first;
      expect(state.isBusy(entry), isFalse);
      expect(state.isLoaded(entry), isTrue);
    });
  });
}
