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

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/palette_health.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/models/models_view.dart';
import 'package:lastanswer/shell/models/palette_candidate.dart';

Widget _wrap(final Widget child) => MaterialApp(
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
    File('$worldHome/.xsoulspace/config.json').writeAsStringSync(
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

    await tester.pumpWidget(_wrap(ModelsView(world: world, service: chat)));
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
      expect(
        find.byKey(const ValueKey('models.form.reasoning.high')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.reasoning.noLane')),
        findsNothing,
      );
      await settleTap(tester, 'models.form.reasoning.high');
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

      expect(
        find.byKey(const ValueKey('models.lens.catalog')),
        findsOneWidget,
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
      await tester.tap(find.byKey(const ValueKey('models.provider.groq')));
      await tester.pump();
      await settleTap(tester, 'models.model.groq.add');
      await enter(tester, 'models.form.id', 'llama-3.3-70b-versatile');
      await enter(tester, 'models.form.maxTokens', '131072');
      await settleTap(tester, 'models.form.cap.tools');
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

  group('the bindings lens', () {
    testWidgets('the lane chip is the FAMILY truth: builtin never means '
        'local by default (jev rides the hosted OpenRouter lane, afm '
        'the Apple-specific one, qwen the local MLX one)', (
      final tester,
    ) async {
      await mount(tester);

      await tester.tap(find.byKey(const ValueKey('models.lens.bindings')));
      await tester.pump();

      final jev = find.byKey(const ValueKey('models.rung.jev'));
      expect(
        find.descendant(of: jev, matching: find.text('open_router')),
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
        find.descendant(of: afm, matching: find.text('afm')),
        findsOneWidget,
      );
      final qwen = find.byKey(const ValueKey('models.rung.qwen'));
      expect(
        find.descendant(of: qwen, matching: find.text('local')),
        findsOneWidget,
      );

      await endClean(tester);
    });

    testWidgets('the ladder order and the primary mark are candidate '
        'verbs over the cast list', (final tester) async {
      await mount(tester);

      await tester.tap(find.byKey(const ValueKey('models.lens.bindings')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('models.rung.modelscope_qwen38max')),
        findsOneWidget,
      );
      expect(find.text('primary'), findsOneWidget);

      // Down moves the row in the CANDIDATE cast order.
      await settleTap(tester, 'models.cast.modelscope_qwen38max.down');
      var cast = (PaletteCandidateModel.debugLastCandidate!['cast']! as List)
          .whereType<Map<Object?, Object?>>()
          .toList();
      expect(cast.first['id'], 'openrouter_deepseek');

      // The primary mark moves, clearing the old one.
      await settleTap(tester, 'models.cast.modelscope_qwen38max.primary');
      cast = (PaletteCandidateModel.debugLastCandidate!['cast']! as List)
          .whereType<Map<Object?, Object?>>()
          .toList();
      final byId = <String, Map<Object?, Object?>>{
        for (final entry in cast) '${entry['id']}': entry,
      };
      expect(byId['modelscope_qwen38max']!['primary'], true);
      expect(byId['openrouter_deepseek']!.containsKey('primary'), isFalse);
      expect(find.text('unsaved changes'), findsOneWidget);

      await endClean(tester);
    });

    testWidgets('the session delegate-via override rides a labelled '
        'chip and clears through selectRung', (final tester) async {
      await mount(tester);
      world.selectRung('qwen');
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('models.lens.bindings')));
      await tester.pump();
      expect(find.text('session: qwen'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('models.session.clear')));
      await tester.pump();
      expect(find.text('session: qwen'), findsNothing);

      await endClean(tester);
    });
  });

  group('the observe lens', () {
    testWidgets('daemon card, verbatim health ledger and the per-model '
        'dispatch ledger (unbound groups honestly)', (final tester) async {
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

      await tester.tap(find.byKey(const ValueKey('models.lens.observe')));
      await tester.pump();

      expect(find.byKey(const ValueKey('models.daemonCard')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.restart')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.stop')), findsOneWidget);
      // The health ledger renders the daemon's verdict VERBATIM — the
      // cooldown/named-skip visibility the old worst-of merge hid.
      expect(
        find.byKey(const ValueKey('models.health.openrouter_deepseek')),
        findsOneWidget,
      );
      expect(find.textContaining('transport_http_403'), findsOneWidget);
      expect(find.textContaining('never downloads'), findsOneWidget);
      // The ledger keys on the model; an unbound actor says so.
      expect(
        find.byKey(const ValueKey('models.ledger.unbound')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.ledger.unbound.cache-probe')),
        findsOneWidget,
      );
      expect(find.text('2r'), findsOneWidget);
      expect(find.text('cache 47%'), findsOneWidget);

      await endClean(tester);
    });
  });
}
