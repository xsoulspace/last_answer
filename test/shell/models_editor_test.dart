/// Wave J — the Models surface as the PROVIDER EDITOR, over a hermetic
/// world (the shell test-lane laws: real services — no fakes — on a
/// disposable realm, settle before any runAsync window, dialogs own
/// their controllers, unfocus + settle at the end, pump — never
/// pumpAndSettle — while a focused field's cursor blinks).
///
/// Under test:
/// * the READ lane (free): provider rows render from the live parsed
///   palette — id, transport family, endpoint, the credential env NAME
///   (never a value), model count and merged health; expanding shows
///   the models (id + context tier) and the read-only cast chips;
/// * the EDIT lane (Pro-gated affordance, fail-open when no entitlement
///   layer is mounted): edits build a candidate palette IN MEMORY — the
///   assertions read the CANDIDATE MAP diff through the dialog's debug
///   seam, never UI pixels;
/// * Propose surfaces the host receipt; a non-owner Apply renders the
///   refusal's recovery text VERBATIM; Cancel reverts to live.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/palette_health.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/status_edge.dart' show HealthDot;
import 'package:lastanswer/shell/view_models.dart';

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
    temp = Directory.systemTemp.createTempSync('models_editor_');
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
          'qwen': {'status': 'not_downloaded'},
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

    // The seat's fixture lives at the realm scope's world home
    // (`<temp>/seat/world`), the root the verbs resolve their config
    // chain from.
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
  /// key into view, then tap. The dialog's ListView is LAZY: a key
  /// below the fold is not in the tree until scrolled, so a missing
  /// finder scrolls it into existence instead of throwing.
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

  /// The dirty-bar / always-visible variant: no Scrollable above these
  /// keys, so ensureVisible would refuse — a plain tap plus the two
  /// pumps that drain the verbs' microtask chain.
  Future<void> barTap(
    final WidgetTester tester,
    final String keyName,
  ) async {
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

  /// The dialog's ListView is LAZY: keys below the fold enter the
  /// tree only once scrolled — scroll, then assert.
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

  Future<void> openEditor(final WidgetTester tester) async {
    await settleTap(tester, 'models.editProviders');
    await tester.pumpAndSettle(); // the dialog's entry animation
    expect(
      find.byKey(const ValueKey('models.providerEditor')),
      findsOneWidget,
    );
  }

  Future<void> endClean(final WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  group('the provider READ lane (free)', () {
    testWidgets(
      'provider rows render id, transport, endpoint, env NAME, health '
      'and model count from the live parsed palette',
      (final tester) async {
        await mount(tester);

        final modelscope = find.byKey(
          const ValueKey('models.provider.modelscope'),
        );
        expect(modelscope, findsOneWidget);
        expect(
          find.byKey(const ValueKey('models.provider.openrouter')),
          findsOneWidget,
        );
        // The merged health of the cast rows rides the row's dot.
        expect(
          find.descendant(of: modelscope, matching: find.byType(HealthDot)),
          findsOneWidget,
        );
        // The api family + endpoint are facts of the declaration.
        expect(find.text('openai_compatible'), findsOneWidget);
        expect(
          find.textContaining('api-inference.modelscope.ai'),
          findsOneWidget,
        );
        // The secret law: the env VARIABLE NAME renders; a value never
        // does (the surface resolves nothing).
        expect(find.text('MODELSCOPE_API_KEY'), findsOneWidget);
        expect(find.text('1 models'), findsWidgets);

        await endClean(tester);
      },
    );

    testWidgets('expanding a provider shows its models with the context '
        'tier and the read-only cast chips', (final tester) async {
      await mount(tester);

      await settleTap(tester, 'models.provider.modelscope');
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('models.provider.modelscope.detail')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('models.model.modelscope.Qwen3.8-Max-Preview'),
        ),
        findsOneWidget,
      );
      // The declared context tier rides the model row.
      expect(find.text('ctx 262144'), findsOneWidget);
      // The cast rows that reference the provider, as read-only chips.
      expect(
        find.byKey(
          const ValueKey(
            'models.provider.modelscope.cast.modelscope_qwen38max',
          ),
        ),
        findsOneWidget,
      );

      await endClean(tester);
    });
  });

  group('the provider EDIT lane (Pro-gated, candidate in memory)', () {
    testWidgets('the edit flow builds the candidate map — add provider '
        'and model land in the wire shape, the live palette is '
        'untouched', (final tester) async {
      await mount(tester);
      await openEditor(tester);

      // Add a provider through the form (the dialog owns the
      // controllers; the transport cycles the CLOSED wire vocabulary).
      await settleTap(tester, 'models.provider.add');
      await settleTap(tester, 'models.form.transport');
      await enter(tester, 'models.form.id', 'groq');
      await enter(
        tester,
        'models.form.baseUrl',
        'https://api.groq.com/openai/v1',
      );
      await enter(tester, 'models.form.credentialEnv', 'GROQ_API_KEY');
      await settleTap(tester, 'models.form.confirm');

      // Add a model under it.
      await settleTap(tester, 'models.model.groq.add');
      await enter(tester, 'models.form.id', 'llama-3.3-70b-versatile');
      await settleTap(tester, 'models.form.confirm');

      // The CANDIDATE MAP diff is the assertion — never UI pixels. The
      // keys are the host parser's own wire vocabulary.
      final candidate = ProviderEditorDialog.debugLastCandidate!;
      final providers = candidate['providers']! as Map;
      expect(providers.containsKey('groq'), isTrue);
      final groq = providers['groq']! as Map;
      expect(groq['transport'], 'openai_compatible');
      expect(groq['base_url'], 'https://api.groq.com/openai/v1');
      expect(groq['credential_env'], 'GROQ_API_KEY');
      expect(groq['models'], <Object?>[
        <String, Object?>{'id': 'llama-3.3-70b-versatile'},
      ]);
      // The live parsed palette is untouched until an owner applies.
      expect(world.palette!.providers.containsKey('groq'), isFalse);
      // The dirty bar names the unsaved state.
      expect(find.text('unsaved changes'), findsOneWidget);

      await endClean(tester);
    });

    testWidgets('propose surfaces the host receipt; a non-owner apply '
        'renders the recovery text VERBATIM', (final tester) async {
      await mount(tester);
      await openEditor(tester);

      await settleTap(tester, 'models.provider.add');
      await enter(tester, 'models.form.id', 'groq');
      await settleTap(tester, 'models.form.confirm');

      // Propose → the host receipt panel (ok + beforeSha256).
      await barTap(tester, 'models.propose');
      await see(tester, find.byKey(const ValueKey('models.receipt.ok')));
      expect(find.textContaining('beforeSha256'), findsOneWidget);

      // Apply is OWNER-ONLY: this seat's profile deliberately lacks the
      // palette_apply grant, so the refusal's recovery text renders
      // verbatim — never a bare error.
      await barTap(tester, 'models.apply');
      await see(
        tester,
        find.byKey(const ValueKey('models.refusal.recovery')),
      );
      expect(find.textContaining('palette_apply_not_owner'), findsOneWidget);
      expect(find.textContaining('owner-only'), findsOneWidget);
      expect(find.textContaining('agent_local_seat'), findsOneWidget);

      await endClean(tester);
    });

    testWidgets('a broken candidate surfaces the PaletteConfigError '
        'verbatim in the receipt panel', (final tester) async {
      await mount(tester);
      await openEditor(tester);

      // A provider id that shadows a built-in name is the parser's own
      // structural refusal (`open_router` is a composition-root lane).
      await settleTap(tester, 'models.provider.add');
      await enter(tester, 'models.form.id', 'open_router');
      await settleTap(tester, 'models.form.confirm');

      await barTap(tester, 'models.propose');

      await see(
        tester,
        find.byKey(const ValueKey('models.receipt.refusal')),
      );
      expect(
        find.textContaining('palette_builtin_provider_shadow'),
        findsOneWidget,
      );

      await endClean(tester);
    });

    testWidgets('referenced provider ids are immutable and referenced '
        'rows refuse removal — NAMING the cast rows', (
      final tester,
    ) async {
      await mount(tester);
      await openEditor(tester);

      // Remove refuses while a cast row references the provider.
      await settleTap(tester, 'models.provider.modelscope.remove');
      await see(
        tester,
        find.byKey(const ValueKey('models.refusal.local')),
      );
      expect(find.textContaining('modelscope_qwen38max'), findsWidgets);
      // The candidate did not move.
      final candidate = ProviderEditorDialog.debugLastCandidate!;
      expect(
        (candidate['providers']! as Map).containsKey('modelscope'),
        isTrue,
      );

      // The edit form locks the referenced id and names the cast rows.
      await settleTap(tester, 'models.provider.modelscope.edit');
      await see(
        tester,
        find.byKey(
          const ValueKey('models.refusal.providerIdImmutable'),
        ),
      );
      final idField = tester.widget<TextField>(
        find.byKey(const ValueKey('models.form.id')),
      );
      expect(idField.readOnly, isTrue);

      // A referenced MODEL refuses removal too, naming its cast row.
      await settleTap(tester, 'models.form.cancel');
      await settleTap(
        tester,
        'models.model.modelscope.Qwen3.8-Max-Preview.remove',
      );
      await see(
        tester,
        find.byKey(const ValueKey('models.refusal.local')),
      );
      final after = ProviderEditorDialog.debugLastCandidate!;
      final modelscope = (after['providers']! as Map)['modelscope']! as Map;
      expect(modelscope['models'], hasLength(1));

      await endClean(tester);
    });

    testWidgets('cancel reverts the candidate to live', (
      final tester,
    ) async {
      await mount(tester);
      await openEditor(tester);

      await settleTap(tester, 'models.provider.add');
      await enter(tester, 'models.form.id', 'groq');
      await settleTap(tester, 'models.form.confirm');
      expect(find.text('unsaved changes'), findsOneWidget);

      await barTap(tester, 'models.cancel');

      // The candidate is the live wire again — no groq, in sync.
      final candidate = ProviderEditorDialog.debugLastCandidate!;
      expect(
        (candidate['providers']! as Map).containsKey('groq'),
        isFalse,
      );
      expect(find.text('in sync with the live palette'), findsOneWidget);
      // The dirty lane is gone with the dirty state.
      expect(find.byKey(const ValueKey('models.propose')), findsNothing);

      await endClean(tester);
    });
  });
}
