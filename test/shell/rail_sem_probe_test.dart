import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hermetic_world_state.dart';

void main() {
  testWidgets('action bar WITH roster: semantics labels', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final pin = Directory.systemTemp.createTempSync('rail_sem_');
    RealmWorld.debugDeviceHome = pin.path;
    addTearDown(() {
      RealmWorld.debugDeviceHome = null;
      pin.deleteSync(recursive: true);
    });
    late RealmChatService service;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('rail_sem_ws_');
      addTearDown(() => temp.delete(recursive: true));
      final world = await RealmWorld.open(rootOverride: temp.path);
      final roster = ActorRoster(replicaId: 'tester');
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: roster,
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      await service.createActor(
        displayName: 'Scout Live',
        kind: ActorKind.model,
        brainRef: '',
      );
      await service.createChannel('guild');
    });
    final handle = tester.ensureSemantics();
    final worldState = hermeticWorldState();
    await worldState.refresh();
    await tester.binding.setSurfaceSize(const Size(1044, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      GlobalStatesProvider(
        builder: (_) => MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: AppShell(
              service: service,
              worldState: worldState,
              child: const CenterTabsArea(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final labels = <String>[];
    void visit(SemanticsNode node) {
      if (node.label.isNotEmpty) labels.add(node.label.split('\n').first);
      node.visitChildren((c) {
        visit(c);
        return true;
      });
    }

    visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
    // §2.3 on the cut anatomy (DESIGN.md, owner law 2026-11-10): the
    // action bar is THREE buttons (rail.search, rail.actors, the gear),
    // the docked rooms column names its sections, the group-scoped
    // strip keeps view.tab.*/view.strip.add.<group>, and the edge keeps
    // its segment names — all in Flutter's own semantics tree (the live
    // fmtk walker's rail-drop is a framework gap, not an app absence —
    // commit 06017111). The kind buttons (rail.view.*) retired with the
    // persistent roster rows (rail.actor.*).
    final snapshot = labels.join('\n');
    for (final key in const [
      'rail.search',
      'rail.actors',
      'rail.settings',
    ]) {
      expect(snapshot, contains(key));
    }
    // The chat-first projection is the first-entry default: the docked
    // rooms column is part of the snapshot contract.
    for (final key in const [
      'rooms.section.dms',
      'rooms.section.channels',
      'rooms.section.rooms',
    ]) {
      expect(snapshot, contains(key));
    }
    expect(snapshot, contains('view.tab.conversations'));
    expect(snapshot, contains('view.strip.add.0'));
    expect(snapshot, contains('edge.world'));
    handle.dispose();
  });
}
