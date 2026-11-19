/// Models refactor (2026-11-14) — the THREE LENSES over one hermetic
/// machine (the shell test-lane laws: real services on a disposable
/// realm, settle before any runAsync window, forms own their
/// controllers, unfocus before pumpAndSettle, the candidate MAP diff is
/// the assertion — never UI pixels).
///
/// Under test:
/// * CATALOG — the nested provider → model table, the compact law
///   (below 640px the chip run drops into the expanded block), the
///   inline forms over the FULL per-model schema, and the JSON lane's
///   named parse refusal;
/// * the dirty bar — propose surfaces the host receipt, a non-owner
///   apply renders the recovery VERBATIM (the single gate law: no tier
///   gate on the surface, the harness's owner-only apply is the gate);
/// * BINDINGS — the ladder order and the persisted primary are
///   candidate verbs (up/down/radio move the MAP);
/// * OBSERVE — the daemon card, the verbatim health ledger and the
///   per-model dispatch ledger (an unbound actor groups honestly).
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/data_journal/actor_roster.dart';
import 'package:lastanswer/ui_chat/palette_health.dart';
import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/realm_world.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_models/local_models_state.dart';
import 'package:lastanswer/ui_models/models_view.dart';
import 'package:lastanswer/ui_models/palette_candidate.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

/// One hermetic installer: no hub reads, nothing installed — the
/// fixtures must never see the operator's real cache (the merged
/// surface's slot door reflects install state).
final class _HermeticInstaller implements LocalModelInstaller {
  @override
  InstalledState stateOf(final MlxModelCatalogEntry entry) =>
      const InstalledState(installed: false);

  @override
  Stream<ProvisionProgress> install(
    final MlxModelCatalogEntry entry, {
    required final bool userConsent,
  }) => const Stream.empty();

  @override
  Future<bool> delete(final MlxModelCatalogEntry entry) async => false;
}

Widget _wrap(final Widget child) => MaterialApp(
  // The kit overlay host (same shape as last_answer_app.dart):
  // LaTooltip/LaMenuAnchor/LaSelect below need a Portal ancestor.
  builder: (final context, final child) =>
      Portal(child: child ?? const SizedBox.shrink()),
  locale: const Locale('en'),
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  home: Scaffold(body: child),
);

Map<String, Object?> _paletteDoc() => {
  'model_palette': {
    'providers': {
      'modelscope': {
        'transport': 'openai_compatible',
        'base_url': 'https://api-inference.modelscope.ai/v1',
        'credential_env': 'MODELSCOPE_API_KEY',
        'models': [
          {'id': 'Qwen3.8-Max-Preview', 'max_tokens': 262144},
        ],
      },
      'openrouter': {
        'transport': 'openrouter',
        'credential_env': 'OPENROUTER_API_KEY',
        'models': [
          {'id': 'deepseek/deepseek-v4.1-flash'},
        ],
      },
    },
    'cast': [
      {
        'id': 'modelscope_qwen38max',
        'provider': 'modelscope',
        'model': 'Qwen3.8-Max-Preview',
        'role': 'generative',
        'primary': true,
      },
      {
        'id': 'openrouter_deepseek',
        'provider': 'openrouter',
        'model': 'deepseek/deepseek-v4.1-flash',
        'role': 'generative',
      },
      {'id': 'qwen', 'builtin': true, 'role': 'generative'},
      {'id': 'jev', 'builtin': true, 'role': 'decision'},
      {'id': 'apple_foundation_afm', 'builtin': true, 'role': 'generative'},
    ],
  },
};

