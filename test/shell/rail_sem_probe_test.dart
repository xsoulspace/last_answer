import 'dart:io';
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
    // §2.3 on the v2 anatomy (DESIGN.md 2026-11-08): the action bar's
    // kind buttons keep the rail.view.* vocabulary, the group-scoped
    // strip keeps view.tab.*/view.strip.add.<group>, and the edge keeps
    // its segment names — all in Flutter's own semantics tree (the live
    // fmtk walker's rail-drop is a framework gap, not an app absence —
    // commit 06017111). The persistent roster rows (rail.actor.*)
    // retired with the room list: rooms live in the picker and the
    // palette now.
    final snapshot = labels.join('\n');
    for (final id in const [
      'conversations',
      'documents',
      'boards',
      'filesystem',
      'browser',
      'inspector',
      'threads',
      'terminal',
      'people',
    ]) {
      expect(snapshot, contains('rail.view.$id'));
    }
    expect(snapshot, contains('view.tab.conversations'));
    expect(snapshot, contains('view.strip.add.0'));
    expect(snapshot, contains('edge.world'));
    expect(snapshot, contains('rail.search'));
    expect(snapshot, contains('rail.settings'));
    handle.dispose();
  });
}
