// The app intent surface (the inversion contract): LA publishes its
// user-level actions as named data over the flutter mcp toolkit, so an
// external driver — a headless gate today, a gesture controller
// tomorrow — can drive the app WITHOUT the app knowing the driver.
// These tests prove the CONTRACT, not just the handlers:
//   1. the published catalog and the registered entries AGREE
//      (a controller never meets a name the app will not answer, and
//      the app never grows an unnamed family);
//   2. the app-shell intents drive the REAL surfaces (the pane's
//      expansion is asserted through the HEADLESS projection — the
//      equal-reader law, never a widget scrape);
//   3. every refusal is honest (no surface, unknown route, unknown
//      action) with the next move named in the message.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/agent_mcp_tools.dart';
import 'package:lastanswer/coding_agent/world_inspector/scripted_session_handle.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_tools.dart';
import 'package:lastanswer/mcp/app_mcp_tools.dart';
import 'package:lastanswer/mcp/doc_mcp_tools.dart';
import 'package:lastanswer/mcp/storage_mcp_tools.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:xsoulspace_agentic_harness_inspector/src/app.dart'
    show WorkbenchMemory;
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

AgentCallEntry _entryOf(final String name) => appMcpEntries().firstWhere(
  (final e) => e.name == name,
  orElse: () => throw StateError('no app entry named $name'),
);

// The legacy mcpToolkitTool bridge wraps every MCPCallResult as
// AgentResult.success — the REAL ok flag is carried in data.
bool _okOf(final AgentResult result) => result.data['ok'] == true;

void main() {
  // The bench memory is static per world key — a clean bench per test.
  setUp(WorkbenchMemory.clearAll);

  test('the catalog and the registered entries AGREE (the contract)', () {
    final published = {for (final s in appIntentCatalog) s.name};
    final families = <Set<AgentCallEntry>>[
      appMcpEntries(),
      agentMcpEntries(),
      docMcpEntries(),
      storageMcpEntries(),
      worldInspectorMcpEntries(),
    ];
    final registered = <String>{
      for (final family in families)
        for (final e in family) e.name,
    };
    // The app family publishes only names LA will answer…
    final unanswerable = published.difference(registered);
    expect(
      unanswerable,
      isEmpty,
      reason: 'catalog names no registered entry: $unanswerable',
    );
    // …and every registered name is PUBLISHED (a controller reads the
    // catalog, never the code — an unpublished tool is a hidden verb).
    final hidden = registered.difference(published);
    expect(
      hidden,
      isEmpty,
      reason: 'registered tools missing from the catalog: $hidden',
    );
    // Groups stay closed (a controller filters by them).
    final groups = appIntentCatalog.map((final s) => s.group).toSet();
    expect(groups, containsAll(<String>['app', 'doc', 'mesh', 'storage']));
  });

  test('app_intents returns the catalog as named data, filterable', () async {
    final all = await _entryOf('app_intents').invokeDirect(const {});
    expect(_okOf(all), isTrue, reason: all.message);
    expect(all.data['count'], appIntentCatalog.length, reason: all.message);
    final intents = ((all.data['intents'] ?? const []) as List).cast<Map>();
    expect(intents.any((final i) => i['name'] == 'app_inspector'), isTrue);
    final filtered = await _entryOf(
      'app_intents',
    ).invokeDirect(const {'group': 'inspector'});
    expect(_okOf(filtered), isTrue);
    final inspector = ((filtered.data['intents'] ?? const []) as List)
        .cast<Map>();
    expect(inspector, hasLength(6));
    expect(inspector.every((final i) => i['group'] == 'inspector'), isTrue);
  });

  testWidgets('app_inspector drives the REAL pane; the projection agrees '
      '(the equal-reader law)', (final tester) async {
    final seeded = seedScriptedSessions();
    final registry = HarnessSessionRegistry()
      ..register('seed-planner', seeded['seed-planner']!)
      ..register('seed-worker', seeded['seed-worker']!)
      ..focused = 'seed-worker';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              WorldInspectorPane(
                registry: registry,
                pollInterval: const Duration(milliseconds: 10),
                showScene: false,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(WorldInspectorPane.lastProjection?.expanded, isFalse);

    final expand = await _entryOf(
      'app_inspector',
    ).invokeDirect(const {'action': 'expand'});
    await tester.pump(const Duration(milliseconds: 50));
    expect(_okOf(expand), isTrue, reason: expand.message);
    expect(expand.data['expanded'], isTrue);
    // The HEADLESS projection — the same data the state verb reports —
    // agrees with what the human screen now shows.
    expect(WorldInspectorPane.lastProjection?.expanded, isTrue);

    final palette = await _entryOf(
      'app_inspector',
    ).invokeDirect(const {'action': 'palette_open'});
    await tester.pump(const Duration(milliseconds: 50));
    expect(_okOf(palette), isTrue, reason: palette.message);
    expect(palette.data['paletteOpen'], isTrue);
    expect(find.bySemanticsLabel(RegExp('command palette.*')), findsOneWidget);

    final close = await _entryOf(
      'app_inspector',
    ).invokeDirect(const {'action': 'palette_close'});
    await tester.pump(const Duration(milliseconds: 50));
    expect(_okOf(close), isTrue);
    expect(find.bySemanticsLabel(RegExp('command palette.*')), findsNothing);

    final collapse = await _entryOf(
      'app_inspector',
    ).invokeDirect(const {'action': 'collapse'});
    await tester.pump(const Duration(milliseconds: 50));
    expect(_okOf(collapse), isTrue);
    expect(collapse.data['expanded'], isFalse);
    expect(WorldInspectorPane.lastProjection?.expanded, isFalse);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });

  test('every refusal is honest and names the next move', () async {
    // No pane mounted → the pane intent refuses and says what to do.
    WorldInspectorPane.debugSurface = null;
    final noPane = await _entryOf(
      'app_inspector',
    ).invokeDirect(const {'action': 'expand'});
    expect(_okOf(noPane), isFalse);
    expect(noPane.message, contains('mounts under an open agent doc'));

    // Unknown route → the navigation allowlist holds.
    final badRoute = await _entryOf(
      'app_navigate',
    ).invokeDirect(const {'path': '/etc/passwd'});
    expect(_okOf(badRoute), isFalse);
    expect(badRoute.message, contains('not a published route'));

    // Unknown action → a NAMED refusal. The schema enum refuses before
    // the handler (AgentValidationException) or the handler refuses
    // itself — either way the message names the allowed moves.
    Object? refusal;
    try {
      final badAction = await _entryOf(
        'app_composer',
      ).invokeDirect(const {'action': 'transmogrify'});
      expect(_okOf(badAction), isFalse);
      refusal = badAction.message;
    } on Object catch (e) {
      refusal = e.toString();
    }
    expect(
      refusal,
      contains('focus'),
      reason: 'the refusal names the allowed actions',
    );
    expect(refusal, contains('submit'));

    // No open surface → the composer refuses with the route to take.
    final noSurface = await _entryOf(
      'app_composer',
    ).invokeDirect(const {'action': 'focus'});
    expect(_okOf(noSurface), isFalse);
    expect(noSurface.message, contains('open one first'));
  });
}