void main() {
  late Directory temp;
  late String worldHome;
  late WorldStateService world;
  late RealmChatService chat;

  /// One hermetic machine: the read-model world (a pinned device home +
  /// a fixture config under the world home) AND the seat world the
  /// palette verbs ride (a disposable realm whose scope dir carries the
  /// same fixture, so the host's write-site walk-up stays hermetic).
  Future<void> mount(final WidgetTester tester) async {
    temp = Directory.systemTemp.createTempSync('models_lenses_');
    RealmWorld.debugDeviceHome = temp.path;
    worldHome = '${temp.path}/worlds/local';
    Directory('$worldHome/.xsoulspace').createSync(recursive: true);
    // The fixture config rides the DEVICE home (the global-config
    // law: that is the default file the chain reads — the old
    // world-home walk-up is gone).
    Directory('${temp.path}/.xsoulspace').createSync(recursive: true);
    File('${temp.path}/.xsoulspace/config.json').writeAsStringSync(
      jsonEncode(_paletteDoc()),
    );
    Directory('${temp.path}/.xsoulspace').createSync(recursive: true);
    File('${temp.path}/.xsoulspace/palette_health.json').writeAsStringSync(
      jsonEncode({
        'entries': {
          'modelscope_qwen38max': {'status': 'ok'},
          'openrouter_deepseek': {
            'status': 'failed',
            'code': 'transport_http_403',
          },
          'qwen': {
            'status': 'not_downloaded',
            'detail': 'weights are not cached; the runtime never downloads',
          },
        },
      }),
    );
    world = WorldStateService(
      health: PaletteHealthStore(resolveHome: () => temp.path),
      debugDoctor: (_) => <String, Object?>{
        'daemon': {'live': true, 'pid': 7, 'worldHome': worldHome},
        'artifacts': {
          'daemon': {'present': false, 'path': ''},
        },
      },
      debugWorldHome: worldHome,
    );
    addTearDown(world.dispose);
    await world.refresh();

    Directory(
      '${temp.path}/seat/world/.xsoulspace',
    ).createSync(recursive: true);
    File(
      '${temp.path}/seat/world/.xsoulspace/config.json',
    ).writeAsStringSync(jsonEncode(_paletteDoc()));

    // Real IO (the realm store) opens inside a runAsync window, BEFORE
    // any widget/animation ticker exists (the fake-clock poison law).
    await tester.runAsync(() async {
      final realmWorld = await RealmWorld.open(
        rootOverride: '${temp.path}/seat',
      );
      chat = RealmChatService(
        debugWorldOverride: realmWorld,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(chat.dispose);
      chat.debugPaletteHealthPath = '${temp.path}/palette_health.json';
      await chat.ensureReady();
      expect(chat.isReady, isTrue, reason: chat.error);
    });

    final localModels = LocalModelsState(
      installer: _HermeticInstaller(),
      readMemoryFacts: () async => null,
    );
    addTearDown(localModels.dispose);
    await localModels.refresh();
    await tester.pumpWidget(
      _wrap(ModelsView(world: world, service: chat, localModels: localModels)),
    );
    await tester.pump();
    addTearDown(() {
      RealmWorld.debugDeviceHome = null;
      temp.deleteSync(recursive: true);
    });
  }

  /// Unfocus first (a blinking caret poisons pumpAndSettle), bring the
  /// key into view (the catalog table is a lazy ListView), then tap.
  Future<void> settleTap(
    final WidgetTester tester,
    final String keyName,
  ) async {
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
  }

  /// The dirty-bar variant: no Scrollable owns these keys, so a plain
  /// tap plus the pumps that drain the verbs' microtask chain.
  Future<void> barTap(final WidgetTester tester, final String keyName) async {
    await tester.tap(find.byKey(ValueKey(keyName)));
    await tester.pump();
    await tester.pump();
  }

  Future<void> enter(
    final WidgetTester tester,
    final String keyName,
    final String text,
  ) async {
    final finder = find.byKey(ValueKey(keyName));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
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
    await tester.enterText(finder, text);
    await tester.pump();
  }

  Future<void> see(final WidgetTester tester, final Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        240,
        scrollable: find.byType(Scrollable).last,
      );
    }
    // "Built" is not "visible": a widget at the viewport's edge eats
    // taps — always settle it fully on-screen.
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    expect(finder, findsOneWidget);
  }

  Future<void> endClean(final WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
  }

  group('the catalog lens', () {
    testWidgets('the reasoning controls are a LANE capability (the Zed '
        'law): tiers for openrouter, an honest absence note for a '
        'transport that declares none', (final tester) async {
      await mount(tester);

      // The openrouter model: the tier picker, titled (never the bare
      // wire value), and the declaration lands on the candidate.
      await settleTap(tester, 'models.provider.openrouter');
      await settleTap(
        tester,
        'models.model.openrouter.deepseek/deepseek-v4.1-flash.edit',
      );
      // The dynamic list starts from the declaration: an undeclared
      // key is ONE tap away through the add-setting row.
      await settleTap(tester, 'models.setting.add.reasoning_effort');
      expect(
        find.byKey(const ValueKey('models.setting.reasoning_effort.high')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.reasoning.noLane')),
        findsNothing,
      );
      await settleTap(tester, 'models.setting.reasoning_effort.high');
      await settleTap(tester, 'models.form.confirm');
      // The row chip titles the declared tier.
      expect(find.text('reasoning High'), findsOneWidget);

      // The openai_compatible lane declares no tiers today: the form
      // names the absence instead of offering a disabled picker.
      await settleTap(tester, 'models.provider.modelscope');
      await settleTap(
        tester,
        'models.model.modelscope.Qwen3.8-Max-Preview.edit',
      );
      expect(
        find.byKey(const ValueKey('models.reasoning.noLane')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.form.reasoning.high')),
        findsNothing,
      );

      await endClean(tester);
    });

    testWidgets('the nested table: provider rows expand into their '
        'models with the verbs on the owning row', (final tester) async {
      await mount(tester);

      // The provider sections sit below the ladder + the catalog (the
      // merged surface's order) — bring them into the lazy viewport.
      await see(
        tester,
        find.byKey(const ValueKey('models.provider.modelscope')),
      );
      expect(
        find.byKey(const ValueKey('models.provider.modelscope')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.provider.openrouter')),
        findsOneWidget,
      );
      // The models are ONE level down, hidden until the row expands.
      expect(
        find.byKey(
          const ValueKey('models.model.modelscope.Qwen3.8-Max-Preview'),
        ),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('models.provider.modelscope')),
      );
      await tester.pump();
      expect(
        find.byKey(
          const ValueKey('models.model.modelscope.Qwen3.8-Max-Preview'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.provider.modelscope.edit')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('models.model.modelscope.Qwen3.8-Max-Preview.edit'),
        ),
        findsOneWidget,
      );
      // The cast chip names who rides the model.
      expect(find.text('modelscope_qwen38max'), findsWidgets);

      await endClean(tester);
    });

    testWidgets('the compact law: below 640px the transport/env chips '
        'drop out of the row (the count stays)', (final tester) async {
      await mount(tester);

      await see(tester, find.text('openai_compatible'));
      expect(find.text('openai_compatible'), findsOneWidget);
      expect(find.text('MODELSCOPE_API_KEY'), findsOneWidget);

      // Post-mount resize rides the view API (setSurfaceSize only
      // seeds the FIRST frame; the metrics change needs tester.view).
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pump();
      expect(find.text('openai_compatible'), findsNothing);
      expect(find.text('MODELSCOPE_API_KEY'), findsNothing);
      expect(find.textContaining('models'), findsWidgets);

      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1;
      await tester.pump();
      expect(find.text('openai_compatible'), findsOneWidget);
      await endClean(tester);
    });

    testWidgets('the inline forms carry the FULL per-model schema into '
        'the candidate (the old form wrote ids only)', (final tester) async {
      await mount(tester);

      await settleTap(tester, 'models.provider.add');
      await enter(tester, 'models.form.id', 'groq');
      await settleTap(tester, 'models.form.confirm');
      // The nested table hides the model verbs one level down: expand
      // the provider row first (the spreadsheet law).
      await settleTap(tester, 'models.provider.groq');
      await settleTap(tester, 'models.model.groq.add');
      await enter(tester, 'models.form.id', 'llama-3.3-70b-versatile');
      await settleTap(tester, 'models.setting.add.max_tokens');
      await enter(tester, 'models.setting.max_tokens.field', '131072');
      await settleTap(tester, 'models.setting.add.capabilities.tools');
      await settleTap(tester, 'models.setting.capabilities.tools.toggle');
      await settleTap(tester, 'models.form.confirm');

      final candidate = PaletteCandidateModel.debugLastCandidate!;
      final groq = (candidate['providers']! as Map)['groq']! as Map;
      expect(groq['transport'], 'openrouter');
      final models = groq['models']! as List;
      expect(models, hasLength(1));
      expect((models.first! as Map)['id'], 'llama-3.3-70b-versatile');
      expect((models.first! as Map)['max_tokens'], 131072);
      expect(
        (models.first! as Map)['capabilities'],
        <String, Object?>{'tools': true},
      );
      // The live parsed palette is untouched until an owner applies.
      expect(world.palette!.providers.containsKey('groq'), isFalse);
      expect(find.text('unsaved changes'), findsOneWidget);

      await endClean(tester);
    });

    testWidgets('the image capability toggles land on the model row '
        '(the binding-consumed pair)', (final tester) async {
      await mount(tester);
      await see(
        tester,
        find.byKey(const ValueKey('models.provider.modelscope')),
      );

      // The fixture's modelscope provider hosts the image model row — the
      // provider is already declared, only the model is added.
      await tester.tap(
        find.byKey(const ValueKey('models.provider.modelscope')),
      );
      await tester.pump();
      await settleTap(tester, 'models.model.modelscope.add');
      await enter(tester, 'models.form.id', 'Qwen/Qwen-Image');
      await enter(
        tester,
        'models.setting.add.free',
        'capabilities.image_generation',
      );
      await settleTap(tester, 'models.setting.add.confirm');
      await settleTap(
        tester,
        'models.setting.capabilities.image_generation.toggle',
      );
      await enter(
        tester,
        'models.setting.add.free',
        'capabilities.image_edit',
      );
      await settleTap(tester, 'models.setting.add.confirm');
      await settleTap(tester, 'models.setting.capabilities.image_edit.toggle');
      await settleTap(tester, 'models.form.confirm');

      final candidate = PaletteCandidateModel.debugLastCandidate!;
      final models =
          ((candidate['providers']! as Map)['modelscope']! as Map)['models']!
              as List;
      final imageModel = models
          .whereType<Map>()
          .singleWhere((model) => model['id'] == 'Qwen/Qwen-Image');
      expect(
        imageModel['capabilities'],
        <String, Object?>{'image_generation': true, 'image_edit': true},
      );

      await endClean(tester);
    });

    testWidgets('propose surfaces the host receipt; a non-owner apply '
        'renders the recovery text VERBATIM (the single gate law)', (
      final tester,
    ) async {
      await mount(tester);

      await settleTap(tester, 'models.provider.add');
      await enter(tester, 'models.form.id', 'groq');
      await settleTap(tester, 'models.form.confirm');

      await barTap(tester, 'models.propose');
      await see(tester, find.byKey(const ValueKey('models.receipt.ok')));
      expect(find.textContaining('beforeSha256'), findsOneWidget);

      await barTap(tester, 'models.apply');
      await see(tester, find.byKey(const ValueKey('models.refusal.recovery')));
      expect(find.textContaining('palette_apply_not_owner'), findsOneWidget);
      expect(find.textContaining('owner-only'), findsOneWidget);

      await endClean(tester);
    });

    testWidgets('the JSON lane names a broken document and keeps the '
        'last valid candidate shape', (final tester) async {
      await mount(tester);

      await settleTap(tester, 'models.json.toggle');
      expect(find.byKey(const ValueKey('models.json.field')), findsOneWidget);
      await enter(tester, 'models.json.field', '{{{');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('models.refusal.local')),
        findsOneWidget,
      );
      expect(find.textContaining('invalid JSON'), findsOneWidget);
      // The candidate kept its shape.
      expect(
        (PaletteCandidateModel.debugLastCandidate!['providers']! as Map)
            .containsKey('modelscope'),
        isTrue,
      );

      await endClean(tester);
    });
  });

    testWidgets('the four class sections: a loopback provider lands in '
        'the local-server section; a free key rides unconsumed', (
      final tester,
    ) async {
      await mount(tester);

      // A loopback endpoint IS the ollama-class lane (the parser's own
      // loopback allowance) — the section law sorts it there.
      await settleTap(tester, 'models.provider.add');
      await enter(tester, 'models.form.id', 'ollama');
      await enter(tester, 'models.form.baseUrl', 'http://127.0.0.1:11434/v1');
      await settleTap(tester, 'models.form.confirm');
      // The merged surface's ladder leads; the provider sections sit
      // below — bring the local-server one into the lazy viewport.
      await see(tester, find.byKey(const ValueKey('models.class.localServer')));
      expect(
        find.byKey(const ValueKey('models.class.localServer')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('models.class.localServer')),
          matching: find.text('loopback'),
        ),
        findsWidgets,
      );

      // The dynamic editor: a free key rides verbatim, marked
      // unconsumed (declared, tolerated by the parser, read by nobody).
      await see(tester, find.byKey(const ValueKey('models.provider.ollama')));
      await settleTap(tester, 'models.provider.ollama');
      await settleTap(tester, 'models.model.ollama.add');
      await enter(tester, 'models.form.id', 'llama3');
      await enter(tester, 'models.setting.add.free', 'num_ctx');
      await settleTap(tester, 'models.setting.add.confirm');
      await enter(tester, 'models.setting.num_ctx.field', '4096');
      await settleTap(tester, 'models.form.confirm');
      final candidate = PaletteCandidateModel.debugLastCandidate!;
      final models =
          ((candidate['providers']! as Map)['ollama']! as Map)['models']!
              as List;
      expect((models.first! as Map)['num_ctx'], 4096);

      await endClean(tester);
    });

    testWidgets('the merged MODELS section (2026-11-19): the ladder '
        'rows carry priority + lifecycle in ONE place — the standalone '
        'checkpoint rows and the lane chips are folded into their '
        'brains', (final tester) async {
      await mount(tester);

      // The merged section title + the ladder's one-line explanation.
      expect(find.text('Models'), findsOneWidget);
      expect(find.textContaining('Tried top-down'), findsOneWidget);
      // The old on-device section does not exist; the `qwen` lane row
      // is absorbed (its id stays in Bindings/Observe).
      expect(
        find.byKey(const ValueKey('models.class.onDevice')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('models.onDevice.qwen')),
        findsNothing,
      );

      final section = find.byKey(const ValueKey('models.class.localModels'));
      // AFM is a LADDER ROW now (priority position 7 in the fixture):
      // the old lane chip is gone.
      expect(
        find.byKey(const ValueKey('models.onDevice.apple_foundation_afm')),
        findsNothing,
      );
      final afm = find.descendant(
        of: section,
        matching: find.byKey(const ValueKey('models.rung.apple_foundation_afm')),
      );
      await see(tester, afm);
      // The checkpoint row folded into its brain: the qwen row hosts
      // the default checkpoint's download verb (the alias law's title
      // names the model — nothing installed, so the slot name shows).
      final qwen = find.descendant(
        of: section,
        matching: find.byKey(const ValueKey('models.rung.qwen')),
      );
      await see(tester, qwen);
      expect(
        find.descendant(
          of: qwen,
          matching: find.byKey(
            const ValueKey('models.local.Qwen3-0.6B-4bit.download'),
          ),
        ),
        findsOneWidget,
      );

      await endClean(tester);
    });
  group('the models ladder (the merged surface)', () {
    testWidgets('the lane chip is the FAMILY truth: builtin never means '
        'local by default (jev rides the hosted OpenRouter lane, afm '
        'the Apple-specific one, qwen the local MLX one)', (
      final tester,
    ) async {
      await mount(tester);

      // jev is a decision role: it lives under System lanes now
      // (collapsed by default, at the ladder's foot — bring the
      // expander into view, then expand it).
      final expander = find.byKey(const ValueKey('models.systemLanes'));
      await tester.ensureVisible(expander);
      await tester.pumpAndSettle();
      await tester.tap(expander);
      await tester.pump();
      final jev = find.byKey(const ValueKey('models.systemLane.jev'));
      expect(jev, findsOneWidget);
      expect(
        find.descendant(of: jev, matching: find.text('remote')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: jev, matching: find.text('local')),
        findsNothing,
        reason: 'the hosted lane is not local',
      );
      // The subtitle names the lane, never silence.
      expect(
        find.descendant(of: jev, matching: find.textContaining('OpenRouter')),
        findsOneWidget,
      );
      final afm = find.byKey(
        const ValueKey('models.rung.apple_foundation_afm'),
      );
      expect(
        find.descendant(of: afm, matching: find.text('on-device')),
        findsOneWidget,
      );
      final qwen = find.byKey(const ValueKey('models.rung.qwen'));
      expect(
        find.descendant(of: qwen, matching: find.text('on-device')),
        findsOneWidget,
      );

      await endClean(tester);
    });

    testWidgets('the ladder order is the candidate verb; position 1 '
        'carries the default (the radio is gone)', (final tester) async {
      await mount(tester);

      expect(
        find.byKey(const ValueKey('models.rung.modelscope_qwen38max')),
        findsOneWidget,
      );
      // The retired radio verb is GONE: moving to the top IS "set as
      // default" now (brain-policy law, 2026-11-16).
      expect(
        find.byKey(
          const ValueKey('models.cast.modelscope_qwen38max.primary'),
        ),
        findsNothing,
      );

      // Down moves the row in the CANDIDATE cast order.
      await settleTap(tester, 'models.cast.modelscope_qwen38max.down');
      var cast = (PaletteCandidateModel.debugLastCandidate!['cast']! as List)
          .whereType<Map<Object?, Object?>>()
          .toList();
      expect(cast.first['id'], 'openrouter_deepseek');

      // The default mark FOLLOWS position 1: the row moved off the top
      // clears, the new first generative row carries it — order and
      // default can never disagree.
      cast = (PaletteCandidateModel.debugLastCandidate!['cast']! as List)
          .whereType<Map<Object?, Object?>>()
          .toList();
      final byId = <String, Map<Object?, Object?>>{
        for (final entry in cast) '${entry['id']}': entry,
      };
      expect(byId['openrouter_deepseek']!['primary'], true);
      expect(byId['modelscope_qwen38max']!.containsKey('primary'), isFalse);
      expect(find.text('unsaved changes'), findsOneWidget);

      await endClean(tester);
    });

    testWidgets('the session delegate-via override rides a labelled '
        'chip and clears through selectRung', (final tester) async {
      await mount(tester);
      world.selectRung('qwen');
      await tester.pump();
      await see(tester, find.text('session: qwen'));
      expect(find.text('session: qwen'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('models.session.clear')));
      await tester.pump();
      expect(find.text('session: qwen'), findsNothing);

      await endClean(tester);
    });
  });

  group('the ladder is manageable (2026-11-19)', () {
    testWidgets('the add verb declares a generative cast from a '
        "provider model — it lands at the ladder's foot as dirty, and "
        'revert takes it back', (final tester) async {
      await mount(tester);

      await settleTap(tester, 'models.ladder.add');
      expect(find.text('Add a model to the ladder'), findsOneWidget);
      // The provider picker defaults to the first declared provider.
      await enter(tester, 'models.ladder.add.model', 'Qwen3.9 Test');
      await settleTap(tester, 'models.ladder.add.confirm');

      final cast = (PaletteCandidateModel.debugLastCandidate!['cast']!
          as List).whereType<Map<Object?, Object?>>().toList();
      final last = cast.last;
      expect(last['id'], 'qwen3.9_test');
      expect(last['provider'], 'modelscope');
      expect(last['model'], 'Qwen3.9 Test');
      expect(last['role'], 'generative');
      expect(find.text('unsaved changes'), findsOneWidget);

      // The revert takes it back (the dirty bar's escape hatch).
      await barTap(tester, 'models.cancel');
      final live = PaletteCandidateModel.debugLastCandidate!;
      expect(
        (live['cast']! as List).whereType<Map<Object?, Object?>>().any(
              (final entry) => entry['id'] == 'qwen3.9_test',
            ),
        isFalse,
      );

      await endClean(tester);
    });

    testWidgets('the remove verb drops a declared cast — a builtin lane '
        'refuses (the composition root owns it)', (final tester) async {
      await mount(tester);

      // The remove door lives in the row's ⋯ overflow. The row sits
      // deep in the merged list — fling down until the lazy viewport
      // builds it (scrollUntilVisible's small drags can stall here).
      final remove = find.byKey(
        const ValueKey('models.cast.openrouter_deepseek.remove'),
      );
      var attempts = 0;
      while (remove.evaluate().isEmpty && attempts < 30) {
        await tester.fling(
          find.byType(Scrollable).last,
          const Offset(0, -300),
          10,
        );
        await tester.pumpAndSettle();
        attempts++;
      }
      await tester.ensureVisible(remove);
      await tester.pumpAndSettle();
      await tester.tap(remove);
      await tester.pump();
      await settleTap(
        tester,
        'models.cast.openrouter_deepseek.removeItem',
      );

      final cast = (PaletteCandidateModel.debugLastCandidate!['cast']!
          as List).whereType<Map<Object?, Object?>>().toList();
      expect(
        cast.any((final entry) => entry['id'] == 'openrouter_deepseek'),
        isFalse,
      );
      expect(find.text('unsaved changes'), findsOneWidget);

      await endClean(tester);
    });
  });

  group('the observe absorption (2026-11-19)', () {
    testWidgets('the daemon strip rides the header; the health + cache '
        'chips live on the rows and open the history expansion (unbound '
        'keeps its honest door)', (final tester) async {
      await mount(tester);
      world.debugTelemetryOverride = <String, ActorTelemetry>{
        'cache-probe': const ActorTelemetry(
          actorId: 'cache-probe',
          rounds: 2,
          promptTokens: 100,
          cachedTokens: 47,
          stalled: false,
          at: '2026-11-15T00:00:00Z',
        ),
      };
      // The override has no notify: force the ladder's rebuild.
      await world.refresh();
      await tester.pump();

      // The daemon strip: on every lens, in the header.
      expect(find.byKey(const ValueKey('models.daemonStrip')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.daemon')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.restart')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.stop')), findsOneWidget);

      // The rows carry the doors: the health chip opens the verbatim
      // verdict (the cooldown/named-skip visibility the old worst-of
      // merge hid). The ladder sits below the catalog — bring the row
      // into the lazy viewport first.
      await see(
        tester,
        find.byKey(const ValueKey('models.rung.openrouter_deepseek')),
      );
      await tester.tap(
        find.byKey(const ValueKey('models.rung.openrouter_deepseek.health')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(
          const ValueKey('models.rung.openrouter_deepseek.history'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('transport_http_403'), findsOneWidget);

      // An unbound actor is nobody's model row, but its requests stay
      // world truth: the unbound door carries its history.
      expect(find.byKey(const ValueKey('models.rung.unbound')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('models.rung.unbound.cache')));
      await tester.pumpAndSettle();
      expect(find.text('2r'), findsOneWidget);
      expect(find.text('cache 47%'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.rung.unbound.history')),
        findsOneWidget,
      );

      await endClean(tester);
    });

    testWidgets('an escalation narrates the promotion in the history '
        'expansion: stalled → tried <model> (the world says what it did)',
        (final tester) async {
      await mount(tester);

      // The daemon records the flattened `escalatedFrom` tag on the
      // promoted run's telemetry row (ADR 0122); the narration names the
      // model it fell back TO, not the raw entry id.
      world.debugTelemetryOverride = <String, ActorTelemetry>{
        'cache-probe': const ActorTelemetry(
          actorId: 'cache-probe',
          rounds: 1,
          promptTokens: 90,
          cachedTokens: 20,
          stalled: false,
          escalatedFrom: 'modelscope_qwen38max',
          at: '2026-11-16T00:00:00Z',
        ),
      };
      // The override has no notify: force the ladder's rebuild.
      await world.refresh();
      await tester.pump();

      // The unbound door sits at the ladder's foot — the lazy list
      // builds it only once scrolled in.
      await see(tester, find.byKey(const ValueKey('models.rung.unbound')));
      await tester.tap(find.byKey(const ValueKey('models.rung.unbound.cache')));
      await tester.pumpAndSettle();

      // modelscope_qwen38max declares model Qwen3.8-Max-Preview → the
      // spoken name (the brain-policy vocabulary law). The narration
      // lives IN the expansion (the row itself names the model too —
      // scope the assertion to the opened history).
      final history = find.byKey(const ValueKey('models.rung.unbound.history'));
      expect(history, findsOneWidget);
      expect(
        find.descendant(of: history, matching: find.textContaining('stalled → tried')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: history,
          matching: find.textContaining('Qwen3.8 Max Preview'),
        ),
        findsOneWidget,
      );

      await endClean(tester);
    });
  });
}
